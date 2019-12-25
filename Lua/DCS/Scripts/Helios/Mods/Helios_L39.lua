Helios_L39 = {}

Helios_L39.Name = "L-39"
Helios_L39.FlamingCliffsAircraft = false

Helios_L39.ExportArguments = {}

function Helios_L39.ProcessInput(data)
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
		lConvDevice = Helios_L39.ExportArguments[sIndex] 	
		lArgument = Helios_Util.Split(string.sub(lConvDevice,1),",")
		min_clamp = 0
		max_clamp = 1
		
		if lArgument[3]>"299" then   -- rockers special cases
			local valor_actual = GetDevice(0)
			local absoluto= math.abs(lCommandArgs[3])
			local variacion= (lCommandArgs[3]/100)
			
			if lArgument[3]=="300" then -- latitude
				valor_axis= valor_actual:get_argument_value(209) + 0.01
				lArgument = {17,3006,1} -- latitude
				min_clamp = 0
				max_clamp = 0.727
			end
			if lArgument[3]=="301" then -- latitude
				valor_axis= valor_actual:get_argument_value(209) - 0.01
				lArgument = {17,3006,1} -- latitude
				min_clamp = 0
				max_clamp = 0.727
			end
			
			lCommandArgs[3]=math.max(min_clamp, math.min(max_clamp, valor_axis))	
		end
		
		lDevice = GetDevice(lArgument[1])
		if type(lDevice) == "table" then
		
			if lArgument[3]=="100" then   -- convert 0.2 0.1 0.0 to 1 0 -1
			 local temporal= lCommandArgs[3]
				lCommandArgs[3] = ((0.2-temporal)*10)-1
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
			
		--if debug_output_file then
			--debug_output_file:write(string.format("ID %s\r\n", lArgument[2] ) )
			--debug_output_file:write(string.format("valor %s\r\n", lCommandArgs[3] ) )
		--end
			--lDevice = GetDevice(lArgument[1])
			lDevice:performClickableAction(lArgument[2],lCommandArgs[3]*lArgument[3])
			
		end
	end
end

function Helios_L39.HighImportance(mainPanelDevice)
	local _LAST_ONE = 0 -- used to mark the end of the tables	
	local MainPanel = GetDevice(0)
	
	local FrontCanopy = MainPanel:get_argument_value(38) 	-- 0 to 1
	local BackCanopy = MainPanel:get_argument_value(421) 	-- 0 to 1
	local FrontSeat = MainPanel:get_argument_value(50) 		-- 0 to 1 simplyfied
	local BackSeat = MainPanel:get_argument_value(472) 		-- 0 to 1 simplyfied
-- Mechanic clock
	local CLOCK_currtime_hours = MainPanel:get_argument_value(67) 				-- 0 to 1
	local CLOCK_currtime_minutes = MainPanel:get_argument_value(68) 			-- 0 to 1
	local CLOCK_seconds_meter_time_seconds = MainPanel:get_argument_value(70) 	-- 0 to 1
	local CLOCK_flight_time_meter_status = MainPanel:get_argument_value(73) 	-- 0 to 0.2
	local CLOCK_flight_hours = MainPanel:get_argument_value(71) 				-- 0 to 1
	local CLOCK_flight_minutes = MainPanel:get_argument_value(72) 				-- 0 to 1
	local CLOCK_seconds_meter_time_minutes = MainPanel:get_argument_value(69) 	-- 0 to 1
-- Mechanic clock
	local CLOCK_2_currtime_hours = MainPanel:get_argument_value(405) 			 -- 0 to 1
	local CLOCK_2_currtime_minutes = MainPanel:get_argument_value(406) 			 -- 0 to 1
	local CLOCK_2_seconds_meter_time_seconds = MainPanel:get_argument_value(408) -- 0 to 1
	local CLOCK_2_flight_time_meter_status = MainPanel:get_argument_value(411) 	 -- 0 to 0.2
	local CLOCK_2_flight_hours = MainPanel:get_argument_value(409) 				 -- 0 to 1
	local CLOCK_2_flight_minutes = MainPanel:get_argument_value(410) 			 -- 0 to 1
	local CLOCK_2_seconds_meter_time_minutes = MainPanel:get_argument_value(407) -- 0 to 1
-- Radar altimeter RV-5
	local RV_5_RALT = MainPanel:get_argument_value(58) -- 0 to 1
	local RV_5_DangerRALT_index = MainPanel:get_argument_value(59) -- 0 to 1
	local RV_5_DangerRALT_lamp = MainPanel:get_argument_value(63) -- 0 to 1
	local RV_5_warning_flag = MainPanel:get_argument_value(62) -- 0 to 1
-- Radar altimeter RV-5
	local RV_5_2_RALT = MainPanel:get_argument_value(396) -- 0 to 1
	local RV_5_2_DangerRALT_index = MainPanel:get_argument_value(397) -- 0 to 1
	local RV_5_2_DangerRALT_lamp = MainPanel:get_argument_value(401) -- 0 to 1
	local RV_5_2_warning_flag = MainPanel:get_argument_value(400) -- 0 to 1
-- variometer
	local Variometer = MainPanel:get_argument_value(74) -- -1 to 1
	local Variometer_sideslip = MainPanel:get_argument_value(76) -- -1 to 1
	local Variometer_turn = MainPanel:get_argument_value(75) -- -1 to 1
	local Variometer_2 = MainPanel:get_argument_value(416) -- -1 to 1
	local Variometer_2_sideslip = MainPanel:get_argument_value(418) -- -1 to 1
	local Variometer_2_turn = MainPanel:get_argument_value(417) -- -1 to 1
-- KPP
	local KPP_1273K_roll = MainPanel:get_argument_value(38) -- -1 to 1
	local KPP_1273K_pitch = MainPanel:get_argument_value(31) -- -0.5 to 0.5
	local KPP_1273K_sideslip = MainPanel:get_argument_value(40) -- -1 to 1
	local KPP_Course_Deviation_Bar = MainPanel:get_argument_value(35) -- -1 to 1
	local KPP_Alt_Deviation_Bar = MainPanel:get_argument_value(34) -- -1 to 1
	local KPP_Glide_Beacon = MainPanel:get_argument_value(36) -- 0 to 1
	local KPP_Localizer_Beacon = MainPanel:get_argument_value(37) -- 0 to 1
	local KPP_Arretir = MainPanel:get_argument_value(29) -- 0 to 1
	local KPP_SDU_Roll_Fwd = MainPanel:get_argument_value(32) -- -1 to 1
	local KPP_SDU_Pitch_Fwd = MainPanel:get_argument_value(33) -- -1 to 1
-- KPP_2
	local KPP_1273K_2_roll = MainPanel:get_argument_value(375) -- -1 to 1
	local KPP_1273K2__pitch = MainPanel:get_argument_value(368) -- -0.5 to 0.5
	local KPP_1273K2__sideslip = MainPanel:get_argument_value(377) -- -1 to 1
	local KPP_2_Course_Deviation_Bar = MainPanel:get_argument_value(372) -- -1 to 1
	local KPP_2_Alt_Deviation_Bar = MainPanel:get_argument_value(371) -- -1 to 1
	local KPP_2_Glide_Beacon = MainPanel:get_argument_value(373) -- 0 to 1
	local KPP_2_Localizer_Beacon = MainPanel:get_argument_value(374) -- 0 to 1
	local KPP_2_Arretir = MainPanel:get_argument_value(366) -- 0 to 1
	local KPP_SDU_Roll_Aft = MainPanel:get_argument_value(369) -- -1 to 1
	local KPP_SDU_Pitch_Aft = MainPanel:get_argument_value(370) -- -1 to 1
-- NPP (HSI)
	local HSI_heading = MainPanel:get_argument_value(41) -- 1 to 0
	local HSI_commanded_course_needle = MainPanel:get_argument_value(42) -- 1 to 0
	local HSI_bearing_needle = MainPanel:get_argument_value(43) -- 0 to 1
	local HSI_Course_Deviation_Bar = MainPanel:get_argument_value(47) -- -0.8 to 0.8
	local HSI_Alt_Deviation_Bar = MainPanel:get_argument_value(45) -- -0.8 to 0.8
	local HSI_Glide_Beacon = MainPanel:get_argument_value(46) -- 0 to 1
	local HSI_Localizer_Beacon = MainPanel:get_argument_value(44) -- 0 to 1
-- NPP 2 (HSI)
	local HSI2_heading = MainPanel:get_argument_value(378) -- 1 to 0
	local HSI2_commanded_course_needle = MainPanel:get_argument_value(379) -- 0 to 1  error ??
	local HSI2_bearing_needle = MainPanel:get_argument_value(380) -- 0 to 1
	local HSI2_Course_Deviation_Bar = MainPanel:get_argument_value(384) -- -0.8 to 0.8
	local HSI2_Alt_Deviation_Bar = MainPanel:get_argument_value(382) -- -0.8 to 0.8
	local HSI2_Glide_Beacon = MainPanel:get_argument_value(383) -- 0 to 1
	local HSI2_Localizer_Beacon = MainPanel:get_argument_value(381) -- 0 to 1
--RSBN
	local RSBN_NAV_Chan = MainPanel:get_argument_value(189) -- 0 to 1
	local RSBN_LAND_Chan = MainPanel:get_argument_value(190) -- 0 to 1
	local RSBN_Range_100 = MainPanel:get_argument_value(66) -- 0 to 1
	local RSBN_Range_10 = MainPanel:get_argument_value(65) -- 0 to 1
	local RSBN_Range_1 = MainPanel:get_argument_value(64) -- 0 to 1
	local RSBN_Range_2_100 = MainPanel:get_argument_value(404) -- 0 to 1
	local RSBN_Range_2_10 = MainPanel:get_argument_value(403) -- 0 to 1
	local RSBN_Range_2_1 = MainPanel:get_argument_value(402) -- 0 to 1
	local RSBN_PanelLightsLmp = MainPanel:get_argument_value(580) -- 0 to 1
-- Altimeter Feet imperial
	local Altimeter_100_footPtr = MainPanel:get_argument_value(637) -- 0 to 1
	local Altimeter_10000_footCount = MainPanel:get_argument_value(632) -- 0 to 1
	local Altimeter_1000_footCount = MainPanel:get_argument_value(631) -- 0 to 1
	local Altimeter_100_footCount = MainPanel:get_argument_value(630) -- 0 to 1
	local pressure_setting_0 = MainPanel:get_argument_value(636) -- 0 to 1
	local pressure_setting_1 = MainPanel:get_argument_value(635) -- 0 to 1
	local pressure_setting_2 = MainPanel:get_argument_value(634) -- 0 to 1
	local pressure_setting_3 = MainPanel:get_argument_value(633) -- 0 to 1
-- Altimeter Feet instructor imperial
	local Altimeter_100_footPtr_2 = MainPanel:get_argument_value(737) -- 0 to 1
	local Altimeter_10000_footCount_2 = MainPanel:get_argument_value(732) -- 0 to 1
	local Altimeter_1000_footCount_2 = MainPanel:get_argument_value(731) -- 0 to 1
	local Altimeter_100_footCount_2 = MainPanel:get_argument_value(730) -- 0 to 1
	local pressure_setting_0_2 = MainPanel:get_argument_value(736) -- 0 to 1
	local pressure_setting_1_2 = MainPanel:get_argument_value(735) -- 0 to 1
	local pressure_setting_2_2 = MainPanel:get_argument_value(734) -- 0 to 1
-- Barometric altimeter VD-20
	local VD_20_km = MainPanel:get_argument_value(52) -- 0 to 1
	local VD_20_m = MainPanel:get_argument_value(53) -- 0 to 1
	local VD_20_km_Ind = MainPanel:get_argument_value(54) -- 0 to 1
	local VD_20_m_Ind = MainPanel:get_argument_value(55) -- 0 to 1
	local VD_20_PRESS = MainPanel:get_argument_value(56) -- 0 to 1
-- Barometric altimeter VD-20 instructor
	local VD_20_km_2 = MainPanel:get_argument_value(389) -- 0 to 1
	local VD_20_m_2 = MainPanel:get_argument_value(390) -- 0 to 1
	local VD_20_km_Ind_2 = MainPanel:get_argument_value(391) -- 0 to 1
	local VD_20_m_Ind_2 = MainPanel:get_argument_value(392) -- 0 to 1
	local VD_20_PRESS_2 = MainPanel:get_argument_value(393) -- 0 to 1
--AIRSPEED AND MACH
	local IAS = MainPanel:get_argument_value(49) 
	local TAS = MainPanel:get_argument_value(50) 
	local MACH = MainPanel:get_argument_value(51) -- 0 to 1
	local IAS_2 = MainPanel:get_argument_value(386) 
	local TAS_2 = MainPanel:get_argument_value(387) 
	local MACH_2 = MainPanel:get_argument_value(388) -- 0 to 1
-- RKL-41
	local RKL_41_needle = MainPanel:get_argument_value(77) 		-- 0 to 1
	local RKL_41_2_needle = MainPanel:get_argument_value(420) 	-- 0 to 1
	local RKL_41_Signal = MainPanel:get_argument_value(156) 	-- 0 to 1
	local RKL_41_2_Signal = MainPanel:get_argument_value(513) 	-- 0 to 1
	local KM_8_heading = MainPanel:get_argument_value(531) 		-- 0 to 1
	local KM_8_variation = MainPanel:get_argument_value(530) 	-- 1 to -1
-- electric interface
	local Voltmeter = MainPanel:get_argument_value(92) 		-- 0 to 1
	local Ampermeter = MainPanel:get_argument_value(93) 	-- 0 to 1
-- oxygen interface
	local FwdOxygenPressure = Helios_Util.ValueConvert(MainPanel:get_argument_value(301),{0.0,	10.0,	150.0,	160.0},{0.0,	0.025,	0.925,	1.0})
	local FwdFlowBlinker = MainPanel:get_argument_value(302) 		-- 0 to 1
	local AftOxygenPressure = Helios_Util.ValueConvert(MainPanel:get_argument_value(477),{0.0,	10.0,	150.0,	160.0},{0.0,	0.025,	0.925,	1.0})
	local AftFlowBlinker = MainPanel:get_argument_value(478) 		-- 0 to 1
-- accelerometer
	local Acceleration = MainPanel:get_argument_value(86) 		-- 0 to 1
	local AccelerationMin = MainPanel:get_argument_value(88) 	-- 0.31 to 0.695
	local AccelerationMax = MainPanel:get_argument_value(87) 	-- 0 to 1
	local CockpitAltFwd = MainPanel:get_argument_value(95) 		-- 0 to 1
	local CockpitAltAft = MainPanel:get_argument_value(550) 	-- 0 to 1
	local PressDiffFwd = MainPanel:get_argument_value(96) 	-- 0 to 1
	local PressDiffAft = MainPanel:get_argument_value(551) 	-- 0 to 1
---Hydro Pressure
	local MainHydro_PRESS = MainPanel:get_argument_value(198) 		-- 0 to 1
	local AuxHydro_PRESS = MainPanel:get_argument_value(200) 		-- 0 to 1
	local BrakeLMainHydro_PRESS = MainPanel:get_argument_value(98) 	-- 0 to 1
	local BrakeRMainHydro_PRESS = MainPanel:get_argument_value(99) 	-- 0 to 1
	local BrakeAuxHydro_PRESS = MainPanel:get_argument_value(100) 	-- 0 to 1
-- fuel and engines
	local Fuel_Quantity = MainPanel:get_argument_value(91) 	-- 0 to 1 simplyfied
	local Fan_RPM = MainPanel:get_argument_value(85) 		-- 0 to 1 simplyfied
	local Compressor_RPM = MainPanel:get_argument_value(84) -- 0 to 1 simplyfied
	local Oil_Temp = MainPanel:get_argument_value(83) 		-- 0 to 1 simplyfied
	local Oil_Press = MainPanel:get_argument_value(82) 		-- 0 to 1 simplyfied
	local Fuel_Press = MainPanel:get_argument_value(81) 	-- 0 to 1 simplyfied
	local Engine_Temp = MainPanel:get_argument_value(90) 	-- 0 to 1 simplyfied
	local EngineVibration = MainPanel:get_argument_value(94) 	-- 0 to 1
	local PitchTrimInd = MainPanel:get_argument_value(247) 	-- 1 to -1
-- fuel and engines 2
	local Fuel_Quantity_2 = MainPanel:get_argument_value(427) 	-- 0 to 1 simplyfied
	local Fan_RPM_2 = MainPanel:get_argument_value(425) 		-- 0 to 1 simplyfied
	local Compressor_RPM_2 = MainPanel:get_argument_value(424) 	-- 0 to 1 simplyfied
	local Oil_Temp_2 = MainPanel:get_argument_value(423) 		-- 0 to 1 simplyfied
	local Oil_Press_2 = MainPanel:get_argument_value(422) 		-- 0 to 1 simplyfied
	local Fuel_Press_2 = MainPanel:get_argument_value(421) 		-- 0 to 1 simplyfied
	local Engine_Temp_2 = MainPanel:get_argument_value(426) 	-- 0 to 1 simplyfied
-- lights system
	local FwdCptInstrumentLightsIntensity = MainPanel:get_argument_value(553) 	-- 0 to 1
	local CompassLightIntensity = MainPanel:get_argument_value(558) 	-- 0 to 1
	local EmergencyLightIntensity = MainPanel:get_argument_value(555) 	-- 0 to 1
	local AftCptInstrumentLightsIntensity = MainPanel:get_argument_value(559) 	-- 0 to 1
-- RKL-41 Radio Compass
	local FarNDBSelectorLamp = MainPanel:get_argument_value(561) 		-- 0 to 1
	local NearNDBSelectorLamp = MainPanel:get_argument_value(570) 		-- 0 to 1
	local FarNDBSelectorLamp_CPT2 = MainPanel:get_argument_value(564) 	-- 0 to 1
	local NearNDBSelectorLamp_CPT2 = MainPanel:get_argument_value(571) 	-- 0 to 1
	local RKL_FwdPanelLights = MainPanel:get_argument_value(563) 		-- 0 to 1
	local RKL_AftPanelLights = MainPanel:get_argument_value(566) 		-- 0 to 1
-- brake
	local BrakeHandle = MainPanel:get_argument_value(127) 		-- 0 to 1
	local BrakeHandle_CPT2 = MainPanel:get_argument_value(542) 		-- 0 to 1

	
	
	-- engine and oxigene instruments  >>> "SAI", "Pitch Adjust"
	
	Helios_Udp.Send("715", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.4f,%.2f,%.2f,%.2f,%.3f,%.3f,%.2f, %.2f",
			Fuel_Quantity, --1
			Fan_RPM, --2
			Compressor_RPM, --3
			Oil_Temp, --4
			Oil_Press, --5
			Fuel_Press, --6
			Engine_Temp, --7
			EngineVibration, --8
		PitchTrimInd, --9
			Voltmeter, --10
			Ampermeter, --11
			MainHydro_PRESS, --12
			AuxHydro_PRESS, --13
			BrakeLMainHydro_PRESS, --14
			BrakeRMainHydro_PRESS, --15
			BrakeAuxHydro_PRESS, --16
			FwdOxygenPressure, --17
			FwdFlowBlinker, --18
		AftOxygenPressure, --19
		AftFlowBlinker, --20
		Fuel_Quantity_2, --21
		Fan_RPM_2, --22
		Compressor_RPM_2, --23
		Oil_Temp_2, --24
		Oil_Press_2, --25
		Fuel_Press_2, --26
		Engine_Temp_2, --27
		_LAST_ONE  -- Last one, do not delete this
	) )
		
	
	-- clock and voltimeter  	>>> "ADI", "Glide Slope Indicator"
	Helios_Udp.Send("27", string.format("%.3f,%.3f,%.3f,%.2f,%.3f,%3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f, %.3f,%.2f",
			CLOCK_currtime_hours, --1
			CLOCK_currtime_minutes, --2
			CLOCK_seconds_meter_time_seconds, --3
			CLOCK_flight_time_meter_status, --4
			CLOCK_flight_hours, --5
			CLOCK_flight_minutes, --6
			CLOCK_seconds_meter_time_minutes, --7
		CLOCK_2_currtime_hours, --8
		CLOCK_2_currtime_minutes, --9
		CLOCK_2_seconds_meter_time_seconds, --10
		CLOCK_2_flight_time_meter_status, --11
		CLOCK_2_flight_hours, --12
		CLOCK_2_flight_minutes, --13
		CLOCK_2_seconds_meter_time_minutes, --14
		Voltmeter, --15
		_LAST_ONE  -- Last one, do not delete this
	) )
			

	-- RALT, variometer and RKL  	>>> "ADI", "Slip Ball"
	Helios_Udp.Send("24", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f,%.2f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
			RV_5_RALT, --1
			RV_5_DangerRALT_index, --2
			RV_5_DangerRALT_lamp, --3
			RV_5_warning_flag, --4
		RV_5_2_RALT, --5
		RV_5_2_DangerRALT_index, --6
		RV_5_2_DangerRALT_lamp, --7
		RV_5_2_warning_flag, --8
			Variometer, --9 
			Variometer_sideslip, --10
			Variometer_turn, --11
		Variometer_2, --12
		Variometer_2_sideslip, --13
		Variometer_2_turn, --14
			RKL_41_needle, --15
		RKL_41_2_needle, --16
			RKL_41_Signal, --17
		RKL_41_2_Signal, --18
		RKL_FwdPanelLights, --19
		RKL_AftPanelLights, --20
		KM_8_heading, --21
		KM_8_variation, --22
		_LAST_ONE  -- Last one, do not delete this
	) )
		
		-- Kpp >>>	"ADI", "Pitch Steering Bar Offset"
	Helios_Udp.Send("21", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f,%.2f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
			KPP_1273K_roll, --1
			KPP_1273K_pitch, --2
		KPP_1273K_sideslip, --3
			KPP_Course_Deviation_Bar, --4
			KPP_Alt_Deviation_Bar, --5
		KPP_Glide_Beacon, --6
		KPP_Localizer_Beacon, --7
			KPP_Arretir, --8
			KPP_SDU_Roll_Fwd, --9 
			KPP_SDU_Pitch_Fwd, --10
		KPP_1273K_2_roll, --11
		KPP_1273K2__pitch, --12
		KPP_1273K2__sideslip, --13
		KPP_2_Course_Deviation_Bar, --14
		KPP_2_Alt_Deviation_Bar, --15
		KPP_2_Glide_Beacon, --16
		KPP_2_Localizer_Beacon, --17
		KPP_2_Arretir, --18
		KPP_SDU_Roll_Aft, --19
		KPP_SDU_Pitch_Aft, --20
		_LAST_ONE  -- Last one, do not delete this
	) )
	

	
	-- HSI and RSBN >>>	"ADI", "Bank Steering Bar Offset"
	Helios_Udp.Send("20", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f,%.2f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
			HSI_heading, --1
			HSI_commanded_course_needle, --2
			HSI_bearing_needle, --3
			HSI_Course_Deviation_Bar, --4
			HSI_Alt_Deviation_Bar, --5
			HSI_Glide_Beacon, --6
			HSI_Localizer_Beacon, --7
		HSI2_heading, --8
		HSI2_commanded_course_needle, --9 
		HSI2_bearing_needle, --10
		HSI2_Course_Deviation_Bar, --11
		HSI2_Alt_Deviation_Bar, --12
		HSI2_Glide_Beacon, --13
		HSI2_Localizer_Beacon, --14
			RSBN_NAV_Chan, --15
			RSBN_LAND_Chan, --16
			RSBN_Range_100, --17
			RSBN_Range_10, --18
			RSBN_Range_1, --19
		RSBN_Range_2_100, --20
		RSBN_Range_2_10, --21
		RSBN_Range_2_1, --22
		RSBN_PanelLightsLmp, --23
		_LAST_ONE  -- Last one, do not delete this
	) )
	

	
	-- altimeter and speed >>>	"UHF Radio", "Fequency"
	Helios_Udp.Send("2000", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f,%.2f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
		Altimeter_100_footPtr, --1
		Altimeter_10000_footCount, --2
		Altimeter_1000_footCount, --3
		Altimeter_100_footCount, --4
		pressure_setting_0, --5
		pressure_setting_1, --6
		pressure_setting_2, --7
		pressure_setting_3, --8
		Altimeter_100_footPtr_2, --9 
		Altimeter_10000_footCount_2, --10
		Altimeter_1000_footCount_2, --11
		Altimeter_100_footCount_2, --12
		pressure_setting_0_2, --13
		pressure_setting_1_2, --14
		pressure_setting_2_2, --15
			IAS, --16
			TAS, --17
			MACH, --18
		IAS_2, --19
		TAS_2, --20
		MACH_2, --21
		_LAST_ONE  -- Last one, do not delete this
	) )
	
	-- Barometric altimeter, accelerometer >>>	"ADI", "Turn Needle"
	Helios_Udp.Send("23", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f,%.2f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
			VD_20_km, --1
			VD_20_m, --2
			VD_20_km_Ind, --3
			VD_20_m_Ind, --4
			VD_20_PRESS, --5
		VD_20_km_2, --6
		VD_20_m_2, --7
		VD_20_km_Ind_2, --8
		VD_20_m_Ind_2, --9 
		VD_20_PRESS_2, --10
			Acceleration, --11
			AccelerationMin, --12
			CockpitAltFwd, --13
		CockpitAltAft, --14
			PressDiffFwd, --15
		PressDiffAft, --16
			AccelerationMax, --17
		FwdCptInstrumentLightsIntensity, --18
		CompassLightIntensity, --19
		EmergencyLightIntensity, --20
		AftCptInstrumentLightsIntensity, --21
		NearNDBSelectorLamp_CPT2, --22
		_LAST_ONE  -- Last one, do not delete this
	) )
	
	Helios_Udp.Send("296", string.format("%.3f", mainPanelDevice:get_argument_value(209) )) 	-- GMK-1AE GMC Latitude Selector Knob 209 axis 0.02 > "Light System", "Flood Light"  296
	Helios_Udp.Send("46", string.format("%.1d", mainPanelDevice:get_argument_value(15)) )    -- BreakdownFinishedLampFwd              >  "HSI", "Bearing Flag" 

	
	Helios_Udp.Flush()
end

function Helios_L39.LowImportance(mainPanelDevice)
																	-- L39ZA  >  A10C
	--lamps
	Helios_Udp.Send("540", string.format("%.1d", mainPanelDevice:get_argument_value(18)) )    -- Marker_lamp                           >  "AOA Indexer", "High Indicator", "High AOA indicator light."
	Helios_Udp.Send("542", string.format("%.1d", mainPanelDevice:get_argument_value(6)) )     -- MainGen_lamp                          >  "AOA Indexer", "Low Indicator", "Low AOA indicator light."
	Helios_Udp.Send("730", string.format("%.1d", mainPanelDevice:get_argument_value(9)) )     -- ReserveGen_lamp                       >  "Refuel Indexer", "Ready Indicator", "Refuel ready indicator light."
	Helios_Udp.Send("731", string.format("%.1d", mainPanelDevice:get_argument_value(12)) )    -- Inverter115_lamp                      >  "Refuel Indexer", "Latched Indicator", "Refuel latched indicator light."
	Helios_Udp.Send("732", string.format("%.1d", mainPanelDevice:get_argument_value(16)) )    -- Inverter363_lamp                      >  "Refuel Indexer", "Disconnect Indicator", "Refuel disconnect indicator light."
	Helios_Udp.Send("662", string.format("%.1d", mainPanelDevice:get_argument_value(316)) )   -- GroundPower_lamp                      >  "Misc", "Gun Ready Indicator", "Indicator is lit when the GAU-8 cannon is armed and ready to fire."
	Helios_Udp.Send("216", string.format("%.1d", mainPanelDevice:get_argument_value(278)) )   -- FlapsUpLamp                           >  "Fire System", "APU Fire Indicator", "Indicator lights when a fire is detedted in the APU."
	Helios_Udp.Send("217", string.format("%.1d", mainPanelDevice:get_argument_value(279)) )   -- FlapsTOLamp                           >  "Fire System", "Right Engine Fire Indicator", "Indicator lights when a fire is detected in the right engine."
	Helios_Udp.Send("404", string.format("%.1d", mainPanelDevice:get_argument_value(280)) )   -- FlapsDnLamp                           >  "UFC", "Master Caution Indicator", "Indicator lamp on master caution button." 
	Helios_Udp.Send("659", string.format("%.1d", mainPanelDevice:get_argument_value(117)) )   -- AirBrakesLampFwd                      >  "Mechanical", "Gear Nose Safe Indicator", "Lit when the nose gear is down and locked."
	Helios_Udp.Send("661", string.format("%.1d", mainPanelDevice:get_argument_value(113)) )   -- GearDown_front                        >  "Mechanical", "Gear Right Safe Indicator", "Lit when the right gear is down and locked."
	Helios_Udp.Send("737", string.format("%.1d", mainPanelDevice:get_argument_value(112)) )   -- GearDown_left                         >  "Mechanical", "Gear Handle Indicator", "Lit when the landing gear are moving between down and stowed position."
	Helios_Udp.Send("606", string.format("%.1d", mainPanelDevice:get_argument_value(114)) )   -- GearDown_right                        >  "Navigation Mode Select Panel", "HARS Indicator", "HARS button indicator lamp."
	Helios_Udp.Send("608", string.format("%.1d", mainPanelDevice:get_argument_value(110)) )   -- GearUp_front                          >  "Navigation Mode Select Panel", "EGI Indicator", "EGI button indicator lamp."
	Helios_Udp.Send("610", string.format("%.1d", mainPanelDevice:get_argument_value(109)) )   -- GearUp_left                           >  "Navigation Mode Select Panel", "TISL Indicator", "TISL button indicator lamp."
	Helios_Udp.Send("612", string.format("%.1d", mainPanelDevice:get_argument_value(111)) )   -- GearUp_right                          >  "Navigation Mode Select Panel", "STEERPT Indicator", "STEERPT button indicator lamp."
	Helios_Udp.Send("614", string.format("%.1d", mainPanelDevice:get_argument_value(115)) )   -- ExtendGears                           >  "Navigation Mode Select Panel", "ANCHR Indicator", "ANCHR button indicator lamp."
	Helios_Udp.Send("616", string.format("%.1d", mainPanelDevice:get_argument_value(116)) )   -- DoorsOut                              >  "Navigation Mode Select Panel", "TCN Indicator", "TCN button indicator lamp."
	Helios_Udp.Send("484", string.format("%.1d", mainPanelDevice:get_argument_value(185)) )   -- RSBN_Azimuth_Correction               >  "Caution Panel", "ANTI SKID", "Lit if landing gear is down but anti-skid is disengaged."
	Helios_Udp.Send("485", string.format("%.1d", mainPanelDevice:get_argument_value(186)) )   -- RSBN_Range_Correction                 >  "Caution Panel", "L-HYD RES", "Lit if left hyudraulic fluid reservoir is low."
	--Helios_Udp.Send("46", string.format("%.1d", mainPanelDevice:get_argument_value(15)) )    -- BreakdownFinishedLampFwd     SENDED in HIGH priority             >  "HSI", "Bearing Flag" 
	Helios_Udp.Send("488", string.format("%.1d", mainPanelDevice:get_argument_value(123)) )   -- GMK_GA_Tilt_Lamp                      >  "Caution Panel", "ELEV DISENG", "Lit if at least one elevator is disengaged from the Emergency Flight Control panel."
	Helios_Udp.Send("489", string.format("%.1d", mainPanelDevice:get_argument_value(206)) )   -- GMK_GA_Tilt_Lamp PU26                     >  "Caution Panel", "VOID1", ""
	Helios_Udp.Send("491", string.format("%.1d", mainPanelDevice:get_argument_value(2)) )     -- DangerAltitude_lamp                   >  "Caution Panel", "BLEED AIR LEAK", "Lit if bleed air is 400 degrees or higher."
	Helios_Udp.Send("493", string.format("%.1d", mainPanelDevice:get_argument_value(27)) )    -- EmergFuelFwd_lamp                     >  "Caution Panel", "L-AIL TAB", "Lit if left aileron is not at normal positoin due to MRFCS."
	Helios_Udp.Send("495", string.format("%.1d", mainPanelDevice:get_argument_value(23)) )    -- TurboStarter_lamp                     >  "Caution Panel", "SERVICE AIR HOT", "Lit if air temperature exceeds allowable ECS range."
	Helios_Udp.Send("496", string.format("%.1d", mainPanelDevice:get_argument_value(4)) )     -- FwdRemain150_lamp                     >  "Caution Panel", "PITCH SAS", "Lit if at least one pitch SAS channel has been disabled."
	Helios_Udp.Send("497", string.format("%.1d", mainPanelDevice:get_argument_value(7)) )     -- FwdDoNotStart_lamp                    >  "Caution Panel", "L-ENG HOT", "Lit if left engine ITT exceeds 880 degrees C."
	Helios_Udp.Send("498", string.format("%.1d", mainPanelDevice:get_argument_value(26)) )    -- FwdFuelFilter_lamp                    >  "Caution Panel", "R-ENG HOT", "Lit if right engine ITT exceeds 880 degrees C."
	Helios_Udp.Send("499", string.format("%.1d", mainPanelDevice:get_argument_value(14)) )    -- FwdWingTanks_lamp                     >  "Caution Panel", "WINDSHIELD HOT", "Lit if windshield temperature exceeds 150 degrees F."
	Helios_Udp.Send("504", string.format("%.1d", mainPanelDevice:get_argument_value(246)) )   -- TrimmerRollNeutralFwd_lamp            >  "Caution Panel", "GCAS", "Lit if LASTE failure is detected that affects GCAS."
	Helios_Udp.Send("507", string.format("%.1d", mainPanelDevice:get_argument_value(3)) )     -- MachMeterLampFwd                      >  "Caution Panel", "VOID2", ""
	Helios_Udp.Send("509", string.format("%.1d", mainPanelDevice:get_argument_value(10)) )    -- FwdCanopyNotClosed                    >  "Caution Panel", "L-WING PUMP", "Lit if boost pump pressure is low."
	Helios_Udp.Send("511", string.format("%.1d", mainPanelDevice:get_argument_value(556)) )   -- LeftPitot_lamp                        >  "Caution Panel", "HARS", "Lit if44,  HARS heading or attitude is invalid."
	Helios_Udp.Send("512", string.format("%.1d", mainPanelDevice:get_argument_value(557)) )   -- RightPitot_lamp                       >  "Caution Panel", "IFF MODE-4", "Lit if inoperative mode 4 capability is detected."
	Helios_Udp.Send("513", string.format("%.1d", mainPanelDevice:get_argument_value(8)) )     -- FwdVibration_lamp                     >  "Caution Panel", "L-MAIN FUEL LOW", "Lit if left main fuel tank has 500 pounds or less."
	Helios_Udp.Send("515", string.format("%.1d", mainPanelDevice:get_argument_value(1)) )     -- FwdFire_lamp                          >  "Caution Panel", "L-R TKS UNEQUAL", "Lit if thers is a 750 or more pund difference between the two main fuel tanks."
	Helios_Udp.Send("517", string.format("%.1d", mainPanelDevice:get_argument_value(28)) )    -- FwdEngineTemperature700_lamp          >  "Caution Panel", "L-FUEL PRESS", "Lit if low fuel pressure is detected in fuel feed lines."
	Helios_Udp.Send("518", string.format("%.1d", mainPanelDevice:get_argument_value(24)) )    -- FwdEngineTemperature730_lamp          >  "Caution Panel", "R-FUEL PRESS", "Lit if low fuel pressure is detected in fuel feed lines."
	Helios_Udp.Send("519", string.format("%.1d", mainPanelDevice:get_argument_value(20)) )    -- FwdEngineMinOilPressure_lamp          >  "Caution Panel", "NAV", "Lit if there is a CDU failure while in alignment mode."
	Helios_Udp.Send("520", string.format("%.1d", mainPanelDevice:get_argument_value(359)) )   -- RSBN_Azimuth_Correction               >  "Caution Panel", "STALL SYS", "Lit if there is a power failure to the AoA and Mach meters."
	Helios_Udp.Send("521", string.format("%.1d", mainPanelDevice:get_argument_value(362)) )   -- RSBN_Range_Correction                 >  "Caution Panel", "L-CONV", "Lit if left electrical converter fails."
	Helios_Udp.Send("522", string.format("%.1d", mainPanelDevice:get_argument_value(19)) )    -- HSI_manual_accordance                 >  "Caution Panel", "R-CONV", "Lit if right electrical converter fails."
	Helios_Udp.Send("523", string.format("%.1d", mainPanelDevice:get_argument_value(11)) )    -- FwdCockpitPressure_lamp               >  "Caution Panel", "CADC", "Lit if CADC has failed."
	Helios_Udp.Send("525", string.format("%.1d", mainPanelDevice:get_argument_value(22)) )    -- FwdConditioningClosed_lamp            >  "Caution Panel", "L-GEN", "Lit if left generator has shut down or AC power is out of limits."
	Helios_Udp.Send("527", string.format("%.1d", mainPanelDevice:get_argument_value(25)) )    -- FwdDefrost_lamp                       >  "Caution Panel", "INST INV", "Lit if AC powered systems are not receiving power from inverter."
	Helios_Udp.Send("191", string.format("%.1d", mainPanelDevice:get_argument_value(21)) )    -- FwdIce_lamp                           >  "Autopilot", "Take Off Trim Indicator", "Lit when reseting autopilot for take off trim"
	Helios_Udp.Send("799", string.format("%.1d", mainPanelDevice:get_argument_value(182)) )   -- RIO_HeatingOk_lamp                    >  "IFF", "Test Lamp", ""
	Helios_Udp.Send("178", string.format("%.1d", mainPanelDevice:get_argument_value(5)) )     -- FwdHydraulicPressureDrop_lamp         >  "Autopilot", "Left Aileron Disengage Indicator", "Lit when the left aileron is disengaged."
	Helios_Udp.Send("181", string.format("%.1d", mainPanelDevice:get_argument_value(253)) )   -- FwdMasterDanger_lamp                  >  "Autopilot", "Left Elevator Disengage Indicator", "Lit when the left elevator is disengaged."
	Helios_Udp.Send("55", string.format("%.1d", mainPanelDevice:get_argument_value(17)) )     -- EmergConditioning_lamp                >  "AOA", "Off Flag", ""
	--Helios_Udp.Send("25", string.format("%.1d", mainPanelDevice:get_argument_value(562)) )    -- FwdRadioUnderControl_lamp             > 
	Helios_Udp.Send("25", string.format("%.1d", mainPanelDevice:get_argument_value(299)) )    -- FLT_recoder_lamp             >  "ADI", "Attitude Warning Flag", "Indicates that the ADI has lost electrical power or otherwise been disabled."

	Helios_Udp.Send("26", string.format("%.1d", mainPanelDevice:get_argument_value(13)) )     -- FwdEmptyWingFuelTanks_lamp only L39za >  "ADI", "Glide Slope Warning Flag", "Indicates that the ADI is not recieving a ILS glide slope signal."
	Helios_Udp.Send("40", string.format("%.1d", mainPanelDevice:get_argument_value(561)) )    -- FarNDBSelectorLamp                    > "HSI", "Power Off Flag"
	Helios_Udp.Send("32", string.format("%.1d", mainPanelDevice:get_argument_value(570)) )    -- NearNDBSelectorLamp                   > "HSI", "Range Flag"

	Helios_Udp.Send("541", string.format("%.1d", mainPanelDevice:get_argument_value(358)) )   -- MarkerInstructor_lamp                 >  "AOA Indexer", "Normal Indicator", "Norm AOA indidcator light."
	Helios_Udp.Send("663", string.format("%.1d", mainPanelDevice:get_argument_value(347)) )   -- MainGen_Instructor_lamp               >  "Misc", "Nose Wheel Steering Indicator", "Indicator is lit when nose wheel steering is engaged."
	Helios_Udp.Send("665", string.format("%.1d", mainPanelDevice:get_argument_value(350)) )   -- ReserveGen_Instructor_lamp            >  "Misc", "Canopy Unlocked Indicator", "Indicator is lit when canopy is open."
	Helios_Udp.Send("664", string.format("%.1d", mainPanelDevice:get_argument_value(353)) )   -- Inverter115_Instructor_lamp           >  "Misc", "Marker Beacon Indicator", "Indicator is lit when in ILS mode and a beacon is overflown."
	Helios_Udp.Send("215", string.format("%.1d", mainPanelDevice:get_argument_value(357)) )   -- Inverter363_Instructor_lamp           >  "Fire System", "Left Engine Fire Indicator", "Indicator lights when a fire is detected in the left engine."
	Helios_Udp.Send("372", string.format("%.1d", mainPanelDevice:get_argument_value(462)) )   -- FlapsUpLamp2                          >  "CMSC", "Missle Launch Indicator", "Flashes when missile has been launched near your aircraft."
	Helios_Udp.Send("373", string.format("%.1d", mainPanelDevice:get_argument_value(463)) )   -- FlapsTOLamp2                          >  "CMSC", "Priority Status Indicator", "Lit when priority display mode is active."
	Helios_Udp.Send("374", string.format("%.1d", mainPanelDevice:get_argument_value(464)) )   -- FlapsDnLamp2                          >  "CMSC", "Unknown Status Indicator", "Lit when unknown threat display is active."
	Helios_Udp.Send("660", string.format("%.1d", mainPanelDevice:get_argument_value(436)) )   -- AirBrakesLampAft                      >  "Mechanical", "Gear Left Safe Indicator", "Lit when the left gear is down and locked."
	Helios_Udp.Send("618", string.format("%.1d", mainPanelDevice:get_argument_value(432)) )   -- GearDown_front2                       >  "Navigation Mode Select Panel", "ILS Indicator", "ILS button indicator lamp."
	Helios_Udp.Send("619", string.format("%.1d", mainPanelDevice:get_argument_value(431)) )   -- GearDown_left2                        >  "Navigation Mode Select Panel", "UHF Homing Indicator", "Lit when the UHF control panel is ste to ADF."
	Helios_Udp.Send("620", string.format("%.1d", mainPanelDevice:get_argument_value(433)) )   -- GearDown_right2                       >  "Navigation Mode Select Panel", "VHF/FM Homing Indicator", "Lit when the VHF/FM control panel is set to homing mode."
	Helios_Udp.Send("600", string.format("%.1d", mainPanelDevice:get_argument_value(429)) )   -- GearUp_front2                         >  "Oxygen System", "Breathflow", "Flashs with each breath."
	Helios_Udp.Send("480", string.format("%.1d", mainPanelDevice:get_argument_value(428)) )   -- GearUp_left2                          >  "Caution Panel", "ENG START CYCLE", "Lit if either engine is in engine start process."
	Helios_Udp.Send("481", string.format("%.1d", mainPanelDevice:get_argument_value(430)) )   -- GearUp_right2                         >  "Caution Panel", "L-HYD PRESS", "Lit if left hydraulic system pressure falls below 1,000 psi."
	Helios_Udp.Send("482", string.format("%.1d", mainPanelDevice:get_argument_value(434)) )   -- ExtendGears2                          >  "Caution Panel", "R-HYD PRESS", "Lit if right hydraulic system pressure falls below 1,000 psi."
	Helios_Udp.Send("483", string.format("%.1d", mainPanelDevice:get_argument_value(435)) )   -- DoorsOut2                             >  "Caution Panel", "GUN UNSAFE", "Lit if gun is capable of being fired."
	Helios_Udp.Send("487", string.format("%.1d", mainPanelDevice:get_argument_value(356)) )   -- BreakdownFinishedLampAft              >  "Caution Panel", "OXY LOW", "Lit if oxygen gauge indices 0.5 liters or less."
	Helios_Udp.Send("490", string.format("%.1d", mainPanelDevice:get_argument_value(443)) )   -- GMK_GA_Tilt_Lamp 2                     >  "Caution Panel", "SEAT NOT ARMED", "Lit if ground safety lever is in the safe position."
	Helios_Udp.Send("492", string.format("%.1d", mainPanelDevice:get_argument_value(343)) )   -- DangerAltitudeInstructor_lamp         >  "Caution Panel", "AIL DISENG", "Lit if at least one aileron is disngaged from the Emergency FLight Control panel."
	Helios_Udp.Send("494", string.format("%.1d", mainPanelDevice:get_argument_value(365)) )   -- EmergFuelAft_lamp                     >  "Caution Panel", "R-AIL TAB", "Lit if right aileron is not at normal positoin due to MRFCS."
	Helios_Udp.Send("500", string.format("%.1d", mainPanelDevice:get_argument_value(345)) )   -- AftRemain150_lamp                     >  "Caution Panel", "YAW SAS", "Lit if at least one yaw SAS channel has been disabled."
	Helios_Udp.Send("501", string.format("%.1d", mainPanelDevice:get_argument_value(348)) )   -- AftDoNotStart_lamp                    >  "Caution Panel", "L-ENG OIL PRESS", "Lit if left engine oil pressure is less than 27.5 psi."
	Helios_Udp.Send("502", string.format("%.1d", mainPanelDevice:get_argument_value(364)) )   -- AftFuelFilter_lamp                    >  "Caution Panel", "R-ENG OIL PRESS", "Lit if right engine oil pressure is less than 27.5 psi."
	Helios_Udp.Send("503", string.format("%.1d", mainPanelDevice:get_argument_value(355)) )   -- AftWingTanks_lamp                     >  "Caution Panel", "CICU", "Lit if ?."
	Helios_Udp.Send("505", string.format("%.1d", mainPanelDevice:get_argument_value(441)) )   -- TrimmerRollNeutralAft_lamp            >  "Caution Panel", "L-MAIN PUMP", "Lit if boost pump pressure is low."
	Helios_Udp.Send("506", string.format("%.1d", mainPanelDevice:get_argument_value(442)) )   -- TrimmerPitchNeutralAft_lamp           >  "Caution Panel", "R-MAIN PUMP", "Lit if boost pump pressure is low."
	Helios_Udp.Send("508", string.format("%.1d", mainPanelDevice:get_argument_value(344)) )   -- MachMeterLampAft                      >  "Caution Panel", "LASTE", "Lit if fault is detected in LASTE computer."
	Helios_Udp.Send("510", string.format("%.1d", mainPanelDevice:get_argument_value(351)) )   -- AftCanopyNotClosed                    >  "Caution Panel", "R-WING PUMP", "Lit if boost pump pressure is low."
	Helios_Udp.Send("514", string.format("%.1d", mainPanelDevice:get_argument_value(349)) )   -- AftVibration_lamp                     >  "Caution Panel", "R-MAIN FUEL LOW", "Lit if right main fuel tank has 500 pounds or less."
	Helios_Udp.Send("516", string.format("%.1d", mainPanelDevice:get_argument_value(342)) )   -- AftFire_lamp                          >  "Caution Panel", "EAC", "Lit if EAC is turned off."
	Helios_Udp.Send("524", string.format("%.1d", mainPanelDevice:get_argument_value(352)) )   -- AftCockpitPressure_lamp               >  "Caution Panel", "APU GEN", "Lit if APU is on but APU generator is not set to PWR."
	Helios_Udp.Send("526", string.format("%.1d", mainPanelDevice:get_argument_value(361)) )   -- AftConditioningClosed_lamp            >  "Caution Panel", "R-GEN", "Lit if right generator has shut down or AC power is out of limits."
	Helios_Udp.Send("260", string.format("%.1d", mainPanelDevice:get_argument_value(363)) )   -- AftDefrost_lamp                       >  "TACAN", "Test Light", ""
	Helios_Udp.Send("798", string.format("%.1d", mainPanelDevice:get_argument_value(360)) )   -- AftIce_lamp                           >  "IFF", "Reply Lamp", ""
	Helios_Udp.Send("179", string.format("%.1d", mainPanelDevice:get_argument_value(346)) )   -- AftHydraulicPressureDrop_lamp         >  "Autopilot", "Right Aileron Disengage Indicator", "Lit when the right aileron is disengaged."
	Helios_Udp.Send("182", string.format("%.1d", mainPanelDevice:get_argument_value(455)) )   -- AftMasterDanger_lamp                  >  "Autopilot", "Right Elevator Disengage Indicator", "Lit when the right elevator is disengaged."
	Helios_Udp.Send("19", string.format("%.1d", mainPanelDevice:get_argument_value(565)) )    -- AftRadioUnderControl_lamp             >  "ADI", "Course Warning Flag", "Indicates thatn an operative ILS or TACAN signal is received."
	Helios_Udp.Send("65", string.format("%.1d", mainPanelDevice:get_argument_value(354)) )    -- AftEmptyWingFuelTanks_lamp only L39za >  "SAI", "Warning Flag", "Displayed when SAI is caged or non-functional."
	Helios_Udp.Send("486", string.format("%.1d", mainPanelDevice:get_argument_value(564)) )    -- FarNDBSelectorLamp_CPT2               > "Caution Panel", "R-HYD RES", "Lit if right hyudraulic fluid reservoir is low."


	-- weapons status lamps L39C
	Helios_Udp.Send("432", string.format("%.1f", mainPanelDevice:get_argument_value(261)) )   -- store_left 	>     "CDU", "8"
	Helios_Udp.Send("433", string.format("%.1f", mainPanelDevice:get_argument_value(262)) )   -- store_right	>     "CDU", "9"
	Helios_Udp.Send("434", string.format("%.1f", mainPanelDevice:get_argument_value(263)) )   -- explosive  	>     "CDU", "0"
	Helios_Udp.Send("435", string.format("%.1f", mainPanelDevice:get_argument_value(264)) )   -- cc_left 		>     "CDU", "Point"
	Helios_Udp.Send("436", string.format("%.1f", mainPanelDevice:get_argument_value(265)) )   -- cc_right 	>         "CDU", "Slash"
	Helios_Udp.Send("437", string.format("%.1f", mainPanelDevice:get_argument_value(266)) )   -- pus_0	   	>         "CDU", "A"
	Helios_Udp.Send("438", string.format("%.1f", mainPanelDevice:get_argument_value(251)) )   -- no_launch   	>     "CDU", "B"
	Helios_Udp.Send("439", string.format("%.1f", mainPanelDevice:get_argument_value(250)) )   -- stand_alert 	>     "CDU", "C"
	Helios_Udp.Send("440", string.format("%.1f", mainPanelDevice:get_argument_value(445)) )   -- store_left_aft	> "CDU", "D"
	Helios_Udp.Send("441", string.format("%.1f", mainPanelDevice:get_argument_value(446)) )   -- store_right_aft	> "CDU", "E"
	Helios_Udp.Send("442", string.format("%.1f", mainPanelDevice:get_argument_value(447)) )   -- cc_left_aft		> "CDU", "F"
	Helios_Udp.Send("443", string.format("%.1f", mainPanelDevice:get_argument_value(448)) )   -- cc_right_aft		> "CDU", "G"
	Helios_Udp.Send("444", string.format("%.1f", mainPanelDevice:get_argument_value(449)) )   -- stand_alert_aft	> "CDU", "H"
	Helios_Udp.Send("445", string.format("%.1f", mainPanelDevice:get_argument_value(450)) )   -- no_launch_aft	>     "CDU", "I"
	Helios_Udp.Send("446", string.format("%.1f", mainPanelDevice:get_argument_value(451)) )   -- explosive_aft	>     "CDU", "J"
	Helios_Udp.Send("447", string.format("%.1f", mainPanelDevice:get_argument_value(453)) )   -- glowing_cc		> "CDU", "K"
	Helios_Udp.Send("448", string.format("%.1f", mainPanelDevice:get_argument_value(454)) )   -- heating_cc		> "CDU", "L"
	Helios_Udp.Send("449", string.format("%.1f", mainPanelDevice:get_argument_value(452)) )   -- armament_fire	>     "CDU", "M"


	-- weapons status lamps only L39ZA
	Helios_Udp.Send("410", string.format("%.1f", mainPanelDevice:get_argument_value(626)) )   -- status_lamps.gsh23_block			>     "CDU", "LSK 3L"
	Helios_Udp.Send("411", string.format("%.1f", mainPanelDevice:get_argument_value(252)) )   -- status_lamps.explosive			>     "CDU", "LSK 5L"
	Helios_Udp.Send("412", string.format("%.1f", mainPanelDevice:get_argument_value(608)) )   -- status_lamps.pus_0	      		>     "CDU", "LSK 7L"
	Helios_Udp.Send("413", string.format("%.1f", mainPanelDevice:get_argument_value(609)) )   -- status_lamps.pus_0_inner			>     "CDU", "LSK 9L"
	Helios_Udp.Send("414", string.format("%.1f", mainPanelDevice:get_argument_value(266)) )   -- status_lamps.pus_0_bombs			>     "CDU", "LSK 3R"
	Helios_Udp.Send("415", string.format("%.1f", mainPanelDevice:get_argument_value(622)) )   -- status_lamps.store_left    		>     "CDU", "LSK 5R"
	Helios_Udp.Send("416", string.format("%.1f", mainPanelDevice:get_argument_value(623)) )   -- status_lamps.store_left_inboard  >      "CDU", "LSK 7R"
	Helios_Udp.Send("417", string.format("%.1f", mainPanelDevice:get_argument_value(624)) )   -- status_lamps.store_right_inboard >      "CDU", "LSK 9R"
	Helios_Udp.Send("418", string.format("%.1f", mainPanelDevice:get_argument_value(625)) )   -- status_lamps.store_right   		>     "CDU", "SYS"
	Helios_Udp.Send("419", string.format("%.1f", mainPanelDevice:get_argument_value(618)) )   -- payload_indicator 1         		>     "CDU", "NAV"
	Helios_Udp.Send("420", string.format("%.1f", mainPanelDevice:get_argument_value(619)) )   -- payload_indicator 2          	>         "CDU", "WP MENU"
	Helios_Udp.Send("421", string.format("%.1f", mainPanelDevice:get_argument_value(620)) )   -- payload_indicator 3              >      "CDU", "OFFSET"
	Helios_Udp.Send("422", string.format("%.1f", mainPanelDevice:get_argument_value(621)) )   -- payload_indicator 4              >      "CDU", "FPMENU"
	Helios_Udp.Send("423", string.format("%.1f", mainPanelDevice:get_argument_value(722)) )   -- aft_status_lamps.store_left    		> "CDU", "PREV"
	Helios_Udp.Send("425", string.format("%.1f", mainPanelDevice:get_argument_value(723)) )   -- aft_status_lamps.store_left_inboard  >  "CDU", "1"
	Helios_Udp.Send("426", string.format("%.1f", mainPanelDevice:get_argument_value(724)) )   -- aft_status_lamps.store_right_inboard >  "CDU", "2"
	Helios_Udp.Send("427", string.format("%.1f", mainPanelDevice:get_argument_value(725)) )   -- aft_status_lamps.store_right   		> "CDU", "3"
	Helios_Udp.Send("428", string.format("%.1f", mainPanelDevice:get_argument_value(718)) )   -- aft_payload_indicator 1         		> "CDU", "4"
	Helios_Udp.Send("429", string.format("%.1f", mainPanelDevice:get_argument_value(719)) )   -- aft_payload_indicator 2          	>     "CDU", "5"
	Helios_Udp.Send("430", string.format("%.1f", mainPanelDevice:get_argument_value(720)) )   -- aft_payload_indicator 3              >  "CDU", "6"
	Helios_Udp.Send("431", string.format("%.1f", mainPanelDevice:get_argument_value(721)) )   -- aft_payload_indicator 4              >  "CDU", "7"


	-- switches

	Helios_Udp.Send("327", string.format("%.1f", mainPanelDevice:get_argument_value(211) ) ) -- CB Air Conditioning, ON/OFF 211 sw 2 pos > "Right MFCD", "OSB2"  327
	Helios_Udp.Send("328", string.format("%.1f", mainPanelDevice:get_argument_value(212) ) ) -- CB Anti-Ice, ON/OFF 212 sw 2 pos >         "Right MFCD", "OSB3"  328
	Helios_Udp.Send("329", string.format("%.1f", mainPanelDevice:get_argument_value(213) ) ) -- CB Pitot Left, ON/OFF 213 sw 2 pos >       "Right MFCD", "OSB4"  329
	Helios_Udp.Send("330", string.format("%.1f", mainPanelDevice:get_argument_value(214) ) ) -- CB Pitot Right, ON/OFF 214 sw 2 pos >      "Right MFCD", "OSB5"  330
	Helios_Udp.Send("331", string.format("%.1f", mainPanelDevice:get_argument_value(215) ) ) -- CB PT-500C, ON/OFF 215 sw 2 pos >          "Right MFCD", "OSB6"  331
	Helios_Udp.Send("332", string.format("%.1f", mainPanelDevice:get_argument_value(216) ) ) -- CB ARC, ON/OFF 216 sw 2 pos >              "Right MFCD", "OSB7"  332
	Helios_Udp.Send("333", string.format("%.1f", mainPanelDevice:get_argument_value(217) ) ) -- CB SRO, ON/OFF 217 sw 2 pos >              "Right MFCD", "OSB8"  333
	Helios_Udp.Send("334", string.format("%.1f", mainPanelDevice:get_argument_value(218) ) ) -- CB Seat-Helmet, ON/OFF 218 sw 2 pos >      "Right MFCD", "OSB9"  334
	Helios_Udp.Send("335", string.format("%.1f", mainPanelDevice:get_argument_value(219) ) ) -- CB Gears, ON/OFF 219 sw 2 pos >            "Right MFCD", "OSB10" 335
	Helios_Udp.Send("336", string.format("%.1f", mainPanelDevice:get_argument_value(220) ) ) -- CB Control, ON/OFF 220 sw 2 pos >          "Right MFCD", "OSB11" 336
	Helios_Udp.Send("337", string.format("%.1f", mainPanelDevice:get_argument_value(221) ) ) -- CB Signaling, ON/OFF 221 sw 2 pos >        "Right MFCD", "OSB12" 337
	Helios_Udp.Send("338", string.format("%.1f", mainPanelDevice:get_argument_value(222) ) ) -- CB Nav. Lights, ON/OFF 222 sw 2 pos >      "Right MFCD", "OSB13" 338
	Helios_Udp.Send("339", string.format("%.1f", mainPanelDevice:get_argument_value(223) ) ) -- CB Spotlight Left, ON/OFF 223 sw 2 pos >   "Right MFCD", "OSB14" 339
	Helios_Udp.Send("340", string.format("%.1f", mainPanelDevice:get_argument_value(224) ) ) -- CB Spotlight Right, ON/OFF 224 sw 2 pos >  "Right MFCD", "OSB15" 340
	Helios_Udp.Send("341", string.format("%.1f", mainPanelDevice:get_argument_value(225) ) ) -- CB Red Lights, ON/OFF 225 sw 2 pos >       "Right MFCD", "OSB16" 341
	Helios_Udp.Send("342", string.format("%.1f", mainPanelDevice:get_argument_value(226) ) ) -- CB White Lights, ON/OFF 226 sw 2 pos >     "Right MFCD", "OSB17" 342
	Helios_Udp.Send("454", string.format("%.1f", mainPanelDevice:get_argument_value(227) ) ) -- CB Start Panel, ON/OFF 227 sw 2 pos >         "CDU", "R"   454
	Helios_Udp.Send("455", string.format("%.1f", mainPanelDevice:get_argument_value(228) ) ) -- CB Booster Pump, ON/OFF 228 sw 2 pos >        "CDU", "S"   455
	Helios_Udp.Send("456", string.format("%.1f", mainPanelDevice:get_argument_value(229) ) ) -- CB Ignition 1, ON/OFF 229 sw 2 pos >          "CDU", "T"   456
	Helios_Udp.Send("457", string.format("%.1f", mainPanelDevice:get_argument_value(230) ) ) -- CB Ignition 2, ON/OFF 230 sw 2 pos >          "CDU", "U"   457
	Helios_Udp.Send("458", string.format("%.1f", mainPanelDevice:get_argument_value(231) ) ) -- CB Engine Instruments, ON/OFF 231 sw 2 pos >  "CDU", "V"   458
	Helios_Udp.Send("459", string.format("%.1f", mainPanelDevice:get_argument_value(232) ) ) -- CB Fire, ON/OFF 232 sw 2 pos >                "CDU", "W"   459
	Helios_Udp.Send("460", string.format("%.1f", mainPanelDevice:get_argument_value(233) ) ) -- CB Emergency Jettison, ON/OFF 233 sw 2 pos >  "CDU", "X"   460
	Helios_Udp.Send("461", string.format("%.1f", mainPanelDevice:get_argument_value(234) ) ) -- CB SARPP, ON/OFF 234 sw 2 pos >               "CDU", "Y"   461
	Helios_Udp.Send("343", string.format("%.1f", mainPanelDevice:get_argument_value(243) ) ) -- RT-12 JPT Regulator Power Switch, ON/OFF 243 sw 2 pos > "Right MFCD", "OSB18" 343

	Helios_Udp.Send("122", string.format("%.1d", mainPanelDevice:get_argument_value(141) ) )     -- Battery Switch, ON/OFF 141 sw 2 pos > "Engine System", "Left Engine Fuel Flow Control" 122
	Helios_Udp.Send("123", string.format("%.1d", mainPanelDevice:get_argument_value(142) ) )     -- Main Generator Switch, ON/OFF 142 sw 2 pos > "Engine System", "Right Engine Fuel Flow Control" 123
	Helios_Udp.Send("126", string.format("%.1d", mainPanelDevice:get_argument_value(143) ) )     -- Emergency Generator Switch, ON/OFF 143 sw 2 pos > "Engine System", "APU" 126
	Helios_Udp.Send("106", string.format("%.1d", mainPanelDevice:get_argument_value(144) ) )     -- CB Engine Switch, ON/OFF 144 sw 2 pos > "Fuel System", "External Wing Tank Boost Pump" 106
	Helios_Udp.Send("107", string.format("%.1d", mainPanelDevice:get_argument_value(145) ) )     -- CB AGD-GMK Switch, ON/OFF 145 sw 2 pos > "Fuel System", "External Fuselage Tank Boost Pump" 107
	Helios_Udp.Send("108", string.format("%.1d", mainPanelDevice:get_argument_value(146) ) )     -- CB Inverter 1 (AC 115V) Switch, ON/OFF 146 sw 2 pos > "Fuel System", "Tank Gate" 108
	Helios_Udp.Send("109", string.format("%.1d", mainPanelDevice:get_argument_value(147) ) )     -- CB Inverter 2 (AC 115V) Switch, ON/OFF 147 sw 2 pos > "Fuel System", "Cross Feed" 109
	Helios_Udp.Send("110", string.format("%.1d", mainPanelDevice:get_argument_value(148) ) )     -- CB RDO (ICS and Radio) Switch, ON/OFF 148 sw 2 pos > "Fuel System", "Boost Pump Left Wing" 110
	Helios_Udp.Send("111", string.format("%.1d", mainPanelDevice:get_argument_value(149) ) )     -- CB MRP-RV (Marker Beacon Receiver and Radio Altimeter) Switch, ON/OFF 149 sw 2 pos > "Fuel System", "Boost Pump Right Wing" 111
	Helios_Udp.Send("112", string.format("%.1d", mainPanelDevice:get_argument_value(150) ) )     -- CB RSBN (ISKRA) Switch, ON/OFF 150 sw 2 pos > "Fuel System", "Boost Pump Main Fuseloge Left" 112
	Helios_Udp.Send("113", string.format("%.1d", mainPanelDevice:get_argument_value(151) ) )     -- CB IFF (SRO) Emergency Connection Switch, ON/OFF 151 sw 2 pos > "Fuel System", "Boost Pump Main Fuseloge Right" 113
	Helios_Udp.Send("114", string.format("%.1d", mainPanelDevice:get_argument_value(152) ) )     -- CB RSBN (ISKRA) Emergency Connection Switch, ON/OFF 152 sw 2 pos > "Fuel System", "Signal Amplifier" 114
	Helios_Udp.Send("120", string.format("%.1d", mainPanelDevice:get_argument_value(153) ) )     -- CB Wing Tanks Switch, ON/OFF" 153 sw 2 pos > "Fuel System", "Fill Disable Main Right" 120
	Helios_Udp.Send("121", string.format("%.1d", mainPanelDevice:get_argument_value(154) ) )     -- CB RIO-3 De-Icing Signal Switch, ON/OFF 154 sw 2 pos > "Fuel System", "Refuel Control Lever" 121
	Helios_Udp.Send("117", string.format("%.1d", mainPanelDevice:get_argument_value(155) ) )     -- CB SDU Switch, ON/OFF 155 sw 2 pos > "Fuel System", "Fill Disable Wing Left" 117
	Helios_Udp.Send("118", string.format("%.1d", mainPanelDevice:get_argument_value(628) ) )     -- CB Heating AOA Sensor Switch, ON/OFF 628 sw 2 pos --------SOLO L39ZA> "Fuel System", "Fill Disable Wing Right" 118
	Helios_Udp.Send("119", string.format("%.1d", mainPanelDevice:get_argument_value(629) ) )     -- CB Weapon Switch, ON/OFF 629 sw 2 pos > "Fuel System", "Fill Disable Main Left" 119
	Helios_Udp.Send("784", string.format("%.1d", mainPanelDevice:get_argument_value(177) ) )   	-- SDU Switch, ON/OFF 177 sw 2 pos > "KY-58 Secure Voice", "Power Switch" 784
	Helios_Udp.Send("780", string.format("%.1d", mainPanelDevice:get_argument_value(169) ) )   	-- Emergency Engine Instruments Power Switch, ON/OFF 169 sw 2 pos > "KY-58 Secure Voice", "Delay" 780

	Helios_Udp.Send("101", string.format("%.1f", mainPanelDevice:get_argument_value(124) ))	-- MC Synchronization Button - Push to synchronize (level flight only) 124 btn > "IFFCC", "Ext Stores Jettison" 101
	Helios_Udp.Send("130", string.format("%.1d", mainPanelDevice:get_argument_value(119) ) )   -- RKL-41 ADF Outer-Inner Beacon (Far-Near NDB) Switch 119 sw 2 pos > "Radar Altimeter", "Normal/Disabled" 130
	Helios_Udp.Send("170", string.format("%.1d", (mainPanelDevice:get_argument_value(204)/2)+0.5 )) -- GMK-1AE GMC Hemisphere Selection Switch, N(orth)/S(outh) 204 sw 2 pos >  "UHF Radio", "Squelch" 170
	Helios_Udp.Send("734", string.format("%.1d", (mainPanelDevice:get_argument_value(207)/2)+0.5 )) -- GMK-1AE GMC Mode Switch, MC(Magnetic Compass Mode)/GC(Directional Gyro Mode) 207 sw 2 pos >  "UHF Radio", "Cover" 734
	Helios_Udp.Send("204", string.format("%.1d", mainPanelDevice:get_argument_value(205) )) 	-- GMK-1AE GMC Test Switch, 0(degrees)/OFF/300(degrees) - Use to check heading indication accuracy 205 sw 3 pos -1 0 1> "IFF", "M-3/A Switch" 204
	Helios_Udp.Send("205", string.format("%.1d", mainPanelDevice:get_argument_value(208) )) 	-- GMK-1AE GMC Course Selector Switch, CCW/OFF/CW 208 sw 3 pos -1 0 1 >  "IFF", "M-C Switch" 205

	Helios_Udp.Send("351", string.format("%.1f", mainPanelDevice:get_argument_value(178) )) 	-- RSBN Mode Switch, LANDING/NAVIGATION/GLIDE PATH {0.0,0.1,0.2} 178 sw 3 pos > "Right MFCD", "Day/Night/Off" 351
	Helios_Udp.Send("300", string.format("%.1f", mainPanelDevice:get_argument_value(179) )) 	-- RSBN Identification Button 179 btn >       "Left MFCD", "OSB1" 300
	Helios_Udp.Send("301", string.format("%.1f", mainPanelDevice:get_argument_value(180) )) 	-- RSBN Test Button - Push to test 180 btn >  "Left MFCD", "OSB2" 301
	Helios_Udp.Send("288", string.format("%.1f", mainPanelDevice:get_argument_value(181) )) 	-- RSBN Control Box Lighting Intensity Knob 181 axis 0.04 0.0, 0.8 > "Light System", "Formation Lights" 288
	Helios_Udp.Send("292", string.format("%.3f", mainPanelDevice:get_argument_value(184) )) 	-- RSBN Volume Knob 184 axis 0.04 0.0, 0.8 > "Light System", "Flight Instruments Lights" 292
	Helios_Udp.Send("202", string.format("%.1d", mainPanelDevice:get_argument_value(187) )) 	-- Initial Azimuth 187 spr sw 3 pos -1.0,0.0,1.0> "IFF", "M-1 Switch" 202
	Helios_Udp.Send("203", string.format("%.1d", mainPanelDevice:get_argument_value(188) )) 	-- Initial Range 188 spr sw 3 pos -1.0,0.0,1.0>   "IFF", "M-2 Switch" 203
	Helios_Udp.Send("624", string.format("%.3f", mainPanelDevice:get_argument_value(191) )) 	-- RSBN Navigation Channel Selector Knob 191 multi sw 40 0.025 > "TISL", "Altitude above target tens of thousands of feet" 624
	Helios_Udp.Send("626", string.format("%.3f", mainPanelDevice:get_argument_value(192) )) 	-- RSBN Landing Channel Selector Knob 192 multi sw 40 0.025  >   "TISL", "Altitude above target thousands of feet" 626
	Helios_Udp.Send("303", string.format("%.1f", mainPanelDevice:get_argument_value(193) )) 	-- Set 0 Azimuth 193 btn > "Left MFCD", "OSB4" 303
	Helios_Udp.Send("308", string.format("%.1f", mainPanelDevice:get_argument_value(297) )) 	-- RSBN Listen Callsign Button - Push to listen 297 btn > "Left MFCD", "OSB9" 308
	Helios_Udp.Send("636", string.format("%.1f", mainPanelDevice:get_argument_value(157) )) 	-- RKL-41 ADF Volume Knob 157 axis 0.05 >     "TISL", "TISL Code Wheel 1" 636
	Helios_Udp.Send("638", string.format("%.1f", mainPanelDevice:get_argument_value(161) )) 	-- RKL-41 ADF Brightness Knob 161 axis 0.05 > "TISL", "TISL Code Wheel 2" 638
	Helios_Udp.Send("103", string.format("%.1d", mainPanelDevice:get_argument_value(159) )) 	-- RKL-41 ADF Mode Switch, TLF(A3)/TLG(A1,A2) 159 sw 2 pos > "Fire System", "APU Fire Pull" 103
	Helios_Udp.Send("364", string.format("%.1f", mainPanelDevice:get_argument_value(160) )) 	-- RKL-41 ADF Function Selector Switch, OFF/COMP(AUTO)/COMP(MAN)/ANT/LOOP 160 multi sw 5 pos 0.1 > "CMSP", "Mode Select Dial" 364 - 5 pos
	Helios_Udp.Send("105", string.format("%.1d", mainPanelDevice:get_argument_value(162) )) 	-- RKL-41 ADF Loop Switch, LEFT/OFF/RIGHT {-1.0,0.0,1.0} 162 spr sw 3 pos > "Fire System", "Discharge Switch" 105
	Helios_Udp.Send("104", string.format("%.1d", mainPanelDevice:get_argument_value(158) )) 	-- RKL-41 ADF Control Switch, TAKE CONTROL/HAND OVER CONTROL 158 sw 2 pos > "Fire System", "Right Engine Fire Pull" 104
	Helios_Udp.Send("640", string.format("%.3f", mainPanelDevice:get_argument_value(165) )) 	-- RKL-41 ADF Far NDB Frequency Tune 165 axis 0.05  > "TISL", "TISL Code Wheel 3" 640
	Helios_Udp.Send("642", string.format("%.3f", mainPanelDevice:get_argument_value(168) )) 	-- RKL-41 ADF Near NDB Frequency Tune 168 axis 0.05 > "TISL", "TISL Code Wheel 4" 642
	Helios_Udp.Send("277", string.format("%.3f", mainPanelDevice:get_argument_value(166) ))	-- RKL-41 ADF Near NDB 100kHz rotary 166  weel arc 0.0588 0.0,0.938  > "Environmental Control", "Canopy Defog" 277
	Helios_Udp.Send("284", string.format("%.3f", mainPanelDevice:get_argument_value(167) ))	-- RKL-41 ADF Near ND  10kHz rotary 167 weel arc 0.1 0.0,0.9 >         "Environmental Control", "Flow Level" 284
	Helios_Udp.Send("221", string.format("%.3f", mainPanelDevice:get_argument_value(163) ))	-- RKL-41 ADF Far NDB 100kHz rotary 163  weel arc 0.0588 0.0,0.938 > "Intercom", "INT Volume" 221
	Helios_Udp.Send("223", string.format("%.3f", mainPanelDevice:get_argument_value(164) ))	-- RKL-41 ADF Far NDB 10kHz rotary 164 weel arc 0.1 0.0,0.9 >        "Intercom", "FM Volume" 223
	Helios_Udp.Send("228", string.format("%.1d", mainPanelDevice:get_argument_value(314) )) 	-- Turbo Button Cover, Open/Close 314 sw 2 pos > "Intercom", "UHF Switch"228
	Helios_Udp.Send("313", string.format("%.1f", mainPanelDevice:get_argument_value(315) )) 	-- Turbo Button 315 btn > "Left MFCD", "OSB14" 313
	Helios_Udp.Send("230", string.format("%.1d", mainPanelDevice:get_argument_value(312) )) 	-- Stop Turbo Switch Cover, Open/Close 312 sw 2 pos > "Intercom", "AIM Switch" 230
	Helios_Udp.Send("222", string.format("%.1d", mainPanelDevice:get_argument_value(313) )) 	-- Stop Turbo Switch, ON/OFF 313 sw 2 pos > "Intercom", "INT Switch" 222
	Helios_Udp.Send("232", string.format("%.1d", mainPanelDevice:get_argument_value(325) )) 	-- Engine Button Cover, Open/Close 325 sw 2 pos > "Intercom", "IFF Switch" 232
	Helios_Udp.Send("314", string.format("%.1f", mainPanelDevice:get_argument_value(326) )) 	-- Engine Button 326 btn >  "Left MFCD", "OSB15" 314
	Helios_Udp.Send("234", string.format("%.1d", mainPanelDevice:get_argument_value(317) )) 	-- Stop Engine Switch Cover, Open/Close 317 sw 2 pos > "Intercom", "ILS Switch" 234
	Helios_Udp.Send("224", string.format("%.1d", mainPanelDevice:get_argument_value(318) )) 	-- Stop Engine Switch 318 sw 2 pos > Intercom", "FM Switch" 224
	Helios_Udp.Send("236", string.format("%.1d", mainPanelDevice:get_argument_value(321) )) 	-- Engine Start Mode Switch Cover, Open/Close 321 sw 2 pos > "Intercom", "TCN Switch" 236
	Helios_Udp.Send("169", string.format("%.1d", mainPanelDevice:get_argument_value(322) )) 	-- Engine Start Mode Switch, START/FALSE START/COLD CRANKING  322 sw 3 pos (-1.0,0.0,1.0 L39ZA) (0.0,0.1,0.2 L39C)> "UHF Radio", "T/Tone Switch" 169
	Helios_Udp.Send("237", string.format("%.1d", mainPanelDevice:get_argument_value(319) )) 	-- Emergency Fuel Switch Cover, Open/Close 319 sw 2 pos > "Intercom", "Hot Mic Switch" 237
	Helios_Udp.Send("226", string.format("%.1d", mainPanelDevice:get_argument_value(320) )) 	-- Emergency Fuel Switch 320 sw 2 pos > "Intercom", "VHF Switch" 226
	Helios_Udp.Send("309", string.format("%.1f", mainPanelDevice:get_argument_value(294) )) 	-- Standby (Left) Pitot Tube Heating Button - Push to turn heating on 294 btn >      "Left MFCD", "OSB10"  309
	Helios_Udp.Send("310", string.format("%.1f", mainPanelDevice:get_argument_value(295) )) 	-- Main (Right) Pitot Tube Heating Button - Push to turn heating on 295 btn >        "Left MFCD", "OSB11"  310
	Helios_Udp.Send("311", string.format("%.1f", mainPanelDevice:get_argument_value(292) )) 	-- Standby (Left) Pitot Tube Heating Off Button - Push to turn heating off 292 btn > "Left MFCD", "OSB12"  311
	Helios_Udp.Send("312", string.format("%.1f", mainPanelDevice:get_argument_value(293) )) 	-- Main (Right) Pitot Tube Heating Off Button - Push to turn heating off 293 btn >   "Left MFCD", "OSB13"  312
	Helios_Udp.Send("177", string.format("%.1d", (mainPanelDevice:get_argument_value(176)*2)-1 ))	-- Navigation Lights Mode Control Switch, FLICKER/OFF/FIXED  176 sw 3 pos 0.0,0.5,1.0 > "Autopilot", "Alieron Emergency Disengage" 177
	Helios_Udp.Send("201", string.format("%.1d", (mainPanelDevice:get_argument_value(175)*2)-1 )) 	-- Navigation Lights Intensity Control Switch, DIM(30%)/BRT(60%)/MAX(100%)  175 sw 3 pos 0.0,0.5,1.0> IFF", "Audio Light Switch" 201
	Helios_Udp.Send("206", string.format("%.1d", mainPanelDevice:get_argument_value(330) )) 	-- Instrument Lighting Switch, Red/OFF/White 330 sw 3 pos -1.0 0.0 1.0 > "IFF", "RAD Test/Monitor Switch" 206
	Helios_Udp.Send("102", string.format("%.1d", mainPanelDevice:get_argument_value(249) )) 	-- Emergency Instrument Light Switch, ON/OFF 249 sw 2 pos > "Fire System", "Left Engine Fire Pull" 102
	Helios_Udp.Send("293", string.format("%.1f", mainPanelDevice:get_argument_value(202) )) 	-- Warning-Light Intensity Knob 202 axis 0.1 > "Light System", "Auxillary instrument Lights" 293
	Helios_Udp.Send("304", string.format("%.1f", mainPanelDevice:get_argument_value(203) )) 	-- Warning-Light Check Button - Push to check 203 btn > "Left MFCD", "OSB5" 304
	rockets_firing_mode=mainPanelDevice:get_argument_value(271)
	if rockets_firing_mode >0.25 then rockets_firing_mode= 0.0 end
	Helios_Udp.Send("325", string.format("%.1f", rockets_firing_mode )) 	-- Rockets Firing Mode Selector Switch, AUT./2RS/4RS 271 multi sw 3 pos 0.3 0.1 0.2 > "Left MFCD", "Day/Night/Off" 325
	Helios_Udp.Send("381", string.format("%.1d", (mainPanelDevice:get_argument_value(260)/2) +0.5 )) 	-- Missile/Bomb Release Selector Switch, PORT(Left)/STARB-BOTH(Right for Missiles/Both) 260 sw 2 pos (1,-1)> "AHCP", "HUD Norm/Standbyh" 381
	Helios_Udp.Send("623", string.format("%.1d", (mainPanelDevice:get_argument_value(607)*2)-1 )) 	-- Pyro Charge Select 607 sw 3 pos 0.0,0.5,1.0 >  "TISL", "Slant Range" 623
	Helios_Udp.Send("621", string.format("%.1d", mainPanelDevice:get_argument_value(577) )) 	-- Charge Outer Guns 577 sw 2 pos > "Navigation Mode Select Panel", "Able - Stow" 621
	Helios_Udp.Send("380", string.format("%.1d", mainPanelDevice:get_argument_value(578) )) 	-- Charge Inner Guns 578 sw 2 pos > "AHCP", "HUD Day/Night" 380
	Helios_Udp.Send("644", string.format("%.1d", mainPanelDevice:get_argument_value(584) )) 	-- Bombs Series 584 sw 3 pos -1.0,0.0,1.0 > "TISL", "Code Select" 644
	Helios_Udp.Send("175", string.format("%.1d", mainPanelDevice:get_argument_value(303) )) 	-- Emergency Oxygen Switch, ON/OFF 303 sw 2 pos >   "Autopilot", "Pitch/Roll Emergency Override"  175
	Helios_Udp.Send("183", string.format("%.1d", mainPanelDevice:get_argument_value(304) )) 	-- Diluter Demand Switch, 100% / MIX 304 sw 2 pos > "Autopilot", "Flaps Emergency Retract"   183
	Helios_Udp.Send("184", string.format("%.1d", mainPanelDevice:get_argument_value(307) ))	-- Helmet Ventilation Switch, ON/OFF 307 sw 2 pos > "Autopilot", "Manual Reversion Flight Control System Switch" 184
	Helios_Udp.Send("174", string.format("%.1d", mainPanelDevice:get_argument_value(298) )) 	-- SARPP Flight Recorder, ON/OFF 298 sw 2 pos > "Autopilot", "Speed Brake Emergency Retract" 174
	Helios_Udp.Send("290", string.format("%.1f", mainPanelDevice:get_argument_value(173) )) 	-- Cabin Air Temperature Controller Rheostat 173 axis 0.1 > "Light System", "Engine Instrument Lights" 290
	Helios_Udp.Send("655", string.format("%.1f", mainPanelDevice:get_argument_value(174) ))	-- De-Icing Mode Switch, MANUAL/AUTOMATIC/OFF  174 sw 3 pos 0.0 0.1 0.2 > "Light System", "Land/Taxi Lights" 655
	Helios_Udp.Send("302", string.format("%.1f", mainPanelDevice:get_argument_value(183) )) 	-- RIO-3 De-Icing Sensor Heating Circuit Check Button - Push to test 183 btn > "Left MFCD", "OSB3" 302
	Helios_Udp.Send("316", string.format("%.1f", mainPanelDevice:get_argument_value(309) ))	-- Helmet Visor Quick Heating Button - Push to heat 309 btn > "Left MFCD", "OSB17" 316
	Helios_Udp.Send("207", string.format("%.1f", mainPanelDevice:get_argument_value(308) )) 	-- Helmet Heating Mode Switch, AUTO/OFF/ON 308 sw 3 pos  0.0 0.5 1.0 > "IFF", "Ident/Mic Switch" 207
	Helios_Udp.Send("476", string.format("%.1d", mainPanelDevice:get_argument_value(290) ))	-- Reserve Intercom Switch, ON/OFF 290 sw 2 pos > "AAP", "CDU Power"   476
	Helios_Udp.Send("477", string.format("%.1d", mainPanelDevice:get_argument_value(291) )) 	-- ADF Audio Switch, ADF/OFF 291 sw 2 pos >       "AAP", "EGI Power"   477
	Helios_Udp.Send("318", string.format("%.1f", mainPanelDevice:get_argument_value(134) ))	-- Radio Button 134 btn > "Left MFCD", "OSB19" 318
	Helios_Udp.Send("319", string.format("%.1f", mainPanelDevice:get_argument_value(133) )) 	-- Intercom Button 133 btn > "Left MFCD", "OSB20" 319
	Helios_Udp.Send("772", string.format("%.1d", mainPanelDevice:get_argument_value(287) )) 	-- Radio Control Switch, ON/OFF 287 sw 2 pos > "Autopilot", "Emergency Brake" 772
	Helios_Udp.Send("196", string.format("%.1d", mainPanelDevice:get_argument_value(286) )) 	-- Squelch Switch, ON/OFF 286 sw 2 pos > "Autopilot", "HARS-SAS Override/Norm" 196
	Helios_Udp.Send("317", string.format("%.1f", mainPanelDevice:get_argument_value(329) ))	-- IV-300 Engine Vibration Test Button - Push to test 329 btn > "Left MFCD", "OSB18" 317		
	Helios_Udp.Send("718", string.format("%.1d", mainPanelDevice:get_argument_value(327) )) 	-- Fire Extinguish Button Cover OPEN/CLOSE 327 sw 2 pos > "Mechanical", "Auxiliary Landing Gear Handle" 718	
	Helios_Udp.Send("315", string.format("%.1f", mainPanelDevice:get_argument_value(328) ))	-- Fire Extinguish Button - Push to extinguish 328 btn > "Left MFCD", "OSB16" 315	
	Helios_Udp.Send("180", string.format("%.1d", mainPanelDevice:get_argument_value(242) ))	-- RT-12 JPT Regulator Test Switch, I/OFF/II  242 sw 3 pos -1.0 0.0 1.0 > "Autopilot", "Elevator Emergency Disengage" 180
	Helios_Udp.Send("305", string.format("%.1f", mainPanelDevice:get_argument_value(281)) ) 	-- Flaps Flight Position (0 degrees) Button 281 btn >     "Left MFCD", "OSB6" 305
	Helios_Udp.Send("306", string.format("%.1f", mainPanelDevice:get_argument_value(282)) ) 	-- Flaps Takeoff Position (25 degrees) Button 282 btn >   "Left MFCD", "OSB7" 306
	Helios_Udp.Send("307", string.format("%.1f", mainPanelDevice:get_argument_value(283)) ) 	-- Flaps Landing Position (44 degrees) Button 283 btn >   "Left MFCD", "OSB8" 307

	Helios_Udp.Send("294", string.format("%.1d", mainPanelDevice:get_argument_value(254) ))	-- CB Armament System Power Switch, ON/OFF 254 sw 2 pos > "Light System", "Signal Lights" 294
	Helios_Udp.Send("358", string.format("%.1d", mainPanelDevice:get_argument_value(255) ))	-- CB Missile Firing Control Circuit Power Switch, ON/OFF 255 sw 2 pos > "CMSP", "ECM Pod Jettison" 358	
	Helios_Udp.Send("295", string.format("%.1d", mainPanelDevice:get_argument_value(256) ))	-- CB ASP-FKP (Gunsight and Gun Camera) Power Switch, ON/OFF 256 sw 2 pos > "Light System", "Accelerometer & Compass Lights" 295	
	Helios_Udp.Send("276", string.format("%.1d", mainPanelDevice:get_argument_value(273) ))	-- EKSR-46 Signal Flare Dispenser Power Switch, ON/OFF 273 sw 2 pos > "Environmental Control", "Windshield Defog/Deice", 276	
	Helios_Udp.Send("279", string.format("%.1d", mainPanelDevice:get_argument_value(274) ))	-- EKSR-46 Yellow Signal Flare Launch Button 274 sw 2 pos >           "Environmental Control", "Pitot heat"              279	
	Helios_Udp.Send("280", string.format("%.1d", mainPanelDevice:get_argument_value(275) ))	-- EKSR-46 Green Signal Flare Launch Button 275 sw 2 pos >            "Environmental Control", "Bleed Air"               280	
	Helios_Udp.Send("283", string.format("%.1d", mainPanelDevice:get_argument_value(276) ))	-- EKSR-46 Red Signal Flare Launch Button 276 sw 2 pos >              "Environmental Control", "Main Air Supply"         283	
	Helios_Udp.Send("291", string.format("%.1d", mainPanelDevice:get_argument_value(277) ))	-- EKSR-46 White Signal Flare Launch Button 277 sw 2 pos >            "Light System", "Nose Illumination"                291	
	Helios_Udp.Send("244", string.format("%.1d", mainPanelDevice:get_argument_value(597) ))	-- Arm Outer Guns 597 sw 2 pos > "Electrical", "AC Generator - Left" 244	
	Helios_Udp.Send("245", string.format("%.1d", mainPanelDevice:get_argument_value(598) ))	-- Arm Inner Guns 598 sw 2 pos > "Electrical", "AC Generator - Right" 245	
	Helios_Udp.Send("246", string.format("%.1d", mainPanelDevice:get_argument_value(596) ))	-- Arm Bombs 596 sw 2 pos >      "Electrical", "Battery" 246	
	Helios_Udp.Send("326", string.format("%.1f", mainPanelDevice:get_argument_value(599)) )	-- Deblock Guns 599 btn > "Right MFCD", "OSB1" 326 	
	Helios_Udp.Send("601", string.format("%.1d", mainPanelDevice:get_argument_value(272)) )	-- Fire Warning Signal Test Switch, I/OFF/II  272 spr sw 3 pos -1.0 0.0 1.0> "Oxygen System", "Emergency Lever" 601

	Helios_Udp.Send("243", string.format("%.1d", mainPanelDevice:get_argument_value(267)))	-- Arm/Safe Bombs Emergency Jettison Switch Cover, 267 OPEN/CLOSE sw 2 pos > "Electrical", "Emergency Flood" 243		
	Helios_Udp.Send("247", string.format("%.1d", mainPanelDevice:get_argument_value(268)))	-- Arm/Safe Bombs Emergency Jettison Switch, LIVE/BLANK 268 sw 2 pos >   "ILS", "Power"               247			
	Helios_Udp.Send("378", string.format("%.1d", mainPanelDevice:get_argument_value(269)))	-- Emergency Jettison Outboard Stations Switch, Cover OPEN/CLOSE 269 sw 2 pos >  "AHCP", "TGP Power"  378			
	Helios_Udp.Send("383", string.format("%.1d", mainPanelDevice:get_argument_value(270)))	-- Emergency Jettison Outboard Stations Switch, ON/OFF 270 sw 2 pos >       "AHCP", "Datalink Power"  383			
	Helios_Udp.Send("602", string.format("%.1d", mainPanelDevice:get_argument_value(582)))	-- Gun+PK3 Switch 582 Cover sw 2 pos > "Oxygen System", "Dilution Lever" 602			
	Helios_Udp.Send("603", string.format("%.1d", mainPanelDevice:get_argument_value(583)))	-- Gun+PK3 Switch 583 sw 2 pos >       "Oxygen System", "Supply Lever"   603			
	Helios_Udp.Send("270", string.format("%.1d", mainPanelDevice:get_argument_value(589)))	-- Emergency Jettison Inboard Stations Switch, Cover OPEN/CLOSE 589 sw 2 pos > "HARS", "Mode"         270			
	Helios_Udp.Send("273", string.format("%.1d", mainPanelDevice:get_argument_value(590)))	-- Emergency Jettison Inboard Stations Switch, ON/OFF 590 sw 2 pos >           "HARS", "Hemisphere Selector"  273			
	Helios_Udp.Send("388", string.format("%.1f", mainPanelDevice:get_argument_value(579)))	-- Pyro Charge Apply 579 btn > "UFC", "4" 388	
	Helios_Udp.Send("716", string.format("%.1d", mainPanelDevice:get_argument_value(585)))	-- Outboard Stations Select 585 sw 2 pos > "Mechanical", "Landing Gear Lever" 716			
	Helios_Udp.Send("385", string.format("%.1f", mainPanelDevice:get_argument_value(586)))	-- Outboard Stations Deselect 586 btn > "UFC", "1" 385			
	Helios_Udp.Send("382", string.format("%.1d", mainPanelDevice:get_argument_value(587)))	-- Inboard Stations Select 587 sw 2 pos >   "AHCP", "CICU Power"               382			
	Helios_Udp.Send("386", string.format("%.1f", mainPanelDevice:get_argument_value(588)))	-- Inboard Stations Deselect 588 btn > "UFC", "2" 386			
	Helios_Udp.Send("241", string.format("%.1d", mainPanelDevice:get_argument_value(591)))	-- Emergency Launch Missiles Cover OPEN/CLOSE 591 sw 2 pos > "Electrical", "APU Generator" 241			
	Helios_Udp.Send("387", string.format("%.1f", mainPanelDevice:get_argument_value(592)))	-- Emergency Launch Missiles 592 btn > "UFC", "3" 387			

	Helios_Udp.Send("389", string.format("%.1f", mainPanelDevice:get_argument_value(197)))	-- Main and Emergency Hydraulic Systems Interconnection Lever, FORWARD(OFF)/BACKWARD(ON) 197 sw 2 pos > "UFC", "5"  389
	Helios_Udp.Send("390", string.format("%.1f", mainPanelDevice:get_argument_value(194)))	-- Emergency Landing Gear Extension Lever, FORWARD(OFF)/BACKWARD(ON) 194 sw 2 pos >                     "UFC", "6"  390
	Helios_Udp.Send("391", string.format("%.1f", mainPanelDevice:get_argument_value(195)))	-- Emergency Flaps Extension Lever, FORWARD(OFF)/BACKWARD(ON) 195 sw 2 pos >                            "UFC", "7"  391
	Helios_Udp.Send("392", string.format("%.1f", mainPanelDevice:get_argument_value(196)))	-- RAT (Emergency Generator) Emergency Lever, FORWARD(OFF)/BACKWARD(ON) 196 sw 2 pos >                  "UFC", "8"  392
	Helios_Udp.Send("297", string.format("%.3f", mainPanelDevice:get_argument_value(201)))	-- RSBN Field Elevation Knob 201 axis 0.02 > "Light System", "Console Lights" 297

	Helios_Udp.Send("393", string.format("%.1f", mainPanelDevice:get_argument_value(333)))	-- Pitot Tube Selector Lever, STBY(Left)/MAIN(Right) 333 sw 2 pos > "UFC", "9" 393
	Helios_Udp.Send("531", string.format("%.1f", mainPanelDevice:get_argument_value(257)))	-- CB Missile Seeker Heating Circuit Power Switch, ON/OF 257  sw 2 pos > "UFC", "FWD" 531
	Helios_Udp.Send("532", string.format("%.1f", mainPanelDevice:get_argument_value(258)))	-- CB Missile Seeker Glowing Circuit Power Switch, ON/OFF 258 sw 2 pos > "UFC", "MID" 532
	Helios_Udp.Send("533", string.format("%.1f", mainPanelDevice:get_argument_value(576)))	-- Gsh-23 Arm/Safe 576 sw 2 pos > "UFC", "AFT" 533
	Helios_Udp.Send("272", string.format("%.1d", mainPanelDevice:get_argument_value(311)))	-- Taxi and Landing Lights (Searchlights) Control Switch, TAXI/OFF/LANDING  311 sw 3 pos -1.0 0.0 1.0 > "HARS", "Magnetic Variation" 272
	Helios_Udp.Send("395", string.format("%.1f", mainPanelDevice:get_argument_value(136)))	-- Air Brake Switch 136 sw 2 pos > "UFC", "0" 395
	Helios_Udp.Send("225", string.format("%.3f", mainPanelDevice:get_argument_value(288)))	-- Intercom Volume Knob 288 axis lim 0.05 0.0 0.8 >	"Intercom", "VHF Volume" 225
	Helios_Udp.Send("227", string.format("%.3f", mainPanelDevice:get_argument_value(289)))	-- Radio Volume Knob 289 axis lim 0.05 0.0 0.8 >   	"Intercom", "UHF Volume" 227
	Helios_Udp.Send("229", string.format("%.3f", mainPanelDevice:get_argument_value(120)))	-- Diffuser and Flight Suit Temperature Rheostat 120 axis 0.1 > "Intercom", "AIM Volume" 229
	Helios_Udp.Send("231", string.format("%.3f", mainPanelDevice:get_argument_value(259)))	-- Missile Seeker Tone Volume Knob 259 axis 0.1 > "Intercom", "IFF Volume" 231
	Helios_Udp.Send("233", string.format("%.3f", mainPanelDevice:get_argument_value(331)))	-- Instrument Lights Intensity Knob 331 axis 0.1 > "Intercom", "ILS Volume" 233
	Helios_Udp.Send("235", string.format("%.3f", mainPanelDevice:get_argument_value(306)))	-- Oxygen Supply Valve (CLOSE - CW, OPEN - CCW) 306 axis 0.05 >           "Intercom", "TCN Volume"    235
	Helios_Udp.Send("238", string.format("%.3f", mainPanelDevice:get_argument_value(484)))	-- Oxygen Interconnaction Valve (CLOSE - CW, OPEN - CCW) 484 axis 0.05  > "Intercom", "Master Volume" 238
	Helios_Udp.Send("704", string.format("%.3f", mainPanelDevice:get_argument_value(245)))	-- ECS and Pressurization Handle, OFF/CANOPIES SEALED/ECS ON 245 axis 0.1 > "Stall Warning", "Stall Volume" 704
	Helios_Udp.Send("22", string.format("%.3f", mainPanelDevice:get_argument_value(334)/2))-- Emergency/Parking Wheel Brake Lever 334 axis lim 0.1 -1.0 1.0 > "ADI", "Pitch Trim Knob" 22 -0.5 a 0.5
	Helios_Udp.Send("705", string.format("%.3f", mainPanelDevice:get_argument_value(296)))	-- Fuel Shut-Off Lever 296 lever 0.0 1.0 > "Stall Warning", "Peak Volume" 705 
	Helios_Udp.Send("261", string.format("%.3f", mainPanelDevice:get_argument_value(284)))	-- R-832M Preset Channel Selector Knob 284 multi sw 20 pos 0.05 > "TACAN", "Volumne" 261
	multi_sw_172=mainPanelDevice:get_argument_value(172)
	if multi_sw_172 >0.04 and multi_sw_172 < 0.06 then multi_sw_172= 0.3 end
	if multi_sw_172 >0.12 and multi_sw_172 < 0.16 then multi_sw_172= 0.3 end
	if multi_sw_172 >0.22 then multi_sw_172= 0.3 end
	Helios_Udp.Send("135", string.format("%.1f", multi_sw_172)) -- Cabin Air Conditioning Control Switch, OFF/HEAT/COOL/AUTOMATIC 172 multi sw 4 pos 0.05 > "VHF AM Radio", "Frequency Selection Dial" 135
	multi_sw_121=mainPanelDevice:get_argument_value(121)
	if multi_sw_121 >0.04 and multi_sw_121 < 0.06 then multi_sw_121= 0.3 end
	if multi_sw_121 >0.12 and multi_sw_121 < 0.16 then multi_sw_121= 0.3 end
	if multi_sw_121 >0.22 then multi_sw_121= 0.3 end
	Helios_Udp.Send("149", string.format("%.1f", multi_sw_121))-- Diffuser and Flight Suit Air Conditioning Control Switch, HEAT/AUTO/COOL 121 sw 3 pos 0.05 > "VHF FM Radio", "Frequency Selection Dial" 149
	Helios_Udp.Send("268", string.format("%.3f", mainPanelDevice:get_argument_value(532)))	-- Magnetic Declination set knob {0.0, 1.0} in 0.05 Steps 532 axis 0.05 > "HARS", "Sync Button Rotate" 268 
	Helios_Udp.Send("195", string.format("%.3f", mainPanelDevice:get_argument_value(57)))	-- Baro pressure QFE knob 57 axis 0.6 > "Light System", "Weapon Station Lights Brightness" 195
	Helios_Udp.Send("193", string.format("%.3f", mainPanelDevice:get_argument_value(61)))	-- RV-5M Radio Altimeter Decision Height Knob 61 axis 0.2 > "Light System", "Refuel Status Indexer Brightness" 193
	Helios_Udp.Send("451", string.format("%.1f", mainPanelDevice:get_argument_value(60)))	-- RV-5M Radio Altimeter Test Button 60 sw 2 pos > "CDU", "O" 451
	Helios_Udp.Send("450", string.format("%.1f", mainPanelDevice:get_argument_value(30)))	-- KPP-1273K Attitude Director Indicator (ADI) Cage Button 30 btn > "CDU", "N" 450
	Helios_Udp.Send("192", string.format("%.3f", mainPanelDevice:get_argument_value(39)))	-- KPP-1273K Attitude Director Indicator (ADI) Pitch Trim Knob 39 axis 0.05 -1 1 > "Autopilot", "Yaw Trim" 192
	Helios_Udp.Send("271", string.format("%.3f", mainPanelDevice:get_argument_value(48)))	-- HSI Course set knob 48 axis 0.15 > "HARS", "Latitude Correction" 271
	Helios_Udp.Send("249", string.format("%.3f", mainPanelDevice:get_argument_value(569)))	-- Variometer adjustment knob 569 axis 0.1 > "ILS", "Volume" 249 
	Helios_Udp.Send("452", string.format("%.1f", mainPanelDevice:get_argument_value(89)))	-- Reset Limits 89 btn > "CDU", "P" 452
	Helios_Udp.Send("132", string.format("%.1d", mainPanelDevice:get_argument_value(335)))	-- Mech clock left lever (right click) 335 btn -1.0 > "Autopilot", "Mode Selection" 132
	Helios_Udp.Send("116", string.format("%.3f", mainPanelDevice:get_argument_value(336)))	-- Mech clock left lever  336 lever 0.04 > "Light System", "Refueling Lighting Dial" 116
	Helios_Udp.Send("453", string.format("%.3f", mainPanelDevice:get_argument_value(337)))	-- Mech clock right lever 337 btn > "CDU", "Q" 453
	Helios_Udp.Send("368", string.format("%.3f", mainPanelDevice:get_argument_value(338)))	-- Mech clock right lever 338 lever 0.1> "CMSC", "RWR Volume" 368
	Helios_Udp.Send("189", string.format("%.1d", mainPanelDevice:get_argument_value(118)))	-- Landing Gear Control Lever 118 sw 3 pos  -1.0 0.0 1.0 > "Autopilot", "Monitor Test Left/Right" 189

	Helios_Udp.Flush()
end

Helios_L39.ExportArguments["1,3000"] = "1,3003,1"   -- ASP-3NMU Gunsight Mode, GYRO/FIXED 101 sw 2 pos > 
Helios_L39.ExportArguments["1,3000"] = "1,3004,1"   -- ASP-3NMU Gunsight Brightness Knob 102 axis 0.2 > 
Helios_L39.ExportArguments["1,3000"] = "1,3001,1"   -- ASP-3NMU Gunsight Target Wingspan Adjustment Dial (meters) 103 axis -0.1 > 
Helios_L39.ExportArguments["1,3000"] = "1,3012,1"   -- ASP-3NMU Gunsight Color Filter, ON/OFF 104 lever 2.0 > 
Helios_L39.ExportArguments["1,3000"] = "1,3011,1"   -- ASP-3NMU Gunsight Fixed Reticle Mask Lever 105 lever 7.0 > 
Helios_L39.ExportArguments["1,3000"] = "1,3016,1"   -- ASP-3NMU Gunsight Mirror Depression 106 axis 0.05 > 
Helios_L39.ExportArguments["1,3000"] = "1,3002,1"   -- ASP-3NMU Gunsight Target Distance 107 axis 0.1 > 
Helios_L39.ExportArguments["49,3008"] = "12,3001,1"  -- Mech clock left lever (left click) 335 btn 1.0 > "Light System", "Position Flash" 132
Helios_L39.ExportArguments["38,3001"] = "12,3002,1"  -- Mech clock left lever (right click) 335 btn -1.0 > "Autopilot", "Mode Selection" 132
Helios_L39.ExportArguments["8,3028"] = "12,3003,0.1"  -- Mech clock left lever  336 lever 0.04 > "UFC", "HUD Brightness"   rocker --
Helios_L39.ExportArguments["8,3029"] = "12,3003,0.1"  -- Mech clock left lever  336 lever 0.04 > "UFC", "HUD Brightness"   rocker --
Helios_L39.ExportArguments["9,3043"] = "12,3004,1"  -- Mech clock right lever 337 btn > "CDU", "Q" 453
Helios_L39.ExportArguments["5,3007"] = "12,3005,1"  -- Mech clock right lever 338 lever 0.1> "CMSC", "RWR Volume" 368
Helios_L39.ExportArguments["9,3066"] = "9,3001,1"   -- Baro pressure QFE knob 57 axis 0.6 >  "CDU", "+/-" 472  rocker --
Helios_L39.ExportArguments["9,3067"] = "9,3001,1"   -- Baro pressure QFE knob 57 axis 0.6 >  "CDU", "+/-" 472  rocker --
Helios_L39.ExportArguments["9,3064"] = "14,3001,0.1"  -- RV-5M Radio Altimeter Decision Height Knob 61 axis 0.2 > "CDU", "Blank"  rocker --
Helios_L39.ExportArguments["9,3065"] = "14,3001,0.1"  -- RV-5M Radio Altimeter Decision Height Knob 61 axis 0.2 > "CDU", "Blank"  rocker --
Helios_L39.ExportArguments["9,3041"] = "14,3002,1"  -- RV-5M Radio Altimeter Test Button 60 sw 2 pos > "CDU", "O" 451
Helios_L39.ExportArguments["54,3010"] = "17,3002,102"  -- GMK-1AE GMC Hemisphere Selection Switch, N(orth)/S(outh) 204 sw 2 pos >  "UHF Radio", "Squelch" 170
Helios_L39.ExportArguments["54,3014"] = "17,3004,102"  -- GMK-1AE GMC Mode Switch, MC(Magnetic Compass Mode)/GC(Directional Gyro Mode) 207 sw 2 pos >  "UHF Radio", "Cover" 734
Helios_L39.ExportArguments["43,3012"] = "17,3003,1"  -- GMK-1AE GMC Test Switch, 0(degrees)/OFF/300(degrees) - Use to check heading indication accuracy 205 sw 3 pos -1 0 1> "IFF", "M-3/A Switch" 204
Helios_L39.ExportArguments["43,3013"] = "17,3005,1"  -- GMK-1AE GMC Course Selector Switch, CCW/OFF/CW 208 sw 3 pos -1 0 1 >  "IFF", "M-C Switch" 205
Helios_L39.ExportArguments["4,3005"] = "17,3006,300"  -- GMK-1AE GMC Latitude Selector Knob 209 axis 0.02 > "CMSP", "Page Cycle" rocker --
Helios_L39.ExportArguments["4,3006"] = "17,3006,301"  -- GMK-1AE GMC Latitude Selector Knob 209 axis 0.02 > "CMSP", "Page Cycle" rocker --
Helios_L39.ExportArguments["12,3001"] = "17,3012,1"  -- MC Synchronization Button - Push to synchronize (level flight only) 124 btn > "IFFCC", "Ext Stores Jettison" 101
Helios_L39.ExportArguments["44,3007"] = "17,3014,1"  -- Magnetic Declination set knob {0.0, 1.0} in 0.05 Steps 532 axis 0.05 > "HARS", "Sync Button Rotate" 268
Helios_L39.ExportArguments["9,3040"] = "22,3002,1"  -- KPP-1273K Attitude Director Indicator (ADI) Cage Button 30 btn > "CDU", "N" 450
Helios_L39.ExportArguments["38,3013"] = "22,3003,1"  -- KPP-1273K Attitude Director Indicator (ADI) Pitch Trim Knob 39 axis 0.05 -1 1 > "Autopilot", "Yaw Trim" 192
Helios_L39.ExportArguments["69,3007"] = "41,3001,1"  -- SDU Switch, ON/OFF 177 sw 2 pos > "KY-58 Secure Voice", "Power Switch" 784
Helios_L39.ExportArguments["22,3000"] = "22,3008,1"  -- AGD Pitch Failure 460 sw 2 pos > 
Helios_L39.ExportArguments["22,3000"] = "22,3009,1"  -- AGD Bank Failure 461 sw 2 pos > 
Helios_L39.ExportArguments["9,3060"] = "24,3001,0.1"  -- HSI Course set knob 48 axis 0.15 > "CDU", "Brightness" rocker --
Helios_L39.ExportArguments["9,3061"] = "24,3001,0.1"  -- HSI Course set knob 48 axis 0.15 > "CDU", "Brightness" rocker --
Helios_L39.ExportArguments["25,3000"] = "25,3002,1"  -- Course Accordance 526 btn > 
Helios_L39.ExportArguments["24,3000"] = "24,3002,1"  -- GMK Failure 458 sw 2 pos > 
Helios_L39.ExportArguments["3,3036"] = "31,3001,1"  -- RSBN Mode Switch, LANDING/NAVIGATION/GLIDE PATH {0.0,0.1,0.2} 178 sw 3 pos > "Right MFCD", "Day/Night/Off" 351
Helios_L39.ExportArguments["2,3001"] = "31,3002,1"  -- RSBN Identification Button 179 btn >       "Left MFCD", "OSB1" 300
Helios_L39.ExportArguments["2,3002"] = "31,3003,1"  -- RSBN Test Button - Push to test 180 btn >  "Left MFCD", "OSB2" 301
Helios_L39.ExportArguments["49,3009"] = "31,3004,1"  -- RSBN Control Box Lighting Intensity Knob 181 axis 0.04 0.0, 0.8 > "Light System", "Formation Lights" 288
Helios_L39.ExportArguments["49,3002"] = "31,3005,1"  -- RSBN Volume Knob 184 axis 0.04 0.0, 0.8 > "Light System", "Flight Instruments Lights" 292
Helios_L39.ExportArguments["43,3010"] = "31,3006,1"  -- Initial Azimuth 187 spr sw 3 pos -1.0,0.0,1.0> "IFF", "M-1 Switch" 202
Helios_L39.ExportArguments["43,3011"] = "31,3007,1"  -- Initial Range 188 spr sw 3 pos -1.0,0.0,1.0>   "IFF", "M-2 Switch" 203
Helios_L39.ExportArguments["57,3003"] = "31,3008,1"  -- RSBN Navigation Channel Selector Knob 191 multi sw 40 0.025 > "TISL", "Altitude above target tens of thousands of feet" 624
Helios_L39.ExportArguments["57,3004"] = "31,3009,1"  -- RSBN Landing Channel Selector Knob 192 multi sw 40 0.025  >   "TISL", "Altitude above target thousands of feet" 626
Helios_L39.ExportArguments["2,3004"] = "31,3010,1"  -- Set 0 Azimuth 193 btn > "Left MFCD", "OSB4" 303
Helios_L39.ExportArguments["49,3006"] = "31,3011,1"  -- RSBN Field Elevation Knob 201 axis 0.02 > "Light System", "Console Lights" 297
Helios_L39.ExportArguments["2,3009"] = "31,3012,1"  -- RSBN Listen Callsign Button - Push to listen 297 btn > "Left MFCD", "OSB9" 308
Helios_L39.ExportArguments["31,3000"] = "31,3013,1"  -- RSBN Emergency Landing Switch, ON/OFF 527 sw 2 pos > 
Helios_L39.ExportArguments["9,3062"] = "15,3001,0.5"  -- Variometer adjustment knob 569 axis 0.1 > "CDU", "Page"    rocker --
Helios_L39.ExportArguments["9,3063"] = "15,3001,0.5"  -- Variometer adjustment knob 569 axis 0.1 > "CDU", "Page"    rocker --
Helios_L39.ExportArguments["67,3001"] = "21,3011,1"  -- RKL-41 ADF Outer-Inner Beacon (Far-Near NDB) Switch 119 sw 2 pos > "Radar Altimeter", "Normal/Disabled" 130
Helios_L39.ExportArguments["57,3005"] = "21,3001,1"  -- RKL-41 ADF Volume Knob 157 axis 0.05 >     "TISL", "TISL Code Wheel 1" 636
Helios_L39.ExportArguments["57,3006"] = "21,3013,1"  -- RKL-41 ADF Brightness Knob 161 axis 0.05 > "TISL", "TISL Code Wheel 2" 638
Helios_L39.ExportArguments["50,3002"] = "21,3002,1"  -- RKL-41 ADF Mode Switch, TLF(A3)/TLG(A1,A2) 159 sw 2 pos > "Fire System", "APU Fire Pull" 103
Helios_L39.ExportArguments["4,3018"] = "21,3003,1"  -- RKL-41 ADF Function Selector Switch, OFF/COMP(AUTO)/COMP(MAN)/ANT/LOOP 160 multi sw 5 pos 0.1 > "CMSP", "Mode Select Dial" 364 - 5 pos
Helios_L39.ExportArguments["50,3004"] = "21,3010,1"  -- RKL-41 ADF Loop Switch, LEFT/OFF/RIGHT {-1.0,0.0,1.0} 162 spr sw 3 pos > "Fire System", "Discharge Switch" 105
Helios_L39.ExportArguments["50,3003"] = "21,3012,1"  -- RKL-41 ADF Control Switch, TAKE CONTROL/HAND OVER CONTROL 158 sw 2 pos > "Fire System", "Right Engine Fire Pull" 104
Helios_L39.ExportArguments["57,3007"] = "21,3004,1"  -- RKL-41 ADF Far NDB Frequency Tune 165 axis 0.05  > "TISL", "TISL Code Wheel 3" 640
Helios_L39.ExportArguments["58,3002"] = "21,3005,1"  -- RKL-41 ADF Far NDB 100kHz rotary 163  weel arc 0.0588 0.0,0.938 > "Intercom", "INT Volume" 221
Helios_L39.ExportArguments["58,3004"] = "21,3006,1"  -- RKL-41 ADF Far NDB 10kHz rotary 164 weel arc 0.1 0.0,0.9 >        "Intercom", "FM Volume" 223
Helios_L39.ExportArguments["57,3008"] = "21,3007,1"  -- RKL-41 ADF Near NDB Frequency Tune 168 axis 0.05 > "TISL", "TISL Code Wheel 4" 642
Helios_L39.ExportArguments["41,3003"] = "21,3008,1"  -- RKL-41 ADF Near NDB 100kHz rotary 166  weel arc 0.0588 0.0,0.938  > "Environmental Control", "Canopy Defog" 277
Helios_L39.ExportArguments["41,3009"] = "21,3009,1"  -- RKL-41 ADF Near ND  10kHz rotary 167 weel arc 0.1 0.0,0.9 >         "Environmental Control", "Flow Level" 284
Helios_L39.ExportArguments["21,3000"] = "21,3027,1"  -- RKL-41 ARK Failure 459 sw 2 pos >
Helios_L39.ExportArguments["37,3001"] = "4,3001,1"   -- Battery Switch, ON/OFF 141 sw 2 pos > "Engine System", "Left Engine Fuel Flow Control" 122
Helios_L39.ExportArguments["37,3002"] = "4,3002,1"   -- Main Generator Switch, ON/OFF 142 sw 2 pos > "Engine System", "Right Engine Fuel Flow Control" 123
Helios_L39.ExportArguments["37,3005"] = "4,3003,1"   -- Emergency Generator Switch, ON/OFF 143 sw 2 pos > "Engine System", "APU" 126
Helios_L39.ExportArguments["69,3003"] = "4,3072,1"   -- Emergency Engine Instruments Power Switch, ON/OFF 169 sw 2 pos > "KY-58 Secure Voice", "Delay" 780
Helios_L39.ExportArguments["58,3007"] = "4,3006,1"	-- Turbo Button Cover, Open/Close 314 sw 2 pos > "Intercom", "UHF Switch"228
Helios_L39.ExportArguments["2,3014"] = "4,3005,1"   -- Turbo Button 315 btn > "Left MFCD", "OSB14" 313
Helios_L39.ExportArguments["58,3009"] = "4,3010,1"   -- Stop Turbo Switch Cover, Open/Close 312 sw 2 pos > "Intercom", "AIM Switch" 230
Helios_L39.ExportArguments["58,3001"] = "4,3009,1"   -- Stop Turbo Switch, ON/OFF 313 sw 2 pos > "Intercom", "INT Switch" 222
Helios_L39.ExportArguments["58,3011"] = "4,3012,1"   -- Engine Button Cover, Open/Close 325 sw 2 pos > "Intercom", "IFF Switch" 232
Helios_L39.ExportArguments["2,3015"] = "4,3011,1"   -- Engine Button 326 btn >  "Left MFCD", "OSB15" 314
Helios_L39.ExportArguments["58,3013"] = "4,3016,1"   -- Stop Engine Switch Cover, Open/Close 317 sw 2 pos > "Intercom", "ILS Switch" 234
Helios_L39.ExportArguments["58,3003"] = "4,3015,1"   -- Stop Engine Switch 318 sw 2 pos > Intercom", "FM Switch" 224
Helios_L39.ExportArguments["58,3015"] = "4,3020,1"   -- Engine Start Mode Switch Cover, Open/Close 321 sw 2 pos > "Intercom", "TCN Switch" 236
Helios_L39.ExportArguments["54,3009"] = "4,3019,1"   -- Engine Start Mode Switch, START/FALSE START/COLD CRANKING  322 sw 3 pos (-1.0,0.0,1.0 L39ZA) (0.0,0.1,0.2 L39C)> "UHF Radio", "T/Tone Switch" 169
Helios_L39.ExportArguments["58,3017"] = "4,3022,1"   -- Emergency Fuel Switch Cover, Open/Close 319 sw 2 pos > "Intercom", "Hot Mic Switch" 237
Helios_L39.ExportArguments["58,3005"] = "4,3021,1"   -- Emergency Fuel Switch 320 sw 2 pos > "Intercom", "VHF Switch" 226
Helios_L39.ExportArguments["36,3001"] = "4,3025,1"   -- CB Engine Switch, ON/OFF 144 sw 2 pos > "Fuel System", "External Wing Tank Boost Pump" 106
Helios_L39.ExportArguments["36,3002"] = "4,3026,1"   -- CB AGD-GMK Switch, ON/OFF 145 sw 2 pos > "Fuel System", "External Fuselage Tank Boost Pump" 107
Helios_L39.ExportArguments["36,3003"] = "4,3027,1"   -- CB Inverter 1 (AC 115V) Switch, ON/OFF 146 sw 2 pos > "Fuel System", "Tank Gate" 108
Helios_L39.ExportArguments["36,3004"] = "4,3028,1"   -- CB Inverter 2 (AC 115V) Switch, ON/OFF 147 sw 2 pos > "Fuel System", "Cross Feed" 109
Helios_L39.ExportArguments["36,3005"] = "4,3029,1"   -- CB RDO (ICS and Radio) Switch, ON/OFF 148 sw 2 pos > "Fuel System", "Boost Pump Left Wing" 110
Helios_L39.ExportArguments["36,3006"] = "4,3030,1"   -- CB MRP-RV (Marker Beacon Receiver and Radio Altimeter) Switch, ON/OFF 149 sw 2 pos > "Fuel System", "Boost Pump Right Wing" 111
Helios_L39.ExportArguments["36,3007"] = "4,3031,1"   -- CB RSBN (ISKRA) Switch, ON/OFF 150 sw 2 pos > "Fuel System", "Boost Pump Main Fuseloge Left" 112
Helios_L39.ExportArguments["36,3008"] = "4,3032,1"   -- CB IFF (SRO) Emergency Connection Switch, ON/OFF 151 sw 2 pos > "Fuel System", "Boost Pump Main Fuseloge Right" 113
Helios_L39.ExportArguments["36,3009"] = "4,3033,1"   -- CB RSBN (ISKRA) Emergency Connection Switch, ON/OFF 152 sw 2 pos > "Fuel System", "Signal Amplifier" 114
Helios_L39.ExportArguments["36,3015"] = "4,3034,1"   -- CB Wing Tanks Switch, ON/OFF" 153 sw 2 pos > "Fuel System", "Fill Disable Main Right" 120
Helios_L39.ExportArguments["36,3016"] = "4,3035,1"   -- CB RIO-3 De-Icing Signal Switch, ON/OFF 154 sw 2 pos > "Fuel System", "Refuel Control Lever" 121
Helios_L39.ExportArguments["36,3012"] = "4,3036,1"   -- CB SDU Switch, ON/OFF 155 sw 2 pos > "Fuel System", "Fill Disable Wing Left" 117
Helios_L39.ExportArguments["36,3013"] = "4,3037,1"   -- CB Heating AOA Sensor Switch, ON/OFF 628 sw 2 pos --------SOLO L39ZA> "Fuel System", "Fill Disable Wing Right" 118
Helios_L39.ExportArguments["36,3014"] = "4,3038,1"   -- CB Weapon Switch, ON/OFF 629 sw 2 pos > "Fuel System", "Fill Disable Main Left" 119
Helios_L39.ExportArguments["4,3000"] = "4,3066,1"   -- CB Weapon, ON/OFF 505 sw 2 pos instructor> 
Helios_L39.ExportArguments["3,3002"] = "4,3040,1"   -- CB Air Conditioning, ON/OFF 211 sw 2 pos > "Right MFCD", "OSB2"
Helios_L39.ExportArguments["3,3003"] = "4,3041,1"   -- CB Anti-Ice, ON/OFF 212 sw 2 pos >         "Right MFCD", "OSB3"
Helios_L39.ExportArguments["3,3004"] = "4,3042,1"   -- CB Pitot Left, ON/OFF 213 sw 2 pos >       "Right MFCD", "OSB4"
Helios_L39.ExportArguments["3,3005"] = "4,3043,1"   -- CB Pitot Right, ON/OFF 214 sw 2 pos >      "Right MFCD", "OSB5"
Helios_L39.ExportArguments["3,3006"] = "4,3044,1"   -- CB PT-500C, ON/OFF 215 sw 2 pos >          "Right MFCD", "OSB6"
Helios_L39.ExportArguments["3,3007"] = "4,3045,1"   -- CB ARC, ON/OFF 216 sw 2 pos >              "Right MFCD", "OSB7"
Helios_L39.ExportArguments["3,3008"] = "4,3046,1"   -- CB SRO, ON/OFF 217 sw 2 pos >              "Right MFCD", "OSB8"
Helios_L39.ExportArguments["3,3009"] = "4,3047,1"   -- CB Seat-Helmet, ON/OFF 218 sw 2 pos >      "Right MFCD", "OSB9"
Helios_L39.ExportArguments["3,3010"] = "4,3048,1"   -- CB Gears, ON/OFF 219 sw 2 pos >            "Right MFCD", "OSB10"
Helios_L39.ExportArguments["3,3011"] = "4,3049,1"   -- CB Control, ON/OFF 220 sw 2 pos >          "Right MFCD", "OSB11"
Helios_L39.ExportArguments["3,3012"] = "4,3050,1"   -- CB Signaling, ON/OFF 221 sw 2 pos >        "Right MFCD", "OSB12"
Helios_L39.ExportArguments["3,3013"] = "4,3051,1"   -- CB Nav. Lights, ON/OFF 222 sw 2 pos >      "Right MFCD", "OSB13"
Helios_L39.ExportArguments["3,3014"] = "4,3052,1"   -- CB Spotlight Left, ON/OFF 223 sw 2 pos >   "Right MFCD", "OSB14"
Helios_L39.ExportArguments["3,3015"] = "4,3053,1"   -- CB Spotlight Right, ON/OFF 224 sw 2 pos >  "Right MFCD", "OSB15"
Helios_L39.ExportArguments["3,3016"] = "4,3054,1"   -- CB Red Lights, ON/OFF 225 sw 2 pos >       "Right MFCD", "OSB16"
Helios_L39.ExportArguments["3,3017"] = "4,3055,1"   -- CB White Lights, ON/OFF 226 sw 2 pos >     "Right MFCD", "OSB17"
Helios_L39.ExportArguments["9,3044"] = "4,3056,1"   -- CB Start Panel, ON/OFF 227 sw 2 pos >         "CDU", "R"
Helios_L39.ExportArguments["9,3045"] = "4,3057,1"   -- CB Booster Pump, ON/OFF 228 sw 2 pos >        "CDU", "S"
Helios_L39.ExportArguments["9,3046"] = "4,3058,1"   -- CB Ignition 1, ON/OFF 229 sw 2 pos >          "CDU", "T"
Helios_L39.ExportArguments["9,3047"] = "4,3059,1"   -- CB Ignition 2, ON/OFF 230 sw 2 pos >          "CDU", "U"
Helios_L39.ExportArguments["9,3048"] = "4,3060,1"   -- CB Engine Instruments, ON/OFF 231 sw 2 pos >  "CDU", "V"
Helios_L39.ExportArguments["9,3049"] = "4,3061,1"   -- CB Fire, ON/OFF 232 sw 2 pos >                "CDU", "W"
Helios_L39.ExportArguments["9,3050"] = "4,3062,1"   -- CB Emergency Jettison, ON/OFF 233 sw 2 pos >  "CDU", "X"
Helios_L39.ExportArguments["9,3051"] = "4,3063,1"   -- CB SARPP, ON/OFF 234 sw 2 pos >               "CDU", "Y"
Helios_L39.ExportArguments["4,3000"] = "4,3067,1"   -- CB Ground Intercom, ON/OFF 512 sw 2 pos > 
Helios_L39.ExportArguments["2,3010"] = "4,3068,1"   -- Standby (Left) Pitot Tube Heating Button - Push to turn heating on 294 btn >      "Left MFCD", "OSB10"  309
Helios_L39.ExportArguments["2,3011"] = "4,3070,1"   -- Main (Right) Pitot Tube Heating Button - Push to turn heating on 295 btn >        "Left MFCD", "OSB11"  310
Helios_L39.ExportArguments["2,3012"] = "4,3069,1"   -- Standby (Left) Pitot Tube Heating Off Button - Push to turn heating off 292 btn > "Left MFCD", "OSB12"  311
Helios_L39.ExportArguments["2,3013"] = "4,3071,1"   -- Main (Right) Pitot Tube Heating Off Button - Push to turn heating off 293 btn >   "Left MFCD", "OSB13"  312
Helios_L39.ExportArguments["38,3021"] = "20,3003,103"  -- Navigation Lights Mode Control Switch, FLICKER/OFF/FIXED  176 sw 3 pos 0.0,0.5,1.0 > "Autopilot", "Alieron Emergency Disengage" 177
Helios_L39.ExportArguments["43,3009"] = "20,3004,103"  -- Navigation Lights Intensity Control Switch, DIM(30%)/BRT(60%)/MAX(100%)  175 sw 3 pos 0.0,0.5,1.0> IFF", "Audio Light Switch" 201
Helios_L39.ExportArguments["44,3004"] = "20,3006,1"  -- Taxi and Landing Lights (Searchlights) Control Switch, TAXI/OFF/LANDING  311 sw 3 pos -1.0 0.0 1.0 > "HARS", "Magnetic Variation" 272
Helios_L39.ExportArguments["43,3014"] = "20,3008,1"  -- Instrument Lighting Switch, Red/OFF/White 330 sw 3 pos -1.0 0.0 1.0 > "IFF", "RAD Test/Monitor Switch" 206
Helios_L39.ExportArguments["58,3014"] = "20,3009,1"  -- Instrument Lights Intensity Knob 331 axis 0.1 > "Intercom", "ILS Volume" 233
Helios_L39.ExportArguments["50,3001"] = "20,3005,1"  -- Emergency Instrument Light Switch, ON/OFF 249 sw 2 pos > "Fire System", "Left Engine Fire Pull" 102
Helios_L39.ExportArguments["49,3003"] = "20,3012,1"  -- Warning-Light Intensity Knob 202 axis 0.1 > "Light System", "Auxillary instrument Lights" 293
Helios_L39.ExportArguments["2,3005"] = "20,3013,1"  -- Warning-Light Check Button - Push to check 203 btn > "Left MFCD", "OSB5" 304
Helios_L39.ExportArguments["49,3013"] = "3,3001,1"   -- CB Armament System Power Switch, ON/OFF 254 sw 2 pos > "Light System", "Signal Lights" 294
Helios_L39.ExportArguments["4,3008"] = "3,3002,1"   -- CB Missile Firing Control Circuit Power Switch, ON/OFF 255 sw 2 pos > "CMSP", "ECM Pod Jettison" 358
Helios_L39.ExportArguments["49,3004"] = "3,3003,1"   -- CB ASP-FKP (Gunsight and Gun Camera) Power Switch, ON/OFF 256 sw 2 pos > "Light System", "Accelerometer & Compass Lights" 295
Helios_L39.ExportArguments["8,3030"] = "3,3004,1"   -- CB Missile Seeker Heating Circuit Power Switch, ON/OF  257 sw 2 pos > "UFC", "FWD" 531
Helios_L39.ExportArguments["8,3031"] = "3,3005,1"   -- CB Missile Seeker Glowing Circuit Power Switch, ON/OFF 258 sw 2 pos > "UFC", "MID" 532
Helios_L39.ExportArguments["58,3012"] = "3,3006,1"   -- Missile Seeker Tone Volume Knob 259 axis 0.1 > "Intercom", "IFF Volume" 231
Helios_L39.ExportArguments["49,3007"] = "3,3008,1"   -- Arm/Safe Bombs Emergency Jettison Switch Cover, OPEN/CLOSE 267 sw 2 pos > "Electrical", "Emergency Flood" 243
Helios_L39.ExportArguments["53,3001"] = "3,3009,1"   -- Arm/Safe Bombs Emergency Jettison Switch, LIVE/BLANK 268 sw 2 pos >   "ILS", "Power"                   247
Helios_L39.ExportArguments["2,3036"] = "3,3012,104"   -- Rockets Firing Mode Selector Switch, AUT./2RS/4RS 271 multi sw 3 pos 0.3 0.1 0.2 > "Left MFCD", "Day/Night/Off"
Helios_L39.ExportArguments["41,3002"] = "3,3013,1"   -- EKSR-46 Signal Flare Dispenser Power Switch, ON/OFF 273 sw 2 pos > "Environmental Control", "Windshield Defog/Deice", 276
Helios_L39.ExportArguments["41,3005"] = "3,3017,1"   -- EKSR-46 Yellow Signal Flare Launch Button 274 sw 2 pos >           "Environmental Control", "Pitot heat"              279
Helios_L39.ExportArguments["41,3006"] = "3,3014,1"   -- EKSR-46 Green Signal Flare Launch Button 275 sw 2 pos >            "Environmental Control", "Bleed Air"               280
Helios_L39.ExportArguments["41,3008"] = "3,3015,1"   -- EKSR-46 Red Signal Flare Launch Button 276 sw 2 pos >              "Environmental Control", "Main Air Supply"         283
Helios_L39.ExportArguments["49,3012"] = "3,3016,1"   -- EKSR-46 White Signal Flare Launch Button 277 sw 2 pos >            "Light System", "Nose Illumination"                291
Helios_L39.ExportArguments["7,3007"] = "3,3007,102"   -- Missile/Bomb Release Selector Switch, PORT(Left)/STARB-BOTH(Right for Missiles/Both) 260 sw 2 pos (1,-1)> "AHCP", "HUD Norm/Standbyh" 381
Helios_L39.ExportArguments["7,3004"] = "3,3010,1"   -- Emergency Jettison Outboard Stations Switch, Cover OPEN/CLOSE 269 sw 2 pos >  "AHCP", "TGP Power"  378
Helios_L39.ExportArguments["7,3009"] = "3,3011,1"   -- Emergency Jettison Outboard Stations Switch, ON/OFF 270 sw 2 pos >       "AHCP", "Datalink Power"   383
-- solo L39ZA
Helios_L39.ExportArguments["40,3002"] = "3,3041,1"   -- Gun+PK3 Switch 582 Cover sw 2 pos > "Oxygen System", "Dilution Lever" 602
Helios_L39.ExportArguments["40,3001"] = "3,3042,1"   -- Gun+PK3 Switch 583 sw 2 pos >       "Oxygen System", "Supply Lever"   603
Helios_L39.ExportArguments["44,3002"] = "3,3043,1"   -- Emergency Jettison Inboard Stations Switch, Cover OPEN/CLOSE 589 sw 2 pos > "HARS", "Mode"                 270
Helios_L39.ExportArguments["44,3003"] = "3,3044,1"   -- Emergency Jettison Inboard Stations Switch, ON/OFF 590 sw 2 pos >           "HARS", "Hemisphere Selector"  273
Helios_L39.ExportArguments["57,3002"] = "3,3045,103"   -- Pyro Charge Select 607 sw 3 pos 0.0,0.5,1.0 >  "TISL", "Slant Range" 623
Helios_L39.ExportArguments["8,3004"] = "3,3046,1"   -- Pyro Charge Apply 579 btn > "UFC", "4" 388 
Helios_L39.ExportArguments["8,3032"] = "3,3047,1"   -- Gsh-23 Arm/Safe 576 sw 2 pos > "UFC", "AFT" 533
Helios_L39.ExportArguments["39,3001"] = "3,3048,1"   -- Outboard Stations Select 585 sw 2 pos > "Mechanical", "Landing Gear Lever" 716
Helios_L39.ExportArguments["8,3001"] = "3,3049,1"   -- Outboard Stations Deselect 586 btn > "UFC", "1" 385
Helios_L39.ExportArguments["7,3008"] = "3,3050,1"   -- Inboard Stations Select 587 sw 2 pos >   "AHCP", "CICU Power"               382
Helios_L39.ExportArguments["8,3002"] = "3,3051,1"   -- Inboard Stations Deselect 588 btn > "UFC", "2" 386
Helios_L39.ExportArguments["46,3008"] = "3,3052,1"   -- Charge Outer Guns 577 sw 2 pos > "Navigation Mode Select Panel", "Able - Stow" 621
Helios_L39.ExportArguments["7,3006"] = "3,3053,1"   -- Charge Inner Guns 578 sw 2 pos > "AHCP", "HUD Day/Night" 380
Helios_L39.ExportArguments["1,3001"] = "3,3054,1"   -- Emergency Launch Missiles Cover OPEN/CLOSE 591 sw 2 pos > "Electrical", "APU Generator" 241
Helios_L39.ExportArguments["8,3003"] = "3,3055,1"   -- Emergency Launch Missiles 592 btn > "UFC", "3" 387
Helios_L39.ExportArguments["1,3004"] = "3,3056,1"   -- Arm Outer Guns 597 sw 2 pos > "Electrical", "AC Generator - Left" 244
Helios_L39.ExportArguments["1,3005"] = "3,3057,1"   -- Arm Inner Guns 598 sw 2 pos > "Electrical", "AC Generator - Right" 245
Helios_L39.ExportArguments["1,3006"] = "3,3058,1"   -- Arm Bombs 596 sw 2 pos >      "Electrical", "Battery" 246
Helios_L39.ExportArguments["57,3009"] = "3,3059,1"  -- Bombs Series 584 sw 3 pos -1.0,0.0,1.0 > "TISL", "Code Select"
Helios_L39.ExportArguments["3,3001"] = "3,3077,1"   -- Deblock Guns 599 btn > "Right MFCD", "OSB1" 326
--
Helios_L39.ExportArguments["38,3016"] = "30,3004,1"  -- Emergency Oxygen Switch, ON/OFF 303 sw 2 pos >   "Autopilot", "Pitch/Roll Emergency Override"  175
Helios_L39.ExportArguments["38,3023"] = "30,3006,1"  -- Diluter Demand Switch, 100% / MIX 304 sw 2 pos > "Autopilot", "Flaps Emergency Retract"   183
Helios_L39.ExportArguments["38,3024"] = "30,3008,1"  -- Helmet Ventilation Switch, ON/OFF 307 sw 2 pos > "Autopilot", "Manual Reversion Flight Control System Switch" 184
Helios_L39.ExportArguments["22,3002"] = "30,3009,1"  -- Oxygen Supply Valve (CLOSE - CW, OPEN - CCW) 306 axis 0.05 >   "AAP", "Steer Toggle Switch" 474  rocker --
Helios_L39.ExportArguments["22,3003"] = "30,3009,1"  -- Oxygen Supply Valve (CLOSE - CW, OPEN - CCW) 306 axis 0.05 >    "AAP", "Steer Toggle Switch" 474 rocker --
Helios_L39.ExportArguments["58,3018"] = "30,3003,1"  -- Oxygen Interconnaction Valve (CLOSE - CW, OPEN - CCW) 484 axis 0.05  > "Intercom", "Master Volume" 238
Helios_L39.ExportArguments["38,3015"] = "36,3001,1"  -- SARPP Flight Recorder, ON/OFF 298 sw 2 pos > "Autopilot", "Speed Brake Emergency Retract" 174
Helios_L39.ExportArguments["52,3002"] = "5,3002,1"   -- Fuel Shut-Off Lever 296 lever 0.0 1.0 > "Stall Warning", "Peak Volume" 705 
Helios_L39.ExportArguments["52,3001"] = "7,3001,1"   -- ECS and Pressurization Handle, OFF/CANOPIES SEALED/ECS ON 245 axis 0.1 > "Stall Warning", "Stall Volume" 704
Helios_L39.ExportArguments["55,3004"] = "7,3004,1"   -- Cabin Air Conditioning Control Switch, OFF/HEAT/COOL/AUTOMATIC 172 multi sw 4 pos 0.05 > "VHF AM Radio", "Frequency Selection Dial" 135
Helios_L39.ExportArguments["49,3001"] = "7,3003,1"   -- Cabin Air Temperature Controller Rheostat 173 axis 0.1 > "Light System", "Engine Instrument Lights" 290
Helios_L39.ExportArguments["56,3004"] = "7,3006,1"   -- Diffuser and Flight Suit Air Conditioning Control Switch, HEAT/AUTO/COOL 121 sw 3 pos 0.05 > "VHF FM Radio", "Frequency Selection Dial" 149
Helios_L39.ExportArguments["58,3010"] = "7,3005,1"   -- Diffuser and Flight Suit Temperature Rheostat 120 axis 0.1 > "Intercom", "AIM Volume" 229
Helios_L39.ExportArguments["7,3000"] = "7,3008,1"   -- aft Conditioning Shutoff Switch Cover, OPEN/CLOSE 510 sw 2 pos > 
Helios_L39.ExportArguments["7,3000"] = "7,3007,1"   -- aft Conditioning Shutoff Switch, OPEN/FRONT PILOT CONTROL/CLOSE 511 sw 3 pos  -1.0 0.0 1.0> 
Helios_L39.ExportArguments["49,3014"] = "7,3009,1"   -- De-Icing Mode Switch, MANUAL/AUTOMATIC/OFF  174 sw 3 pos 0.0 0.1 0.2 > "Light System", "Land/Taxi Lights" 655
Helios_L39.ExportArguments["2,3003"] = "7,3010,1"    -- RIO-3 De-Icing Sensor Heating Circuit Check Button - Push to test 183 btn > "Left MFCD", "OSB3" 302
Helios_L39.ExportArguments["2,3017"] = "7,3011,1"   -- Helmet Visor Quick Heating Button - Push to heat 309 btn > "Left MFCD", "OSB17" 316
Helios_L39.ExportArguments["43,3015"] = "7,3012,103"   -- Helmet Heating Mode Switch, AUTO/OFF/ON 308 sw 3 pos  0.0 0.5 1.0 > "IFF", "Ident/Mic Switch" 207
Helios_L39.ExportArguments["7,3000"] = "7,3013,1"   -- Helmet Heating Temperature Rheostat 310 axis 0.1 > 
Helios_L39.ExportArguments["22,3005"] = "34,3004,1"  -- Reserve Intercom Switch, ON/OFF 290 sw 2 pos > "AAP", "CDU Power"   476
Helios_L39.ExportArguments["22,3006"] = "34,3003,1"  -- ADF Audio Switch, ADF/OFF 291 sw 2 pos >       "AAP", "EGI Power"   477
Helios_L39.ExportArguments["58,3006"] = "34,3001,1"  -- Intercom Volume Knob 288 axis lim 0.05 0.0 0.8 >	"Intercom", "VHF Volume" 225
Helios_L39.ExportArguments["58,3008"] = "34,3002,1"  -- Radio Volume Knob 289 axis lim 0.05 0.0 0.8 >   	"Intercom", "UHF Volume" 227
Helios_L39.ExportArguments["2,3019"] = "34,3005,1"  -- Radio Button 134 btn > "Left MFCD", "OSB19" 318
Helios_L39.ExportArguments["2,3020"] = "34,3006,1"  -- Intercom Button 133 btn > "Left MFCD", "OSB20" 319
Helios_L39.ExportArguments["38,3030"] = "19,3003,1"  -- Radio Control Switch, ON/OFF 287 sw 2 pos > "Autopilot", "Emergency Brake" 772
Helios_L39.ExportArguments["38,3031"] = "19,3002,1"  -- Squelch Switch, ON/OFF 286 sw 2 pos > "Autopilot", "HARS-SAS Override/Norm" 196
Helios_L39.ExportArguments["74,3007"] = "19,3001,1"  -- R-832M Preset Channel Selector Knob 284 multi sw 20 pos 0.05 > "TACAN", "Volumne" 261
Helios_L39.ExportArguments["2,3018"] = "6,3001,1"   -- IV-300 Engine Vibration Test Button - Push to test 329 btn > "Left MFCD", "OSB18" 317
Helios_L39.ExportArguments["39,3008"] = "6,3002,1"   -- Fire Extinguish Button Cover OPEN/CLOSE 327 sw 2 pos > "Mechanical", "Auxiliary Landing Gear Handle" 718
Helios_L39.ExportArguments["2,3016"] = "6,3003,1"   -- Fire Extinguish Button - Push to extinguish 328 btn > "Left MFCD", "OSB16" 315
Helios_L39.ExportArguments["40,3003"] = "6,3006,1"   -- Fire Warning Signal Test Switch, I/OFF/II  272 spr sw 3 pos -1.0 0.0 1.0> "Oxygen System", "Emergency Lever" 601
Helios_L39.ExportArguments["6,3000"] = "6,3007,1"   -- RT-12 JPT Regulator Manual Disable Switch Cover, ROPEN/CLOSE 323 sw 2 pos > 
Helios_L39.ExportArguments["6,3000"] = "6,3008,1"   -- RT-12 JPT Regulator Manual Disable Switch, RT-12 DISABLED/RT-12 ENABLED 324 sw 2 pos > 
Helios_L39.ExportArguments["3,3018"] = "6,3009,1"   -- RT-12 JPT Regulator Power Switch, ON/OFF 243 sw 2 pos > "Right MFCD", "OSB18" 343
Helios_L39.ExportArguments["38,3022"] = "6,3010,1"   -- RT-12 JPT Regulator Test Switch, I/OFF/II  242 sw 3 pos -1.0 0.0 1.0 > "Autopilot", "Elevator Emergency Disengage" 180
Helios_L39.ExportArguments["6,3000"] = "6,3011,1"   -- EGT Indicator Switch, FRONT/REAR 499 sw 2 pos > 
Helios_L39.ExportArguments["2,3006"] = "37,3001,1"  -- Flaps Flight Position (0 degrees) Button 281 btn >     "Left MFCD", "OSB6" 305
Helios_L39.ExportArguments["2,3007"] = "37,3002,1"  -- Flaps Takeoff Position (25 degrees) Button 282 btn >   "Left MFCD", "OSB7" 306
Helios_L39.ExportArguments["2,3008"] = "37,3003,1"  -- Flaps Landing Position (44 degrees) Button 283 btn >   "Left MFCD", "OSB8" 307
Helios_L39.ExportArguments["37,3000"] = "37,3021,1"  -- Throttle Limiter 549 sw 2 pos > 
Helios_L39.ExportArguments["37,3000"] = "37,3008,1"  -- Air Brake Switch 135 btn > 
Helios_L39.ExportArguments["8,3010"] = "37,3007,1"  -- Air Brake Switch 136 sw 2 pos > "UFC", "0" 395
Helios_L39.ExportArguments["38,3011"] = "37,3011,1"  -- Landing Gear Control Lever 118 sw 3 pos  -1.0 0.0 1.0 > "Autopilot", "Monitor Test Left/Right" 189
Helios_L39.ExportArguments["47,3001"] = "37,3016,2"  -- Emergency/Parking Wheel Brake Lever 334 axis lim 0.1 -1.0 1.0 > "ADI", "Pitch Trim Knob" 22 -0.5 a 0.5
Helios_L39.ExportArguments["37,3000"] = "37,3024,1"  -- Parking Brake Lever Flag - Push to remove parking brake 334 sw 1 pos ?? > 
Helios_L39.ExportArguments["8,3005"] = "35,3001,1"  -- Main and Emergency Hydraulic Systems Interconnection Lever, FORWARD(OFF)/BACKWARD(ON) 197 sw 2 pos > "UFC", "5"  389
Helios_L39.ExportArguments["8,3006"] = "35,3003,1"  -- Emergency Landing Gear Extension Lever, FORWARD(OFF)/BACKWARD(ON) 194 sw 2 pos >                     "UFC", "6"  390
Helios_L39.ExportArguments["8,3007"] = "35,3005,1"  -- Emergency Flaps Extension Lever, FORWARD(OFF)/BACKWARD(ON) 195 sw 2 pos >                            "UFC", "7"  391
Helios_L39.ExportArguments["8,3008"] = "35,3007,1"  -- RAT (Emergency Generator) Emergency Lever, FORWARD(OFF)/BACKWARD(ON) 196 sw 2 pos >                  "UFC", "8"  392
Helios_L39.ExportArguments["39,3000"] = "39,3002,1"  -- Full pressure failure, ON/STBY/FAILURE 456 sw 3 pos -0.5 0.0 0.5> 
Helios_L39.ExportArguments["39,3000"] = "39,3001,1"  -- Static pressure failure, ON/STBY/FAILURE 457 sw 3 pos -0.5 0.0 0.5 > 
Helios_L39.ExportArguments["9,3042"] = "33,3001,1"  -- Reset Limits 89 btn > "CDU", "P" 452
Helios_L39.ExportArguments["2,3000"] = "2,3001,1"   -- Canopy Handle 998 sw 2 pos > 
Helios_L39.ExportArguments["2,3000"] = "2,3007,1"   -- Forward Canopy Lock Handle 285 lever > 
Helios_L39.ExportArguments["2,3000"] = "2,3009,1"   -- Forward Canopy Emergency Jettison Handle 244 btn > 
Helios_L39.ExportArguments["2,3000"] = "2,3006,1"   -- CPT2 Instrument Flight Practice Hood Control Handle, EXTEND/RETRACT 1000 sw 2 pos > 
Helios_L39.ExportArguments["8,3009"] = "37,3022,1"  -- Pitot Tube Selector Lever, STBY(Left)/MAIN(Right) 333 sw 2 pos > "UFC", "9" 393
Helios_L39.ExportArguments["37,3000"] = "37,3022,1"  -- Panel Visor Extend 627 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3004,1"   	-- CPT2 Net Switch, ON/OFF 502 sw 2 pos > 
Helios_L39.ExportArguments["13,3000"] = "13,3001,1"  -- CPT2 Mech clock left lever (left click) 412 btn 1.0 > 
Helios_L39.ExportArguments["13,3000"] = "13,3002,1"  -- CPT2 Mech clock left lever (right click) 412 btn -1.0 > 
Helios_L39.ExportArguments["13,3000"] = "13,3003,1"  -- CPT2 Mech clock left lever 413 lever 0.04 > 
Helios_L39.ExportArguments["13,3000"] = "13,3004,1"  -- CPT2 Mech clock right lever 414 btn > 
Helios_L39.ExportArguments["13,3000"] = "13,3005,1"  -- CPT2 Mech clock right lever {0.0,0.3} in 0.1 steps 415 Rotary > 
Helios_L39.ExportArguments["10,3000"] = "10,3001,1"  -- CPT2 Baro pressure QFE knob axis 0.6 > 
Helios_L39.ExportArguments["14,3000"] = "14,3005,1"  -- CPT2 RV-5M Radio Altimeter Test Button 398 sw 2 pos > 
Helios_L39.ExportArguments["14,3000"] = "14,3004,1"  -- CPT2 RV-5M Radio Altimeter Decision Height Knob 399 axis 0.2 > 
Helios_L39.ExportArguments["17,3000"] = "17,3013,1"  -- CPT2 MC Synchronization Button - Push to synchronize (level flight only) CP2 444 btn > 
Helios_L39.ExportArguments["23,3000"] = "23,3002,1"  -- CPT2 KPP-1273K Attitude Director Indicator (ADI) Cage Button 367 btn > 
Helios_L39.ExportArguments["23,3000"] = "23,3003,1"  -- CPT2 KPP-1273K Attitude Director Indicator (ADI) Pitch Trim Knob 376 axis 0.05 -1.0, 1.0 > 
Helios_L39.ExportArguments["25,3000"] = "25,3001,1"  -- CPT2 HSI Course set knob 385 axis 0.15 > 
Helios_L39.ExportArguments["16,3000"] = "16,3001,1"  -- CPT2 Variometer adjustment knob 419 axis 0.1  > 
Helios_L39.ExportArguments["21,3000"] = "21,3011,1"  -- CPT2 RKL-41 ADF Outer-Inner Beacon (Far-Near NDB) Switch 440 sw 2 pos > 
Helios_L39.ExportArguments["21,3000"] = "21,3001,1"  -- CPT2 RKL-41 ADF Volume Knob 514 axis 0.05 > 
Helios_L39.ExportArguments["21,3000"] = "21,3013,1"  -- CPT2 RKL-41 ADF Brightness Knob 518 axis 0.05 > 
Helios_L39.ExportArguments["21,3000"] = "21,3002,1"  -- CPT2 RKL-41 ADF Mode Switch, TLF(A3)/TLG(A1,A2) 516 sw 2 pos > 
Helios_L39.ExportArguments["21,3000"] = "21,3003,1"  -- CPT2 RKL-41 ADF Function Selector Switch, OFF/COMP(AUTO)/COMP(MAN)/ANT/LOOP 517 multi sw 5 pos 0.1 > 
Helios_L39.ExportArguments["21,3000"] = "21,3010,1"  -- CPT2 RKL-41 ADF Loop Switch, LEFT/OFF/RIGHT {-1.0,0.0,1.0} 519 spr sw 3 pos > 
Helios_L39.ExportArguments["21,3000"] = "21,3012,1"  -- CPT2 RKL-41 ADF Control Switch, TAKE CONTROL/HAND OVER CONTROL 515 sw 2 pos > 
Helios_L39.ExportArguments["21,3000"] = "21,3004,1"  -- CPT2 RKL-41 ADF Far NDB Frequency Tune 522 axis 0.05  > 
Helios_L39.ExportArguments["21,3000"] = "21,3005,1"  -- CPT2 RKL-41 ADF Far NDB 100kHz rotary 520  weel arc 0.0588 0.0,0.938 > 
Helios_L39.ExportArguments["21,3000"] = "21,3006,1"  -- CPT2 RKL-41 ADF Far NDB 10kHz rotary 521 weel arc 0.1 0.0,0.9 > 
Helios_L39.ExportArguments["21,3000"] = "21,3007,1"  -- CPT2 RKL-41 ADF Near NDB Frequency Tune 525 axis 0.05 > 
Helios_L39.ExportArguments["21,3000"] = "21,3008,1"  -- CPT2 RKL-41 ADF Near NDB 100kHz rotary 523  weel arc 0.0588 0.0,0.938  > 
Helios_L39.ExportArguments["21,3000"] = "21,3009,1"  -- CPT2 RKL-41 ADF Near NDB 10kHz rotary  524 weel arc 0.1 0.0,0.9  > 
Helios_L39.ExportArguments["21,3000"] = "21,3008,1"  -- CPT2 Turbo Button Cover, Open/Close 487 sw 2 pos >
Helios_L39.ExportArguments["4,3000"] = "4,3007,1"   -- CPT2 Turbo Button 488 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3014,1"   -- CPT2 Engine Button Cover, Open/Close 493 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3013,1"   -- CPT2 Engine Button 494 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3018,1"   -- CPT2 Stop Engine Switch Cover, Open/Close 489 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3017,1"   -- CPT2 Stop Engine Switch 490 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3024,1"   -- CPT2 Emergency Fuel Switch Cover, Open/Close 491 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3023,1"   -- CPT2 Emergency Fuel Switch 492 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3064,1"   -- CPT2 CB Seat, ON/OFF 503 sw 2 pos > 
Helios_L39.ExportArguments["4,3000"] = "4,3065,1"   -- CPT2 CB Signal, ON/OFF 504 sw 2 pos > 
Helios_L39.ExportArguments["20,3000"] = "20,3007,1"  -- CPT2 Taxi and Landing Lights (Searchlights) Control Switch, TAXI/OFF/LANDING 486 sw 3 pos -1.0 0.0 1.0 > 
Helios_L39.ExportArguments["20,3000"] = "20,3010,1"  -- CPT2 Instrument Lighting Switch, Red/OFF/White 497 sw 3 pos -1.0 0.0 1.0 > 
Helios_L39.ExportArguments["20,3000"] = "20,3011,1"  -- CPT2 Instrument Lights Intensity Knob 498 axis 0.1 > 
Helios_L39.ExportArguments["20,3000"] = "20,3014,1"  -- CPT2 Warning-Light Intensity Knob 537 axis 0.1 > 
Helios_L39.ExportArguments["20,3000"] = "20,3015,1"  -- CPT2 Warning-Light Check Button - Push to check 538 btn > 
Helios_L39.ExportArguments["3,3000"] = "3,3018,1"   -- CPT2 Arm/Safe Bombs Emergency Jettison Switch cover, OPEN/CLOSE 508 sw 2 pos > 
Helios_L39.ExportArguments["3,3000"] = "3,3019,1"   -- CPT2 Arm/Safe Bombs Emergency Jettison Switch, LIVE/BOMBS/BLANK 509 sw 3 pos > 
Helios_L39.ExportArguments["3,3000"] = "3,3022,1"   -- CPT2 Emergency Jettison Switch cover, OPEN/CLOSE 506 sw 2 pos > 
Helios_L39.ExportArguments["3,3000"] = "3,3021,1"   -- CPT2 Emergency Jettison Switch, ON/OFF 507 sw 2 pos > 
Helios_L39.ExportArguments["30,3000"] = "30,3005,1"  -- CPT2 Emergency Oxygen Switch, ON/OFF 479 sw 2 pos > 
Helios_L39.ExportArguments["30,3000"] = "30,3007,1"  -- CPT2 Diluter Demand Switch, 100% / MIX 480 sw 2 pos > 
Helios_L39.ExportArguments["30,3000"] = "30,3002,1"  -- CPT2 Oxygen Supply Valve (CLOSE - CW, OPEN - CCW) 482  axis 0.05 > 
Helios_L39.ExportArguments["5,3000"] = "5,3003,1"   -- CPT2 Fuel Shut-Off Lever 475 lever 0.0 1.0 > 
Helios_L39.ExportArguments["7,3000"] = "7,3002,1"   -- CPT2 ECS and Pressurization Handle, OFF/CANOPIES SEALED/ECS ON 245 axis 0.1 > 
Helios_L39.ExportArguments["34,3000"] = "34,3010,1"  -- CPT2 Reserve Intercom Switch, ON/OFF 473 sw 2 pos > 
Helios_L39.ExportArguments["34,3000"] = "34,3009,1"  -- CPT2 ADF Audio Switch, ADF/OFF 474 sw 2 pos > 
Helios_L39.ExportArguments["34,3000"] = "34,3007,1"  -- CPT2 Intercom Volume Knob 471 axis lim 0.05 0.0 0.8 >  
Helios_L39.ExportArguments["34,3000"] = "34,3008,1"  -- CPT2 Radio Volume Knob 472 axis lim 0.05 0.0 0.8 > 
Helios_L39.ExportArguments["34,3000"] = "34,3011,1"  -- CPT2 Radio Button 547 btn > 
Helios_L39.ExportArguments["34,3000"] = "34,3012,1"  -- CPT2 Intercom Button 546 btn > 
Helios_L39.ExportArguments["19,3000"] = "19,3006,1"  -- CPT2 R-832M Radio Control Switch, ON/OFF 470 sw 2 pos > 
Helios_L39.ExportArguments["19,3000"] = "19,3005,1"  -- CPT2 R-832M Squelch Switch, ON/OFF 469 sw 2 pos > 
Helios_L39.ExportArguments["19,3000"] = "19,3004,1"  -- CPT2 R-832M Preset Channel Selector Knob 468 multi sw 20 pos 0.05  > 
Helios_L39.ExportArguments["6,3000"] = "6,3004,1"   -- CPT2 Fire Extinguish Button Cover, OPEN/CLOSE 495 sw 2 pos > 
Helios_L39.ExportArguments["6,3000"] = "6,3005,1"   -- CPT2 Fire Extinguish Button - Push to extinguish 496 btn > 
Helios_L39.ExportArguments["37,3000"] = "37,3004,1"  -- CPT2 Flaps Flight Position (0 degrees) Button 465 btn > 
Helios_L39.ExportArguments["37,3000"] = "37,3005,1"  -- CPT2 Flaps Takeoff Position (25 degrees) Button 466 btn > 
Helios_L39.ExportArguments["37,3000"] = "37,3006,1"  -- CPT2 Flaps Landing Position (44 degrees) Button 467 btn > 
Helios_L39.ExportArguments["37,3000"] = "37,3009,1"  -- CPT2 Air Brake Switch 548 sw 3 pos  -1.0 0.0 1.0  > 
Helios_L39.ExportArguments["37,3000"] = "37,3012,1"  -- CPT2 Landing Gear Control Lever 437 sw 3 pos  -1.0 0.0 1.0 > 
Helios_L39.ExportArguments["37,3000"] = "37,3017,1"  -- CPT2 Emergency/Parking Wheel Brake Lever 501 axis lim 0.1 0.0 1.0> 
Helios_L39.ExportArguments["35,3000"] = "35,3002,1"  -- CPT2 Main and Emergency Hydraulic Systems Interconnection Lever, FORWARD(OFF)/BACKWARD(ON) 536 sw 2 pos > 
Helios_L39.ExportArguments["35,3000"] = "35,3004,1"  -- CPT2 Emergency Landing Gear Extension Lever, FORWARD(OFF)/BACKWARD(ON) 533 sw 2 pos > 
Helios_L39.ExportArguments["35,3000"] = "35,3006,1"  -- CPT2 Emergency Flaps Extension Lever, FORWARD(OFF)/BACKWARD(ON) 534 sw 2 pos > 
Helios_L39.ExportArguments["35,3000"] = "35,3008,1"  -- CPT2 RAT (Emergency Generator) Emergency Lever, FORWARD(OFF)/BACKWARD(ON) 535 sw 2 pos > 
Helios_L39.ExportArguments["2,3000"] = "2,3002,1"   -- CPT2 Canopy Handle 999 sw 2 pos > 
Helios_L39.ExportArguments["2,3000"] = "2,3008,1"   -- CPT2 Rearward Canopy Lock Handle 485 lever > 
Helios_L39.ExportArguments["2,3000"] = "2,3010,1"   -- CPT2 Rearward Canopy Emergency Jettison Handle 539 btn > 
