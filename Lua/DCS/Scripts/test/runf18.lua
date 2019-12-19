helios_mock.test = {
    -- this will stress Helios if run with the same profile, running every
    -- value through 0..100 repeatedly, regardless of type intended
    [1] = function()
        helios_mock.setSelf("FA-18C_hornet")
        helios_mock.loadDriver("FA-18C_hornet", "my_F18_profile_name")
    end,
    [3600] = function()
    end
}
