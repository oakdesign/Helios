-- mock implementation, only used when testing in LUA 5.1 runtime without DCS
local mock_log = {}

mock_log.INFO = 'info'
mock_log.DEBUG = 'debug'
mock_log.WARNING = 'warning'
mock_log.ERROR = 'error'

local filters = {
    facilities = {},
    levels = {}
}

function mock_log.mock_filter_facility(facility)
    filters.facilities[facility] = true
end

function mock_log.mock_filter_level(level)
    filters.levels[level] = true
end

function mock_log.write(facility, level, message)
    if filters.facilities[facility] ~= nil then
        return
    end
    if filters.levels[level] ~= nil then
        return
    end
    -- luacheck: globals print
    print(string.format("%-20s: %-8s %s", facility, level, message))
end

return mock_log