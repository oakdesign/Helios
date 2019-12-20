-- mock testing interface, only for test/*.lua
-- luacheck: globals helios_mock
helios_mock = {}
helios_mock.nextValue = 0
helios_mock.selfName = ""

-- load modules from our containing directory
package.path = package.path..';./exmock/?.lua;'
package.cpath = package.cpath..';./exmock/?.dll;'

-- mock implementation, only used when testing in LUA 5.1 runtime without DCS
lfs = require("mock_lfs")
log = require("mock_log")

-- mock DCS device (singleton for now)
local helios_mock_device = {}

-- mock tuning
local helios_mock_private = {}
helios_mock_private.fps = 60.0

-- set name of vehicle/aircraft to be reported by mock DCS
function helios_mock.setSelf(name)
    helios_mock.selfName = name
end

function helios_mock.profileName()
    return helios_impl.driverName
end

function helios_mock.loadDriver(selfName, profileName)
    -- NOTE: this isn't part of the helios API, enforced by luacheck
    helios_impl.loadProfile(selfName, profileName)
end

function helios_mock.receiveLoadProfile(profileName)
    helios_impl.dispatchCommand(string.format("P%s", profileName))
end

function helios_mock.framesUntilAutoLoad()
    return math.ceil((helios_impl.autoLoadDelay + helios_impl.exportInterval) * helios_mock_private.fps)
end

function helios_mock_device.performClickableAction(arg1, arg2)
    log.write('MOCK', log.INFO, string.format("click %d, %d", arg1, arg2))
end

function helios_mock_device.update_arguments()
end

function helios_mock_device.get_argument_value(index)  --luacheck: no unused
    -- value goes from 0 to 100 and then wraps repeatedly
    local value = helios_mock.nextValue % 101
    helios_mock.nextValue = helios_mock.nextValue + 1
    return value
end

function list_indication(indicator_id) -- luacheck: no global, no unused
    return ""
end

function GetDevice(name) -- luacheck: no global, no unused args
    return helios_mock_device
end

function LoGetSelfData() -- luacheck: no global
    local info = {}
    info.Name = helios_mock.selfName
    return info
end

-- load export script as if we were DCS
dofile "Export.lua"

-- default test
helios_mock.test = { [10] = function() end }

-- configure test, if any
-- luacheck: read_globals arg
if arg[1] then
    dofile(string.format("test/%s.lua", arg[1]))
end

-- create sorted work list of events in test
local eventFrames = {}
for eventFrame, _ in pairs(helios_mock.test)  do
    table.insert(eventFrames, eventFrame)
end
table.sort(eventFrames)

-- run scenario
LuaExportStart()
local frame = 0
local nextEvent = 0;
for _, eventFrame in ipairs(eventFrames) do
    local event = helios_mock.test[eventFrame]
    log.write('MOCK', log.INFO, string.format("executing until next test event at frame %d", eventFrame))
    for progress=frame,eventFrame do
        log.write('MOCK', log.DEBUG, string.format("frame %d", progress))
        LuaExportBeforeNextFrame()
        frame = progress
        LuaExportAfterNextFrame()

        local clock = frame / helios_mock_private.fps
        if clock >= nextEvent then
            log.write('MOCK', log.DEBUG, string.format("export activity at clock %f", clock))
            nextEvent = LuaExportActivityNextEvent(nextEvent)
        end
    end
    -- now we have just processed a frame after which we have a test event
    log.write('MOCK', log.INFO, string.format("test event at frame %d", eventFrame))
    event()
end
LuaExportStop()