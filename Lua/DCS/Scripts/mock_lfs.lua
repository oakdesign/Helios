-- mock implementation, only used when testing in LUA 5.1 runtime without DCS
local mock_lfs = {}
-- XXX we can't get lfs to build in our luadist environment, so we can't just wrap the real lfs yet
local io = require("io")

function mock_lfs.writedir()
    return "../"
end

function mock_lfs.dir(path)
    -- insane windows escaping requirements of cmd
    -- https://stackoverflow.com/questions/53452818/lua-io-popen-run-program-with-space-in-path
    local cmdLine = string.format([==[dir "%s" /b]==], path)
    cmdLine = '"'..cmdLine..'"'
    return io.popen(cmdLine):lines()
end

return mock_lfs