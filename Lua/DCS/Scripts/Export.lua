-- global scope for Helios code and state available to profiles
helios = {}

-- global scope for privileged interface used for testing
helios_impl = {}
helios_impl.driverName = ""

-- seconds before we load a profile even if we don't hear from Helios
helios_impl.autoLoadDelay = 3.0

-- seconds between ticks (high priority export interval)
helios_impl.exportInterval = 0.067

-- maximum number of seconds without us sending anything
-- NOTE: Helios needs us to send something to discover our UDP client port number
helios_impl.announceInterval = 3.0

-- luasocket
local socket  -- lazy init

-- local scope for private code, to avoid name clashes
local helios_private = {}

helios_private.host = "127.0.0.1"
helios_private.port = 9089
helios_private.exportLowTickInterval = 1

-- Simulation id
helios_private.simID = string.format("%08x*", os.time())

-- most recently detected selfName
helios_private.previousSelfName = ""

-- event time 'now' as told to us by DCS
helios_private.clock = 0;

-- State data for export processing
helios_private.state = {}

function helios_private.clearState()
    helios_private.state.packetSize = 0
    helios_private.state.sendStrings = {}
    helios_private.state.lastData = {}

    -- event time of last message sent
    helios_private.state.lastSend = 0;

    -- Frame counter for non important data
    helios_private.state.tickCount = 0

    -- times at which we need to take a specific action
    helios_private.state.timers = {}
end



function helios.splitString(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return {str}
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0 -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then
            break
        end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function helios.round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function helios.ensureString(s)
    if type(s) == "string" then
        return s
    else
        return ""
    end
end

function helios.textureToString(s)
    if s == nil then
        return "0"
    else
        return "1"
    end
end

function helios_private.processArguments(device, arguments)
    local lArgumentValue
    for lArgument, lFormat in pairs(arguments) do
        lArgumentValue = string.format(lFormat, device:get_argument_value(lArgument))
        helios.send(lArgument, lArgumentValue)
    end
end

function helios.parseIndication(indicator_id) -- Thanks to [FSF]Ian code
    local ret = {}
    local li = list_indication(indicator_id)
    if li == "" then
        return nil
    end
    local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
    while true do
        local name, value = m()
        if not name then
            break
        end
        ret[name] = value
    end
    return ret
end

-- Network Functions
function helios.send(id, value)
    if string.len(value) > 3 and value == string.sub("-0.00000000", 1, string.len(value)) then
        value = value:sub(2)
    end
    if helios_private.state.lastData[id] == nil or helios_private.state.lastData[id] ~= value then
        helios_private.doSend(id, value)
    end
end

-- sends without checking if the value has changed
function helios_private.doSend(id, value)
    local data = id .. "=" .. value
    local dataLen = string.len(data)

    if dataLen + helios_private.state.packetSize > 576 then
        helios_private.flush()
    end

    table.insert(helios_private.state.sendStrings, data)
    helios_private.state.lastData[id] = value
    helios_private.state.packetSize = helios_private.state.packetSize + dataLen + 1
end

function helios_private.flush()
    if #helios_private.state.sendStrings > 0 then
        local packet = helios_private.simID .. table.concat(helios_private.state.sendStrings, ":") .. "\n"
        socket.try(helios_private.clientSocket:sendto(packet, helios_private.host, helios_private.port))
        helios_private.state.lastSend = helios_private.clock
        helios_private.state.sendStrings = {}
        helios_private.state.packetSize = 0
    end
end

function helios_private.resetCachedValues()
    helios_private.state.lastData = {}
    helios_private.state.tickCount = 10 -- XXX why 10 insted of 0?
end

function helios_impl.dispatchCommand(command)
    local lCommand, lCommandArgs, lDevice
    lCommand = string.sub(command, 1, 1)

    if lCommand == "R" then
        helios_private.resetCachedValues()
    elseif (lCommand == "C") then
        lCommandArgs = helios.splitString(string.sub(command, 2), ",")
        lDevice = GetDevice(lCommandArgs[1])
        if type(lDevice) == "table" then
            lDevice:performClickableAction(lCommandArgs[2], lCommandArgs[3])
        end
    elseif (lCommand == "P") then
        local profileName = command:sub(2):match("^(.-)%s*$")
        helios_impl.loadProfile(helios.selfName(), profileName)
    end
end

function helios_private.processInput()
    local lInput = helios_private.clientSocket:receive()

    if lInput then
        helios_impl.dispatchCommand(lInput)
    end
end

function helios_private.createDriver()
    -- defaults
    local driver = {}
    driver.selfName = ""
    driver.everyFrameArguments = {}
    driver.arguments = {}
    function driver.processHighImportance()
        -- do nothing
    end
    function driver.processLowImportance()
        -- do nothing
    end
    return driver
end

function helios_private.notifyLoaded()
    -- export code for 'currently active vehicle, reserved across all DCS interfacess
    log.write("HELIOS.EXPORT", log.INFO, string.format("notifying Helios of active driver '%s'", helios_impl.driverName))
    helios_private.doSend("ACTIVE_PROFILE", helios_impl.driverName)
end

function helios_private.notifySelfName(selfName)
    -- export code for 'currently active vehicle, reserved across all DCS interfacess
    log.write("HELIOS.EXPORT", log.INFO, string.format("notifying Helios of active vehicle '%s'", selfName))
    helios_private.doSend("ACTIVE_VEHICLE", selfName)
    helios_private.flush()
end

function helios_impl.loadProfile(selfName, profileName)
    local driver = helios_private.createDriver()
    local success, result

    -- cancel any pending auto load
    helios_private.state.timers.autoLoad = nil

    -- check if request is allowed
    local currentSelfName = helios.selfName()
    if currentSelfName ~= selfName then
        success = false
        result = string.format("cannot load profile '%s' while vehicle '%s' is active", profileName, currentSelfName)
        -- tell Helios to choose something that makes sense
        helios_private.notifySelfName(currentSelfName)
    -- check if request is already satisfied
    elseif helios_impl.driverName == profileName then
        -- do nothing
        log.write("HELIOS.EXPORT", log.INFO, string.format("profile driver '%s' for '%s' is already loaded", profileName, selfName))
        helios_private.notifyLoaded()
        return
    else
        -- now try to load specific profile
        local driverPath = string.format("%sScripts\\Helios\\%s\\%s.lua", lfs.writedir(), selfName, profileName)
        success, result = pcall(dofile, driverPath)

        -- check result for nil, since profile may not have returned anything
        if success and result == nil then
            success = false
            result = string.format("driver %s did not return a profile object; incompatible with this export script",
                driverPath
            )
        end

        -- sanity check, make sure profile is for correct selfName, since race condition is possible
        if success and result.selfName ~= selfName then
            success = false
            result = string.format("driver %s is for incorrect vehicle '%s'",
                driverPath,
                driver.selfName
            )
        end
    end

    if success then
        -- merge, replacing anything specified by the profile
        for k, v in pairs(result) do
            driver[k] = v
        end
        log.write("HELIOS.EXPORT", log.INFO, string.format("loaded profile driver '%s' for '%s'", profileName, driver.selfName))
        helios_impl.driverName = profileName
    else
        -- if the load fails, just leave the driver initialized to defaults
        log.write(
            "HELIOS.EXPORT",
            log.WARNING,
            string.format("failed to load profile driver '%s' for '%s'; disabling interface", profileName, selfName)
        )
        log.write("HELIOS.EXPORT", log.WARNING, result)
        helios_impl.driverName = ""
    end

    -- install driver
    helios_private.driver = driver

    -- drop any remmaining data and mark all values as dirty
    helios_private.clearState()

    -- tell Helios about it
    helios_private.notifyLoaded()
end

-- currently active vehicle/airplane
function helios.selfName()
    local info = LoGetSelfData()
    if info == nil then
        return ""
    end
    return info.Name
end

function helios_private.findProfiles(selfName)
    local numProfiles = 0
    local firstProfile = nil
    for path in lfs.dir(string.format("%sScripts\\Helios\\%s", lfs.writedir(), selfName)) do
        if path:match(".lua$") then
            log.write(
                "HELIOS.EXPORT",
                log.DEBUG,
                string.format("found %s", path)
            )
            if firstProfile == nil then
                firstProfile = path:gsub(".lua$", "")
            end
            numProfiles = numProfiles + 1
        end
    end
    return numProfiles, firstProfile
end

function helios_private.autoLoad()
    local selfName = helios.selfName()
    local numProfiles, firstProfile = helios_private.findProfiles(selfName)
    if numProfiles < 1 then
        -- deleted or maybe the type of vehicle changed
        log.write(
            "HELIOS.EXPORT",
            log.INFO,
            string.format("no profiles for vehicle '%s'; cannot automatically load profile", selfName)
        )
        return
    end
    log.write(
        "HELIOS.EXPORT",
        log.INFO,
        string.format("automatically loading first driver '%s' for '%s'", firstProfile, selfName)
    )
    helios_impl.loadProfile(selfName, firstProfile)
end

function helios_private.handleSelfNameChange(selfName)
    log.write(
        "HELIOS.EXPORT",
        log.INFO,
        string.format("changed vehicle from '%s' to '%s'", helios_private.previousSelfName, selfName)
    )
    helios_private.notifySelfName(selfName)
    helios_private.previousSelfName = selfName

    -- no matter what, the current driver is done
    helios_private.clearState()
    helios_private.driver = helios_private.createDriver()
    helios_impl.driverName = ""

    -- check applicable profiles
    local numProfiles, firstProfile = helios_private.findProfiles(selfName)
    if numProfiles > 1 then
        -- if there are multiple profiles for self.name, then load [none] driver, and set timer
        -- 		export using [none] driver (do nothing)
        -- 		if timer expires before Helios specifies profile, then load first profile for self.name
        log.write(
            "HELIOS.EXPORT",
            log.INFO,
            string.format("%d profiles for vehicle '%s'; waiting up to %f seconds for Helios", numProfiles, selfName, helios_impl.autoLoadDelay)
        )
        helios_private.state.timers.autoLoad = helios_private.clock + helios_impl.autoLoadDelay

        -- don't notify Helios, we will silently wait
    elseif numProfiles < 1 then
        log.write(
            "HELIOS.EXPORT",
            log.INFO,
            string.format("no profiles for vehicle '%s'; disabling interface", selfName)
        )
        -- let Helios know we have a dummy driver loaded
        helios_private.notifyLoaded()
    else
        -- exactly one driver applies, so we don't have to wait
        -- NOTE: this makes us more compatible with legacy Helios
        -- NOTE: this handles notification also
        helios_impl.loadProfile(selfName, firstProfile)
    end
end

-- DCS Export Functions
function LuaExportStart()
    -- called once just before mission start.
    package.path = package.path .. ";.\\LuaSocket\\?.lua"
    package.cpath = package.cpath .. ";.\\LuaSocket\\?.dll"

    -- load socket library
    socket = require("socket")

    -- init
    helios_private.clearState()
    helios_private.driver = helios_private.createDriver()

    -- start service
    helios_private.clientSocket = socket.udp()
    helios_private.clientSocket:setsockname("*", 0)
    helios_private.clientSocket:setoption("broadcast", true)
    helios_private.clientSocket:settimeout(.001) -- set the timeout for reading the socket
end

function LuaExportBeforeNextFrame()
    helios_private.processInput()
end

function LuaExportAfterNextFrame()
end

function LuaExportStop()
    -- Called once just after mission stop.
    -- Flush pending data, send DISCONNECT message so we can fire the Helios Disconnect event
    helios_private.doSend("DISCONNECT", "")
    helios_private.flush()
    helios_private.clientSocket:close()
end

function LuaExportActivityNextEvent(t)
    helios_private.clock = t
    local nextEvent = t + helios_impl.exportInterval

    -- process timers
    for timerName, timer in pairs(helios_private.state.timers) do
        if timer ~= nil then
            -- log.write(
            --     "HELIOS.EXPORT",
            --     log.DEBUG,
            --     string.format("active timer %s at %f, clock is %f", timerName, timer, clock)
            -- )
            if helios_private.clock >= timer then
                -- timer expired
                if timerName == "autoLoad" then
                    helios_private.state.timers.autoLoad = nil
                    helios_private.autoLoad()
                end
            else
                if timer < nextEvent then
                    -- need to wake up for this
                    nextEvent = timer
                end
            end
        end
    end
    t = nextEvent

    -- check if vehicle type has changed
    local selfName = helios.selfName()
    if selfName ~= helios_private.previousSelfName then
        helios_private.handleSelfNameChange(selfName)
    end

    -- NOTE: the retransmission strategy here is:
    --   if self.name change is not heard by Helios, we will end up running first valid profile
    --     Helios may display this loaded profile driver, or it may lose this notification
    --   if Helios' request for a profile is lost, it will retry forever, since it won't get
    --     our confirmation
    --   finally, if whenever Helios is started up with a DCS profile, it will send a notification
    --     that will also prompt us to tell it what the current self.name is (infinite retry)

    -- NOTE: we send self.name change notification as a normal protocol message (string)
    -- with a reserved ID.  We will then subclass Helios UDP interface as DCS interface
    -- and add registration for this network function with a local handler.
    -- The profile will then need to register as handler for all its interfaces.  Finally,
    -- the control center will need to register for an event on the currently active profile.

    helios_private.state.tickCount = helios_private.state.tickCount + 1
    local lDevice = GetDevice(0)
    if type(lDevice) == "table" then
        lDevice:update_arguments()

        helios_private.processArguments(lDevice, helios_private.driver.everyFrameArguments)
        helios_private.driver.processHighImportance(lDevice)

        if helios_private.state.tickCount >= helios_private.exportLowTickInterval then
            helios_private.processArguments(lDevice, helios_private.driver.arguments)
            helios_private.driver.processLowImportance(lDevice)
            helios_private.state.tickCount = 0
        end

        helios_private.flush()
    end

    -- if we sent nothing for a long time, send something just to let Helios discover us
    if helios_private.clock > (helios_impl.announceInterval + helios_private.state.lastSend) then
        log.write("HELIOS.EXPORT", log.DEBUG, string.format("sending alive announcement after %f seconds without any data sent (clock %f, sent %f)",
            helios_impl.announceInterval,
            helios_private.clock,
            helios_private.state.lastSend
        ))
        helios_private.doSend("ALIVE", "")
        helios_private.flush();
    end

    return t
end

-- local Tacviewlfs = require("lfs")
-- dofile(Tacviewlfs.writedir() .. "Scripts/TacviewGameExport.lua")
