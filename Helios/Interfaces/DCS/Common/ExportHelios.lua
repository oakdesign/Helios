
local PrevExport = {}
PrevExport.LuaExportStart = LuaExportStart
PrevExport.LuaExportStop = LuaExportStop
PrevExport.LuaExportBeforeNextFrame = LuaExportBeforeNextFrame
PrevExport.LuaExportAfterNextFrame = LuaExportAfterNextFrame
PrevExport.LuaExportActivityNextEvent = LuaExportActivityNextEvent

local c

local parse_indication
local parse_indication
local FlushData
local SendData
local ProcessArguments
local ResetChangeValues
local ProcessInput
local StrSplit
local roundS
local check
local parse_indication
local ResetChangeValues

LuaExportStart =nil
LuaExportBeforeNextFrame =nil
LuaExportAfterNextFrame =nil
LuaExportStop =nil
LuaExportActivityNextEvent =nil

local scriptDebug = false

local thisScript = debug.getinfo(1,'S').short_src:gsub("\\","/"):match('^.*/(.*).lua"]$')

if gHeliosDebug then
    WriteToHeliosLog(thisScript,string.format("intends to communicate on " .. lHost .. ":" .. lPort .. "\n"))
	WriteToHeliosLog(thisScript,string.format("Aircraft: " .. gAircraft))
	WriteToHeliosLog(thisScript,string.format("Local Mods - Running " .. thisScript))
end

-- for some reason, this causes a failure on my system so commenting it
-- out in the hope that others don't see a problem with it.
-- os.setlocale("ISO-8559-1", "numeric")

-- Simulation id
local lID = string.format("%08x*",os.time())

-- State data for export
local lPacketSize = 0
local lSendStrings = {}
local lLastData = {}

-- Frame counter for non important data
local lTickCount = 0


-- DCS Export Functions
LuaExportStart= function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportStart() invoked.") end
-- Works once just before mission start.
	
    -- 2) Setup udp sockets to talk to helios
    package.path  = package.path..";.\\LuaSocket\\?.lua"
    package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
   
    socket = require("socket")
    
    c = socket.udp()
	c:setsockname("*", 0)
	c:setoption('broadcast', true)
    c:settimeout(.001) -- set the timeout for reading the socket 
    if c~= nil then 
		WriteToHeliosLog(thisScript,"LuaExportStart() socket open for communication.")
	else
		WriteToHeliosLog(thisScript,"LuaExportStart() socket failed to open.")
	end
    if PrevExport.LuaExportStart then
        PrevExport.LuaExportStart()
    end
end

LuaExportBeforeNextFrame= function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportBeforeNextFrame() invoked.") end
	ProcessInput()
    if PrevExport.LuaExportBeforeNextFrame then
       PrevExport.LuaExportBeforeNextFrame()
    end
end

LuaExportAfterNextFrame= function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportAfterNextFrame() invoked.") end

    if PrevExport.LuaExportAfterNextFrame  then
        PrevExport.LuaExportAfterNextFrame()
    end

end

LuaExportStop= function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportStop() invoked.") end
-- Works once just after mission stop.
    c:close()
    if PrevExport.LuaExportStop  then
        PrevExport.LuaExportStop()
    end

end

LuaExportActivityNextEvent= function(t)
	if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportActivityNextEvent() invoked.") end
	if scriptDebug and c == nil then WriteToHeliosLog(thisScript,"Connection object is Nil in LuaExportActivityNextEvent().") end

	local lt = t + lInterval
    local lot = lt

	lTickCount = lTickCount + 1
	local lDevice = GetDevice(0)
	if type(lDevice) == "table" then
		lDevice:update_arguments()

		ProcessArguments(lDevice, lEveryFrameArguments)
		ProcessHighImportance(lDevice)

		if lTickCount >= lLowTickInterval then
			ProcessArguments(lDevice, lArguments)
			ProcessLowImportance(lDevice)
			lTickCount = 0
		end

		FlushData()
	end
    if PrevExport.LuaExportActivityNextEvent then
        lot = PrevExport.LuaExportActivityNextEvent(t)  -- if we were given a value then pass it on
    end
    if  lt > lot then 
        lt = lot -- take the lesser of the next event times
    end
    return lt

end

-- Network Functions
FlushData = function()
	if #lSendStrings > 0 then
		local packet = lID .. table.concat(lSendStrings, ":") .. "\n"
		socket.try(c:sendto(packet, lHost, lPort))
		lSendStrings = {}
		lPacketSize = 0
	end
end

SendData = function(id, value)
    WriteToHeliosLog(thisScript,"Pre SendData: " .. id .. "=" .. value)
	if string.len(value) > 3 and value == string.sub("-0.00000000",1, string.len(value)) then
		value = value:sub(2)
	end
	
	if lLastData[id] == nil or lLastData[id] ~= value then
		local data =  id .. "=" .. value
		local dataLen = string.len(data)

		if dataLen + lPacketSize > 576 then
			FlushData()
		end
        --WriteToHeliosLog(thisScript,"SendData: " .. data)

		table.insert(lSendStrings, data)
		lLastData[id] = value	
		lPacketSize = lPacketSize + dataLen + 1
	end	
end

-- Status Gathering Functions
ProcessArguments = function(device, arguments)
	local lArgument , lFormat , lArgumentValue
	for lArgument, lFormat in pairs(arguments) do 
		lArgumentValue = string.format(lFormat,device:get_argument_value(lArgument))
		SendData(lArgument, lArgumentValue)
	end
end

-- Data Processing Functions

parse_indication = function(indicator_id)  -- Thanks to [FSF]Ian code
	local ret = {}
	local li = list_indication(indicator_id)
	if li == "" then return nil end
	local m = li:gmatch("-----------------------------------------\n([^\n]+)\n([^\n]*)\n")
	while true do
	local name, value = m()
	if not name then break end
		ret[name] = value
	end
	return ret
end

ProcessInput = function()
    local lInput = c:receive()
    local lCommand, lCommandArgs, lDevice, lArgument, lLastValue
    
    if lInput then
	
        lCommand = string.sub(lInput,1,1)
        
		if lCommand == "R" then
            WriteToHeliosLog(thisScript,"Reset Received - " .. lInput)
			ResetChangeValues()
		end
	
		if (lCommand == "C") then
            --WriteToHeliosLog(thisScript,"Command Received - " .. lInput)
			lCommandArgs = StrSplit(string.sub(lInput,2),",")
			lDevice = GetDevice(lCommandArgs[1])
			if type(lDevice) == "table" then
				lDevice:performClickableAction(lCommandArgs[2],lCommandArgs[3])	
			end
		end
    end 
end

-- Helper Functions
StrSplit = function(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then break end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

check = function(s)
    if type(s) == "string" then 
        print("Variable type is "..type(s))
        return s
    else
	    return "*"
    end
end
ResetChangeValues = function()
	lLastData = {}
	lTickCount = 10
end
end
end