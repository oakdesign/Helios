helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("FA-18C_hornet")
        -- now wait for event loop to notice change before we load
    end,
    [11] = function()
        assert(helios.selfName() == "FA-18C_hornet", "plane not active")
        helios_mock.loadDriver("FA-18C_hornet", "my_F18_profile_name")
        assert(helios_mock.profileName() == "my_F18_profile_name", "profile not active")
    end,
    [12] = function()
        local reloaded = helios_loader.reload() -- luacheck: no global

        -- this step is only because mock needs the privileged interface, it would
        -- not happen at run time
        helios_mock.installReloaded(reloaded)
        assert(helios_mock.profileName() == "", "state not reset")
    end,
    [13] = function()
        local reloaded = helios_loader.reload() -- luacheck: no global

        -- this step is only because mock needs the privileged interface, it would
        -- not happen at run time
        helios_mock.installReloaded(reloaded)
        assert(helios_mock.profileName() == "", "state not reset")
    end,
    [14] = function()
        helios_mock.setSelf("FA-18C_hornet")
    end,
    [24] = function()
        assert(helios.selfName() == "FA-18C_hornet", "plane not active")
        helios_mock.loadDriver("FA-18C_hornet", "my_F18_profile_name")
        assert(helios_mock.profileName() == "my_F18_profile_name", "profile not active")
    end
}
