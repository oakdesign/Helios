helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("A-10C")
        -- now wait for event loop to notice change before we load
    end,
    [11] = function()
        helios_mock.receiveLoadDriver("FA-18C_hornet")
    end,
    [12] = function()
        assert(helios_mock.moduleName() == "Helios_A10C", "should resist change")
    end,
    [13] = function()
        helios_mock.receiveLoadDriver("A-10C")
    end,
    [14] = function()
        assert(helios.selfName() == "A-10C", "plane not active")
        assert(helios_mock.driverName() == "A-10C", "driver not active")
        assert(helios_mock.moduleName() == nil, "module active")
    end
}
