-- mock implementation, only used when testing in LUA 5.1 runtime without DCS
local mock_log = {}

mock_log.INFO = 'info'
mock_log.DEBUG = 'debug'
mock_log.WARNING = 'warning'
mock_log.ERROR = 'error'

function mock_log.write(facility, level, message)
    -- luacheck: globals print
    print(string.format("%-20s: %-8s %s", facility, level, message))
end

return mock_log