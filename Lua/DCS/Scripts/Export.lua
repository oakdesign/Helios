-- normal install:
dofile(lfs.writedir().."Scripts\\Helios\\HeliosExport15.lua")

-- optional: Let the script reload itself if changed.  The path must be complete,
-- since the script does not know its own name.
-- local Helios = dofile(lfs.writedir().."Scripts\\Helios\\HeliosExport15.lua")
-- Helios.enableHotReload(lfs.writedir().."Scripts\\Helios\\HeliosExport15.lua")