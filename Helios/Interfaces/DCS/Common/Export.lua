local lfs = require "lfs"
require "debug"
local InvokeChildExports = nil
local ThisExport = {}
local PrevExport = {}
PrevExport.LuaExportStart = LuaExportStart
PrevExport.LuaExportStop = LuaExportStop
PrevExport.LuaExportBeforeNextFrame = LuaExportBeforeNextFrame
PrevExport.LuaExportAfterNextFrame = LuaExportAfterNextFrame
PrevExport.LuaExportActivityNextEvent = LuaExportActivityNextEvent

LuaExportStart = nil
LuaExportStop = nil
LuaExportBeforeNextFrame = nil
LuaExportAfterNextFrame = nil
LuaExportActivityNextEvent = nil
gHeliosDebug = true
local scriptDebug = false   -- local control of tracing
local lInterval = 0.067
-- introspect the script and where it was run from
local thisScript = debug.getinfo(1,'S').short_src:gsub("\\","/"):match('^.*/(.*).[Ll][Uu][Aa]"]$')
local thisPath = debug.getinfo(1,'S').short_src:gsub("\\","/"):match('^.*%s"(.*/)[Ss][Cc][Rr][Ii][Pp][Tt][Ss]/.*.[Ll][Uu][Aa]"]$'):gsub("/","\\\\")
local llogFile
local lDebugLogFileName = thisPath .. "Logs\\Helios.log"
WriteToHeliosLog = function(caller, message)
    if gHeliosDebug then
    	if llogFile then
			local lAircraft = gAircraft
			if lAircraft == nil then lAircraft = "*" end
    		llogFile:write(string.format("%s %s: %s\r\n", os.date("%H:%M:%S"), lAircraft .. '|' .. caller, message))
        end
    end
end
if gHeliosDebug then
	llogFile = assert(io.open(lDebugLogFileName, "w"))
	if llogFile then
		   WriteToHeliosLog(thisScript,"Helios Exports Initialisation")
		   WriteToHeliosLog(thisScript,"Current Directory=" .. lfs.currentdir())
	end
end
InvokeChildExports = function ()
		-- This function attempts to determine the aircraft type which will usually happen on first 
		-- invocation for local aircraft missions, however if the export file gets invoked as part 
		-- of a mission, then there will not be an aircraft so we have to be prepared to find the 
		-- aircraft type at a later time so this function is also called as part of LuaExportStart
		-- * * * We also need to check the best way to get hooked in to missions where the pilot chooses a different aircraft type * * * 
		local DCSInfo = LoGetSelfData()
		if DCSInfo == nil then
			WriteToHeliosLog(thisScript,string.format("DCSInfo / LoGetSelfData is nil in InvokeChildExports"))
		else
			local k,v
			for k,v in pairs(DCSInfo) do
					if type(v) == "string" or type(v) == "number" then 
					WriteToHeliosLog(thisScript,"DCSInfo - Key: " .. k .. " Value: " .. v)	
					end
			end
			gAircraft = DCSInfo.Name
			WriteToHeliosLog(thisScript,string.format("Aircraft: " .. gAircraft))
			-- invoke all of the Export scripts in the Aircraft Directory
			for file in lfs.dir(thisPath .. "Scripts\\" .. gAircraft .."\\") do
				if file:match('(.*).[Ll][Uu][Aa]$') ~= nil then 
					WriteToHeliosLog(thisScript,"Mods - Calling " .. thisPath .. "Scripts\\" .. gAircraft .. "\\" .. file)
					log.write('USERMOD.HELIOS',log.INFO,thisScript,"Mods - Calling " .. thisPath .. "Scripts\\" .. gAircraft .. "\\" .. file)
					dofile(thisPath .. "Scripts\\" .. gAircraft .. "\\" .. file)
				end
			end		
		end

end 
LuaExportStart = function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportStart() invoked.") end
    -- the only reason for code in this function is to catch a later
	-- aircraft selection and invokve the necessary child scripts.
	if gAircraft == nil then
    	WriteToHeliosLog(thisScript,"Invoking child exports from LuaExportStart()")
		InvokeChildExports()
	else
		local DCSInfo = LoGetSelfData()
		if DCSInfo.Name ~= gAircraft then
	    	WriteToHeliosLog(thisScript,"Aircraft change from " .. gAircraft .. " to " .. DCSInfo.Name )
			-- if the aircraft name does not match the one that we previously had
			-- then we need to unhook the existing exports and reattach some new ones.
			InvokeChildExports()
			if gAircraft == nil then
				   WriteToHeliosLog(thisScript,"Aircraft remains NIL after InvokeChildExports() called from LuaExportStart().")
			end
		end
	end
	if PrevExport.LuaExportStart then 
		PrevExport.LuaExportStart()
	end
end
LuaExportStop = function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportStop() invoked.") end
	if PrevExport.LuaExportStop then
		PrevExport.LuaExportStop()
	end
	-- A stop has been issued so we unhook the child routines because if
	-- we restart, it could be with a new aircraft
	LuaExportStart = ThisExport.LuaExportStart
	LuaExportStop = ThisExport.LuaExportStop
	LuaExportAfterNextFrame = ThisExport.LuaExportAfterNextFrame
	LuaExportBeforeNextFrame = ThisExport.LuaExportBeforeNextFrame
	LuaExportActivityNextEvent = ThisExport.LuaExportActivityNextEvent
	gAircraft = nil
end
LuaExportAfterNextFrame = function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportAfterNextFrame() invoked.") end

	if PrevExport.LuaExportAfterNextFrame then
		PrevExport.LuaExportAfterNextFrame()
	end
end
LuaExportBeforeNextFrame = function()
if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportBeforeNextFrame() invoked.") end
    -- the only reason for code in this function is to catch a later
	-- aircraft selection and invokve the necessary child scripts.
	if gAircraft == nil then
    	WriteToHeliosLog(thisScript,"Invoking child exports from LuaExportBeforeNextFrame()")
		InvokeChildExports()
		if gAircraft == nil then
		   WriteToHeliosLog(thisScript,"Aircraft remains NIL after InvokeChildExports() called from LuaExportBeforeNextFrame().")
		else 
		   LuaExportStart() -- If we are successful at catching a late Aircraft selection then we need to call LuaExportStart() to allow them to set their UDP connections
		end
	else
	local DCSInfo = LoGetSelfData()
	if DCSInfo.Name ~= gAircraft then
		-- if the aircraft name does not match the one that we previously had
		-- then we need to unhook the existing exports and reattach some new ones.
		WriteToHeliosLog(thisScript,"Aircraft change from " .. gAircraft .. " to " .. DCSInfo.Name)
		InvokeChildExports()
		if gAircraft == nil then
		   WriteToHeliosLog(thisScript,"Aircraft remains NIL after InvokeChildExports() called from LuaExportBeforeNextFrame().")
		end
	end
end
if PrevExport.LuaExportBeforeNextFrame then 
	PrevExport.LuaExportBeforeNextFrame()
end
end
LuaExportActivityNextEvent = function(t)
	if scriptDebug then WriteToHeliosLog(thisScript,"LuaExportActivityNextEvent() invoked.") end
	local lt = t + lInterval
    local lot = lt
	if PrevExport.LuaExportActivityNextEvent then
		lt = PrevExport.LuaExportActivityNextEvent(t)
	end
	if  lt > lot then 
        lt = lot -- take the lesser of the next event times
    end
	return lt
end
--
-- save away the stub routines in this script so that they can be restored
-- on exit
--
ThisExport.LuaExportStart = LuaExportStart
ThisExport.LuaExportStop = LuaExportStop
ThisExport.LuaExportAfterNextFrame = LuaExportAfterNextFrame
ThisExport.LuaExportBeforeNextFrame = LuaExportBeforeNextFrame
ThisExport.LuaExportActivityNextEvent = LuaExportActivityNextEvent
--
-- Everything prepared so attempt to set up the scripting
--
WriteToHeliosLog(thisScript,"Script Path: " .. thisPath)
if gAircraft == nil then
	InvokeChildExports()
	if gAircraft == nil then
	   WriteToHeliosLog(thisScript,"Aircraft remains NIL after InvokeChildExports().")
	end
end
