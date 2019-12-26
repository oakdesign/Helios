-- mock testing interface, only for test/*.lua
-- luacheck: globals helios_mock

-- we implement a bunch of DCS globals, so we write them:
-- luacheck: ignore 121

helios_mock = {}
helios_mock.nextValue = 0
helios_mock.selfName = ""

-- load modules from our containing directory
package.path = package.path..';./exmock/?.lua;'
package.cpath = package.cpath..';./exmock/?.dll;'

-- mock implementation, only used when testing in LUA 5.1 runtime without DCS
lfs = require("mock_lfs")
log = require("mock_log")

-- mock tuning
local helios_mock_private = {}
helios_mock_private.fps = 60.0

-- mock DCS device (singleton for now)
local helios_mock_device = {}

function helios_mock_device.update_arguments()
end

function helios_mock_device.get_argument_value(index)  --luacheck: no unused
    -- value goes from 0 to 100 and then wraps repeatedly
    return helios_mock.makeValue(0, 100, 1.0)
end

function helios_mock.makeValue(min, max, resolution)
    local iteration = helios_mock.nextValue % ((max - min) / resolution)
    local value = min + (resolution * iteration)
    helios_mock.nextValue = helios_mock.nextValue + 1
    return value
end

function helios_mock_device.get_frequency()
    return helios_mock.makeValue(100, 200, 0.1)
end

function list_indication(indicator_id) -- luacheck: no unused
    return ""
end

function GetDevice(name) -- luacheck: no unused
    return helios_mock_device
end

function LoGetSelfData()
    local info = {}
    info.Name = helios_mock.selfName
    info.Heading = helios_mock.makeValue(-1, 1, 0.02)
    return info
end

function LoGetAltitudeAboveSeaLevel()
    return helios_mock.makeValue(10000, 20000, 10)
end

function LoGetAltitudeAboveGroundLevel()
    return LoGetAltitudeAboveSeaLevel() - 1000;
end

function LoGetADIPitchBankYaw()
    return helios_mock.makeValue(-10, 10, 0.1), helios_mock.makeValue(-10, 10, 0.1), helios_mock.makeValue(-10, 10, 0.1)
end

function LoGetEngineInfo()
    return {
        RPM = {
           left = helios_mock.makeValue(1, 100, 1),
           right = helios_mock.makeValue(1, 100, 1)
        },
        Temperature = {
            left = helios_mock.makeValue(1, 100, 1),
            right = helios_mock.makeValue(1, 100, 1)
        },
        FuelConsumption = {
            left = helios_mock.makeValue(1, 100, 1),
            right = helios_mock.makeValue(1, 100, 1)
        },
        fuel_internal = helios_mock.makeValue(1000, 2000, 1),
        fuel_external = helios_mock.makeValue(1000, 2000, 1)
    }
end

function LoGetControlPanel_HSI()
    return {
        ADR_raw = helios_mock.makeValue(-10, 10, 0.1),
        RMI_raw = helios_mock.makeValue(-10, 10, 0.1)
    }
end

function LoGetVerticalVelocity()
    return helios_mock.makeValue(-10, 10, 0.1)
end

function LoGetIndicatedAirSpeed()
    return helios_mock.makeValue(100, 500, 1.0)
end

function LoGetRoute()
    return nil
end

function LoGetAngleOfAttack()
    return helios_mock.makeValue(-10, 10, 0.1)
end

function LoGetAccelerationUnits()
    return { x = helios_mock.makeValue(-10, 10, 0.1), y = helios_mock.makeValue(-10, 10, 0.1), z = helios_mock.makeValue(-10, 10, 0.1) }
end

function LoGetGlideDeviation()
    return helios_mock.makeValue(-10, 10, 0.1);
end

function LoGetSideDeviation()
    return helios_mock.makeValue(-10, 10, 0.1);
end

function LoGetNavigationInfo()
    return nil
end

function LoGeoCoordinatesToLoCoordinates(x1, z1)
    return { x = x1, y = 0.0, z = z1};
end

-- load export script as if we were DCS and gain privileged access
local helios_impl = dofile(".\\Helios\\HeliosExport15.lua")

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

-- test loading module in compatibility mode
function helios_mock.loadModuleDriver(selfName, moduleName)
    helios_impl.cancelAutoLoad();
    local driver = helios_impl.createModuleDriver(selfName, moduleName)
    if driver == nil then
        log.write('MOCK', log.ERROR, string.format("failed to create module driver %s for %s", moduleName, selfName))
        return
    end
    helios_impl.installDriver(driver, moduleName)
    helios_impl.notifyLoaded()
end

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