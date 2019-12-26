helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("FA-18C_hornet")
        helios_mock.loadDriver("FA-18C_hornet", "my_F18_profile_name")
        assert(helios_mock.profileName() == "my_F18_profile_name", "profile not active")
    end,
    [2] = function()
        -- luacheck: globals tostring LuaExportActivityNextEvent helios_loader
        helios_mock.impl.setSimID("ORIGINAL*")
        log.write('RELOAD', log.DEBUG, string.format("global LuaExportActivityNextEvent '%s'", tostring(LuaExportActivityNextEvent)))
        local reloaded = helios_loader.reload()

        -- this step is only because mock needs the privileged interface, it would
        -- not happen at run time
        helios_mock.installReloaded(reloaded)
        assert(helios_mock.profileName() == "", "state not reset")

        log.write('RELOAD', log.DEBUG, string.format("global LuaExportActivityNextEvent '%s'", tostring(LuaExportActivityNextEvent)))
    end,
    [3] = function()
        helios_mock.setSelf("FA-18C_hornet")
        helios_mock.loadDriver("FA-18C_hornet", "my_F18_profile_name")
        assert(helios_mock.profileName() == "my_F18_profile_name", "profile not active")
    end
}
