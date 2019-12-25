Helios_P51 = {}

Helios_P51.Name = "P-51D;TF-51D"
Helios_P51.FlamingCliffsAircraft = false
Helios_P51.ExportArguments = {}


function Helios_P51.HighImportance(data)


	-- read from main panel
	local MainPanel = GetDevice(0)
	local AirspeedNeedle = MainPanel:get_argument_value(11)*1000
	local Altimeter_10000_footPtr = MainPanel:get_argument_value(96)*100000
	local Variometer = MainPanel:get_argument_value(29)   
	local TurnNeedle = MainPanel:get_argument_value(27)   
	local Slipball = MainPanel:get_argument_value(28)
	local CompassHeading = MainPanel:get_argument_value(1) 
	local CommandedCourse = MainPanel:get_argument_value(2) 							
	local Manifold_Pressure = MainPanel:get_argument_value(10) 
	local Engine_RPM = MainPanel:get_argument_value(23)
	local AHorizon_Pitch = MainPanel:get_argument_value(15) 
	local AHorizon_Bank = MainPanel:get_argument_value(14) 
	local AHorizon_PitchShift = MainPanel:get_argument_value(16) * 10.0 * math.pi/180.0
	local AHorizon_Caged = MainPanel:get_argument_value(20) 
	local GyroHeading = MainPanel:get_argument_value(12) 
	local vaccum_suction = MainPanel:get_argument_value(9)
	local carburator_temp = MainPanel:get_argument_value(21)
	local coolant_temp = MainPanel:get_argument_value(22)
	local Acelerometer = MainPanel:get_argument_value(175)
	local OilTemperature = MainPanel:get_argument_value(30)
	local OilPressure = MainPanel:get_argument_value(31)
	local FuelPressure = MainPanel:get_argument_value(32)
	local Clock_hours = MainPanel:get_argument_value(4)
	local Clock_minutes = MainPanel:get_argument_value(5)
	local Clock_seconds = MainPanel:get_argument_value(6)
	local LandingGearGreenLight = MainPanel:get_argument_value(80) 
	local LandingGearRedLight = MainPanel:get_argument_value(82)
	local Hight_Blower_Lamp = MainPanel:get_argument_value(59) 						
	local Acelerometer_Min = MainPanel:get_argument_value(177)
	local Acelerometer_Max = MainPanel:get_argument_value(178)
	local Ammeter = MainPanel:get_argument_value(101)	
	local hydraulic_Pressure = MainPanel:get_argument_value(78)  
	local Oxygen_Flow_Blinker = MainPanel:get_argument_value(33)
	local Oxygen_Pressure = MainPanel:get_argument_value(34)
	local Fuel_Tank_Left = MainPanel:get_argument_value(155)
	local Fuel_Tank_Right = MainPanel:get_argument_value(156)
	local Fuel_Tank_Fuselage = MainPanel:get_argument_value(160)
	local Tail_radar_warning = MainPanel:get_argument_value(161)
	local Channel_A = MainPanel:get_argument_value(122)
	local Channel_B = MainPanel:get_argument_value(123)
	local Channel_C = MainPanel:get_argument_value(124)
	local Channel_D = MainPanel:get_argument_value(125)
	local transmit_light = MainPanel:get_argument_value(126)
	local RocketCounter = MainPanel:get_argument_value(77)

	--- preparing landing gear and High Blower lights, all together, in only one value	
	local gear_lights = 0
	if LandingGearGreenLight > 0 then gear_lights = gear_lights +100 end
	if LandingGearRedLight > 0 then gear_lights = gear_lights +10 end
	if Hight_Blower_Lamp > 0 then gear_lights = gear_lights +1 end
	------------------------------------------------------------	

	--- preparing radio lights, all together, in only one value	
	local radio_active = 0
	if Channel_A > 0 then radio_active = 1 end
	if Channel_B > 0 then radio_active= 2 end
	if Channel_C > 0 then radio_active= 3 end
	if Channel_D > 0 then radio_active= 4 end
	if transmit_light > 0 then radio_active = radio_active + 10 end
	------------------------------------------------------------


	---- sending P51 and tf51 data across fc2 interface

	Helios_Udp.Send("1", string.format("%.5f", math.floor((AHorizon_Pitch+1)*1000) + ((AHorizon_Bank+1)/100) ) ) 	-- pitch
	Helios_Udp.Send("2", string.format("%.3f", math.floor(Oxygen_Flow_Blinker*100) + (Oxygen_Pressure/100) ) )		-- bank
	Helios_Udp.Send("3", string.format("%.4f", math.floor(OilTemperature*100) + (vaccum_suction/100) ) )			-- yaw
	Helios_Udp.Send("4", string.format("%.3f", math.floor(Altimeter_10000_footPtr) + (AHorizon_Caged/100) ) )		-- barometric altitude 
	Helios_Udp.Send("5", string.format("%.5f", math.floor(Clock_hours*1000000) + (Tail_radar_warning/100) ) )		-- radar altitude 
	Helios_Udp.Send("6", string.format("%.5f", math.floor(CompassHeading*1000) + (CommandedCourse/100) ) )			-- adf
	Helios_Udp.Send("7", string.format("%.4f", math.floor(Clock_seconds*100) + (hydraulic_Pressure/100) ) )		-- rmi
	Helios_Udp.Send("8", string.format("%.2f", math.floor(GyroHeading*1000) + (radio_active/100) ) )				-- heading
	Helios_Udp.Send("9", string.format("%.4f", math.floor(Engine_RPM*100) + (Manifold_Pressure/100) ) )			-- left rpm
	Helios_Udp.Send("10", string.format("%.4f", math.floor(Fuel_Tank_Left*100) + (Fuel_Tank_Right/100) ) )			-- right rpm
	Helios_Udp.Send("11", string.format("%.4f", math.floor(carburator_temp*100) + (coolant_temp/100) ) )			-- left temp
	Helios_Udp.Send("12", string.format("%.4f", math.floor(gear_lights) + (Acelerometer_Min/100 ) ) )				-- right temp
	Helios_Udp.Send("13", string.format("%.2f", Variometer) )														-- vvi
	Helios_Udp.Send("14", string.format("%.5f", math.floor(AirspeedNeedle)+ (RocketCounter/100) ) )				-- ias
	Helios_Udp.Send("15", string.format("%.4f", math.floor(OilPressure*100) + (FuelPressure/100) ) )				-- distance to way
	Helios_Udp.Send("16", string.format("%.3f", math.floor(Acelerometer*1000) + (Acelerometer_Max/100 ) ) )		-- aoa
	Helios_Udp.Send("17", string.format("%.4f", math.floor((TurnNeedle+1)*100) + ((Slipball+1)/100) ) )			-- glide
	Helios_Udp.Send("18", string.format("%.4f", math.floor(Fuel_Tank_Fuselage*100) + (Ammeter/100) ) )				-- side


	Helios_Udp.Flush()
end


function Helios_P51.LowImportance(MainPanel)



	Helios_Udp.Flush()
end





function Helios_P51.ProcessInput(data)
    local lCommand, lCommandArgs, lDevice, lArgument, lLastValue
    local sIndex, lConvDevice
	local valor_axis, absoluto, min_clamp
	
	lCommand = string.sub(data,1,1)
	
	if lCommand == "R" then
		Helios_Udp.ResetChangeValues()
	end

	if (lCommand == "C") then
		lCommandArgs = Helios_Util.Split(string.sub(data,2),",")
		sIndex = lCommandArgs[1]..","..lCommandArgs[2]
		lConvDevice = Helios_P51.ExportArguments[sIndex] 	
		lArgument = Helios_Util.Split(string.sub(lConvDevice,1),",")
		min_clamp = 0
		max_clamp = 1
		
				
		lDevice = GetDevice(lArgument[1])    -- data conversions between switches extended and MI8
		if type(lDevice) == "table" then
		
			if lArgument[3]=="100" then   -- convert 0.2 0.1 0.0 to 1 0 -1
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = ((temporal)*10)-1
				lArgument[3] = 1
			end
			if lArgument[3]=="101" then   -- convert 1 0.5 0.0 to 1 0 -1
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = (temporal*2)-1
				lArgument[3] = 1
			end
			if lArgument[3]=="102" then   -- convert 1 0 to 1 -1
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = (temporal*2)-1
				lArgument[3] = 1
			end
			if lArgument[3]=="103" then   -- convert 1 0 -1 to 1 0.5 0.0
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = (temporal+1)/2
				lArgument[3] = 1
			end
			if lArgument[3]=="104" then   -- convert 0.2 0.1 0.0 to 0.2 0.1 0.3
			 --local temporal= lCommandArgs[3]

				if lCommandArgs[3] <= "0.05" then
				 lCommandArgs[3] = 0.3
				end
				lArgument[3] = 1
			end
			if lArgument[3]=="105" then   -- convert 0.0 0.1 0.2 0.3 0.4  to -0.1 0.0 0.1 0.2 0.3
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = temporal - 0.1
				lArgument[3] = 1
				
			end
			if lArgument[3]=="106" then   -- convert 0.2 0.1 0.0  to 1.0 0.5 0.0
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = temporal*5
				lArgument[3] = 1
				
			end
			
			lDevice:performClickableAction(lArgument[2],lCommandArgs[3]*lArgument[3])
		end
	end
end

