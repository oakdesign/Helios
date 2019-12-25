Helios_F18C = {}

Helios_F18C.Name = "FA-18C_hornet"
Helios_F18C.FlamingCliffsAircraft = false
Helios_F18C.ExportArguments = {}

function Helios_F18C.ProcessInput(data)
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
		lConvDevice = Helios_F18C.ExportArguments[sIndex] 	
		lArgument = Helios_Util.Split(string.sub(lConvDevice,1),",")
		min_clamp = 0
		max_clamp = 1
		
		if lArgument[3]=="300" then   -- several axis exported in the same rotator encoder, because i dont have enought axis outputs in the A10C Helios interface
			local valor_actual = GetDevice(0)
			local absoluto= math.abs(lCommandArgs[3])
			local variacion= (lCommandArgs[3]/absoluto)/10
				
			if absoluto==0.1 then
				valor_axis= valor_actual:get_argument_value(174) + variacion
				lArgument = {33,3007,1} -- IFEI Lights Dimmer Control max 0.5?
			end
			if absoluto==0.15 then
				valor_axis =  variacion/10
				lArgument = {32,3003,1} -- -- Cage Standby Attitude Indicator  var 0.3
				min_clamp = -1
			end
			if absoluto==0.2 then
				valor_axis =  variacion/10
				lArgument = {26,3001,1} -- AAU-52 Altimeter Pressure Setting Knob lim 0.04-0.6 var 0.01
				min_clamp = -1
			end
			if absoluto==0.25 then
				valor_axis= valor_actual:get_argument_value(262) + variacion
				lArgument = {0,3130,1} -- ALR-67 AUDIO Control Knob (no function) var 0.01
			end
			if absoluto==0.3 then
				valor_axis= valor_actual:get_argument_value(357) + variacion
				lArgument = {40,3002,1} -- VOX Volume Control Knob var 0.01
			end
			if absoluto==0.35 then
				valor_axis =  variacion/10
				lArgument = {30,3002,1} --ID2163A low altitude var 0.01
				min_clamp = -1
			end
			if absoluto==0.40 then
				valor_axis =  variacion
				lArgument = {44,3002,1} -- INS Switch, OFF/CV/GND/NAV/IFA/GYRO/GB/TEST
				min_clamp = -1
			end
			if absoluto==0.45 then
				valor_axis= valor_actual:get_argument_value(446) + variacion
				lArgument = {41,3002,1} -- KY58_FillSw 8 pos
			end
			if absoluto==0.50 then
				valor_axis= valor_actual:get_argument_value(440) + variacion
				lArgument = {42,3001,1} -- KY58_radarSw 4 pos
			end
			if absoluto==0.55 then
				valor_axis= valor_actual:get_argument_value(504) + variacion
				lArgument = {2,3012,1} -- Throttles Friction Adjusting Lever
			end

			
			lCommandArgs[3]=math.max(min_clamp, math.min(1, valor_axis))	
		end
			
		
		lDevice = GetDevice(lArgument[1])    -- data conversions between switches A10C and F18
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

function Helios_F18C.HighImportance(mainPanelDevice)
	local _LAST_ONE = 0 -- used to mark the end of the tables	
	local MainPanel = GetDevice(0)

	-- Electric Interface
	local VoltmeterU = MainPanel:get_argument_value(400) 	-- 0 to 1
	local VoltmeterE = MainPanel:get_argument_value(401) 	-- 0 to 1
	-- Hydraulic Interface
	local HydIndLeft = MainPanel:get_argument_value(310) 	-- 0 to 1
	local HydIndRight = MainPanel:get_argument_value(311) 	-- 0 to 1
	local HydIndBrake = MainPanel:get_argument_value(242) 	-- 0 to 1
	-- Gear Interface
	local EmergGearDownHandle = MainPanel:get_argument_value(228) 	-- 0 to 1
	local EmergParkBrakeHandle = MainPanel:get_argument_value(240) 	-- 0 to 1
	-- Standby Pressure Altimeter AAU-52/A
	local Altimeter_100_footPtr = MainPanel:get_argument_value(218) 	-- 0 to 1
	local Altimeter_10000_footCount = MainPanel:get_argument_value(220) 	-- 0 to 1
	local Altimeter_1000_footCount = Helios_Util.ValueConvert(MainPanel:get_argument_value(219),{-1.0, 0.0, 0.0, 10.0},{0.9, 1.0, 0.0, 1.0})
	local pressure_setting_0 = MainPanel:get_argument_value(221) 	-- 0 to 1
	local pressure_setting_1 = MainPanel:get_argument_value(222) 	-- 0 to 1
	local pressure_setting_2 = Helios_Util.ValueConvert(MainPanel:get_argument_value(223),{26, 31},{0.0, 1.0})
	-- Indicated Airspeed Indicator AVU-35/A
	local Airspeed = MainPanel:get_argument_value(217) 	-- 0 to 1
	-- Vertical Speed Indicator AVU-53/A
	local Variometer = Helios_Util.ValueConvert(MainPanel:get_argument_value(225),{-6000.0, -4000.0, -3000.0, -2000.0, -1000.0, -500.0, 0.0, 500.0, 1000.0, 2000.0, 3000.0, 4000.0, 6000.0},{   -1.0,   -0.83,   -0.73,  -0.605,   -0.40,  -0.22, 0.0,  0.22,   0.40,  0.605,   0.73,   0.83,    1.0})
	-- Clock
	local CLOCK_currtime_hours = MainPanel:get_argument_value(278) 	-- 0 to 1
	local CLOCK_currtime_minutes = MainPanel:get_argument_value(279) 	-- 0 to 1
	local CLOCK_elapsed_time_minutes = MainPanel:get_argument_value(281) 	-- 0 to 1
	local CLOCK_elapsed_time_seconds = MainPanel:get_argument_value(280) 	-- 0 to 1
	-- ID-2163/A
	local Min_Height_Indicator_ID2163A = MainPanel:get_argument_value(287) 	-- 0 to 1
	local Altitude_Pointer_ID2163A = MainPanel:get_argument_value(286) 	-- 0 to 1
	local OFF_Flag_ID2163A = MainPanel:get_argument_value(288) 	-- 0 to 1
	local Red_Lamp_ID2163A = MainPanel:get_argument_value(290) 	-- 0 to 1
	local Green_Lamp_ID2163A = MainPanel:get_argument_value(289) 	-- 0 to 1
	-- SAI
	local SAI_Pitch = MainPanel:get_argument_value(205) 	-- -1 to 1
	local SAI_Bank = MainPanel:get_argument_value(206) 	-- -1 to 1
	local SAI_attitude_warning_flag = MainPanel:get_argument_value(209) 	-- 0 to 1
	local SAI_manual_pitch_adjustment = MainPanel:get_argument_value(210) 	-- -1 to 1
	local SAI_SlipBall = MainPanel:get_argument_value(207) 	-- -1 to 1
	local SAI_RateOfTurn = MainPanel:get_argument_value(208) 	-- -1 to 1
	-- Cockpit Pressure Altimeter
	local CockpitPressureAltimeter = MainPanel:get_argument_value(285)
	local Windfold_pull = MainPanel:get_argument_value(296)
	-- additional axis values:
	local IFEI_Lights = MainPanel:get_argument_value(174) 
	local Cage_SAI = MainPanel:get_argument_value(214) 
	local AAU52_Pressure = MainPanel:get_argument_value(224) 
	local ALR67_AUDIO = MainPanel:get_argument_value(262) 
	local VOX_Volume = MainPanel:get_argument_value(357) 
	local ID2163A_Low_altitude= MainPanel:get_argument_value(291) 
	local KY58_FillSw= MainPanel:get_argument_value(446) 
	local RADAR_SW= MainPanel:get_argument_value(440)
	local EMERGENCY_BRAKE= MainPanel:get_argument_value(241)
	local FRICTION = MainPanel:get_argument_value(504)  
	-- RWR panel lights
	local FAIL_light = MainPanel:get_argument_value(264)   -- FAIL light
	local BIT_light = MainPanel:get_argument_value(265)   -- BIT light
	local ENABLE_light = MainPanel:get_argument_value(267)   -- ENABLE light
	local OFFSET_light = MainPanel:get_argument_value(268)   -- OFFSET light
	local SPECIAL_UP_light = MainPanel:get_argument_value(270)   -- SPECIAL UP light
	local SPECIAL_light = MainPanel:get_argument_value(271)   -- SPECIAL light
	local LIMIT_light = MainPanel:get_argument_value(273)   -- LIMIT light
	local DISPLAY_light = MainPanel:get_argument_value(274)   -- DISPLAY light
	local ON_light = MainPanel:get_argument_value(276)   -- ON light
	
	
	--    >>> "SAI", "Pitch Adjust"							F18 instruments
	Helios_Udp.Send("715", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.1f",
		VoltmeterU, --1
		VoltmeterE, --2
		HydIndLeft, --3
		HydIndRight, --4
		HydIndBrake, --5
		EmergGearDownHandle, --6
		EmergParkBrakeHandle, --7
		Altimeter_100_footPtr, --8
		Altimeter_10000_footCount, --9
		Altimeter_1000_footCount, --10
		pressure_setting_0, --11
		pressure_setting_1, --12
		pressure_setting_2, --13
		Airspeed, --14
		Variometer, --15
		Windfold_pull, --16
		_LAST_ONE  -- Last one, do not delete this
	) )
		
	
	-- >>> "ADI", "Glide Slope Indicator"					F18 clock and SAI  
	Helios_Udp.Send("27", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
		CLOCK_currtime_hours,--1
		CLOCK_currtime_minutes,--2
		CLOCK_elapsed_time_minutes,--3
		CLOCK_elapsed_time_seconds,--4
		Min_Height_Indicator_ID2163A,--5
		Altitude_Pointer_ID2163A,--6
		OFF_Flag_ID2163A,--7
		Red_Lamp_ID2163A,--8
		Green_Lamp_ID2163A,--9
		SAI_Pitch,--10
		SAI_Bank,--11
		SAI_attitude_warning_flag,--12
		SAI_manual_pitch_adjustment, --13
		SAI_SlipBall,--14
		SAI_RateOfTurn,--15
		CockpitPressureAltimeter,--16
		_LAST_ONE  -- Last one, do not delete this
	) )
			

	 -->>>	"ADI", "Turn Needle"                          F18 adittional axis values
	Helios_Udp.Send("23", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
		IFEI_Lights,--1
		Cage_SAI,--2
		AAU52_Pressure,--3
		ALR67_AUDIO,--4
		VOX_Volume,--5
		ID2163A_Low_altitude,--6
		KY58_FillSw,--7
		RADAR_SW,--8
		EMERGENCY_BRAKE, --9
		FRICTION, --10
		_LAST_ONE  -- Last one, do not delete this
	) )
	
	
	-->>>	"ADI", "Slip Ball"                           F18 RWR lights
	Helios_Udp.Send("24", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f",
		FAIL_light,--1
		BIT_light,--2
		ENABLE_light,--3
		OFFSET_light,--4
		SPECIAL_UP_light,--5
		SPECIAL_light,--6
		LIMIT_light,--7
		DISPLAY_light,--8
		ON_light, --9
		_LAST_ONE  -- Last one, do not delete this
	) )
	
	--Helios_Udp.Send("21", string.format("%s", table.concat(IFEI_Textures_table,", ") ) )   	    >>> "ADI", "Pitch Steering Bar Offset"
	--Helios_Udp.Send("20", string.format("%s", table.concat(UFC_table,", ") ) )        >>> "ADI", "Bank Steering Bar Offset"
	-- >>>	"UHF Radio", "Fequency"
	--	Helios_Udp.Send("2000", string.format("%.3f,",

	--		_LAST_ONE  -- Last one, do not delete this
	--) )
			
	Helios_Udp.Flush()
end

function Helios_F18C.LowImportance(mainPanelDevice)
	--lamps
	Helios_Udp.Send("540", string.format("%.1d", mainPanelDevice:get_argument_value(298)) )   -- CPT_LTS_CK_SEAT				>  "AOA Indexer", "High Indicator", "High AOA indicator light."
	Helios_Udp.Send("542", string.format("%.1d", mainPanelDevice:get_argument_value(299)) )   -- CPT_LTS_APU_ACC				>  "AOA Indexer", "Low Indicator", "Low AOA indicator light."
	Helios_Udp.Send("730", string.format("%.1d", mainPanelDevice:get_argument_value(300)) )   -- CPT_LTS_BATT_SW				>  "Refuel Indexer", "Ready Indicator", "Refuel ready indicator light."
	Helios_Udp.Send("731", string.format("%.1d", mainPanelDevice:get_argument_value(301)) )   -- CPT_LTS_FCS_HOT				>  "Refuel Indexer", "Latched Indicator", "Refuel latched indicator light."
	Helios_Udp.Send("732", string.format("%.1d", mainPanelDevice:get_argument_value(302)) )   -- CPT_LTS_GEN_TIE				>  "Refuel Indexer", "Disconnect Indicator", "Refuel disconnect indicator light."
	Helios_Udp.Send("662", string.format("%.1d", mainPanelDevice:get_argument_value(303)) )   -- CPT_LTS_SPARE_CTN1			>  "Misc", "Gun Ready Indicator", "Indicator is lit when the GAU-8 cannon is armed and ready to fire."
	Helios_Udp.Send("216", string.format("%.1d", mainPanelDevice:get_argument_value(304)) )   -- CPT_LTS_FUEL_LO				>  "Fire System", "APU Fire Indicator", "Indicator lights when a fire is detedted in the APU."
	Helios_Udp.Send("217", string.format("%.1d", mainPanelDevice:get_argument_value(305)) )   -- CPT_LTS_FCES					>  "Fire System", "Right Engine Fire Indicator", "Indicator lights when a fire is detected in the right engine."
	Helios_Udp.Send("404", string.format("%.1d", mainPanelDevice:get_argument_value(306)) )   -- CPT_LTS_SPARE_CTN2			>  "UFC", "Master Caution Indicator", "Indicator lamp on master caution button." 
	Helios_Udp.Send("659", string.format("%.1d", mainPanelDevice:get_argument_value(307)) )   -- CPT_LTS_L_GEN					>  "Mechanical", "Gear Nose Safe Indicator", "Lit when the nose gear is down and locked."
	Helios_Udp.Send("661", string.format("%.1d", mainPanelDevice:get_argument_value(308)) )   -- CPT_LTS_R_GEN					>  "Mechanical", "Gear Right Safe Indicator", "Lit when the right gear is down and locked."
	Helios_Udp.Send("737", string.format("%.1d", mainPanelDevice:get_argument_value(309)) )   -- CPT_LTS_SPARE_CTN3			>  "Mechanical", "Gear Handle Indicator", "Lit when the landing gear are moving between down and stowed position."
	Helios_Udp.Send("606", string.format("%.1d", mainPanelDevice:get_argument_value( 13)) )   -- CPT_LTS_MASTER_CAUTION		>  "Navigation Mode Select Panel", "HARS Indicator", "HARS button indicator lamp."
	Helios_Udp.Send("608", string.format("%.1d", mainPanelDevice:get_argument_value( 10)) )   -- CPT_LTS_FIRE_LEFT				>  "Navigation Mode Select Panel", "EGI Indicator", "EGI button indicator lamp."
	Helios_Udp.Send("610", string.format("%.1d", mainPanelDevice:get_argument_value( 15)) )   -- CPT_LTS_GO					>  "Navigation Mode Select Panel", "TISL Indicator", "TISL button indicator lamp."
	Helios_Udp.Send("612", string.format("%.1d", mainPanelDevice:get_argument_value( 16)) )   -- CPT_LTS_NO_GO					>  "Navigation Mode Select Panel", "STEERPT Indicator", "STEERPT button indicator lamp."
	Helios_Udp.Send("614", string.format("%.1d", mainPanelDevice:get_argument_value( 17)) )   -- CPT_LTS_L_BLEED				>  "Navigation Mode Select Panel", "ANCHR Indicator", "ANCHR button indicator lamp."
	Helios_Udp.Send("616", string.format("%.1d", mainPanelDevice:get_argument_value( 18)) )   -- CPT_LTS_R_BLEED				>  "Navigation Mode Select Panel", "TCN Indicator", "TCN button indicator lamp."
	Helios_Udp.Send("484", string.format("%.1d", mainPanelDevice:get_argument_value( 19)) )   -- CPT_LTS_SPD_BRK				>  "Caution Panel", "ANTI SKID", "Lit if landing gear is down but anti-skid is disengaged."
	Helios_Udp.Send("485", string.format("%.1d", mainPanelDevice:get_argument_value( 20)) )   -- CPT_LTS_STBY					>  "Caution Panel", "L-HYD RES", "Lit if left hyudraulic fluid reservoir is low."
	Helios_Udp.Send("46",  string.format("%.1d", mainPanelDevice:get_argument_value( 21)) )   -- CPT_LTS_L_BAR_RED				>  "HSI", "Bearing Flag" 
	Helios_Udp.Send("488", string.format("%.1d", mainPanelDevice:get_argument_value( 22)) )   -- CPT_LTS_REC					>  "Caution Panel", "ELEV DISENG", "Lit if at least one elevator is disengaged from the Emergency Flight Control panel."
	Helios_Udp.Send("489", string.format("%.1d", mainPanelDevice:get_argument_value( 23)) )   -- CPT_LTS_L_BAR_GREEN			>  "Caution Panel", "VOID1", ""
	Helios_Udp.Send("491", string.format("%.1d", mainPanelDevice:get_argument_value( 24)) )   -- CPT_LTS_XMIT					>  "Caution Panel", "BLEED AIR LEAK", "Lit if bleed air is 400 degrees or higher."
	Helios_Udp.Send("493", string.format("%.1d", mainPanelDevice:get_argument_value( 25)) )   -- CPT_LTS_ASPJ_OH				>  "Caution Panel", "L-AIL TAB", "Lit if left aileron is not at normal positoin due to MRFCS."
	Helios_Udp.Send("495", string.format("%.1d", mainPanelDevice:get_argument_value( 29)) )   -- CPT_LTS_FIRE_APU				>  "Caution Panel", "SERVICE AIR HOT", "Lit if air temperature exceeds allowable ECS range."
	Helios_Udp.Send("496", string.format("%.1d", mainPanelDevice:get_argument_value( 26)) )   -- CPT_LTS_FIRE_RIGHT			>  "Caution Panel", "PITCH SAS", "Lit if at least one pitch SAS channel has been disabled."
	Helios_Udp.Send("497", string.format("%.1d", mainPanelDevice:get_argument_value( 31)) )   -- CPT_LTS_RCDR_ON				>  "Caution Panel", "L-ENG HOT", "Lit if left engine ITT exceeds 880 degrees C."
	Helios_Udp.Send("498", string.format("%.1d", mainPanelDevice:get_argument_value( 32)) )   -- CPT_LTS_DISP					>  "Caution Panel", "R-ENG HOT", "Lit if right engine ITT exceeds 880 degrees C."
	Helios_Udp.Send("499", string.format("%.1d", mainPanelDevice:get_argument_value( 38)) )   -- CPT_LTS_SAM					>  "Caution Panel", "WINDSHIELD HOT", "Lit if windshield temperature exceeds 150 degrees F."
	Helios_Udp.Send("504", string.format("%.1d", mainPanelDevice:get_argument_value( 39)) )   -- CPT_LTS_AI					>  "Caution Panel", "GCAS", "Lit if LASTE failure is detected that affects GCAS."
	Helios_Udp.Send("507", string.format("%.1d", mainPanelDevice:get_argument_value( 40)) )   -- CPT_LTS_AAA					>  "Caution Panel", "VOID2", ""
	Helios_Udp.Send("509", string.format("%.1d", mainPanelDevice:get_argument_value( 41)) )   -- CPT_LTS_CW					>  "Caution Panel", "L-WING PUMP", "Lit if boost pump pressure is low."
	Helios_Udp.Send("511", string.format("%.1d", mainPanelDevice:get_argument_value( 33)) )   -- CPT_LTS_SPARE_RH1				>  "Caution Panel", "HARS", "Lit if44,  HARS heading or attitude is invalid."
	Helios_Udp.Send("512", string.format("%.1d", mainPanelDevice:get_argument_value( 34)) )   -- CPT_LTS_SPARE_RH2				>  "Caution Panel", "IFF MODE-4", "Lit if inoperative mode 4 capability is detected."
	Helios_Udp.Send("513", string.format("%.1d", mainPanelDevice:get_argument_value( 35)) )   -- CPT_LTS_SPARE_RH3				>  "Caution Panel", "L-MAIN FUEL LOW", "Lit if left main fuel tank has 500 pounds or less."
	Helios_Udp.Send("515", string.format("%.1d", mainPanelDevice:get_argument_value( 36)) )   -- CPT_LTS_SPARE_RH4				>  "Caution Panel", "L-R TKS UNEQUAL", "Lit if thers is a 750 or more pund difference between the two main fuel tanks."
	Helios_Udp.Send("517", string.format("%.1d", mainPanelDevice:get_argument_value( 37)) )   -- CPT_LTS_SPARE_RH5				>  "Caution Panel", "L-FUEL PRESS", "Lit if low fuel pressure is detected in fuel feed lines."
	Helios_Udp.Send("518", string.format("%.1d", mainPanelDevice:get_argument_value(152)) )   -- CPT_LTS_CTR					>  "Caution Panel", "R-FUEL PRESS", "Lit if low fuel pressure is detected in fuel feed lines."
	Helios_Udp.Send("519", string.format("%.1d", mainPanelDevice:get_argument_value(154)) )   -- CPT_LTS_LI					>  "Caution Panel", "NAV", "Lit if there is a CDU failure while in alignment mode."
	Helios_Udp.Send("520", string.format("%.1d", mainPanelDevice:get_argument_value(156)) )   -- CPT_LTS_LO					>  "Caution Panel", "STALL SYS", "Lit if there is a power failure to the AoA and Mach meters."
	Helios_Udp.Send("521", string.format("%.1d", mainPanelDevice:get_argument_value(158)) )   -- CPT_LTS_RI					>  "Caution Panel", "L-CONV", "Lit if left electrical converter fails."
	Helios_Udp.Send("522", string.format("%.1d", mainPanelDevice:get_argument_value(160)) )   -- CPT_LTS_RO					>  "Caution Panel", "R-CONV", "Lit if right electrical converter fails."
	Helios_Udp.Send("523", string.format("%.1d", mainPanelDevice:get_argument_value(166)) )   -- CPT_LTS_NOSE_GEAR				>  "Caution Panel", "CADC", "Lit if CADC has failed."
	Helios_Udp.Send("525", string.format("%.1d", mainPanelDevice:get_argument_value(165)) )   -- CPT_LTS_LEFT_GEAR				>  "Caution Panel", "L-GEN", "Lit if left generator has shut down or AC power is out of limits."
	Helios_Udp.Send("527", string.format("%.1d", mainPanelDevice:get_argument_value(167)) )   -- CPT_LTS_RIGHT_GEAR			>  "Caution Panel", "INST INV", "Lit if AC powered systems are not receiving power from inverter."
	Helios_Udp.Send("191", string.format("%.1d", mainPanelDevice:get_argument_value(163)) )   -- CPT_LTS_HALF_FLAPS			>  "Autopilot", "Take Off Trim Indicator", "Lit when reseting autopilot for take off trim"
	Helios_Udp.Send("799", string.format("%.1d", mainPanelDevice:get_argument_value(164)) )   -- CPT_LTS_FULL_FLAPS			>  "IFF", "Test Lamp", ""
	Helios_Udp.Send("178", string.format("%.1d", mainPanelDevice:get_argument_value(162)) )   -- CPT_LTS_FLAPS					>  "Autopilot", "Left Aileron Disengage Indicator", "Lit when the left aileron is disengaged."
	Helios_Udp.Send("181", string.format("%.1d", mainPanelDevice:get_argument_value(  1)) )   -- CPT_LTS_LOCK					>  "Autopilot", "Left Elevator Disengage Indicator", "Lit when the left elevator is disengaged."
	Helios_Udp.Send("55",  string.format("%.1d", mainPanelDevice:get_argument_value(  2)) )   -- CPT_LTS_SHOOT					>  "AOA", "Off Flag", ""
	Helios_Udp.Send("25",  string.format("%.1d", mainPanelDevice:get_argument_value(  3)) )   -- CPT_LTS_SHOOT_STROBE			>  "ADI", "Attitude Warning Flag", "Indicates that the ADI has lost electrical power or otherwise been disabled."
	Helios_Udp.Send("26",  string.format("%.1d", mainPanelDevice:get_argument_value( 47)) )   -- CPT_LTS_AA					>  "ADI", "Glide Slope Warning Flag", "Indicates that the ADI is not recieving a ILS glide slope signal."
	Helios_Udp.Send("40",  string.format("%.1d", mainPanelDevice:get_argument_value( 48)) )   -- CPT_LTS_AG					>  "HSI", "Power Off Flag"
	Helios_Udp.Send("32",  string.format("%.1d", mainPanelDevice:get_argument_value( 45)) )   -- CPT_LTS_DISCH					>  "HSI", "Range Flag"
	Helios_Udp.Send("541", string.format("%.1d", mainPanelDevice:get_argument_value( 44)) )   -- CPT_LTS_READY					>  "AOA Indexer", "Normal Indicator", "Norm AOA indidcator light."
	Helios_Udp.Send("663", string.format("%.1d", mainPanelDevice:get_argument_value(294)) )   -- CPT_LTS_HOOK					>  "Misc", "Nose Wheel Steering Indicator", "Indicator is lit when nose wheel steering is engaged."
	--Helios_Udp.Send("665", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_LDG_GEAR_HANDLE *		>  "Misc", "Canopy Unlocked Indicator", "Indicator is lit when canopy is open."
	Helios_Udp.Send("664", string.format("%.1d", mainPanelDevice:get_argument_value(376)) )   -- CPT_LTS_APU_READY	 			>  "Misc", "Marker Beacon Indicator", "Indicator is lit when in ILS mode and a beacon is overflown."
	--Helios_Udp.Send("215", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_SEL *	 				>  "Fire System", "Left Engine Fire Indicator", "Indicator lights when a fire is detected in the left engine."
	Helios_Udp.Send("372", string.format("%.1d", mainPanelDevice:get_argument_value(137)) )   -- CPT_LTS_SPN	 				>  "CMSC", "Missle Launch Indicator", "Flashes when missile has been launched near your aircraft."
	Helios_Udp.Send("373", string.format("%.1d", mainPanelDevice:get_argument_value(290)) )   -- CPT_LTS_LOW_ALT_WARN	 		>  "CMSC", "Priority Status Indicator", "Lit when priority display mode is active."
	--Helios_Udp.Send("374", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_ARM_LEFT *			>  "CMSC", "Unknown Status Indicator", "Lit when unknown threat display is active."
	--Helios_Udp.Send("660", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_ARM_RIGHT *			>  "Mechanical", "Gear Left Safe Indicator", "Lit when the left gear is down and locked."
	--Helios_Udp.Send("618", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_SAFE_LEFT *			>  "Navigation Mode Select Panel", "ILS Indicator", "ILS button indicator lamp."
	--Helios_Udp.Send("619", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_SAFE_RIGHT *			>  "Navigation Mode Select Panel", "UHF Homing Indicator", "Lit when the UHF control panel is ste to ADF."
	--Helios_Udp.Send("620", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_CONTR_LEFT *			>  "Navigation Mode Select Panel", "VHF/FM Homing Indicator", "Lit when the VHF/FM control panel is set to homing mode."
	--Helios_Udp.Send("600", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_CONTR_RIGHT *			>  "Oxygen System", "Breathflow", "Flashs with each breath."
	--Helios_Udp.Send("480", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_DCDR_LEFT*			>  "Caution Panel", "ENG START CYCLE", "Lit if either engine is in engine start process."
	--Helios_Udp.Send("481", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_DCDR_RIGHT *			>  "Caution Panel", "L-HYD PRESS", "Lit if left hydraulic system pressure falls below 1,000 psi."
	--Helios_Udp.Send("482", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- CPT_LTS_USG_XMT*	 			>  "Caution Panel", "R-HYD PRESS", "Lit if right hydraulic system pressure falls below 1,000 psi."
	Helios_Udp.Send("483", string.format("%.1d", mainPanelDevice:get_argument_value(  4)) )   -- CPT_LTS_AOA_HIGH 				>  "Caution Panel", "GUN UNSAFE", "Lit if gun is capable of being fired."
	Helios_Udp.Send("487", string.format("%.1d", mainPanelDevice:get_argument_value(  5)) )   -- CPT_LTS_AOA_CENTER			>  "Caution Panel", "OXY LOW", "Lit if oxygen gauge indices 0.5 liters or less."
	Helios_Udp.Send("490", string.format("%.1d", mainPanelDevice:get_argument_value(  6)) )   -- CPT_LTS_AOA_LOW      			>  "Caution Panel", "SEAT NOT ARMED", "Lit if ground safety lever is in the safe position."
	Helios_Udp.Send("492", string.format("%.1d", mainPanelDevice:get_argument_value(460)) )   -- Console_lt					>  "Caution Panel", "AIL DISENG", "Lit if at least one aileron is disngaged from the Emergency FLight Control panel."
	Helios_Udp.Send("494", string.format("%.1d", mainPanelDevice:get_argument_value(461)) )   -- Flood_lt						>  "Caution Panel", "R-AIL TAB", "Lit if right aileron is not at normal positoin due to MRFCS."
	Helios_Udp.Send("500", string.format("%.1d", mainPanelDevice:get_argument_value(462)) )   -- NvgFlood_lt					>  "Caution Panel", "YAW SAS", "Lit if at least one yaw SAS channel has been disabled."
	Helios_Udp.Send("501", string.format("%.1d", mainPanelDevice:get_argument_value(464)) )   -- EmerInstr_lt					>  "Caution Panel", "L-ENG OIL PRESS", "Lit if left engine oil pressure is less than 27.5 psi."
	Helios_Udp.Send("502", string.format("%.1d", mainPanelDevice:get_argument_value(465)) )   -- EngInstFlood_lt				>  "Caution Panel", "R-ENG OIL PRESS", "Lit if right engine oil pressure is less than 27.5 psi."
	Helios_Udp.Send("503", string.format("%.1d", mainPanelDevice:get_argument_value(466)) )   -- Instrument_lt					>  "Caution Panel", "CICU", "Lit if ?."
	Helios_Udp.Send("505", string.format("%.1d", mainPanelDevice:get_argument_value(467)) )   -- StbyCompass_lt				>  "Caution Panel", "L-MAIN PUMP", "Lit if boost pump pressure is low."
	--Helios_Udp.Send("506", string.format("%.1d", mainPanelDevice:get_argument_value(000)) )   -- Utility_lt *					>  "Caution Panel", "R-MAIN PUMP", "Lit if boost pump pressure is low."
	Helios_Udp.Send("508", string.format("%.1d", mainPanelDevice:get_argument_value(463)) )   -- Chart_lt						>  "Caution Panel", "LASTE", "Lit if fault is detected in LASTE computer."


	-- rockers:
	Helios_Udp.Send("356", string.format("%1d", mainPanelDevice:get_argument_value(331) ) ) -- fire test >> CMSP :: Page Cycle
	Helios_Udp.Send("424", string.format("%1d", mainPanelDevice:get_argument_value(332) ) ) -- Ground Power Switch 1, A ON/AUTO/B ON >> CDU :: Brightness
	Helios_Udp.Send("463", string.format("%1d", mainPanelDevice:get_argument_value(333) ) ) -- Ground Power Switch 2, A ON/AUTO/B ON >> CDU :: Page
	Helios_Udp.Send("469", string.format("%1d", mainPanelDevice:get_argument_value(334) ) ) -- Ground Power Switch 3, A ON/AUTO/B ON >> CDU :: Blank
	Helios_Udp.Send("472", string.format("%1d", mainPanelDevice:get_argument_value(335) ) ) -- Ground Power Switch 4, A ON/AUTO/B ON >> CDU :: +/- 
	Helios_Udp.Send("405", string.format("%1d", mainPanelDevice:get_argument_value(177) ) ) -- AMPCD Night/Day brightness selector >> UFC :: Steer
	Helios_Udp.Send("406", string.format("%1d", mainPanelDevice:get_argument_value(179) ) ) -- AMPCD symbology control >> UFC :: Data
	Helios_Udp.Send("407", string.format("%1d", mainPanelDevice:get_argument_value(182) ) ) -- AMPCD contrast control >> UFC :: Select
	Helios_Udp.Send("408", string.format("%1d", mainPanelDevice:get_argument_value(180) ) ) -- AMPCD gain control >> UFC :: Adjust Depressible Pipper
	Helios_Udp.Send("409", string.format("%1d", mainPanelDevice:get_argument_value(312) ) ) -- Left MDI HDG switch >> UFCHUD :: Brightness
	Helios_Udp.Send("474", string.format("%1d", mainPanelDevice:get_argument_value(313) ) ) -- Left MDI CRS switch >> AAPSteer :: Toggle Switch
	Helios_Udp.Send("718", string.format("%1d", mainPanelDevice:get_argument_value(226) ) ) -- gears >> Mechanical :: Auxiliary Landing Gear Handle
	Helios_Udp.Send("622", string.format("%0.1f", mainPanelDevice:get_argument_value(236)+ 0.1 ) ) -- CHART Light Dimmer Control >> TISL :: Mode Select
	Helios_Udp.Send("124", string.format("%1d", mainPanelDevice:get_argument_value(377) ) ) -- Engine Crank Switch, LEFT/OFF/RIGHT >> ENGINE_SYSTEM :: Engine Operate Left*
	Helios_Udp.Send("134", string.format("%1d", mainPanelDevice:get_argument_value(368) ) ) -- MC Switch, 1 OFF/NORM/2 OFF >> VHF AM Radio :: Squelch / Tone*
	Helios_Udp.Send("245", string.format("%1d", mainPanelDevice:get_argument_value(27) ) ) -- Right Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress >> ELEC_INTERFACE :: AC Generator - Right 245
	Helios_Udp.Send("244", string.format("%1d", mainPanelDevice:get_argument_value(28) ) ) -- Right Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress/(RMB) cover control >> ELEC_INTERFACE :: AC Generator - Left 244
	Helios_Udp.Send("232", string.format("%1d", mainPanelDevice:get_argument_value(11) ) ) -- Left Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress >> Intercom :: IFF Switch 232
	Helios_Udp.Send("230", string.format("%1d", mainPanelDevice:get_argument_value(12) ) ) -- Left Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress/(RMB) cover control >> Intercom :: AIM Switch 230
	Helios_Udp.Send("350", string.format("%1d", mainPanelDevice:get_argument_value(354) ) ) -- IFF Crypto Switch, HOLD/NORM/ZERO* >> Right MFCD :: Entity Level
	Helios_Udp.Send("323", string.format("%1d", mainPanelDevice:get_argument_value(453) ) ) -- Canopy Control Switch, OPEN/HOLD/CLOSE >> Left MFCD :: Contrast
	Helios_Udp.Send("250", string.format("%0.1f", mainPanelDevice:get_argument_value(443) ) ) -- INS Switch, OFF/CV/GND/NAV/IFA/GYRO/GB/TEST >> ILS :: ILS Frequencey Khz    encoder
	Helios_Udp.Send("532", string.format("%1d", mainPanelDevice:get_argument_value(292) ) ) -- ID2163A Push to Test Switch >> UFC:: MID
	Helios_Udp.Send("346", string.format("%1d", mainPanelDevice:get_argument_value(514) ) ) -- Seat Height Adjustment Switch, UP/HOLD/DOWN >> Right MFCD :: Moving Map Scale

	-- switches	
	Helios_Udp.Send("148", string.format("%1d", mainPanelDevice:get_argument_value(336) ) ) -- External Power Switch, RESET/NORM/OFF >> VHF FM Radio :: Squelch / Tone* 
	Helios_Udp.Send("241", string.format("%1d",( mainPanelDevice:get_argument_value(30)/2)+0.5)) -- APU Fire Warning/Extinguisher Light >> ELEC_INTERFACE :: APU Generator
	Helios_Udp.Send("642", string.format("%0.2f", mainPanelDevice:get_argument_value(352) ) ) -- ILS Channel Selector Switch >> TISL :: TISL Code Wheel 4
	Helios_Udp.Send("351", string.format("%0.1f",( mainPanelDevice:get_argument_value(175)+1)/10 )) -- Selector Switch, HMD/LDDI/RDDI >> Right MFCD :: Day/Night/Off 
	Helios_Udp.Send("118", string.format("%1d",( mainPanelDevice:get_argument_value(42)/2)+0.5)) -- Canopy Jettison Lever, Pull to jettison >> Fuel System :: Fill Disable Wing Right 
	Helios_Udp.Send("401", string.format("%.1f", mainPanelDevice:get_argument_value(43) ) ) -- Canopy Jettison Handle Unlock Button - Press to unlock >> UFC :: Create Overhead Mark Point 
	Helios_Udp.Send("273", string.format("%1d",( mainPanelDevice:get_argument_value(511)/2)+0.5)) -- Ejection Seat SAFE/ARMED Handle, SAFE/ARMED >> HARS :: Hemisphere Selecto
	Helios_Udp.Send("270", string.format("%1d",( mainPanelDevice:get_argument_value(512)/2)+0.5)) -- Ejection Seat Manual Override Handle, PULL/PUSH >> HARS :: Mode 
	Helios_Udp.Send("366", string.format("%.1f", mainPanelDevice:get_argument_value(260) ) ) -- Rudder Pedal Adjust Lever >> CMSC :: Cycle MWS Program Button 
	Helios_Udp.Send("365", string.format("%.1f", mainPanelDevice:get_argument_value(380) ) ) -- Dispense Button - Push to dispense flares and chaff >> CMSC :: Cycle JMR Program Button
	Helios_Udp.Send("180", string.format("%1d", mainPanelDevice:get_argument_value(295) ) ) -- Wing Fold Control Handle, (RMB)Pull/(LMB)Stow/(MW)Rotate >> Autopilot :: Elevator Emergency Disengage 
	Helios_Udp.Send("277", string.format("%0.2f", mainPanelDevice:get_argument_value(418) ) ) -- CHART Light Dimmer Control >> Environmental Control :: Canopy Defog
	Helios_Udp.Send("296", string.format("%0.2f", mainPanelDevice:get_argument_value(417) ) ) -- WARN/CAUTION Dimmer Control >> Light System :: Flood Light
	Helios_Udp.Send("109", string.format("%1d",( mainPanelDevice:get_argument_value(416)/2)+0.5)) -- LT TEST Switch, TEST/OFF >> Fuel System :: Cross Feed
	Helios_Udp.Send("259", string.format("%.1f", mainPanelDevice:get_argument_value(14) ) ) -- MASTER CAUTION Reset Switch, Press to reset >> TACAN :: Test
	Helios_Udp.Send("222", string.format("%1d",( mainPanelDevice:get_argument_value(239)/2)+0.5)) -- HOOK BYPASS Switch, FIELD/CARRIER >> Intercom :: INT Switch
	Helios_Udp.Send("121", string.format("%1d",( mainPanelDevice:get_argument_value(365)/2)+0.5)) -- OBOGS Control Switch, ON/OFF >> Fuel System :: Refuel Control Lever
	Helios_Udp.Send("249", string.format("%0.2f", mainPanelDevice:get_argument_value(366) ) ) -- OXY FLOW Knob >> ILS :: Volume
	Helios_Udp.Send("168", string.format("%0.1f", mainPanelDevice:get_argument_value(411) ) ) -- Bleed Air Switch, R OFF/NORM/L OFF/OFF >> UHF Radio :: Frequency Dial
	Helios_Udp.Send("267", string.format("%.1f", mainPanelDevice:get_argument_value(412) ) ) -- Bleed Air Switch, AUG PULL >> HARS :: Sync Button Push
	Helios_Udp.Send("282", string.format("%1d", mainPanelDevice:get_argument_value(405) ) ) -- ECS Mode Switch, AUTO/MAN/OFF(RAM) >> Environmental Control :: Temp/Press
	Helios_Udp.Send("287", string.format("%1d", mainPanelDevice:get_argument_value(408) ) ) -- Cabin Pressure Switch, NORM/DUMP/RAM(DUMP) >> Light System :: Position Flash
	Helios_Udp.Send("192", string.format("%0.2f", mainPanelDevice:get_argument_value(451) ) ) -- Defog Handle >> Autopilot :: Yaw Trim
	Helios_Udp.Send("261", string.format("%0.2f", mainPanelDevice:get_argument_value(407) ) ) -- Cabin Temperature Knob >> TACAN :: Volumne
	Helios_Udp.Send("147", string.format("%0.2f", mainPanelDevice:get_argument_value(406) ) ) -- Suit Temperature Knob >> VHF FM Radio :: Volume
	Helios_Udp.Send("470", string.format("%.1f", mainPanelDevice:get_argument_value(46) ) ) -- Fire Extinguisher Switch >> CDU :: CLR
	Helios_Udp.Send("468", string.format("%.1f", mainPanelDevice:get_argument_value(458) ) ) -- A/A Master Mode Switch >> CDU :: SPC
	Helios_Udp.Send("467", string.format("%.1f", mainPanelDevice:get_argument_value(459) ) ) -- A/G Master Mode Switch >> CDU :: BCK
	Helios_Udp.Send("120", string.format("%1d",( mainPanelDevice:get_argument_value(49)/2)+0.5)) -- Master Arm Switch >> Fuel System :: Fill Disable Main Right
	Helios_Udp.Send("436", string.format("%.1f", mainPanelDevice:get_argument_value(50) ) ) -- Emergency Jettison Button >> CDU :: Slash
	Helios_Udp.Send("283", string.format("%1d",( mainPanelDevice:get_argument_value(258)/2)+0.5)) -- Auxiliary Release Switch, ENABLE/NORM >> Environmental Control :: Main Air Supply
	Helios_Udp.Send("280", string.format("%1d",( mainPanelDevice:get_argument_value(153)/2)+0.5)) -- Jett Station Center >> Environmental Control :: Bleed Air
	Helios_Udp.Send("279", string.format("%1d",( mainPanelDevice:get_argument_value(155)/2)+0.5)) -- Jett Station Left In >> Environmental Control :: Pitot heat
	Helios_Udp.Send("358", string.format("%1d",( mainPanelDevice:get_argument_value(157)/2)+0.5)) -- Jett Station Left Out >> CMSP :: ECM Pod Jettison
	Helios_Udp.Send("291", string.format("%1d",( mainPanelDevice:get_argument_value(159)/2)+0.5)) -- Jett Station Right In >> Light System :: Nose Illumination
	Helios_Udp.Send("107", string.format("%1d",( mainPanelDevice:get_argument_value(161)/2)+0.5)) -- Jett Station Righr Out >> Fuel System :: External Fuselage Tank Boost Pump
	Helios_Udp.Send("435", string.format("%.1f", mainPanelDevice:get_argument_value(235) ) ) -- Selective Jettison >> CDU :: Point
	Helios_Udp.Send("654", string.format("%0.1f", mainPanelDevice:get_argument_value(236) ) ) -- Selective Jettison Knob, L FUS MSL/SAFE/R FUS MSL/ RACK/LCHR /STORES >> Fuel System :: Fuel Display Selector
	Helios_Udp.Send("138", string.format("%0.1f", mainPanelDevice:get_argument_value(135) ) ) -- IR COOLING, ORIDE/NORM/OFF >> VHF AM Radio :: Frequency Mode Dial
	Helios_Udp.Send("162", string.format("%0.1f", mainPanelDevice:get_argument_value(140) ) ) -- HUD Symbology Reject Switch >> UHF Radio :: 100Mhz Selector
	Helios_Udp.Send("704", string.format("%0.2f", mainPanelDevice:get_argument_value(141) ) ) -- HUD Symbology Brightness Control >> Stall Warning :: Stall Volume
	Helios_Udp.Send("381", string.format("%1d",( mainPanelDevice:get_argument_value(142)/2)+0.5)) -- HUD Symbology Brightness Selector Knob >> AHCP :: HUD Norm/Standbyh
	Helios_Udp.Send("238", string.format("%0.2f", mainPanelDevice:get_argument_value(143) ) ) -- Black Level Control >> Intercom :: Master Volume
	Helios_Udp.Send("655", string.format("%0.1f", mainPanelDevice:get_argument_value(144) ) ) -- HUD Video Control Switch >> Light System :: Land/Taxi Lights
	Helios_Udp.Send("233", string.format("%0.2f", mainPanelDevice:get_argument_value(145) ) ) -- Balance Control >> Intercom :: ILS Volume
	Helios_Udp.Send("223", string.format("%0.2f", mainPanelDevice:get_argument_value(146) ) ) -- AOA Indexer Control >> Intercom :: FM Volume
	Helios_Udp.Send("382", string.format("%1d",( mainPanelDevice:get_argument_value(147)/2)+0.5)) -- Altitude Switch >> AHCP :: CICU Power
	Helios_Udp.Send("272", string.format("%1d", mainPanelDevice:get_argument_value(148) ) ) -- Attitude Selector Switch >> HARS :: Magnetic Variation
	Helios_Udp.Send("379", string.format("%0.1f", mainPanelDevice:get_argument_value(51) ) ) -- Left MDI Off/Night/Day switch >> AHCP :: Altimeter Source
	Helios_Udp.Send("284", string.format("%0.2f", mainPanelDevice:get_argument_value(52) ) ) -- Left MDI brightness control >> Environmental Control :: Flow Level
	Helios_Udp.Send("229", string.format("%0.2f", mainPanelDevice:get_argument_value(53) ) ) -- Left MDI contrast control >> Intercom :: AIM Volume
	Helios_Udp.Send("300", string.format("%.1f", mainPanelDevice:get_argument_value(54) ) ) -- Left MDI PB 1 >> Left MFCD :: OSB1
	Helios_Udp.Send("301", string.format("%.1f", mainPanelDevice:get_argument_value(55) ) ) -- Left MDI PB 2 >> Left MFCD :: OSB2
	Helios_Udp.Send("302", string.format("%.1f", mainPanelDevice:get_argument_value(56) ) ) -- Left MDI PB 3 >> Left MFCD :: OSB3
	Helios_Udp.Send("303", string.format("%.1f", mainPanelDevice:get_argument_value(57) ) ) -- Left MDI PB 4 >> Left MFCD :: OSB4
	Helios_Udp.Send("304", string.format("%.1f", mainPanelDevice:get_argument_value(58) ) ) -- Left MDI PB 5 >> Left MFCD :: OSB5
	Helios_Udp.Send("305", string.format("%.1f", mainPanelDevice:get_argument_value(59) ) ) -- Left MDI PB 6 >> Left MFCD :: OSB6
	Helios_Udp.Send("306", string.format("%.1f", mainPanelDevice:get_argument_value(60) ) ) -- Left MDI PB 7 >> Left MFCD :: OSB7
	Helios_Udp.Send("307", string.format("%.1f", mainPanelDevice:get_argument_value(61) ) ) -- Left MDI PB 8 >> Left MFCD :: OSB8
	Helios_Udp.Send("308", string.format("%.1f", mainPanelDevice:get_argument_value(62) ) ) -- Left MDI PB 9 >> Left MFCD :: OSB9
	Helios_Udp.Send("309", string.format("%.1f", mainPanelDevice:get_argument_value(63) ) ) -- Left MDI PB 10 >> Left MFCD :: OSB10
	Helios_Udp.Send("310", string.format("%.1f", mainPanelDevice:get_argument_value(64) ) ) -- Left MDI PB 11 >> Left MFCD :: OSB11
	Helios_Udp.Send("311", string.format("%.1f", mainPanelDevice:get_argument_value(65) ) ) -- Left MDI PB 12 >> Left MFCD :: OSB12
	Helios_Udp.Send("312", string.format("%.1f", mainPanelDevice:get_argument_value(66) ) ) -- Left MDI PB 13 >> Left MFCD :: OSB13
	Helios_Udp.Send("114", string.format("%1d",( mainPanelDevice:get_argument_value(353)/2)+0.5)) -- ILS UFC/MAN Switch, UFC/MAN >> Fuel System :: Signal Amplifier
	Helios_Udp.Send("135", string.format("%0.1f", mainPanelDevice:get_argument_value(444) ) ) -- KY-58 Mode Select Knob, P/C/LD/RV >> VHF AM Radio :: Frequency Selection Dial
	Helios_Udp.Send("235", string.format("%0.2f", mainPanelDevice:get_argument_value(445) ) ) -- KY-58 Volume Control Knob >> Intercom :: TCN Volume
	Helios_Udp.Send("473", string.format("%0.1f", mainPanelDevice:get_argument_value(447) ) ) -- KY-58 Power Select Knob, OFF/ON/TD >> AAP :: Steer Point Dial
	Helios_Udp.Send("420", string.format("%.1f", mainPanelDevice:get_argument_value(230) ) ) -- Warning Tone Silence Button - Push to silence >> CDU :: WP MENU
	Helios_Udp.Send("607", string.format("%.1f", mainPanelDevice:get_argument_value(277) ) ) -- ALR-67 POWER Pushbutton >> Navigation Mode Select Panel :: EGI
	Helios_Udp.Send("605", string.format("%.1f", mainPanelDevice:get_argument_value(275) ) ) -- ALR-67 DISPLAY Pushbutton >> Navigation Mode Select Panel :: HARS
	Helios_Udp.Send("613", string.format("%.1f", mainPanelDevice:get_argument_value(272) ) ) -- ALR-67 SPECIAL Pushbutton >> Navigation Mode Select Panel :: ANCHR
	Helios_Udp.Send("609", string.format("%.1f", mainPanelDevice:get_argument_value(269) ) ) -- ALR-67 OFFSET Pushbutton >> Navigation Mode Select Panel :: TISL
	Helios_Udp.Send("611", string.format("%.1f", mainPanelDevice:get_argument_value(266) ) ) -- ALR-67 BIT Pushbutton >> Navigation Mode Select Panel :: STEERPT
	Helios_Udp.Send("705", string.format("%0.2f", mainPanelDevice:get_argument_value(263) ) ) -- ALR-67 DMR Control Knob >> Stall Warning :: Peak Volume
	Helios_Udp.Send("262", string.format("%0.1f", mainPanelDevice:get_argument_value(261) ) ) -- ALR-67 DIS TYPE Switch, N/I/A/U/F >> TACAN :: Mode
	Helios_Udp.Send("116", string.format("%0.2f", mainPanelDevice:get_argument_value(216) ) ) -- RWR Intensity Knob >> Light System :: Refueling Lighting Dial"
	Helios_Udp.Send("419", string.format("%.1f", mainPanelDevice:get_argument_value(380) ) ) -- Dispense Button - Push to dispense flares and chaff >> CDU :: NAV
	Helios_Udp.Send("376", string.format("%0.1f", mainPanelDevice:get_argument_value(517) ) ) -- DISPENSER Switch, BYPASS/ON/OFF >> AHCP :: Gun Arm 
	Helios_Udp.Send("170", string.format("%1d", mainPanelDevice:get_argument_value(515) ) ) -- ECM JETT JETT SEL Button - Push to jettison >> UHF Radio :: Squelch
	Helios_Udp.Send("364", string.format("%0.1f", mainPanelDevice:get_argument_value(248) ) ) -- ECM Mode Switch, XMIT/REC/BIT/STBY/OFF >> CMSP :: Mode Select Dial
	Helios_Udp.Send("112", string.format("%1d",( mainPanelDevice:get_argument_value(507)/2)+0.5)) -- NUC WPN Switch, ENABLE/DISABLE (no function) >> Fuel System :: Boost Pump Main Fuseloge Left
	Helios_Udp.Send("384", string.format("%0.1f",( mainPanelDevice:get_argument_value(176)+1)/10 )) -- Selector Switch, HUD/LDIR/RDDI >> AHCP :: IFFCC Power
	Helios_Udp.Send("375", string.format("%0.1f",( mainPanelDevice:get_argument_value(314)+1)/10 )) -- Mode Selector Switch, MAN/OFF/AUTO >> AHCP :: Master Arm
	Helios_Udp.Send("423", string.format("%.1f", mainPanelDevice:get_argument_value(7) ) ) -- HUD Video BIT Initiate Pushbutton - Push to initiate BIT >> CDU :: PREV
	Helios_Udp.Send("288", string.format("%0.2f", mainPanelDevice:get_argument_value(136) ) ) -- HMD OFF/BRT Knob >> Light System :: Formation Lights
	Helios_Udp.Send("194", string.format("%0.1f",( mainPanelDevice:get_argument_value(439)+1)/10 )) -- FLIR Switch, ON/STBY/OFF >> Light System :: Nightvision Lights
	Helios_Udp.Send("60", string.format("%0.1f", mainPanelDevice:get_argument_value(441))) -- LTD/R Switch, ARM/SAFE/AFT >> ELECT/PNEU switch
	Helios_Udp.Send("477", string.format("%1d", mainPanelDevice:get_argument_value(442))) -- LST/NFLR Switch, ON/OFF >> AAP :: EGI Power
	Helios_Udp.Send("370", string.format("%.1f", mainPanelDevice:get_argument_value(315) ) ) -- Left Video Sensor BIT Initiate Pushbutton - Push to initiate BIT >> CMSC :: Separate Button
	Helios_Udp.Send("422", string.format("%.1f", mainPanelDevice:get_argument_value(318) ) ) -- Right Video Sensor BIT Initiate Pushbutton - Push to initiate BIT >> CDU :: FPMENU
	Helios_Udp.Send("169", string.format("%1d", mainPanelDevice:get_argument_value(410) ) ) -- Engine Anti-Ice Switch, ON/OFF/TEST >> UHF Radio :: T/Tone Switch
	Helios_Udp.Send("108", string.format("%1d",( mainPanelDevice:get_argument_value(297)/2)+0.5)) -- AV COOL Switch, NORM/EMERG >> Fuel System :: Tank Gate
	Helios_Udp.Send("206", string.format("%1d", mainPanelDevice:get_argument_value(452) ) ) -- Windshield Anti-Ice/Rain Switch, ANTI ICE/OFF/RAIN >> IFF :: RAD Test/Monitor Switch
	Helios_Udp.Send("126", string.format("%1d",( mainPanelDevice:get_argument_value(348)/2)+0.5)) -- GAIN Switch Cover >> Engine System :: APU
	Helios_Udp.Send("110", string.format("%1d",( mainPanelDevice:get_argument_value(347)/2)+0.5)) -- GAIN Switch, NORM/ORIDE >> Fuel System :: Boost Pump Left Wing
	Helios_Udp.Send("205", string.format("%1d", mainPanelDevice:get_argument_value(234) ) ) -- FLAP Switch, AUTO/HALF/FULL >> IFF :: M-C Switch
	Helios_Udp.Send("123", string.format("%1d",( mainPanelDevice:get_argument_value(139)/2)+0.5)) -- SPIN Recovery Switch Cover >> Engine System :: Right Engine Fuel Flow Control
	Helios_Udp.Send("111", string.format("%1d",( mainPanelDevice:get_argument_value(138)/2)+0.5)) -- SPIN Recovery Switch, RCVY/NORM >> Fuel System :: Boost Pump Right Wing
	Helios_Udp.Send("471", string.format("%.1f", mainPanelDevice:get_argument_value(470) ) ) -- CS BIT switch >> CDU :: FA
	Helios_Udp.Send("105", string.format("%1d", mainPanelDevice:get_argument_value(404) ) ) -- Battery Switch, ON/OFF/ORIDE >> Fire System :: Discharge Switch
	Helios_Udp.Send("380", string.format("%1d", mainPanelDevice:get_argument_value(403) ) ) -- Right Generator Switch, NORM/OFF >> AHCP :: HUD Day/Night
	Helios_Udp.Send("780", string.format("%1d",( mainPanelDevice:get_argument_value(379)/2)+0.5)) -- Generator TIE Control Switch Cover, OPEN/CLOSE >> KY-58 Secure Voice :: Delay
	Helios_Udp.Send("104", string.format("%1d", mainPanelDevice:get_argument_value(378) ) ) -- Generator TIE Control Switch, NORM/RESET >> FIRE_SYSTEM :: Right Engine Fire Pull
	Helios_Udp.Send("716", string.format("%1d", mainPanelDevice:get_argument_value(336) ) ) -- External Power Switch, RESET/NORM/OFF >> CPT_MECH :: Landing Gear Lever
	Helios_Udp.Send("226", string.format("%1d",( mainPanelDevice:get_argument_value(409)/2)+0.5)) -- Anti Ice Pitot Switch, ON/AUTO >> Intercom :: VHF Switch
	Helios_Udp.Send("234", string.format("%1d", mainPanelDevice:get_argument_value(381) ) ) -- CB FCS CHAN 1, ON/OFF >> Intercom :: ILS Switch
	Helios_Udp.Send("175", string.format("%1d", mainPanelDevice:get_argument_value(382) ) ) -- CB FCS CHAN 2, ON/OFF >> Autopilot :: Pitch/Roll Emergency Override
	Helios_Udp.Send("184", string.format("%1d", mainPanelDevice:get_argument_value(383) ) ) -- CB SPD BRK, ON/OFF >> Autopilot :: Manual Reversion Flight Control System Switch
	Helios_Udp.Send("224", string.format("%1d", mainPanelDevice:get_argument_value(384) ) ) -- CB LAUNCH BAR, ON/OFF >> Intercom :: FM Switch
	Helios_Udp.Send("237", string.format("%1d", mainPanelDevice:get_argument_value(454) ) ) -- CB FCS CHAN 3, ON/OFF >> Intercom :: Hot Mic Switch
	Helios_Udp.Send("236", string.format("%1d", mainPanelDevice:get_argument_value(455) ) ) -- CB FCS CHAN 4, ON/OFF >> Intercom :: TCN Switch
	Helios_Udp.Send("174", string.format("%1d", mainPanelDevice:get_argument_value(456) ) ) -- CB HOOK, ON/OFF >> Autopilot :: Speed Brake Emergency Retract
	Helios_Udp.Send("183", string.format("%1d", mainPanelDevice:get_argument_value(457) ) ) -- CB LG, ON/OFF >> Autopilot :: Flaps Emergency Retract
	Helios_Udp.Send("378", string.format("%1d", mainPanelDevice:get_argument_value(402) ) ) -- Left Generator Switch, NORM/OFF >> AHCP :: TGP Power
	Helios_Udp.Send("102", string.format("%1d", mainPanelDevice:get_argument_value(375) ) ) -- APU Control Switch - ON/OFF >> FIRE_SYSTEM :: Left Engine Fire Pull
	Helios_Udp.Send("784", string.format("%1d",( mainPanelDevice:get_argument_value(369)/2)+0.5)) -- Hydraulic Isolate Override Switch, NORM/ORIDE >> KY-58 Secure Voice :: Power Switch
	Helios_Udp.Send("354", string.format("%.1f", mainPanelDevice:get_argument_value(229) ) ) -- Down Lock Override Button - Push to unlock >> CMSP :: OSB 3
	Helios_Udp.Send("117", string.format("%1d",( mainPanelDevice:get_argument_value(238)/2)+0.5)) -- Anti Skid Switch, ON/OFF >> Fuel System :: Fill Disable Wing Left
	Helios_Udp.Send("734", string.format("%1d", mainPanelDevice:get_argument_value(233) ) ) -- Launch Bar Control Switch, EXTEND/RETRACT >> UHF Radio :: Cover
	Helios_Udp.Send("196", string.format("%1d",( mainPanelDevice:get_argument_value(293)/2)+0.5)) -- Arresting Hook Handle, UP/DOWN >> Autopilot :: HARS-SAS Override/Norm
	Helios_Udp.Send("113", string.format("%1d",( mainPanelDevice:get_argument_value(340)/2)+0.5)) -- Internal Wing Tank Fuel Control Switch, INHIBIT/NORM >> Fuel System :: Boost Pump Main Fuseloge Right
	Helios_Udp.Send("201", string.format("%1d", mainPanelDevice:get_argument_value(341) ) ) -- Probe Control Switch, EXTEND/RETRACT/EMERG EXTD >> IFF :: Audio Light Switch
	Helios_Udp.Send("621", string.format("%1d", mainPanelDevice:get_argument_value(344) ) ) -- Fuel Dump Switch, ON/OFF >> NMSP :: Able - Stow
	Helios_Udp.Send("204", string.format("%1d", mainPanelDevice:get_argument_value(343) ) ) -- External Tanks CTR Switch, STOP/NORM/ORIDE >> IFF :: M-3/A Switch
	Helios_Udp.Send("207", string.format("%1d", mainPanelDevice:get_argument_value(342) ) ) -- External Tanks WING Switch, STOP/NORM/ORIDE >> IFF :: Ident/Mic Switch
	Helios_Udp.Send("275", string.format("%.1f", mainPanelDevice:get_argument_value(43) ) ) -- Canopy Jettison Lever Safety Button, Press to unlock >> Environmental Control :: Oxygen Indicator Test
	Helios_Udp.Send("118", string.format("%1d",( mainPanelDevice:get_argument_value(42)/2)+0.5)) -- Canopy Jettison Lever, Pull to jettison >> Fuel System :: Fill Disable Wing Right
	Helios_Udp.Send("171", string.format("%0.2f", mainPanelDevice:get_argument_value(338) ) ) -- POSITION Lights Dimmer Control >> UHF Radio :: Volume
	Helios_Udp.Send("227", string.format("%0.2f", mainPanelDevice:get_argument_value(337) ) ) -- FORMATION Lights Dimmer Control >> Intercom :: UHF Volume
	Helios_Udp.Send("177", string.format("%1d", mainPanelDevice:get_argument_value(339) ) ) -- STROBE Lights Switch, BRT/OFF/DIM >> Autopilot :: Alieron Emergency Disengage
	Helios_Udp.Send("294", string.format("%1d",( mainPanelDevice:get_argument_value(237)/2)+0.5)) -- LDG/TAXI LIGHT Switch, ON/OFF >> Light System :: Signal Lights
	Helios_Udp.Send("290", string.format("%0.2f", mainPanelDevice:get_argument_value(413) ) ) -- CONSOLES Lights Dimmer Control >> Light System :: Engine Instrument Lights
	Helios_Udp.Send("225", string.format("%0.2f", mainPanelDevice:get_argument_value(414) ) ) -- INST PNL Dimmer Control >> Intercom :: VHF Volume
	Helios_Udp.Send("297", string.format("%0.2f", mainPanelDevice:get_argument_value(415) ) ) -- FLOOD Light Dimmer Control >> Light System :: Console Lights
	Helios_Udp.Send("132", string.format("%1d", mainPanelDevice:get_argument_value(419) ) ) -- MODE Switch, NVG/NITE/DAY >> Autopilot :: Mode Selection
	Helios_Udp.Send("313", string.format("%.1f", mainPanelDevice:get_argument_value(67) ) ) -- Left MDI PB 14 >> Left MFCD :: OSB14
	Helios_Udp.Send("314", string.format("%.1f", mainPanelDevice:get_argument_value(68) ) ) -- Left MDI PB 15 >> Left MFCD :: OSB15
	Helios_Udp.Send("133", string.format("%0.2f",( mainPanelDevice:get_argument_value(345)/2)+0.5)) -- RUD TRIM Control >> VHF AM Radio :: Volume
	Helios_Udp.Send("352", string.format("%.1f", mainPanelDevice:get_argument_value(346) ) ) -- T/O TRIM PUSH Switch >> CMSP :: OSB 1
	Helios_Udp.Send("353", string.format("%.1f", mainPanelDevice:get_argument_value(349) ) ) -- FCS RESET Switch >> CMSP :: OSB 2
	Helios_Udp.Send("315", string.format("%.1f", mainPanelDevice:get_argument_value(69) ) ) -- Left MDI PB 16 >> Left MFCD :: OSB16
	Helios_Udp.Send("316", string.format("%.1f", mainPanelDevice:get_argument_value(70) ) ) -- Left MDI PB 17 >> Left MFCD :: OSB17
	Helios_Udp.Send("317", string.format("%.1f", mainPanelDevice:get_argument_value(72) ) ) -- Left MDI PB 18 >> Left MFCD :: OSB18
	Helios_Udp.Send("318", string.format("%.1f", mainPanelDevice:get_argument_value(73) ) ) -- Left MDI PB 19 >> Left MFCD :: OSB19
	Helios_Udp.Send("319", string.format("%.1f", mainPanelDevice:get_argument_value(75) ) ) -- Left MDI PB 20 >> Left MFCD :: OSB20
	Helios_Udp.Send("377", string.format("%0.1f", mainPanelDevice:get_argument_value(76) ) ) -- Right MDI Off/Night/Day switch >> AHCP :: Laser Arm
	Helios_Udp.Send("326", string.format("%.1f", mainPanelDevice:get_argument_value(79) ) ) -- Right MDI PB 1 >> Right MFCD :: OSB1
	Helios_Udp.Send("327", string.format("%.1f", mainPanelDevice:get_argument_value(80) ) ) -- Right MDI PB 2 >> Right MFCD :: OSB2
	Helios_Udp.Send("328", string.format("%.1f", mainPanelDevice:get_argument_value(81) ) ) -- Right MDI PB 3 >> Right MFCD :: OSB3
	Helios_Udp.Send("329", string.format("%.1f", mainPanelDevice:get_argument_value(82) ) ) -- Right MDI PB 4 >> Right MFCD :: OSB4
	Helios_Udp.Send("330", string.format("%.1f", mainPanelDevice:get_argument_value(83) ) ) -- Right MDI PB 5 >> Right MFCD :: OSB5
	Helios_Udp.Send("331", string.format("%.1f", mainPanelDevice:get_argument_value(84) ) ) -- Right MDI PB 6 >> Right MFCD :: OSB6
	Helios_Udp.Send("332", string.format("%.1f", mainPanelDevice:get_argument_value(85) ) ) -- Right MDI PB 7 >> Right MFCD :: OSB7
	Helios_Udp.Send("333", string.format("%.1f", mainPanelDevice:get_argument_value(86) ) ) -- Right MDI PB 8 >> Right MFCD :: OSB8
	Helios_Udp.Send("334", string.format("%.1f", mainPanelDevice:get_argument_value(87) ) ) -- Right MDI PB 9 >> Right MFCD :: OSB9
	Helios_Udp.Send("335", string.format("%.1f", mainPanelDevice:get_argument_value(88) ) ) -- Right MDI PB 10 >> Right MFCD :: OSB10
	Helios_Udp.Send("336", string.format("%.1f", mainPanelDevice:get_argument_value(89) ) ) -- Right MDI PB 11 >> Right MFCD :: OSB11
	Helios_Udp.Send("337", string.format("%.1f", mainPanelDevice:get_argument_value(90) ) ) -- Right MDI PB 12 >> Right MFCD :: OSB12
	Helios_Udp.Send("338", string.format("%.1f", mainPanelDevice:get_argument_value(91) ) ) -- Right MDI PB 13 >> Right MFCD :: OSB13
	Helios_Udp.Send("339", string.format("%.1f", mainPanelDevice:get_argument_value(92) ) ) -- Right MDI PB 14 >> Right MFCD :: OSB14
	Helios_Udp.Send("340", string.format("%.1f", mainPanelDevice:get_argument_value(93) ) ) -- Right MDI PB 15 >> Right MFCD :: OSB15
	Helios_Udp.Send("341", string.format("%.1f", mainPanelDevice:get_argument_value(94) ) ) -- Right MDI PB 16 >> Right MFCD :: OSB16
	Helios_Udp.Send("342", string.format("%.1f", mainPanelDevice:get_argument_value(95) ) ) -- Right MDI PB 17 >> Right MFCD :: OSB17
	Helios_Udp.Send("271", string.format("%0.2f", mainPanelDevice:get_argument_value(77) ) ) -- Right MDI brightness control >> HARS :: Latitude Correction
	Helios_Udp.Send("293", string.format("%0.2f", mainPanelDevice:get_argument_value(78) ) ) -- Right MDI contrast control >> Light System :: Auxillary instrument Lights
	Helios_Udp.Send("343", string.format("%.1f", mainPanelDevice:get_argument_value(96) ) ) -- Right MDI PB 18 >> Right MFCD :: OSB18
	Helios_Udp.Send("344", string.format("%.1f", mainPanelDevice:get_argument_value(97) ) ) -- Right MDI PB 19 >> Right MFCD :: OSB19
	Helios_Udp.Send("345", string.format("%.1f", mainPanelDevice:get_argument_value(98) ) ) -- Right MDI PB 20 >> Right MFCD :: OSB20
	Helios_Udp.Send("231", string.format("%0.2f", mainPanelDevice:get_argument_value(203) ) ) -- AMPCD Off/brightness control >> Intercom :: IFF Volume
	Helios_Udp.Send("437", string.format("%.1f", mainPanelDevice:get_argument_value(183) ) ) -- AMPCD PB 1 >> CDU :: A
	Helios_Udp.Send("438", string.format("%.1f", mainPanelDevice:get_argument_value(184) ) ) -- AMPCD PB 2 >> CDU :: B
	Helios_Udp.Send("439", string.format("%.1f", mainPanelDevice:get_argument_value(185) ) ) -- AMPCD PB 3 >> CDU :: C
	Helios_Udp.Send("440", string.format("%.1f", mainPanelDevice:get_argument_value(186) ) ) -- AMPCD PB 4 >> CDU :: D
	Helios_Udp.Send("441", string.format("%.1f", mainPanelDevice:get_argument_value(187) ) ) -- AMPCD PB 5 >> CDU :: E
	Helios_Udp.Send("442", string.format("%.1f", mainPanelDevice:get_argument_value(188) ) ) -- AMPCD PB 6 >> CDU :: F
	Helios_Udp.Send("443", string.format("%.1f", mainPanelDevice:get_argument_value(189) ) ) -- AMPCD PB 7 >> CDU :: G
	Helios_Udp.Send("444", string.format("%.1f", mainPanelDevice:get_argument_value(190) ) ) -- AMPCD PB 8 >> CDU :: H
	Helios_Udp.Send("445", string.format("%.1f", mainPanelDevice:get_argument_value(191) ) ) -- AMPCD PB 9 >> CDU :: I
	Helios_Udp.Send("446", string.format("%.1f", mainPanelDevice:get_argument_value(192) ) ) -- AMPCD PB 10 >> CDU :: J
	Helios_Udp.Send("447", string.format("%.1f", mainPanelDevice:get_argument_value(193) ) ) -- AMPCD PB 11 >> CDU :: K
	Helios_Udp.Send("448", string.format("%.1f", mainPanelDevice:get_argument_value(194) ) ) -- AMPCD PB 12 >> CDU :: L
	Helios_Udp.Send("449", string.format("%.1f", mainPanelDevice:get_argument_value(195) ) ) -- AMPCD PB 13 >> CDU :: M
	Helios_Udp.Send("450", string.format("%.1f", mainPanelDevice:get_argument_value(196) ) ) -- AMPCD PB 14 >> CDU :: N
	Helios_Udp.Send("451", string.format("%.1f", mainPanelDevice:get_argument_value(197) ) ) -- AMPCD PB 15 >> CDU :: O
	Helios_Udp.Send("452", string.format("%.1f", mainPanelDevice:get_argument_value(198) ) ) -- AMPCD PB 16 >> CDU :: P
	Helios_Udp.Send("453", string.format("%.1f", mainPanelDevice:get_argument_value(199) ) ) -- AMPCD PB 17 >> CDU :: Q
	Helios_Udp.Send("454", string.format("%.1f", mainPanelDevice:get_argument_value(200) ) ) -- AMPCD PB 18 >> CDU :: R
	Helios_Udp.Send("455", string.format("%.1f", mainPanelDevice:get_argument_value(201) ) ) -- AMPCD PB 19 >> CDU :: S
	Helios_Udp.Send("456", string.format("%.1f", mainPanelDevice:get_argument_value(202) ) ) -- AMPCD PB 20 >> CDU :: T
	Helios_Udp.Send("632", string.format("%.1f", mainPanelDevice:get_argument_value(213) ) ) -- Cage Standby Attitude Indicator >> TISL :: Bite
	Helios_Udp.Send("466", string.format("%.1f", mainPanelDevice:get_argument_value(215) ) ) -- SAI test >> CDU :: MK
	Helios_Udp.Send("457", string.format("%.1f", mainPanelDevice:get_argument_value(168) ) ) -- IFEI Mode button >> CDU :: U
	Helios_Udp.Send("458", string.format("%.1f", mainPanelDevice:get_argument_value(169) ) ) -- IFEI QTY button >> CDU :: V
	Helios_Udp.Send("459", string.format("%.1f", mainPanelDevice:get_argument_value(170) ) ) -- IFEI up arrow button >> CDU :: W
	Helios_Udp.Send("460", string.format("%.1f", mainPanelDevice:get_argument_value(171) ) ) -- IFEI down arrow button >> CDU :: X
	Helios_Udp.Send("461", string.format("%.1f", mainPanelDevice:get_argument_value(172) ) ) -- IFEI ZONE button >> CDU :: Y
	Helios_Udp.Send("462", string.format("%.1f", mainPanelDevice:get_argument_value(173) ) ) -- IFEI ET button >> CDU :: Z
	Helios_Udp.Send("630", string.format("%.1f", mainPanelDevice:get_argument_value(283) ) ) -- ABU-43 Clock Wind/Set Control >> TISL :: OverTemp
	Helios_Udp.Send("115", string.format("%.1f", mainPanelDevice:get_argument_value(284) ) ) -- ABU-43 Clock Stop/Reset Control >> Fuel System :: Line Check
	Helios_Udp.Send("390", string.format("%.1f", mainPanelDevice:get_argument_value(128) ) ) -- UFC Function Pushbutton, A/P >> UFC :: 6
	Helios_Udp.Send("391", string.format("%.1f", mainPanelDevice:get_argument_value(129) ) ) -- UFC Function Pushbutton, IFF >> UFC :: 7
	Helios_Udp.Send("392", string.format("%.1f", mainPanelDevice:get_argument_value(130) ) ) -- UFC Function Pushbutton, TCN >> UFC :: 8
	Helios_Udp.Send("393", string.format("%.1f", mainPanelDevice:get_argument_value(131) ) ) -- UFC Function Pushbutton, ILS >> UFC :: 9
	Helios_Udp.Send("395", string.format("%.1f", mainPanelDevice:get_argument_value(132) ) ) -- UFC Function Pushbutton, D/L >> UFC :: 0
	Helios_Udp.Send("396", string.format("%.1f", mainPanelDevice:get_argument_value(133) ) ) -- UFC Function Pushbutton, BCN >> UFC :: Space
	Helios_Udp.Send("394", string.format("%.1f", mainPanelDevice:get_argument_value(134) ) ) -- UFC Function Pushbutton, ON(OFF) >> UFC :: Display Hack Time
	Helios_Udp.Send("385", string.format("%.1f", mainPanelDevice:get_argument_value(100) ) ) -- UFC Option Select Pushbutton 1 >> UFC :: 1
	Helios_Udp.Send("386", string.format("%.1f", mainPanelDevice:get_argument_value(101) ) ) -- UFC Option Select Pushbutton 2 >> UFC :: 2
	Helios_Udp.Send("387", string.format("%.1f", mainPanelDevice:get_argument_value(102) ) ) -- UFC Option Select Pushbutton 3 >> UFC :: 3
	Helios_Udp.Send("388", string.format("%.1f", mainPanelDevice:get_argument_value(103) ) ) -- UFC Option Select Pushbutton 4 >> UFC :: 4
	Helios_Udp.Send("389", string.format("%.1f", mainPanelDevice:get_argument_value(106) ) ) -- UFC Option Select Pushbutton 5 >> UFC :: 5
	Helios_Udp.Send("425", string.format("%.1f", mainPanelDevice:get_argument_value(111) ) ) -- UFC Keyboard Pushbutton, 1 >> CDU :: 1
	Helios_Udp.Send("426", string.format("%.1f", mainPanelDevice:get_argument_value(112) ) ) -- UFC Keyboard Pushbutton, 2 >> CDU :: 2
	Helios_Udp.Send("427", string.format("%.1f", mainPanelDevice:get_argument_value(113) ) ) -- UFC Keyboard Pushbutton, 3 >> CDU :: 3
	Helios_Udp.Send("428", string.format("%.1f", mainPanelDevice:get_argument_value(114) ) ) -- UFC Keyboard Pushbutton, 4 >> CDU :: 4
	Helios_Udp.Send("429", string.format("%.1f", mainPanelDevice:get_argument_value(115) ) ) -- UFC Keyboard Pushbutton, 5 >> CDU :: 5
	Helios_Udp.Send("430", string.format("%.1f", mainPanelDevice:get_argument_value(116) ) ) -- UFC Keyboard Pushbutton, 6 >> CDU :: 6
	Helios_Udp.Send("431", string.format("%.1f", mainPanelDevice:get_argument_value(117) ) ) -- UFC Keyboard Pushbutton, 7 >> CDU :: 7
	Helios_Udp.Send("432", string.format("%.1f", mainPanelDevice:get_argument_value(118) ) ) -- UFC Keyboard Pushbutton, 8 >> CDU :: 8
	Helios_Udp.Send("433", string.format("%.1f", mainPanelDevice:get_argument_value(119) ) ) -- UFC Keyboard Pushbutton, 9 >> CDU :: 9
	Helios_Udp.Send("434", string.format("%.1f", mainPanelDevice:get_argument_value(120) ) ) -- UFC Keyboard Pushbutton, 0 >> CDU :: 0
	Helios_Udp.Send("399", string.format("%.1f", mainPanelDevice:get_argument_value(121) ) ) -- UFC Keyboard Pushbutton, CLR >> UFC :: Clear
	Helios_Udp.Send("400", string.format("%.1f", mainPanelDevice:get_argument_value(122) ) ) -- UFC Keyboard Pushbutton, ENT >> UFC :: Enter
	Helios_Udp.Send("397", string.format("%.1f", mainPanelDevice:get_argument_value(99) ) ) -- UFC I/P Pushbutton >> UFC :: Select Funciton Mode
	Helios_Udp.Send("398", string.format("%.1f", mainPanelDevice:get_argument_value(110) ) ) -- UFC EMCON Select Pushbutton >> UFC :: Select Letter Mode
	Helios_Udp.Send("623", string.format("%1d", mainPanelDevice:get_argument_value(107) ) ) -- UFC ADF Function Select Switch, 1/OFF/2 >> TISL :: Slant Range
	Helios_Udp.Send("195", string.format("%0.2f", mainPanelDevice:get_argument_value(108) ) ) -- UFC COMM 1 Volume Control Knob >> Light System :: Weapon Station Lights Brightness
	Helios_Udp.Send("193", string.format("%0.2f", mainPanelDevice:get_argument_value(123) ) ) -- UFC COMM 2 Volume Control Knob >> Light System :: Refuel Status Indexer Brightness
	Helios_Udp.Send("292", string.format("%0.2f", mainPanelDevice:get_argument_value(109) ) ) -- UFC Brightness Control Knob >> Light System :: Flight Instruments Lights
	Helios_Udp.Send("640", string.format("%0.2f", mainPanelDevice:get_argument_value(358) ) ) -- ICS Volume Control Knob >> TISL :: TISL Code Wheel 3
	Helios_Udp.Send("221", string.format("%0.2f", mainPanelDevice:get_argument_value(359) ) ) -- RWR Volume Control Knob >> Intercom :: INT Volume;
	Helios_Udp.Send("626", string.format("%0.2f", mainPanelDevice:get_argument_value(360) ) ) -- WPN Volume Control Knob >> TISL :: Altitude above target thousands of feet
	Helios_Udp.Send("624", string.format("%0.2f", mainPanelDevice:get_argument_value(361) ) ) -- MIDS B Volume Control Knob >> TISL :: Altitude above target tens of thousands of feet
	Helios_Udp.Send("636", string.format("%0.2f", mainPanelDevice:get_argument_value(362) ) ) -- MIDS A Volume Control Knob >> TISL :: TISL Code Wheel 1
	Helios_Udp.Send("638", string.format("%0.2f", mainPanelDevice:get_argument_value(363) ) ) -- TACAN Volume Control Knob >> TISL :: TISL Code Wheel 2
	Helios_Udp.Send("368", string.format("%0.2f", mainPanelDevice:get_argument_value(364) ) ) -- AUX Volume Control Knob >> CMSC :: RWR Volume
	Helios_Udp.Send("601", string.format("%1d", mainPanelDevice:get_argument_value(350) ) ) -- COMM RLY Select Switch, CIPHER/OFF/PLAIN >> Oxygen System :: Emergency Lever
	Helios_Udp.Send("202", string.format("%1d", mainPanelDevice:get_argument_value(351) ) ) -- COMM G XMT Switch, COMM 1/OFF/COMM 2 >> IFF :: M-1 Switch
	Helios_Udp.Send("476", string.format("%1d",( mainPanelDevice:get_argument_value(356)/2)+0.5)) -- IFF Master Switch, EMER/NORM >> AAP :: CDU Power
	Helios_Udp.Send("644", string.format("%1d", mainPanelDevice:get_argument_value(355) ) ) -- IFF Mode 4 Switch, DIS-AUD/DIS/OFF >> TISL :: Code Select
	Helios_Udp.Send("278", string.format("%1d", mainPanelDevice:get_argument_value(373) ) ) -- COMM 1 ANT SEL Switch, UPPER/AUTO/LOWER >> Environmental Control :: Windshield Remove/Wash
	Helios_Udp.Send("203", string.format("%1d", mainPanelDevice:get_argument_value(374) ) ) -- IFF ANT SEL Switch, UPPER/BOTH/LOWER >> IFF :: M-2 Switch

	Helios_Udp.Flush()
end


-- Format: device,button number, multiplier
-- arguments with multiplier 100, 101,102 or >300 are special conversion cases, and are computed in different way
--                     A10C        FA18C

--rockers:
Helios_F18C.ExportArguments["4,3005"] ="12,3006,1" -- Fire Test Switch, (RMB) TEST A/(LMB) TEST B >> CMSP :: Page Cycle
Helios_F18C.ExportArguments["4,3006"] ="12,3007,1" -- Fire Test Switch, (RMB) TEST A/(LMB) TEST B >> CMSP :: Page Cycle
Helios_F18C.ExportArguments["9,3060"] ="3,3008,1" -- Ground Power Switch 1, A ON/AUTO/B ON >> CDU", "Brightness
Helios_F18C.ExportArguments["9,3061"] ="3,3009,1" -- Ground Power Switch 1, A ON/AUTO/B ON >> CDU", "Brightness
Helios_F18C.ExportArguments["9,3062"] ="3,3010,1" -- Ground Power Switch 2, A ON/AUTO/B ON >> CDU :: Page
Helios_F18C.ExportArguments["9,3063"] ="3,3011,1" -- Ground Power Switch 2, A ON/AUTO/B ON >> CDU :: Page
Helios_F18C.ExportArguments["9,3064"] ="3,3012,1" -- Ground Power Switch 3, A ON/AUTO/B ON >> CDU :: Blank
Helios_F18C.ExportArguments["9,3065"] ="3,3013,1" -- Ground Power Switch 3, A ON/AUTO/B ON >> CDU :: Blank
Helios_F18C.ExportArguments["9,3066"] ="3,3014,1" -- Ground Power Switch 4, A ON/AUTO/B ON >> CDU :: +/-
Helios_F18C.ExportArguments["9,3067"] ="3,3015,1" -- Ground Power Switch 4, A ON/AUTO/B ON >> CDU :: +/-
Helios_F18C.ExportArguments["8,3020"] ="37,3002,1" -- AMPCD Night/Day brightness selector >> UFC :: Steer
Helios_F18C.ExportArguments["8,3021"] ="37,3003,1" -- AMPCD Night/Day brightness selector >> UFC :: Steer
Helios_F18C.ExportArguments["8,3022"] ="37,3004,1" -- AMPCD symbology control >> UFC :: Data
Helios_F18C.ExportArguments["8,3023"] ="37,3005,1" -- AMPCD symbology control >> UFC :: Data
Helios_F18C.ExportArguments["8,3024"] ="37,3006,1" -- AMPCD contrast control >> UFC :: Select
Helios_F18C.ExportArguments["8,3025"] ="37,3007,1" -- AMPCD contrast control >> UFC :: Select
Helios_F18C.ExportArguments["8,3026"] ="37,3008,1" -- AMPCD gain control >> UFC :: Adjust Depressible Pipper
Helios_F18C.ExportArguments["8,3027"] ="37,3009,1" -- AMPCD gain control >> UFC :: Adjust Depressible Pipper
Helios_F18C.ExportArguments["8,3028"] ="35,3004,1" -- Left MDI HDG switch >> UFCHUD :: Brightness
Helios_F18C.ExportArguments["8,3029"] ="35,3005,1" -- Left MDI HDG switch >> UFCHUD :: Brightness
Helios_F18C.ExportArguments["22,3002"] ="35,3006,1" -- Left MDI CRS switch >> AAPSteer :: Toggle Switch
Helios_F18C.ExportArguments["22,3003"] ="35,3007,1" -- Left MDI CRS switch >> AAPSteer :: Toggle Switch
Helios_F18C.ExportArguments["3,3034"] ="40,3014,1" -- IFF Crypto Switch, HOLD/NORM/ZERO >> Right MFCD :: Entity Level
Helios_F18C.ExportArguments["3,3033"] ="40,3015,1" -- IFF Crypto Switch, HOLD/NORM/ZERO >> Right MFCD :: Entity Level
Helios_F18C.ExportArguments["3,3035"] ="40,3015,1" -- IFF Crypto Switch, HOLD/NORM/ZERO >> Right MFCD :: Entity Level (el reposo lo trae un tercer command)
Helios_F18C.ExportArguments["2,3031"] ="7,3002,1" -- Canopy Control Switch, OPEN/HOLD/CLOSE >> Left MFCD :: Contrast
Helios_F18C.ExportArguments["2,3030"] ="7,3001,1" -- Canopy Control Switch, OPEN/HOLD/CLOSE >> Left MFCD :: Contrast
Helios_F18C.ExportArguments["2,3032"] ="7,3001,1" -- Canopy Control Switch, OPEN/HOLD/CLOSE >> Left MFCD :: Contrast
Helios_F18C.ExportArguments["74,3002"] ="25,3033,1" -- UFC COMM 1 Channel Selector Knob >> TACAN :: Channel Selector (Ones X/Y)
Helios_F18C.ExportArguments["74,3001"] ="25,3034,1" -- UFC COMM 2 Channel Selector Knob >> TACAN :: Channel Selector (Tens)
Helios_F18C.ExportArguments["2,3027"] ="5,3006,1" -- emergency park >> Left MFCD :: Brightness   vertical
Helios_F18C.ExportArguments["2,3029"] ="5,3007,1" -- emergency park >> Left MFCD :: Brightness   horizontal
Helios_F18C.ExportArguments["7,3009"] ="5,3006,1" -- emergency park >> AHCP :: Datalink Power   unblock last pass
Helios_F18C.ExportArguments["3,3022"] ="7,3010,1" -- Seat Height Adjustment Switch, UP/HOLD/DOWN >> Right MFCD :: Moving Map Scale
Helios_F18C.ExportArguments["3,3021"] ="7,3011,1" -- Seat Height Adjustment Switch, UP/HOLD/DOWN >> Right MFCD :: Moving Map Scale
Helios_F18C.ExportArguments["3,3023"] ="7,3011,1" -- Seat Height Adjustment Switch, UP/HOLD/DOWN >> Right MFCD :: Moving Map Scale (el reposo lo trae un tercer command)

-- multiple F/A-18C axis in one A10C encoder

Helios_F18C.ExportArguments["48,3003"] ="25,3034,300" -- Multiple F/A-18C axis in one A10C encoder  >> SAI :: Pitch Trim / Cage

--switches:

Helios_F18C.ExportArguments["39,3008"] ="5,3001,1" -- Landing Gear Control Handle, (RMB)UP/(LMB)DOWN/(MW)EMERGENCY DOWN >> Mechanical :: Auxiliary Landing Gear Handle
Helios_F18C.ExportArguments["39,3010"] ="5,3002,1" -- Landing Gear Control Handle emergency, (RMB)UP/(LMB)DOWN/(MW)EMERGENCY DOWN >> Mechanical :: Seat Arm Handle
Helios_F18C.ExportArguments["57,3001"] ="23,3011,105" -- Left MDI CRS switch >> TISL :: Mode Select  ( restar 0.1)
Helios_F18C.ExportArguments["38,3022"] ="2,3011,1" -- Wing Fold Control Handle, (RMB)Pull/(LMB)Stow/(MW)Rotate >> Autopilot :: Elevator Emergency Disengage 
Helios_F18C.ExportArguments["56,3008"] ="3,3005,1" -- External Power Switch, RESET/NORM/OFF >> VHF FM Radio :: Squelch / Tone* 
Helios_F18C.ExportArguments["37,3007"] ="12,3003,1" -- Engine Crank Switch, LEFT/OFF/RIGHT >> ENGINE_SYSTEM :: Engine Operate Left* 
Helios_F18C.ExportArguments["37,3003"] ="12,3002,1" -- Engine Crank Switch, LEFT/OFF/RIGHT >> ENGINE_SYSTEM :: Engine Operate Left* 
Helios_F18C.ExportArguments["55,3008"] ="3,3025,1" -- MC Switch, 1 OFF/NORM/2 OFF >> VHF AM Radio :: Squelch / Tone*
Helios_F18C.ExportArguments["55,3007"] ="3,3026,1" -- MC Switch, 1 OFF/NORM/2 OFF >> VHF AM Radio :: Squelch / Tone*
Helios_F18C.ExportArguments["1,3005"] ="12,3011,1" -- Right Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress >> ELEC_INTERFACE :: AC Generator - Right 245
Helios_F18C.ExportArguments["1,3004"] ="12,3013,1" -- Right Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress/(RMB) cover control >> ELEC_INTERFACE :: AC Generator - Left 244
Helios_F18C.ExportArguments["58,3011"] ="12,3011,1" -- Left Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress >> Intercom :: IFF Switch 232
Helios_F18C.ExportArguments["58,3009"] ="12,3012,1" -- Left Engine/AMAD Fire Warning/Extinguisher Light - (LMB) depress/(RMB) cover control >> Intercom :: AIM Switch 230
Helios_F18C.ExportArguments["8,3018"] ="25,3008,1" -- UFC COMM 2 Channel Selector Knob PULL >> UFC :: Display and Adjust Altitude Alert Values  encoder
Helios_F18C.ExportArguments["8,3030"] ="25,3009,1" -- UFC COMM 2 Channel Selector Knob PULL >> UFC :: FWD    encoder
Helios_F18C.ExportArguments["50,3002"] ="2,3010,1" -- Wing Fold Control Handle, (RMB)Pull/(LMB)Stow/(MW)Rotate >> FIRE_SYSTEM :: APU Fire Pull
Helios_F18C.ExportArguments["8,3031"] ="30,3001,1" -- ID2163A Push to Test Switch >> UFC:: MID
Helios_F18C.ExportArguments["8,3032"] ="42,3002,1" -- radar Switch pull >> UFC:: AFT
Helios_F18C.ExportArguments["38,3030"] ="5,3005,1" -- emergency brake pull >> CPT_MECH:: Landing Gear Lever

-- generated:
Helios_F18C.ExportArguments["56,3007"] ="3,3004,1" -- External Power Switch, RESET/NORM/OFF >> VHF FM Radio :: Squelch / Tone* 
Helios_F18C.ExportArguments["1,3001"] ="12,3009,102" -- APU Fire Warning/Extinguisher Light >> ELEC_INTERFACE :: APU Generator  241
Helios_F18C.ExportArguments["57,3008"] ="40,3017,1" -- ILS Channel Selector Switch >> TISL :: TISL Code Wheel 4 
Helios_F18C.ExportArguments["3,3036"] ="0,3104,100" -- Selector Switch, HMD/LDDI/RDDI >> Right MFCD :: Day/Night/Off 
Helios_F18C.ExportArguments["36,3013"] ="7,3003,102" -- Canopy Jettison Lever, Pull to jettison >> Fuel System :: Fill Disable Wing Right 
Helios_F18C.ExportArguments["8,3017"] ="7,3004,1" -- Canopy Jettison Handle Unlock Button - Press to unlock >> UFC :: Create Overhead Mark Point 
Helios_F18C.ExportArguments["44,3003"] ="7,3006,102" -- Ejection Seat SAFE/ARMED Handle, SAFE/ARMED >> HARS :: Hemisphere Selecto 
Helios_F18C.ExportArguments["44,3002"] ="7,3007,102" -- Ejection Seat Manual Override Handle, PULL/PUSH >> HARS :: Mode 
Helios_F18C.ExportArguments["5,3002"] ="7,3012,1" -- Rudder Pedal Adjust Lever >> CMSC :: Cycle MWS Program Button 
Helios_F18C.ExportArguments["5,3001"] ="54,3002,1" -- Dispense Button - Push to dispense flares and chaff >> CMSC :: Cycle JMR Program Button
Helios_F18C.ExportArguments["41,3003"] ="9,3005,1" -- CHART Light Dimmer Control >> Environmental Control :: Canopy Defog
Helios_F18C.ExportArguments["49,3005"] ="9,3006,1" -- WARN/CAUTION Dimmer Control >> Light System :: Flood Light
Helios_F18C.ExportArguments["36,3004"] ="9,3007,102" -- LT TEST Switch, TEST/OFF >> Fuel System :: Cross Feed
Helios_F18C.ExportArguments["74,3004"] ="9,3008,1" -- MASTER CAUTION Reset Switch, Press to reset >> TACAN :: Test
Helios_F18C.ExportArguments["58,3001"] ="9,3009,102" -- HOOK BYPASS Switch, FIELD/CARRIER >> Intercom :: INT Switch
Helios_F18C.ExportArguments["36,3016"] ="10,3001,102" -- OBOGS Control Switch, ON/OFF >> Fuel System :: Refuel Control Lever
Helios_F18C.ExportArguments["53,3005"] ="10,3002,1" -- OXY FLOW Knob >> ILS :: Volume
Helios_F18C.ExportArguments["54,3008"] ="11,3001,1" -- Bleed Air Switch, R OFF/NORM/L OFF/OFF >> UHF Radio :: Frequency Dial
Helios_F18C.ExportArguments["44,3006"] ="11,3002,1" -- Bleed Air Switch, AUG PULL >> HARS :: Sync Button Push
Helios_F18C.ExportArguments["41,3007"] ="11,3003,1" -- ECS Mode Switch, AUTO/MAN/OFF(RAM) >> Environmental Control :: Temp/Press
Helios_F18C.ExportArguments["49,3008"] ="11,3004,1" -- Cabin Pressure Switch, NORM/DUMP/RAM(DUMP) >> Light System :: Position Flash
Helios_F18C.ExportArguments["38,3013"] ="11,3005,1" -- Defog Handle >> Autopilot :: Yaw Trim
Helios_F18C.ExportArguments["74,3005"] ="11,3006,1" -- Cabin Temperature Knob >> TACAN :: Volumne
Helios_F18C.ExportArguments["56,3005"] ="11,3007,1" -- Suit Temperature Knob >> VHF FM Radio :: Volume
Helios_F18C.ExportArguments["9,3058"] ="12,3008,1" -- Fire Extinguisher Switch >> CDU :: CLR
Helios_F18C.ExportArguments["9,3057"] ="23,3001,1" -- A/A Master Mode Switch >> CDU :: SPC
Helios_F18C.ExportArguments["9,3056"] ="23,3002,1" -- A/G Master Mode Switch >> CDU :: BCK
Helios_F18C.ExportArguments["36,3015"] ="23,3003,102" -- Master Arm Switch >> Fuel System :: Fill Disable Main Right
Helios_F18C.ExportArguments["9,3026"] ="23,3004,1" -- Emergency Jettison Button >> CDU :: Slash
Helios_F18C.ExportArguments["41,3008"] ="23,3012,102" -- Auxiliary Release Switch, ENABLE/NORM >> Environmental Control :: Main Air Supply
Helios_F18C.ExportArguments["41,3006"] ="23,3005,102" -- Jett Station Center >> Environmental Control :: Bleed Air
Helios_F18C.ExportArguments["41,3005"] ="23,3006,102" -- Jett Station Left In >> Environmental Control :: Pitot heat
Helios_F18C.ExportArguments["4,3008"] ="23,3007,102" -- Jett Station Left Out >> CMSP :: ECM Pod Jettison
Helios_F18C.ExportArguments["49,3012"] ="23,3008,102" -- Jett Station Right In >> Light System :: Nose Illumination
Helios_F18C.ExportArguments["36,3002"] ="23,3009,102" -- Jett Station Righr Out >> Fuel System :: External Fuselage Tank Boost Pump
Helios_F18C.ExportArguments["9,3025"] ="23,3010,1" -- Selective Jettison >> CDU :: Point
Helios_F18C.ExportArguments["36,3017"] ="23,3011,1" -- Selective Jettison Knob, L FUS MSL/SAFE/R FUS MSL/ RACK/LCHR /STORES >> Fuel System :: Fuel Display Selector
Helios_F18C.ExportArguments["55,3003"] ="23,3013,1" -- IR COOLING, ORIDE/NORM/OFF >> VHF AM Radio :: Frequency Mode Dial
Helios_F18C.ExportArguments["54,3002"] ="34,3001,1" -- HUD Symbology Reject Switch >> UHF Radio :: 100Mhz Selector
Helios_F18C.ExportArguments["52,3001"] ="34,3002,1" -- HUD Symbology Brightness Control >> Stall Warning :: Stall Volume
Helios_F18C.ExportArguments["7,3007"] ="34,3003,102" -- HUD Symbology Brightness Selector Knob >> AHCP :: HUD Norm/Standbyh
Helios_F18C.ExportArguments["58,3018"] ="34,3004,1" -- Black Level Control >> Intercom :: Master Volume
Helios_F18C.ExportArguments["49,3014"] ="34,3005,1" -- HUD Video Control Switch >> Light System :: Land/Taxi Lights
Helios_F18C.ExportArguments["58,3014"] ="34,3006,1" -- Balance Control >> Intercom :: ILS Volume
Helios_F18C.ExportArguments["58,3004"] ="34,3007,1" -- AOA Indexer Control >> Intercom :: FM Volume
Helios_F18C.ExportArguments["7,3008"] ="34,3008,102" -- Altitude Switch >> AHCP :: CICU Power
Helios_F18C.ExportArguments["44,3004"] ="34,3009,1" -- Attitude Selector Switch >> HARS :: Magnetic Variation
Helios_F18C.ExportArguments["7,3005"] ="35,3001,1" -- Left MDI Off/Night/Day switch >> AHCP :: Altimeter Source
Helios_F18C.ExportArguments["41,3009"] ="35,3002,1" -- Left MDI brightness control >> Environmental Control :: Flow Level
Helios_F18C.ExportArguments["58,3010"] ="35,3003,1" -- Left MDI contrast control >> Intercom :: AIM Volume
Helios_F18C.ExportArguments["2,3001"] ="35,3011,1" -- Left MDI PB 1 >> Left MFCD :: OSB1
Helios_F18C.ExportArguments["2,3002"] ="35,3012,1" -- Left MDI PB 2 >> Left MFCD :: OSB2
Helios_F18C.ExportArguments["2,3003"] ="35,3013,1" -- Left MDI PB 3 >> Left MFCD :: OSB3
Helios_F18C.ExportArguments["2,3004"] ="35,3014,1" -- Left MDI PB 4 >> Left MFCD :: OSB4
Helios_F18C.ExportArguments["2,3005"] ="35,3015,1" -- Left MDI PB 5 >> Left MFCD :: OSB5
Helios_F18C.ExportArguments["2,3006"] ="35,3016,1" -- Left MDI PB 6 >> Left MFCD :: OSB6
Helios_F18C.ExportArguments["2,3007"] ="35,3017,1" -- Left MDI PB 7 >> Left MFCD :: OSB7
Helios_F18C.ExportArguments["2,3008"] ="35,3018,1" -- Left MDI PB 8 >> Left MFCD :: OSB8
Helios_F18C.ExportArguments["2,3009"] ="35,3019,1" -- Left MDI PB 9 >> Left MFCD :: OSB9
Helios_F18C.ExportArguments["2,3010"] ="35,3020,1" -- Left MDI PB 10 >> Left MFCD :: OSB10
Helios_F18C.ExportArguments["2,3011"] ="35,3021,1" -- Left MDI PB 11 >> Left MFCD :: OSB11
Helios_F18C.ExportArguments["2,3012"] ="35,3022,1" -- Left MDI PB 12 >> Left MFCD :: OSB12
Helios_F18C.ExportArguments["2,3013"] ="35,3023,1" -- Left MDI PB 13 >> Left MFCD :: OSB13
Helios_F18C.ExportArguments["36,3009"] ="40,3016,102" -- ILS UFC/MAN Switch, UFC/MAN >> Fuel System :: Signal Amplifier
Helios_F18C.ExportArguments["55,3004"] ="41,3001,1" -- KY-58 Mode Select Knob, P/C/LD/RV >> VHF AM Radio :: Frequency Selection Dial
Helios_F18C.ExportArguments["58,3016"] ="41,3005,1" -- KY-58 Volume Control Knob >> Intercom :: TCN Volume
Helios_F18C.ExportArguments["22,3001"] ="41,3004,1" -- KY-58 Power Select Knob, OFF/ON/TD >> AAP :: Steer Point Dial
Helios_F18C.ExportArguments["9,3011"] ="40,3018,1" -- Warning Tone Silence Button - Push to silence >> CDU :: WP MENU
Helios_F18C.ExportArguments["46,3002"] ="53,3001,1" -- ALR-67 POWER Pushbutton >> Navigation Mode Select Panel :: EGI
Helios_F18C.ExportArguments["46,3001"] ="53,3002,1" -- ALR-67 DISPLAY Pushbutton >> Navigation Mode Select Panel :: HARS
Helios_F18C.ExportArguments["46,3005"] ="53,3003,1" -- ALR-67 SPECIAL Pushbutton >> Navigation Mode Select Panel :: ANCHR
Helios_F18C.ExportArguments["46,3003"] ="53,3004,1" -- ALR-67 OFFSET Pushbutton >> Navigation Mode Select Panel :: TISL
Helios_F18C.ExportArguments["46,3004"] ="53,3005,1" -- ALR-67 BIT Pushbutton >> Navigation Mode Select Panel :: STEERPT
Helios_F18C.ExportArguments["52,3002"] ="53,3006,1" -- ALR-67 DMR Control Knob >> Stall Warning :: Peak Volume
Helios_F18C.ExportArguments["74,3006"] ="53,3007,1" -- ALR-67 DIS TYPE Switch, N/I/A/U/F >> TACAN :: Mode
Helios_F18C.ExportArguments["49,3018"] ="53,3008,1" -- RWR Intensity Knob >> Light System :: Refueling Lighting Dial"
Helios_F18C.ExportArguments["9,3010"] ="54,3001,1" -- Dispense Button - Push to dispense flares and chaff >> CDU :: NAV
Helios_F18C.ExportArguments["7,3002"] ="54,3001,1" -- DISPENSER Switch, BYPASS/ON/OFF >> AHCP :: Gun Arm 
Helios_F18C.ExportArguments["54,3010"] ="54,3003,1" -- ECM JETT JETT SEL Button - Push to jettison >> UHF Radio :: Squelch
Helios_F18C.ExportArguments["4,3018"] ="0,3116,1" -- ECM Mode Switch, XMIT/REC/BIT/STBY/OFF >> CMSP :: Mode Select Dial
Helios_F18C.ExportArguments["36,3007"] ="0,3100,102" -- NUC WPN Switch, ENABLE/DISABLE (no function) >> Fuel System :: Boost Pump Main Fuseloge Left
Helios_F18C.ExportArguments["7,3010"] ="0,3105,100" -- Selector Switch, HUD/LDIR/RDDI >> AHCP :: IFFCC Power 
Helios_F18C.ExportArguments["7,3001"] ="0,3106,100" -- Mode Selector Switch, MAN/OFF/AUTO >> AHCP :: Master Arm
Helios_F18C.ExportArguments["9,3014"] ="0,3107,1" -- HUD Video BIT Initiate Pushbutton - Push to initiate BIT >> CDU :: PREV
Helios_F18C.ExportArguments["49,3009"] ="58,3001,1" -- HMD OFF/BRT Knob >> Light System :: Formation Lights
Helios_F18C.ExportArguments["49,3017"] ="62,3001,100" -- FLIR Switch, ON/STBY/OFF >> Light System :: Nightvision Lights
Helios_F18C.ExportArguments["62,3002"] ="62,3002,1" -- LTD/R Switch, ARM/SAFE/AFT >> ELECT/PNEU switch
Helios_F18C.ExportArguments["12,3003"] ="62,3003,1" -- LTD/R Switch, ARM/SAFE/AFT >> Arm Ground Safety Override Switch
Helios_F18C.ExportArguments["22,3006"] ="62,3004,1" -- LST/NFLR Switch, ON/OFF >> AAP :: EGI Power
Helios_F18C.ExportArguments["5,3004"] ="0,3127,1" -- Left Video Sensor BIT Initiate Pushbutton - Push to initiate BIT >> CMSC :: Separate Button
Helios_F18C.ExportArguments["9,3013"] ="0,3128,1" -- Right Video Sensor BIT Initiate Pushbutton - Push to initiate BIT >> CDU :: FPMENU
Helios_F18C.ExportArguments["54,3009"] ="12,3014,1" -- Engine Anti-Ice Switch, ON/OFF/TEST >> UHF Radio :: T/Tone Switch
Helios_F18C.ExportArguments["36,3003"] ="11,3008,102" -- AV COOL Switch, NORM/EMERG >> Fuel System :: Tank Gate
Helios_F18C.ExportArguments["43,3014"] ="11,3009,1" -- Windshield Anti-Ice/Rain Switch, ANTI ICE/OFF/RAIN >> IFF :: RAD Test/Monitor Switch
Helios_F18C.ExportArguments["37,3005"] ="2,3005,102" -- GAIN Switch Cover >> Engine System :: APU
Helios_F18C.ExportArguments["36,3005"] ="2,3006,102" -- GAIN Switch, NORM/ORIDE >> Fuel System :: Boost Pump Left Wing
Helios_F18C.ExportArguments["43,3013"] ="2,3007,1" -- FLAP Switch, AUTO/HALF/FULL >> IFF :: M-C Switch
Helios_F18C.ExportArguments["37,3002"] ="2,3008,102" -- SPIN Recovery Switch Cover >> Engine System :: Right Engine Fuel Flow Control
Helios_F18C.ExportArguments["36,3006"] ="2,3009,102" -- SPIN Recovery Switch, RCVY/NORM >> Fuel System :: Boost Pump Right Wing
Helios_F18C.ExportArguments["9,3059"] ="2,3004,1" -- CS BIT switch >> CDU :: FA
Helios_F18C.ExportArguments["50,3004"] ="3,3001,1" -- Battery Switch, ON/OFF/ORIDE >> Fire System :: Discharge Switch
Helios_F18C.ExportArguments["7,3006"] ="3,3003,1" -- Right Generator Switch, NORM/OFF >> AHCP :: HUD Day/Night
Helios_F18C.ExportArguments["69,3003"] ="3,3007,102" -- Generator TIE Control Switch Cover, OPEN/CLOSE >> KY-58 Secure Voice :: Delay
Helios_F18C.ExportArguments["50,3003"] ="3,3006,1" -- Generator TIE Control Switch, NORM/RESET >> FIRE_SYSTEM :: Right Engine Fire Pull
Helios_F18C.ExportArguments["39,3001"] ="3,3004,1" -- External Power Switch, RESET/NORM/OFF >> CPT_MECH :: Landing Gear Lever
Helios_F18C.ExportArguments["58,3005"] ="3,3016,102" -- Anti Ice Pitot Switch, ON/AUTO >> Intercom :: VHF Switch
Helios_F18C.ExportArguments["58,3013"] ="3,3017,1" -- CB FCS CHAN 1, ON/OFF >> Intercom :: ILS Switch
Helios_F18C.ExportArguments["38,3016"] ="3,3018,1" -- CB FCS CHAN 2, ON/OFF >> Autopilot :: Pitch/Roll Emergency Override
Helios_F18C.ExportArguments["38,3024"] ="3,3019,1" -- CB SPD BRK, ON/OFF >> Autopilot :: Manual Reversion Flight Control System Switch
Helios_F18C.ExportArguments["58,3003"] ="3,3020,1" -- CB LAUNCH BAR, ON/OFF >> Intercom :: FM Switch
Helios_F18C.ExportArguments["58,3017"] ="3,3021,1" -- CB FCS CHAN 3, ON/OFF >> Intercom :: Hot Mic Switch
Helios_F18C.ExportArguments["58,3015"] ="3,3022,1" -- CB FCS CHAN 4, ON/OFF >> Intercom :: TCN Switch
Helios_F18C.ExportArguments["38,3015"] ="3,3023,1" -- CB HOOK, ON/OFF >> Autopilot :: Speed Brake Emergency Retract
Helios_F18C.ExportArguments["38,3023"] ="3,3024,1" -- CB LG, ON/OFF >> Autopilot :: Flaps Emergency Retract
Helios_F18C.ExportArguments["7,3004"] ="3,3002,1" -- Left Generator Switch, NORM/OFF >> AHCP :: TGP Power
Helios_F18C.ExportArguments["50,3001"] ="12,3001,1" -- APU Control Switch - ON/OFF >> FIRE_SYSTEM :: Left Engine Fire Pull
Helios_F18C.ExportArguments["69,3007"] ="4,3001,102" -- Hydraulic Isolate Override Switch, NORM/ORIDE >> KY-58 Secure Voice :: Power Switch
Helios_F18C.ExportArguments["4,3003"] ="5,3003,1" -- Down Lock Override Button - Push to unlock >> CMSP :: OSB 3
Helios_F18C.ExportArguments["36,3012"] ="5,3004,102" -- Anti Skid Switch, ON/OFF >> Fuel System :: Fill Disable Wing Left
Helios_F18C.ExportArguments["54,3014"] ="5,3008,1" -- Launch Bar Control Switch, EXTEND/RETRACT >> UHF Radio :: Cover
Helios_F18C.ExportArguments["38,3031"] ="5,3009,102" -- Arresting Hook Handle, UP/DOWN >> Autopilot :: HARS-SAS Override/Norm
Helios_F18C.ExportArguments["36,3008"] ="6,3001,102" -- Internal Wing Tank Fuel Control Switch, INHIBIT/NORM >> Fuel System :: Boost Pump Main Fuseloge Right
Helios_F18C.ExportArguments["43,3009"] ="6,3002,1" -- Probe Control Switch, EXTEND/RETRACT/EMERG EXTD >> IFF :: Audio Light Switch
Helios_F18C.ExportArguments["46,3008"] ="6,3003,1" -- Fuel Dump Switch, ON/OFF >> NMSP :: Able - Stow
Helios_F18C.ExportArguments["43,3012"] ="6,3004,1" -- External Tanks CTR Switch, STOP/NORM/ORIDE >> IFF :: M-3/A Switch
Helios_F18C.ExportArguments["43,3015"] ="6,3005,1" -- External Tanks WING Switch, STOP/NORM/ORIDE >> IFF :: Ident/Mic Switch
Helios_F18C.ExportArguments["41,3001"] ="7,3004,1" -- Canopy Jettison Lever Safety Button, Press to unlock >> Environmental Control :: Oxygen Indicator Test
Helios_F18C.ExportArguments["36,3013"] ="7,3003,102" -- Canopy Jettison Lever, Pull to jettison >> Fuel System :: Fill Disable Wing Right
Helios_F18C.ExportArguments["54,3011"] ="8,3001,1" -- POSITION Lights Dimmer Control >> UHF Radio :: Volume
Helios_F18C.ExportArguments["58,3008"] ="8,3002,1" -- FORMATION Lights Dimmer Control >> Intercom :: UHF Volume
Helios_F18C.ExportArguments["38,3021"] ="8,3003,1" -- STROBE Lights Switch, BRT/OFF/DIM >> Autopilot :: Alieron Emergency Disengage
Helios_F18C.ExportArguments["49,3013"] ="8,3004,102" -- LDG/TAXI LIGHT Switch, ON/OFF >> Light System :: Signal Lights
Helios_F18C.ExportArguments["49,3001"] ="9,3001,1" -- CONSOLES Lights Dimmer Control >> Light System :: Engine Instrument Lights
Helios_F18C.ExportArguments["58,3006"] ="9,3002,1" -- INST PNL Dimmer Control >> Intercom :: VHF Volume
Helios_F18C.ExportArguments["49,3006"] ="9,3003,1" -- FLOOD Light Dimmer Control >> Light System :: Console Lights
Helios_F18C.ExportArguments["38,3001"] ="9,3004,1" -- MODE Switch, NVG/NITE/DAY >> Autopilot :: Mode Selection
Helios_F18C.ExportArguments["2,3014"] ="35,3024,1" -- Left MDI PB 14 >> Left MFCD :: OSB14
Helios_F18C.ExportArguments["2,3015"] ="35,3025,1" -- Left MDI PB 15 >> Left MFCD :: OSB15
Helios_F18C.ExportArguments["55,3005"] ="2,3001,102" -- RUD TRIM Control >> VHF AM Radio :: Volume
Helios_F18C.ExportArguments["4,3001"] ="2,3002,1" -- T/O TRIM PUSH Switch >> CMSP :: OSB 1
Helios_F18C.ExportArguments["4,3002"] ="2,3003,1" -- FCS RESET Switch >> CMSP :: OSB 2
Helios_F18C.ExportArguments["2,3016"] ="35,3026,1" -- Left MDI PB 16 >> Left MFCD :: OSB16
Helios_F18C.ExportArguments["2,3017"] ="35,3027,1" -- Left MDI PB 17 >> Left MFCD :: OSB17
Helios_F18C.ExportArguments["2,3018"] ="35,3028,1" -- Left MDI PB 18 >> Left MFCD :: OSB18
Helios_F18C.ExportArguments["2,3019"] ="35,3029,1" -- Left MDI PB 19 >> Left MFCD :: OSB19
Helios_F18C.ExportArguments["2,3020"] ="35,3030,1" -- Left MDI PB 20 >> Left MFCD :: OSB20
Helios_F18C.ExportArguments["7,3003"] ="36,3001,1" -- Right MDI Off/Night/Day switch >> AHCP :: Laser Arm
Helios_F18C.ExportArguments["3,3001"] ="36,3011,1" -- Right MDI PB 1 >> Right MFCD :: OSB1
Helios_F18C.ExportArguments["3,3002"] ="36,3012,1" -- Right MDI PB 2 >> Right MFCD :: OSB2
Helios_F18C.ExportArguments["3,3003"] ="36,3013,1" -- Right MDI PB 3 >> Right MFCD :: OSB3
Helios_F18C.ExportArguments["3,3004"] ="36,3014,1" -- Right MDI PB 4 >> Right MFCD :: OSB4
Helios_F18C.ExportArguments["3,3005"] ="36,3015,1" -- Right MDI PB 5 >> Right MFCD :: OSB5
Helios_F18C.ExportArguments["3,3006"] ="36,3016,1" -- Right MDI PB 6 >> Right MFCD :: OSB6
Helios_F18C.ExportArguments["3,3007"] ="36,3017,1" -- Right MDI PB 7 >> Right MFCD :: OSB7
Helios_F18C.ExportArguments["3,3008"] ="36,3018,1" -- Right MDI PB 8 >> Right MFCD :: OSB8
Helios_F18C.ExportArguments["3,3009"] ="36,3019,1" -- Right MDI PB 9 >> Right MFCD :: OSB9
Helios_F18C.ExportArguments["3,3010"] ="36,3020,1" -- Right MDI PB 10 >> Right MFCD :: OSB10
Helios_F18C.ExportArguments["3,3011"] ="36,3021,1" -- Right MDI PB 11 >> Right MFCD :: OSB11
Helios_F18C.ExportArguments["3,3012"] ="36,3022,1" -- Right MDI PB 12 >> Right MFCD :: OSB12
Helios_F18C.ExportArguments["3,3013"] ="36,3023,1" -- Right MDI PB 13 >> Right MFCD :: OSB13
Helios_F18C.ExportArguments["3,3014"] ="36,3024,1" -- Right MDI PB 14 >> Right MFCD :: OSB14
Helios_F18C.ExportArguments["3,3015"] ="36,3025,1" -- Right MDI PB 15 >> Right MFCD :: OSB15
Helios_F18C.ExportArguments["3,3016"] ="36,3026,1" -- Right MDI PB 16 >> Right MFCD :: OSB16
Helios_F18C.ExportArguments["3,3017"] ="36,3027,1" -- Right MDI PB 17 >> Right MFCD :: OSB17
Helios_F18C.ExportArguments["44,3005"] ="36,3002,1" -- Right MDI brightness control >> HARS :: Latitude Correction
Helios_F18C.ExportArguments["49,3003"] ="36,3003,1" -- Right MDI contrast control >> Light System :: Auxillary instrument Lights
Helios_F18C.ExportArguments["3,3018"] ="36,3028,1" -- Right MDI PB 18 >> Right MFCD :: OSB18
Helios_F18C.ExportArguments["3,3019"] ="36,3029,1" -- Right MDI PB 19 >> Right MFCD :: OSB19
Helios_F18C.ExportArguments["3,3020"] ="36,3030,1" -- Right MDI PB 20 >> Right MFCD :: OSB20
Helios_F18C.ExportArguments["58,3012"] ="37,3001,1" -- AMPCD Off/brightness control >> Intercom :: IFF Volume
Helios_F18C.ExportArguments["9,3027"] ="37,3011,1" -- AMPCD PB 1 >> CDU :: A
Helios_F18C.ExportArguments["9,3028"] ="37,3012,1" -- AMPCD PB 2 >> CDU :: B
Helios_F18C.ExportArguments["9,3029"] ="37,3013,1" -- AMPCD PB 3 >> CDU :: C
Helios_F18C.ExportArguments["9,3030"] ="37,3014,1" -- AMPCD PB 4 >> CDU :: D
Helios_F18C.ExportArguments["9,3031"] ="37,3015,1" -- AMPCD PB 5 >> CDU :: E
Helios_F18C.ExportArguments["9,3032"] ="37,3016,1" -- AMPCD PB 6 >> CDU :: F
Helios_F18C.ExportArguments["9,3033"] ="37,3017,1" -- AMPCD PB 7 >> CDU :: G
Helios_F18C.ExportArguments["9,3034"] ="37,3018,1" -- AMPCD PB 8 >> CDU :: H
Helios_F18C.ExportArguments["9,3035"] ="37,3019,1" -- AMPCD PB 9 >> CDU :: I
Helios_F18C.ExportArguments["9,3036"] ="37,3020,1" -- AMPCD PB 10 >> CDU :: J
Helios_F18C.ExportArguments["9,3037"] ="37,3021,1" -- AMPCD PB 11 >> CDU :: K
Helios_F18C.ExportArguments["9,3038"] ="37,3022,1" -- AMPCD PB 12 >> CDU :: L
Helios_F18C.ExportArguments["9,3039"] ="37,3023,1" -- AMPCD PB 13 >> CDU :: M
Helios_F18C.ExportArguments["9,3040"] ="37,3024,1" -- AMPCD PB 14 >> CDU :: N
Helios_F18C.ExportArguments["9,3041"] ="37,3025,1" -- AMPCD PB 15 >> CDU :: O
Helios_F18C.ExportArguments["9,3042"] ="37,3026,1" -- AMPCD PB 16 >> CDU :: P
Helios_F18C.ExportArguments["9,3043"] ="37,3027,1" -- AMPCD PB 17 >> CDU :: Q
Helios_F18C.ExportArguments["9,3044"] ="37,3028,1" -- AMPCD PB 18 >> CDU :: R
Helios_F18C.ExportArguments["9,3045"] ="37,3029,1" -- AMPCD PB 19 >> CDU :: S
Helios_F18C.ExportArguments["9,3046"] ="37,3030,1" -- AMPCD PB 20 >> CDU :: T
Helios_F18C.ExportArguments["57,3012"] ="32,3002,1" -- Cage Standby Attitude Indicator >> TISL :: Bite
Helios_F18C.ExportArguments["9,3055"] ="32,3001,1" -- SAI test >> CDU :: MK
Helios_F18C.ExportArguments["9,3047"] ="33,3001,1" -- IFEI Mode button >> CDU :: U
Helios_F18C.ExportArguments["9,3048"] ="33,3002,1" -- IFEI QTY button >> CDU :: V
Helios_F18C.ExportArguments["9,3049"] ="33,3003,1" -- IFEI up arrow button >> CDU :: W
Helios_F18C.ExportArguments["9,3050"] ="33,3004,1" -- IFEI down arrow button >> CDU :: X
Helios_F18C.ExportArguments["9,3051"] ="33,3005,1" -- IFEI ZONE button >> CDU :: Y
Helios_F18C.ExportArguments["9,3052"] ="33,3006,1" -- IFEI ET button >> CDU :: Z
Helios_F18C.ExportArguments["57,3011"] ="29,3001,1" -- ABU-43 Clock Wind/Set Control >> TISL :: OverTemp
Helios_F18C.ExportArguments["36,3010"] ="29,3003,1" -- ABU-43 Clock Stop/Reset Control >> Fuel System :: Line Check
Helios_F18C.ExportArguments["8,3006"] ="25,3001,1" -- UFC Function Pushbutton, A/P >> UFC :: 6
Helios_F18C.ExportArguments["8,3007"] ="25,3002,1" -- UFC Function Pushbutton, IFF >> UFC :: 7
Helios_F18C.ExportArguments["8,3008"] ="25,3003,1" -- UFC Function Pushbutton, TCN >> UFC :: 8
Helios_F18C.ExportArguments["8,3009"] ="25,3004,1" -- UFC Function Pushbutton, ILS >> UFC :: 9
Helios_F18C.ExportArguments["8,3010"] ="25,3005,1" -- UFC Function Pushbutton, D/L >> UFC :: 0
Helios_F18C.ExportArguments["8,3011"] ="25,3006,1" -- UFC Function Pushbutton, BCN >> UFC :: Space
Helios_F18C.ExportArguments["8,3012"] ="25,3007,1" -- UFC Function Pushbutton, ON(OFF) >> UFC :: Display Hack Time
Helios_F18C.ExportArguments["8,3001"] ="25,3010,1" -- UFC Option Select Pushbutton 1 >> UFC :: 1
Helios_F18C.ExportArguments["8,3002"] ="25,3011,1" -- UFC Option Select Pushbutton 2 >> UFC :: 2
Helios_F18C.ExportArguments["8,3003"] ="25,3012,1" -- UFC Option Select Pushbutton 3 >> UFC :: 3
Helios_F18C.ExportArguments["8,3004"] ="25,3013,1" -- UFC Option Select Pushbutton 4 >> UFC :: 4
Helios_F18C.ExportArguments["8,3005"] ="25,3014,1" -- UFC Option Select Pushbutton 5 >> UFC :: 5
Helios_F18C.ExportArguments["9,3015"] ="25,3019,1" -- UFC Keyboard Pushbutton, 1 >> CDU :: 1
Helios_F18C.ExportArguments["9,3016"] ="25,3020,1" -- UFC Keyboard Pushbutton, 2 >> CDU :: 2
Helios_F18C.ExportArguments["9,3017"] ="25,3021,1" -- UFC Keyboard Pushbutton, 3 >> CDU :: 3
Helios_F18C.ExportArguments["9,3018"] ="25,3022,1" -- UFC Keyboard Pushbutton, 4 >> CDU :: 4
Helios_F18C.ExportArguments["9,3019"] ="25,3023,1" -- UFC Keyboard Pushbutton, 5 >> CDU :: 5
Helios_F18C.ExportArguments["9,3020"] ="25,3024,1" -- UFC Keyboard Pushbutton, 6 >> CDU :: 6
Helios_F18C.ExportArguments["9,3021"] ="25,3025,1" -- UFC Keyboard Pushbutton, 7 >> CDU :: 7
Helios_F18C.ExportArguments["9,3022"] ="25,3026,1" -- UFC Keyboard Pushbutton, 8 >> CDU :: 8
Helios_F18C.ExportArguments["9,3023"] ="25,3027,1" -- UFC Keyboard Pushbutton, 9 >> CDU :: 9
Helios_F18C.ExportArguments["9,3024"] ="25,3018,1" -- UFC Keyboard Pushbutton, 0 >> CDU :: 0
Helios_F18C.ExportArguments["8,3015"] ="25,3028,1" -- UFC Keyboard Pushbutton, CLR >> UFC :: Clear
Helios_F18C.ExportArguments["8,3016"] ="25,3029,1" -- UFC Keyboard Pushbutton, ENT >> UFC :: Enter
Helios_F18C.ExportArguments["8,3013"] ="25,3015,1" -- UFC I/P Pushbutton >> UFC :: Select Funciton Mode
Helios_F18C.ExportArguments["8,3014"] ="25,3017,1" -- UFC EMCON Select Pushbutton >> UFC :: Select Letter Mode
Helios_F18C.ExportArguments["57,3002"] ="25,3016,1" -- UFC ADF Function Select Switch, 1/OFF/2 >> TISL :: Slant Range 
Helios_F18C.ExportArguments["49,3016"] ="25,3030,1" -- UFC COMM 1 Volume Control Knob >> Light System :: Weapon Station Lights Brightness
Helios_F18C.ExportArguments["49,3015"] ="25,3031,1" -- UFC COMM 2 Volume Control Knob >> Light System :: Refuel Status Indexer Brightness
Helios_F18C.ExportArguments["49,3002"] ="25,3032,1" -- UFC Brightness Control Knob >> Light System :: Flight Instruments Lights
Helios_F18C.ExportArguments["57,3007"] ="40,3003,1" -- ICS Volume Control Knob >> TISL :: TISL Code Wheel 3
Helios_F18C.ExportArguments["58,3002"] ="40,3004,1" -- RWR Volume Control Knob >> Intercom :: INT Volume;
Helios_F18C.ExportArguments["57,3004"] ="40,3005,1" -- WPN Volume Control Knob >> TISL :: Altitude above target thousands of feet
Helios_F18C.ExportArguments["57,3003"] ="40,3007,1" -- MIDS B Volume Control Knob >> TISL :: Altitude above target tens of thousands of feet
Helios_F18C.ExportArguments["57,3005"] ="40,3006,1" -- MIDS A Volume Control Knob >> TISL :: TISL Code Wheel 1
Helios_F18C.ExportArguments["57,3006"] ="40,3008,1" -- TACAN Volume Control Knob >> TISL :: TISL Code Wheel 2
Helios_F18C.ExportArguments["5,3007"] ="40,3009,1" -- AUX Volume Control Knob >> CMSC :: RWR Volume
Helios_F18C.ExportArguments["40,3003"] ="40,3010,1" -- COMM RLY Select Switch, CIPHER/OFF/PLAIN >> Oxygen System :: Emergency Lever
Helios_F18C.ExportArguments["43,3010"] ="40,3011,1" -- COMM G XMT Switch, COMM 1/OFF/COMM 2 >> IFF :: M-1 Switch
Helios_F18C.ExportArguments["22,3005"] ="40,3012,102" -- IFF Master Switch, EMER/NORM >> AAP :: CDU Power
Helios_F18C.ExportArguments["57,3009"] ="40,3013,1" -- IFF Mode 4 Switch, DIS-AUD/DIS/OFF >> TISL :: Code Select
Helios_F18C.ExportArguments["41,3004"] ="50,3001,1" -- COMM 1 ANT SEL Switch, UPPER/AUTO/LOWER >> Environmental Control :: Windshield Remove/Wash
Helios_F18C.ExportArguments["43,3011"] ="50,3002,1" -- IFF ANT SEL Switch, UPPER/BOTH/LOWER >> IFF :: M-2 Switch
