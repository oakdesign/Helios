helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("A-10C")
        helios_mock.loadDriver("A-10C", "my_A10_profile_name")
    end,
    [3] = function()
        helios_mock.receiveLoadProfile("my_A10_profile_name")
    end,
    [5] = function()
        assert(helios.selfName() == "A-10C", "plane not active")
        assert(helios_mock.profileName() == "my_A10_profile_name", "profile not active")
    end
}
