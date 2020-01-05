helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("A-10C")
        -- now wait for event loop to notice change before we load
    end,
    [11] = function()
        helios_mock.loadModule("A-10C", "Helios_A10C")
    end,
    [12] = function()
        helios_mock.receiveLoadDriver("FA-18C_hornet")
    end,
    [13] = function()
        assert(helios_mock.moduleName() == "Helios_A10C", "should not change")
    end
}
