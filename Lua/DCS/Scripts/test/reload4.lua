helios_mock.test = {
    [1] = function()
        helios_mock.impl.setSimID("ORIGINAL*")
        helios_mock.setSelf("FA-18C_hornet")
    end,
    [2] = function()
        local reloaded = helios_loader.reload() -- luacheck: no global

        -- this step is only because mock needs the privileged interface, it would
        -- not happen at run time
        helios_mock.installReloaded(reloaded)
    end,
    [3] = function()
        assert(helios_mock.driverName() == "", "state not reset")
        helios_mock.impl.setSimID("SECOND*")
        local reloaded = helios_loader.reload() -- luacheck: no global

        -- this step is only because mock needs the privileged interface, it would
        -- not happen at run time
        helios_mock.installReloaded(reloaded)
        assert(helios_mock.driverName() == "", "state not reset")
    end,
    [4] = function()
    end
}
