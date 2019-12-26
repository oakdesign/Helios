Helios_FC = {}

Helios_FC.Name = "A-10A;F-15C;MiG-29;Su-25;Su-27;Su-33"

Helios_FC.FlamingCliffsAircraft = true

function Helios_FC.ProcessExports(data)
	local altBar = LoGetAltitudeAboveSeaLevel()
	local altRad = LoGetAltitudeAboveGroundLevel()
	local pitch, bank, yaw = LoGetADIPitchBankYaw()
	local engine = LoGetEngineInfo()
	local hsi    = LoGetControlPanel_HSI()
	local vvi = LoGetVerticalVelocity()
	local ias = LoGetIndicatedAirSpeed()
	local route = LoGetRoute()
	local aoa = LoGetAngleOfAttack()
	local accelerometer = LoGetAccelerationUnits()
	local glide = LoGetGlideDeviation()
	local side = LoGetSideDeviation()

	local distanceToWay = 999
	local navInfo = LoGetNavigationInfo()

	if engine then
		local fuelLeftKG = engine.fuel_internal  + engine.fuel_external
		local fuelConsumptionKGsec = engine.FuelConsumption.left + engine.FuelConsumption.right
	end
			
	if (data and route) then -- if neither are nil
		local myLoc = LoGeoCoordinatesToLoCoordinates(data.LatLongAlt.Long, data.LatLongAlt.Lat)
		-- DCS coordinates are X & Z, with Y as altitude.
		distanceToWay = math.sqrt((myLoc.x - route.goto_point.world_point.x)^2 + (myLoc.z -  route.goto_point.world_point.z)^2)
	end

	if data.Name=="F-15C" then   --- F-15C  prepared for Capt Zeen helios profile
		Helios_Udp.Send("1", string.format("%.2f", Helios_Util.Degrees(pitch) ) )
		Helios_Udp.Send("2", string.format("%.2f", Helios_Util.Degrees(bank) ) )
		Helios_Udp.Send("3", string.format("%.2f", Helios_Util.Degrees(yaw) ) )
		Helios_Udp.Send("4", string.format("%.2f", altBar) )
		Helios_Udp.Send("7", string.format("%.2f", 360 - Helios_Util.Degrees(hsi.RMI_raw) ))
		Helios_Udp.Send("8", string.format("%.2f", Helios_Util.Degrees(data.Heading) ) )
		Helios_Udp.Send("13", string.format("%.2f", vvi) )
		Helios_Udp.Send("16", string.format("%.2f", Helios_Util.Degrees(aoa) ) )
		Helios_Udp.Send("17", string.format("%.2f", glide) )
		Helios_Udp.Send("18", string.format("%.2f", side) )


		-- prepare pairs of data to send more info to helios........

		Helios_Udp.Send("9", string.format("%.4f", (math.floor(engine.fuel_internal) + (engine.RPM.left /1000))  ) ) --fuel int + rpm left in rpm.left import data
		Helios_Udp.Send("10", string.format("%.4f", (math.floor(engine.fuel_external) + (engine.RPM.right /1000))  ) ) --fuel ext + rpm right in rpm.right import data
		Helios_Udp.Send("11", string.format("%.4f", (math.floor(engine.fuel_internal+engine.fuel_external) + (engine.Temperature.left/1000)) ) ) --fuel TOTAL +  eng temp left in eng temp left import data
		
		if math.floor(route.goto_point.world_point.x)<0 then
			Helios_Udp.Send("12", string.format("%.4f", (math.floor(route.goto_point.world_point.x) - (engine.Temperature.right/1000)) ) ) --x coord +  eng temp left in eng temp rifgt import data
			else
			Helios_Udp.Send("12", string.format("%.4f", (math.floor(route.goto_point.world_point.x) + (engine.Temperature.right/1000)) ) ) --x coord +  eng temp left in eng temp rifgt import data
		end

		Helios_Udp.Send("14", string.format("%.5f", (math.floor(distanceToWay) + (ias /10000))  ) ) --distance to way + ias in IAS import data

		-- end of pairs

		Helios_Udp.Send("5", string.format("%.2f", accelerometer.y ))   -- acelerometer in Radar altidud import data
		Helios_Udp.Send("15", string.format("%s", navInfo.SystemMode.master .." / ".. navInfo.SystemMode.submode))  -- HUD MODE and SUBMODE in distancetoway import data
		Helios_Udp.Send("6", string.format("%.2f", 360 - (hsi.ADF_raw * 57.3)) )  --HSI in f15 format
	else
		--------------------------------------------------------------------------------------------------------------
		------------------------------------------------------------------------------------------     Other airplanes
		--------------------------------------------------------------------------------------------------------------

		Helios_Udp.Send("1", string.format("%.2f", Helios_Util.Degrees(pitch) ) )
		Helios_Udp.Send("2", string.format("%.2f", Helios_Util.Degrees(bank) ) )
		Helios_Udp.Send("3", string.format("%.2f", Helios_Util.Degrees(yaw) ) )
		Helios_Udp.Send("4", string.format("%.2f", altBar) )
		Helios_Udp.Send("5", string.format("%.2f", altRad) )
		
		if (hsi) then
			Helios_Udp.Send("6", string.format("%.2f", (360 - Helios_Util.Degrees(hsi.ADF_raw))+(360 - Helios_Util.Degrees(data.Heading)) ) )
			Helios_Udp.Send("7", string.format("%.2f", 360 - Helios_Util.Degrees(hsi.RMI_raw)) )
			Helios_Udp.Send("8", string.format("%.2f", Helios_Util.Degrees(data.Heading)) ) 
		end
		
		if (engine) then
			Helios_Udp.Send("9", string.format("%.2f", engine.RPM.left) )
			Helios_Udp.Send("10", string.format("%.2f", engine.RPM.right) )
			Helios_Udp.Send("11", string.format("%.2f", engine.Temperature.left) )
			Helios_Udp.Send("12", string.format("%.2f", engine.Temperature.right) )
		end
		
		Helios_Udp.Send("13", string.format("%.2f", vvi) )
		Helios_Udp.Send("14", string.format("%.2f", ias) )
		Helios_Udp.Send("15", string.format("%.2f", distanceToWay) )
		Helios_Udp.Send("16", string.format("%.2f", Helios_Util.Degrees(aoa) ) )
		Helios_Udp.Send("17", string.format("%.2f", glide) )
		Helios_Udp.Send("18", string.format("%.2f", side) )
	end

	Helios_Udp.Flush()
end
