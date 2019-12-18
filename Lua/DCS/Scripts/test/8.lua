local waitUntil = helios_mock.framesUntilAutoLoad()
helios_mock.test = {
    [1] = function()
        helios_mock.setSelf("A-10C")
    end,
    [waitUntil + 1] = function()
        assert(helios.selfName() == "A-10C", "plane not active")
        assert(helios_mock.profileName() == "A10C_compatible_with_F18tt", "auto loaded profile not active")
    end,
    [waitUntil + 10] = function()
        helios_mock.receiveLoadProfile("my_A10_profile_name")
    end,
    [waitUntil + 20] = function()
        assert(helios.selfName() == "A-10C", "plane not active")
        assert(helios_mock.profileName() == "my_A10_profile_name", "profile not active")
    end
}
