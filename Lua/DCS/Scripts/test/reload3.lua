--luacheck: globals io LuaExportActivityNextEvent tostring
helios_mock.test = {
    [0] = function()
        helios_mock.sleepRatio = 0.1
        log.mock_filter_facility("MOCK")
    end,
    [1] = function()
        helios_mock.impl.setSimID("ORIGINAL*")
        log.write('RELOAD', log.DEBUG, string.format("global LuaExportActivityNextEvent '%s'", tostring(LuaExportActivityNextEvent)))

        helios_mock.setSelf("FA-18C_hornet")
        -- now wait for event loop to notice change before we load
    end,
    [11] = function()
        assert(helios.selfName() == "FA-18C_hornet", "plane not active")
        helios_mock.loadDriver("FA-18C_hornet", "my_F18_profile_name")
        assert(helios_mock.driverName() == "FA-18C_hornet", "driver not active")
    end,
    [12] = function()
        local fd = io.open("Helios\\HeliosExport15.lua", "a")
        fd:write("\n-- changed by test reload3")
        fd:close();
    end,
    [412] = function()
        helios_mock.impl.setSimID("SECOND*")
        log.write('RELOAD', log.DEBUG, string.format("global LuaExportActivityNextEvent '%s'", tostring(LuaExportActivityNextEvent)))
        local fd = io.open("Helios\\HeliosExport15.lua", "a")
        fd:write("\n-- changed by test reload3 again")
        fd:close();
    end,
    [1000] = function()
    end
}
