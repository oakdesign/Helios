-- this still fails because not all FC stats are mocked
helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("F-15C")
    end,
    -- wait until we notice vehicle change
    [11] = function()
        helios_mock.loadModuleDriver("F-15C", "Helios_FC")
    end,
    [20] = function()
    end
}
