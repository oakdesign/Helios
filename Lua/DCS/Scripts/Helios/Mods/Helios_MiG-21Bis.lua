Helios_Mig21Bis = {}

Helios_Mig21Bis.Name = "MiG-21Bis"
Helios_Mig21Bis.FlamingCliffsAircraft = false

Helios_Mig21Bis.ExportArguments = {}

-- Take any inputs from Helios and Convert them from A10C to MIG-21 before pass them to DCS World
function Helios_Mig21Bis.ProcessInput(data)
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
		lConvDevice = Helios_Mig21Bis.ExportArguments[sIndex] 	
		lArgument = Helios_Util.Split(string.sub(lConvDevice,1),",")
		min_clamp = 0
		
		if lArgument[3]>"299" then   -- rockers special cases
			local valor_actual = GetDevice(0)
			local absoluto= math.abs(lCommandArgs[3])
			local variacion= (lCommandArgs[3]/100)
			
			if lArgument[3]=="300" then 
				valor_axis= valor_actual:get_argument_value(262) + variacion
				lArgument = {32,3073,1} -- Altimeter pressure knob 262 axis lim 0.02 
				min_clamp = -1
			end
			if lArgument[3]=="301" then 
				valor_axis= valor_actual:get_argument_value(260) + variacion
				lArgument = {28,3141,1} -- KPP Set 260 axis lim 0.0001
				min_clamp = -1
			end
			
			if lArgument[3]=="302" then 
			
				valor_axis= variacion
				lArgument = {23,3144,1} -- NPP Course set 263 axis 0.1 
				min_clamp = -1
			end
			
			lCommandArgs[3]=math.max(min_clamp, math.min(1, valor_axis))	
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
			
			lDevice:performClickableAction(lArgument[2],lCommandArgs[3]*lArgument[3])
		end
	end
end

function Helios_Mig21Bis.HighImportance(data)
	local _LAST_ONE = 0 -- used to mark the end of the tables	
	local MainPanel = GetDevice(0)
	
	-- Pilot console instruments
	local ENGINE_TEMPERATURE = MainPanel:get_argument_value(51)
	local FUEL_METER = MainPanel:get_argument_value(52)
	local ENGINE_RPM = Helios_Util.ValueConvert(MainPanel:get_argument_value(50),{ 0.0, 1, 110 },{ 0.0, 0.2, 1.0 })
	local ENGINE_RPM2 = MainPanel:get_argument_value(670)
	local IAS_indicator = Helios_Util.ValueConvert(MainPanel:get_argument_value(100),{ 0.0, 83.33, 166.67, 250.0, 333.34, 416.67, 555.55 },{ 0.0, 0.15, 0.30, 0.45, 0.60, 0.75, 1.0 })
	local COMPRESSED_AIR_main = MainPanel:get_argument_value(413)
	local COMPRESSED_AIR_aux = MainPanel:get_argument_value(414)
	local OXYGENE_instrument_IK52 = MainPanel:get_argument_value(59)
	local OXYGENE_instrument_M2000 = MainPanel:get_argument_value(58)
	local OIL_PRESSURE = MainPanel:get_argument_value(627)
	local ACCELEROMETER = MainPanel:get_argument_value(110)
	local MAX_G = MainPanel:get_argument_value(113)
	local MIN_G = MainPanel:get_argument_value(114)
	local UUA_indicator = Helios_Util.ValueConvert(MainPanel:get_argument_value(105),{ -0.1745, 0.0, 0.6108 },{ -0.2857, 0.0, 1.0 })
	local KONUS_efficiency = MainPanel:get_argument_value(625)
	local KONUS_UPES_3_instrument = MainPanel:get_argument_value(66)
	local ARU_3G_instrument = MainPanel:get_argument_value(64)
	local TAS_indicator = Helios_Util.ValueConvert(MainPanel:get_argument_value(101),{ 0.0, 8, 63, 135, 206, 350 },{ 0.0, 0.20, 0.309, 0.49, 0.67, 1.00 })
	local M_indicator = Helios_Util.ValueConvert(MainPanel:get_argument_value(102),{ 0.0,  13,  67,  180,  208, 350 },{ 0.0, 0.202, 0.312, 0.6, 0.66, 1.00 })
	local DC_BUS_V_needle = MainPanel:get_argument_value(124)
	local RADIO_ALTIMETER_indicator = Helios_Util.ValueConvert(MainPanel:get_argument_value(103),{ 63, 81, 88, 115, 129, 154, 160, 173, 179, 186, 193, 212, 229, 246, 257, 277, 294, 300, 301, },{ 0.0, 0.041, 0.07, 0.103, 0.13, 0.181, 0.21, 0.245, 0.260, 0.298, 0.325, 0.472, 0.58, 0.680, 0.732, 0.807, 0.867, 0.909, 1.0 })
	local DA200_TurnNeedle = MainPanel:get_argument_value(107)
	local DA200_VerticalVelocity = Helios_Util.ValueConvert(MainPanel:get_argument_value(106),{37, 55, 75, 100, 110, 145, 180, 215, 250, 260, 285, 305, 323},{ -1.0, -0.878, -0.754, -0.575, -0.504, -0.256, 0.0, 0.256, 0.505, 0.571, 0.751, 0.871, 1.0 })
	local variometer_set = MainPanel:get_argument_value(261)
	DA200_VerticalVelocity= DA200_VerticalVelocity + (variometer_set*20)  -- adjust VVI + variometer set value
	local DA200_SLIPBALL = MainPanel:get_argument_value(31)
	local H_indicator_needle_m = MainPanel:get_argument_value(104)
	local H_indicator_needle_km = MainPanel:get_argument_value(112)
	local GIDRO_PRESS_P_needle = Helios_Util.ValueConvert(MainPanel:get_argument_value(126),{ 210, 60 },{ 0.0, 1.0 })
	local GIDRO_PRESS_S_needle = Helios_Util.ValueConvert(MainPanel:get_argument_value(125),{ 60, 210 },{ 0.0, 1.0 })
	local DC_BUS_ISA_K = MainPanel:get_argument_value(55)
	local COCKPIT_PRESSURE_ALTIMETER = Helios_Util.ValueConvert(MainPanel:get_argument_value(655),{ 0, 320 },{ 0.0, 1.0 })
	local COCKPIT_PRESSURE = Helios_Util.ValueConvert(MainPanel:get_argument_value(656),{ 270, 290, 319, 251, 216, 180, 150, 120, 90, 55 },{ -1.0, -0.56, -0.27, 0.0, 0.17, 0.35, 0.50, 0.66, 0.82, 1.0 })
	local ARK_RSBN_needle = MainPanel:get_argument_value(36)
	local KSI_course_set_needle = MainPanel:get_argument_value(68)
	local KPP_Bank = MainPanel:get_argument_value(108)
	local KPP_Pitch = MainPanel:get_argument_value(109)
	local KPP_Set = MainPanel:get_argument_value(260)
	KPP_Pitch = KPP_Pitch + (KPP_Set/9) -- adjust KPP pitch + KPP_set value
	local Needle_ora_sec = MainPanel:get_argument_value(117)
	local Needle_ora = MainPanel:get_argument_value(115)
	local Needle_ora_perc = MainPanel:get_argument_value(116)
	local Needle_ora_min_kis = MainPanel:get_argument_value(121)
	local Needle_ora_sec_kis = MainPanel:get_argument_value(122)
	local RSBN_distance_meter_Hundreds = MainPanel:get_argument_value(355)
	local RSBN_distance_meter_Tens = MainPanel:get_argument_value(356)
	local RSBN_distance_meter_Singles = MainPanel:get_argument_value(357)
	local Gearbrake_needle1 = MainPanel:get_argument_value(56)
	local Gearbrake_needle2 = MainPanel:get_argument_value(57)
	local IAS_Nr = MainPanel:get_argument_value(100)
	local KSI_course_indicator = MainPanel:get_argument_value(111)
	local RSBN_NPP_kurs_needle = MainPanel:get_argument_value(590)
	local RSBN_NPP_glisada_needle = MainPanel:get_argument_value(589)
	local RSBN_KPP_kurs_director = MainPanel:get_argument_value(565)
	local RSBN_KPP_glisada_director = MainPanel:get_argument_value(566)
	local ENGINE_OXYGENE_manometer = MainPanel:get_argument_value(61)
	local AltimeterPressure = Helios_Util.ValueConvert(MainPanel:get_argument_value(262),{ 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79 },{ -1.000, -0.889, -0.770, -0.668, -0.557, -0.450, -0.333, -0.222, -0.118, -0.007, 0.313, 0.639, 1.000 })
	local Clock_status_bar = MainPanel:get_argument_value(118)*10

	
	local lamps_table =
	{	
		[1] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(513)),    -- OIL_LIGHT
		[2] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(542)),    -- SORC
		[3] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(500)),    -- LOW_ALT_LIGHT
		[4] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(546)),	   -- SAU_stabilization_LIGHT
		[5] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(544)),	   -- SAU_landing_COMMAND_LIGHT
		[6] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(545)),	   -- SAU_landing_AUTO_LIGHT
		[7] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(547)),	   -- SAU_privedenie_LIGHT
		[8] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(584)),	   -- MISSILE_55_1_LIGHT
		[9] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(585)),	   -- MISSILE_55_2_LIGHT
		[10] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(586)),   -- MISSILE_62_LIGHT
		[11] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(538)),   -- ASP_LAUNCH_LIGHT
		[12] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(540)),   -- ASP_DISENGAGE_LIGHT
		[13] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(503)),   -- FUEL_450
		[14] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(63)),	   -- TACTICAL_DROP_ARMED_LIGHT
		[15] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(553)),   -- RADAR_ERROR_LIGHT
		[16] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(554)),   -- RADAR_LOW_ALT_LIGHT
		[17] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(555)),   -- RADAR_FIX_BEAM_LIGHT
		[18] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(607)),   -- SRZO_ON (EOD)_LIGHT
		[19] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(608)),   -- SRZO_CODE_LIGHT
		[20] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(609)),   -- SRZO_CIPH (DEC)_LIGHT
		[21] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(549)),   -- RSBN_dalnost_korekcija_LIGHT
		[22] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(534)),   -- FIRE_LIGHT
		[23] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(537)),   -- AOA_WARNING_LIGHT
		[24] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(550)),   -- GUN_gotovn_LIGHT
		[25] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(606)),   -- SOD_ANSWER
		[26] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(516)),   -- MARKER_LIGHT
		[27] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(601)),   -- SPO_L_F (SPO LEFT TOP) LIGHT
		[28] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(602)),   -- SPO_R_F (SPO RIGHT TOP) LIGHT
		[29] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(603)),   -- SPO_R_B (SPO RIGHT BOTTOM) LIGHT
		[30] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(604)),   -- SPO_L_B (SPO LEFT BOTTOM) LIGHT
		[31] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(605)),   -- SPO_MUTED(SPO TEST) LIGHT
		[32] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(517)),   -- KONUS_LIGHT
		[33] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(518)),   -- STABILISATOR_LIGHT
		[34] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(519)),   -- TRIMMER_LIGHT
		[35] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(509)),   -- START_DEVICE_ZAZIG_LIGHT
		[36] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(510)),   -- DC_GEN_LIGHT
		[37] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(511)),   -- AC_GEN_LIGHT
		[38] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(512)),   -- NOZZLE_LIGHT
		[39] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(514)),   -- CHECK_BUSTER_PRESSURE
		[40] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(515)),   -- CHECK_HYDRAULIC_PRESSURE
		[41] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(505)),   -- FUEL_PODW
		[42] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(502)),   -- FUEL_1GR
		[43] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(504)),   -- FUEL_3GR
		[44] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(568)),   -- RSBN_KPP_tangaz_blinker (RED T LIGHT)
		[45] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(526)),   -- PYLON_1_ON_LIGHT
		[46] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(527)),   -- PYLON_2_ON_LIGHT
		[47] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(528)),   -- PYLON_3_ON_LIGHT
		[48] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(529)),   -- PYLON_4_ON_LIGHT
		[49] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(524)),   -- RATO_L_LIGHT
		[50] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(501)),   -- FUEL_PODC
		[51] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(525)),   -- RATO_R_LIGHT
		[52] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(506)),   -- FUEL_RASHOD (DISP TK EMPTY)
		[53] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(507)),   -- FORSAZ_1_LIGHT (AFTERBURNER)
		[54] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(508)),   -- FORSAZ_2_LIGHT (SECOND AFTERBURNER)
		[55] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(523)),   -- CENTRAL_PYLON_LIGHT
		[56] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(530)),   -- PYLON_1_OFF_LIGHT(UB POD 1 EMPTY)
		[57] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(531)),   -- PYLON_2_OFF_LIGHT(UB POD 2 EMPTY)
		[58] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(532)),   -- PYLON_3_OFF_LIGHT(UB POD 3 EMPTY)
		[59] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(533)),   -- PYLON_4_OFF_LIGHT(UB POD 4 EMPTY)
		[60] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(536)),   -- GIRO_ARRETIR (CAGE VERT RED LIGHT)
		[61] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(535)),   -- KPP_ARRETIR_light (RED LIGHT MARKED APPETNP)
		[62] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(541)),   -- CANOPY_WARNG_LIGHT
		[63] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9)),     -- GEAR_NOSE_UP_LIGHT
		[64] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(12)),    -- GEAR_NOSE_DOWN_LIGHT
		[65] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(10)),    -- GEAR_LEFT_UP_LIGHT
		[66] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(13)),    -- GEAR_LEFT_DOWN_LIGHT
		[67] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(11)),    -- GEAR_RIGHT_UP_LIGHT
		[68] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(14)),    -- GEAR_RIGHT_DOWN_LIGHT
		[69] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(522)),   -- AIRBRAKE_LIGHT
		[70] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(521)),   -- FLAPS_LIGHT
		[71] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(520)),   -- CHECK_GEAR_LIGHT
		[72] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(581)),   -- IAB_LIGHT_1 (RN24 PANEL 'LOADED' LIGHT)
		[73] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(582)),   -- IAB_LIGHT_2 (RN24 PANEL 'ARMED' LIGHT)
		[74] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(583)),   -- IAB_LIGHT_3 (RN24 PANEL 'FUSE ON' LIGHT)
		[75] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(594)),   -- SPS_LAUNCH(SPS 141 PANEL 'LAUNCH' LIGHT)
		[76] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(592)),   -- SPS_WORKS (SPS 141 PANEL 'READY' LIGHT)
		[77] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(593)),   -- SPS_ILLUMINATION (SPS 141 PANEL 'SIGNAL' LIGHT)
		[78] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(701)),   -- GUV_LAUNCH (UPK23-250 PANEL 'STATUS' LIGHT)
		[79] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(560)),   -- RADAR_JAMMED (HORIZ LEFT 'JAMMING' - RED LIGHT)
		[80] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(571)),   -- RADAR_19A_1 (CMS 'C' LIGHT) 
		[81] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(572)),   -- ADAR_19A_2(CMS 'O N' LIGHT) 
		[82] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(573)),   -- RADAR_19A_3 (CMS 'T E' LIGHT) 
		[83] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(574)),   -- RADAR_19A_4 (CMS 'WEATH' LIGHT)
		[84] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(575)),   -- RADAR_19A_5(CMS 'IFF' LIGHT) 
		[85] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(576)),   -- RADAR_19A_6 (CMS 'LOW' LIGHT) 
		[86] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(577)),   -- RADAR_19A_7 (CMS 'SELF TEST' LIGHT)
		[87] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(578)),   -- RADAR_19A_8 (CMS 'RESET' LIGHT) 
		[88] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(558)),   -- RADAR_LAUNCH (VERTICAL TOP - RED LIGHT)
		[89] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(559)),   -- RADAR_MISSILE_HEAD_RDY (VERTICAL BOTTOM - RED LIGHT)
		[90] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(561)),   -- RADAR_BROKEN (HORIZ RIGHT - RED LIGHT)
		[91] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(562)),   -- RADAR_DISENGAGE(ROUND RED LIGHT)
		[92] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(539)),   -- ASP_TGT_ACQUIRED_LIGHT(ROUND GREEN LIGHT)
		[93] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(60)),    -- OXYGENE_instrument_IK52_blinking_lungs
		[94] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(587)),   -- RSBN_NPP_kurs_blinker (WHITE COURSE LIGHT)
		[95] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(588)),   -- RSBN_NPP_glisada_blinker (WHITE GLIDESLOPE LIGHT)
		[96] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(567))    -- RSBN_KPP_kren_blinker (RED K LIGHT)
	} 

	----------------------------------------------------------
	---- ok, now lets send all this MIG-21 data across A10C interface to Helios
	----------------------------------------------------------			


	-- gauges and instruments  >>> "SAI", "Pitch Adjust"
	Helios_Udp.Send("715", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f, %.2f,%.2f,%.2f,%.4f,%.2f,%.2f,%.2f,%.3f,%.3f,%.2f, %.2f",
		ENGINE_TEMPERATURE, --1
		FUEL_METER, --2
		ENGINE_RPM, --3
		ENGINE_RPM2, --4
		IAS_indicator, --5
		COMPRESSED_AIR_main, --6
		COMPRESSED_AIR_aux, --7
		OXYGENE_instrument_IK52, --8
		OXYGENE_instrument_M2000, --9
		OIL_PRESSURE, --10
		ACCELEROMETER, --11
		MAX_G, --12
		MIN_G, --13
		UUA_indicator, --14
		KONUS_efficiency, --15
		KONUS_UPES_3_instrument, --16
		ARU_3G_instrument, --17
		TAS_indicator, --18
		M_indicator, --19
		DC_BUS_V_needle, --20
		_LAST_ONE  -- Last one, do not delete this
	) )
					
			
		
	-- gauges and instruments  	>>> "ADI", "Glide Slope Indicator"
	Helios_Udp.Send("27", string.format("%.2f,%.1f,%.2f,%.2f,%.2f,%.f,%.3f,%.3f,%.3f,%.3f, %.3f,%.3f,%.3f,%.3f, %.3f,%.2f",
		RSBN_distance_meter_Hundreds, --1
		RSBN_distance_meter_Tens, --2
		RSBN_distance_meter_Singles, --3
		Gearbrake_needle1, --4
		Gearbrake_needle2, --5
		IAS_Nr, --6
		KSI_course_indicator, --7
		RSBN_NPP_kurs_needle, --8
		RSBN_NPP_glisada_needle, --9
		RSBN_KPP_kurs_director, --10
		RSBN_KPP_glisada_director, --11
		KPP_Pitch, --12
		ENGINE_OXYGENE_manometer, --13
		AltimeterPressure, --14
		Clock_status_bar, --15
		_LAST_ONE  -- Last one, do not delete this
	) )
			
			
	-- gauges and instruments  	>>> "ADI", "Slip Ball"
	Helios_Udp.Send("24", string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.2f,%.3f, %.3f,%.3f,%.3f,%.3f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f",
		RADIO_ALTIMETER_indicator, --1
		DA200_TurnNeedle, --2
		DA200_VerticalVelocity, --3
		DA200_SLIPBALL, --4
		H_indicator_needle_m, --5
		H_indicator_needle_km, --6
		GIDRO_PRESS_P_needle, --7
		GIDRO_PRESS_S_needle, --8
		DC_BUS_ISA_K, --9 
		COCKPIT_PRESSURE_ALTIMETER, --10
		COCKPIT_PRESSURE, --11
		ARK_RSBN_needle, --12
		KSI_course_set_needle, --13
		KPP_Bank, --14
		Needle_ora_sec, --15
		Needle_ora, --16
		Needle_ora_perc, --17
		Needle_ora_min_kis, --18
		Needle_ora_sec_kis, --19
		_LAST_ONE  -- Last one, do not delete this
	) )
		
			
	-- switches and lamps tables exported on pure networvalues from A10C				
	Helios_Udp.Send("269", string.format("%s", table.concat(lamps_table,"") ) )    -- lamps table	    >>> "HARS", "SYN-IND Sync Needle"
	
	--flaps			
	Helios_Udp.Send("628", string.format("%.1f", MainPanel:get_argument_value(311) ) )		-- Flaps Neutral 311 2 > "TISL", "Enter" 628 --
	Helios_Udp.Send("630", string.format("%.1f", MainPanel:get_argument_value(312) ) )		-- Flaps Take-Off 312 2 > "TISL", "OverTemp" 630 --
	Helios_Udp.Send("632", string.format("%.1f", MainPanel:get_argument_value(313) ) )		-- Flaps Landing 313 2 > "TISL", "Bite" 632 --
	Helios_Udp.Send("634", string.format("%.1f", MainPanel:get_argument_value(314) ) )		-- Flaps Reset buttons 314 btn > "TISL", "Track" 634 --
	--axis	
	Helios_Udp.Send("171", string.format("%.3f", MainPanel:get_argument_value(210) ) )		-- Radio Volume  210 axis 0.1 >  "UHF Radio", "Volume" 171
	Helios_Udp.Send("221", string.format("%.3f", MainPanel:get_argument_value(198) ) )		-- ARK Sound  198 axis 0.1 > "Intercom", "INT Volume" 221
	Helios_Udp.Send("223", string.format("%.3f", MainPanel:get_argument_value(345) ) )		-- RSBN Sound  345 axis 0.1 > "Intercom", "FM Volume" 223 
	Helios_Udp.Send("225", string.format("%.3f", MainPanel:get_argument_value(612) ) )		-- Cockpit Texts Back-light  612 axis 0.1 +300 dwn> "Intercom", "VHF Volume"  225
	Helios_Udp.Send("227", string.format("%.3f", MainPanel:get_argument_value(156) ) )		-- Instruments Back-light  156 axis 0.1 +300 dwn>   "Intercom", "UHF Volume"  227
	Helios_Udp.Send("229", string.format("%.3f", MainPanel:get_argument_value(157) ) )		-- Main Red Lights  157 axis 0.1 +300 dwn>          "Intercom", "AIM Volume"  229
	Helios_Udp.Send("231", string.format("%.3f", MainPanel:get_argument_value(222) ) )		-- Main White Lights  222 axis 0.1 +300 dwn>        "Intercom", "IFF Volume"  231
	Helios_Udp.Send("233", string.format("%.3f", MainPanel:get_argument_value(225) ) )		-- SPO-10 Volume  	225 axis 0.1 > "Intercom", "ILS Volume" 233 
	Helios_Udp.Send("235", string.format("%.3f", MainPanel:get_argument_value(623) ) )		-- Radar Polar Filter 623 axis 0.1 > "Intercom", "TCN Volume" 235 
	Helios_Udp.Send("636", string.format("%.3f", MainPanel:get_argument_value(236) ) )		-- Nosecone manual position controller 236 axis 0.05 > "TISL", "TISL Code Wheel 1" 636 
	Helios_Udp.Send("238", string.format("%.3f", MainPanel:get_argument_value(263) ) )		-- NPP Course set 263 axis 0.1 > "Intercom", "Master Volume" 238
	Helios_Udp.Send("288", string.format("%.3f", MainPanel:get_argument_value(245) ) )		-- Target Size 245 axis 0.1 >                      "Light System", "Formation Lights"            288 
	Helios_Udp.Send("290", string.format("%.3f", MainPanel:get_argument_value(246) ) )		-- Intercept Angle 246 axis 0.1 >                  "Light System", "Engine Instrument Lights"    290 
	Helios_Udp.Send("292", string.format("%.3f", MainPanel:get_argument_value(247) ) )		-- Scale Backlights control 247 axis 0.1 >         "Light System", "Flight Instruments Lights"   292 
	Helios_Udp.Send("293", string.format("%.3f", MainPanel:get_argument_value(248) ) )		-- Pipper light control 248 axis 0.1 >             "Light System", "Auxillary instrument Lights" 293 
	Helios_Udp.Send("296", string.format("%.3f", MainPanel:get_argument_value(251) ) )		-- Fix Net light control 251 axis 0.1 >            "Light System", "Flood Light"                 296 
	Helios_Udp.Send("297", string.format("%.3f", MainPanel:get_argument_value(348) ) )		-- TDC Range / Pipper Span control 384 axis 0.1 >  "Light System", "Console Lights"              297 
	Helios_Udp.Send("193", string.format("%.3f", MainPanel:get_argument_value(297) ) )		-- Missile Seeker Sound  297 axis 0.1 > "Light System", "Refuel Status Indexer Brightness" 193 	
	Helios_Udp.Send("642", string.format("%.3f", MainPanel:get_argument_value(223) ) )		-- Main Gears Emergency Release Handle 223 axis 0.2 > "TISL Code Wheel 4" 642 aaaaaaaaaa
	Helios_Udp.Send("277", string.format("%.3f", MainPanel:get_argument_value(267) ) )		-- Mech clock right lever  267 axis  0.05 -015 0.15 > "Environmental Control", "Canopy Defog" 277 --
	Helios_Udp.Send("192", string.format("%.3f", MainPanel:get_argument_value(261) ) )		-- variometer Set  261 axis lim 0.0001   (-1,1) > "Autopilot", "Yaw Trim" 192  --
	--others
	Helios_Udp.Send("624", string.format("%.3f", MainPanel:get_argument_value(351) ) )		-- RSBN Channel Selector - 99 positions 0 - 99 > "TISL", "Altitude above target tens of thousands of feet" 624 
	Helios_Udp.Send("626", string.format("%.3f", MainPanel:get_argument_value(352) ) )		-- PRMG Channel Selector - 99 positions 0 - 99 >"TISL", "Altitude above target thousands of feet" 626 
	Helios_Udp.Send("780", string.format("%.1d", MainPanel:get_argument_value(202) ) )		-- SPO-10 RWR On/Off 202 2 > "KY-58 Secure Voice", "Delay" 780 --	
	Helios_Udp.Send("784", string.format("%.1d", MainPanel:get_argument_value(227) ) )		-- SPO-10 Night / Day  	227 2 > "KY-58 Secure Voice", "Power Switch" 784 --		
	Helios_Udp.Send("170", string.format("%.1d", MainPanel:get_argument_value(326) ) )		-- Gear Handle Fixator 326 2 > "UHF Radio", "Squelch" 170 --
	Helios_Udp.Send("105", string.format("%.1d", MainPanel:get_argument_value(327) ) )		-- Gear Up/Neutral/Down 327 multi sw 3 1.0 > "Fire System", "Discharge Switch" 105 ----------- -1 0 1
	Helios_Udp.Send("540", string.format("%.1d", MainPanel:get_argument_value(611) ) )		-- SRZO_ERROR lamp > "AOA Indexer", "High Indicator" 540

	Helios_Udp.Flush()
end


function Helios_Mig21Bis.LowImportance(MainPanel)


	local sw_table =
		{			
			[1] = Helios_Util.Convert_SW (MainPanel:get_argument_value(165)),			-- Battery On/Off
			[2] = Helios_Util.Convert_SW (MainPanel:get_argument_value(155)),			-- Battery Heat On/Off
			[3] = Helios_Util.Convert_SW (MainPanel:get_argument_value(166)),			-- DC Generator On/Off
			[4] = Helios_Util.Convert_SW (MainPanel:get_argument_value(169)),			-- AC Generator On/Off
			[5] = Helios_Util.Convert_SW (MainPanel:get_argument_value(153)),			-- PO-750 Inverter #1 On/Off
			[6] = Helios_Util.Convert_SW (MainPanel:get_argument_value(154)),			-- PO-750 Inverter #2 On/Off
			[7] = Helios_Util.Convert_SW (MainPanel:get_argument_value(164)),			-- Emergency Inverter
			[8] = Helios_Util.Convert_SW (MainPanel:get_argument_value(162)),			-- Giro, NPP, SAU, RLS Signal, KPP Power On/Off
			[9] = Helios_Util.Convert_SW (MainPanel:get_argument_value(163)),			-- DA-200 Signal, Giro, NPP, RLS, SAU Power On/Off
			[10] = Helios_Util.Convert_SW (MainPanel:get_argument_value(159)),			-- Fuel Tanks 3rd Group, Fuel Pump
			[11] = Helios_Util.Convert_SW (MainPanel:get_argument_value(160)),			-- Fuel Tanks 1st Group, Fuel Pump
			[12] = Helios_Util.Convert_SW (MainPanel:get_argument_value(161)),			-- Drain Fuel Tank, Fuel Pump
			[13] = Helios_Util.Convert_SW (MainPanel:get_argument_value(302)),			-- APU On/Off
			[14] = Helios_Util.Convert_SW (MainPanel:get_argument_value(288)),			-- Engine Cold / Normal Start
			[15] = Helios_Util.Convert_SW (MainPanel:get_argument_value(301)),			-- Engine Emergency Air Start			
			[16] = Helios_Util.Convert_SW (MainPanel:get_argument_value(229)),			-- Pitot tube Selector Main/Emergency
			[17] = Helios_Util.Convert_SW (MainPanel:get_argument_value(279)),			-- Pitot tube/Periscope/Clock Heat
			[18] = Helios_Util.Convert_SW (MainPanel:get_argument_value(280)),			-- Secondary Pitot Tube Heat				
			[19] = Helios_Util.Convert_SW (MainPanel:get_argument_value(308)),			-- Anti surge doors - Auto/Manual
			[20] = Helios_Util.Convert_SW (MainPanel:get_argument_value(300)),			-- Afterburner/Maximum Off/On
			[21] = Helios_Util.Convert_SW (MainPanel:get_argument_value(320)),			-- Emergency Afterburner Off/On				
			[22] = Helios_Util.Convert_SW (MainPanel:get_argument_value(303)),			-- Fire Extinguisher Off/On
			[23] = Helios_Util.Convert_SW (MainPanel:get_argument_value(324)),			-- Fire Extinguisher Cover					
			[24] = Helios_Util.Convert_SW (MainPanel:get_argument_value(173)),			-- Radio System On/Off
			[25] = Helios_Util.Convert_SW (MainPanel:get_argument_value(208)),			-- Radio / Compass
			[26] = Helios_Util.Convert_SW (MainPanel:get_argument_value(209)),			-- Squelch On/Off
			[27] = Helios_Util.Convert_SW (MainPanel:get_argument_value(174)),			-- ARK On/Off
			[28] = Helios_Util.Convert_SW (MainPanel:get_argument_value(197)),			-- ARK Mode - Antenna / Compass
			[29] = Helios_Util.Convert_SW (MainPanel:get_argument_value(176)),			-- RSBN On/Off
			[30] = Helios_Util.Convert_SW (MainPanel:get_argument_value(340)),			-- RSBN / ARK	
			[31] = Helios_Util.Convert_SW (MainPanel:get_argument_value(367)),			-- RSBN Bearing
			[32] = Helios_Util.Convert_SW (MainPanel:get_argument_value(368)),			-- RSBN Distance
			[33] = Helios_Util.Convert_SW (MainPanel:get_argument_value(179)),			-- SAU On/Off
			[34] = Helios_Util.Convert_SW (MainPanel:get_argument_value(180)),			-- SAU Pitch On/Off	
			[35] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(323)*2)-1)),  -- Landing Lights Off/Taxi/Land - 3 posiciones 0,5
			[36] = Helios_Util.Convert_SW (MainPanel:get_argument_value(202)),			-- SPO-10 RWR On/Off
			[37] = Helios_Util.Convert_SW (MainPanel:get_argument_value(188)),			-- SRZO IFF Coder/Decoder On/Off	
			[38] = Helios_Util.Convert_SW (MainPanel:get_argument_value(346)),			-- IFF System 'Type 81' On/Off
			[39] = Helios_Util.Convert_SW (MainPanel:get_argument_value(190)),			-- Emergency Transmitter Cover
			[40] = Helios_Util.Convert_SW (MainPanel:get_argument_value(191)),			-- Emergency Transmitter On/Off
			[41] = Helios_Util.Convert_SW (MainPanel:get_argument_value(427)),			-- SRZO Self Destruct Cover
			[42] = Helios_Util.Convert_SW (MainPanel:get_argument_value(200)),			-- SOD IFF On/Off	
			[43] = Helios_Util.Convert_SW (MainPanel:get_argument_value(207)),			-- Locked Beam On/Off
			[44] = Helios_Util.Convert_SW (MainPanel:get_argument_value(167)),			-- SPRD (RATO) System On/Off	
			[45] = Helios_Util.Convert_SW (MainPanel:get_argument_value(168)),			-- SPRD (RATO) Drop System On/Off	
			[46] = Helios_Util.Convert_SW (MainPanel:get_argument_value(252)),			-- SPRD (RATO) Start Cover
			[47] = Helios_Util.Convert_SW (MainPanel:get_argument_value(317)),       	-- SPRD (RATO)t Drop Cover
			[48] = string.format("%02.f", math.floor((MainPanel:get_argument_value(211)*20)+ 0.05)) -- Radio channel selector 20 channels from 0 to 19 - 0,0555
			-- warning 48 uses 2 characters		
		}																
		
		local sw_table_2 =
		{			
			[1] = Helios_Util.Convert_SW (MainPanel:get_argument_value(299)),			-- ABS Off/On
			[2] = Helios_Util.Convert_SW (MainPanel:get_argument_value(238)),			-- Nosegear Brake Off/On
			[3] = Helios_Util.Convert_SW (MainPanel:get_argument_value(237)),			-- Emergency Brake
			[4] = Helios_Util.Convert_SW (MainPanel:get_argument_value(281)),			-- Nose Gear Emergency Release Handle
			[5] = Helios_Util.Convert_SW (MainPanel:get_argument_value(304)),			-- Drop Drag Chute Cover
			[6] = Helios_Util.Convert_SW (MainPanel:get_argument_value(172)),			-- Trimmer On/Off			
			[7] = Helios_Util.Convert_SW (MainPanel:get_argument_value(170)),			-- Nosecone On/Off
			[8] = Helios_Util.Convert_SW (MainPanel:get_argument_value(309)),			-- Nosecone Control - Manual/Auto
			[9] = Helios_Util.Convert_SW (MainPanel:get_argument_value(291)),			-- Engine Nozzle 2 Position Emergency Control				
			[10] = Helios_Util.Convert_SW (MainPanel:get_argument_value(171)),			-- Emergency Hydraulic Pump On/Off
			[11] = Helios_Util.Convert_SW (MainPanel:get_argument_value(319)),			-- Aileron Booster - Off/On
			[12] = Helios_Util.Convert_SW (MainPanel:get_argument_value(175)),			-- Radio Altimeter/Marker On/Off			
			[13] = Helios_Util.Convert_SW (MainPanel:get_argument_value(285)),			-- Helmet Air Condition Off/On
			[14] = Helios_Util.Convert_SW (MainPanel:get_argument_value(286)),			-- Emergency Oxygen Off/On					
			[15] = Helios_Util.Convert_SW (MainPanel:get_argument_value(287)),			-- Mixture/Oxygen
			[16] = Helios_Util.Convert_SW (MainPanel:get_argument_value(224)),			-- Canopy Emergency Release Handle
			[17] = Helios_Util.Convert_SW (MainPanel:get_argument_value(186)),			-- ASP Optical sight On/Off
			[18] = Helios_Util.Convert_SW (MainPanel:get_argument_value(241)),			-- ASP Main Mode - Manual/Auto
			[19] = Helios_Util.Convert_SW (MainPanel:get_argument_value(242)),			-- ASP Mode - Bombardment/Shooting
			[20] = Helios_Util.Convert_SW (MainPanel:get_argument_value(243)),			-- ASP Mode - Missiles-Rockets/Gun
			[21] = Helios_Util.Convert_SW (MainPanel:get_argument_value(244)),			-- ASP Mode - Giro/Missile	
			[22] = Helios_Util.Convert_SW (MainPanel:get_argument_value(249)),			-- Pipper On/Off
			[23] = Helios_Util.Convert_SW (MainPanel:get_argument_value(250)),			-- Fix net On/Off
			[24] = Helios_Util.Convert_SW (MainPanel:get_argument_value(181)),			-- Missiles - Rockets Heat On/Off
			[25] = Helios_Util.Convert_SW (MainPanel:get_argument_value(182)),			-- Missiles - Rockets Launch On/Off
			[26] = Helios_Util.Convert_SW (MainPanel:get_argument_value(183)),			-- Pylon 1-2 Power On/Off
			[27] = Helios_Util.Convert_SW (MainPanel:get_argument_value(184)),			-- Pylon 3-4 Power On/Off
			[28] = Helios_Util.Convert_SW (MainPanel:get_argument_value(185)),			-- GS-23 Gun On/Off
			[29] = Helios_Util.Convert_SW (MainPanel:get_argument_value(187)),			-- Guncam On/Off
			[30] = Helios_Util.Convert_SW (MainPanel:get_argument_value(277)),			-- Tactical Drop Cover
			[31] = Helios_Util.Convert_SW (MainPanel:get_argument_value(278)),			-- Tactical Drop
			[32] = Helios_Util.Convert_SW (MainPanel:get_argument_value(275)),			-- Emergency Missile/Rocket Launcher Cover
			[33] = Helios_Util.Convert_SW (MainPanel:get_argument_value(256)),			-- Drop Wing Fuel Tanks Cover
			[34] = Helios_Util.Convert_SW (MainPanel:get_argument_value(269)),			-- Drop Payload - Outer Pylons Cover
			[35] = Helios_Util.Convert_SW (MainPanel:get_argument_value(271)),			-- Drop Payload - Inner Pylons Cover
			[36] = Helios_Util.Convert_SW (MainPanel:get_argument_value(230)),			-- Weapon Mode - Air/Ground	
			[37] = Helios_Util.Convert_SW (MainPanel:get_argument_value(383)),			-- Release Weapon Cover
			[38] = Helios_Util.Convert_SW (MainPanel:get_argument_value(306)),			-- Helmet Heat - Manual/Auto
			[39] = Helios_Util.Convert_SW (MainPanel:get_argument_value(193)),			-- SARPP-12 Flight Data Recorder On/Off
			[40] = Helios_Util.Convert_SW (MainPanel:get_argument_value(632)),			-- Radar emission - Cover
			[41] = Helios_Util.Convert_SW (MainPanel:get_argument_value(633)),			-- Radar emission - Combat/Training
			[42] = Helios_Util.Convert_SW (MainPanel:get_argument_value(638)),			-- 1.7 Mach Test Cover (note: clickable.lua shows this as PNT_439 in error)
			[43] = Helios_Util.Convert_SW (MainPanel:get_argument_value(387)),			-- Emergency Jettison - RN24 Nuke Panel
			[44] = Helios_Util.Convert_SW (MainPanel:get_argument_value(388)),			-- Emergency Jettison Armed / Not Armed - RN24 Nuke Panel
			[45] = Helios_Util.Convert_SW (MainPanel:get_argument_value(389)),			-- Tactical Jettison - RN24 Nuke Panel
			[46] = Helios_Util.Convert_SW (MainPanel:get_argument_value(390)),			-- Special AB / Missile-Rocket-Bombs-Cannon - RN24 Nuke Panel
			[47] = Helios_Util.Convert_SW (MainPanel:get_argument_value(391)),			-- Brake Chute - RN24 Nuke Panel
			[48] = Helios_Util.Convert_SW (MainPanel:get_argument_value(392)),			-- Detonation Air / Ground - RN24 Nuke Panel
			[49] = Helios_Util.Convert_SW (MainPanel:get_argument_value(393)),			-- On / Off - SPS 141 CMS Panel
			[50] = Helios_Util.Convert_SW (MainPanel:get_argument_value(394)),			-- Transmit / Receive (Active/Passive) - SPS 141 CMS Panel
			[51] = string.format("%02.f", math.floor((MainPanel:get_argument_value(235)*10)+0.2))  -- Weapon Selector - 11 positions 0.1
			-- warning 51 uses 2 characters
		}
		
		local sw_table_3 =
		{	
			[1] = Helios_Util.Convert_SW (MainPanel:get_argument_value(395)),			-- Program I / II - SPS 141 CMS Panel
			[2] = Helios_Util.Convert_SW (MainPanel:get_argument_value(396)),			-- Continuous / Impulse - SPS 141 CMS Panel
			[3] = Helios_Util.Convert_SW (MainPanel:get_argument_value(398)),			-- Dispenser Auto / Manual - SPS 141 CMS Panel
			[4] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(399)*2)-1)), -- Off / Parallel / Full - SPS 141 CMS Panel - 3 posiciones 0,5
			[5] = Helios_Util.Convert_SW (MainPanel:get_argument_value(400)),			-- Manual Activation button - Cover - SPS 141 CMS Panel
			[6] = Helios_Util.Convert_SW (MainPanel:get_argument_value(420)),			-- On / Off - UPK Panel
			[7] = Helios_Util.Convert_SW (MainPanel:get_argument_value(341)),			-- SAU - Landing - Command
			[8] = Helios_Util.Convert_SW (MainPanel:get_argument_value(342)),			-- SAU - Landing - Auto
			[9] = Helios_Util.Convert_SW (MainPanel:get_argument_value(343)),			-- SAU - Stabilize
			[10] = Helios_Util.Convert_SW (MainPanel:get_argument_value(348)),			-- SAU Reset/Off
			[11] = Helios_Util.Convert_SW (MainPanel:get_argument_value(344)),			-- SAU Preset - Limit Altitude
			[12] = Helios_Util.Convert_SW (MainPanel:get_argument_value(177)),			-- KPP Main/Emergency (Giro/Aux Giro switch)
			[13] = Helios_Util.Convert_SW (MainPanel:get_argument_value(254)),			-- Marker Far/Near
			[14] = Helios_Util.Convert_SW (MainPanel:get_argument_value(239)),			-- Canopy Anti Ice
			[15] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(205)*2)-1)),       -- Radar Off/Prep/On - 3 posiciones 0,5
			[16] = (math.floor((MainPanel:get_argument_value(284)*7.142)+ 0.1))+1,         -- Dangerous Altitude Warning Set - 8 posiciones 0,14	
			[17] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(231)*2)-1)),       -- Weapon Mode - IR Missile/Neutral/SAR Missile - 3 posiciones 0,5
			[18] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(240)*2)-1)),       -- RSBN Mode Land/Navigation/Descend - 3 posiciones 0,5
			[19] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(201)*2)-1)),       -- SOD Wave Selector 3/1/2 - 3 posiciones 0,5
			[20] = Helios_Util.Convert_SW (math.floor((MainPanel:get_argument_value(206)*2)-1)),       -- Low Altitude Off/Comp/On - 3 posiciones 0,5
			[21] = (math.floor((MainPanel:get_argument_value(204)*4)+ 0.1))+1,             -- SOD Modes - 5 posiciones 0,25
			[22] = (math.floor((MainPanel:get_argument_value(189)*7.142)+ 0.1))+1,         -- ARK Zone - 8 posiciones 0,14
			[23] = Helios_Util.Convert_SW (MainPanel:get_argument_value(296)),                         -- ARU System - Low Speed/Neutral/High Speed - 3 posiciones 1.00, 0.00, -1.00
			[24] = (math.floor((MainPanel:get_argument_value(213)*10)+0.1)),               -- ARK Change - 9 posiciones 0,1 (starting at 0,1)
			[25] = Helios_Util.Convert_SW (MainPanel:get_argument_value(295)),                         -- ARU System - Manual/Auto
			[26] = Helios_Util.Convert_SW (MainPanel:get_argument_value(293)),                         -- SPS System Off/On
			[27] = Helios_Util.Convert_SW (MainPanel:get_argument_value(178)),                         -- NPP (FDS)On/Off
			[28] = Helios_Util.Convert_SW (MainPanel:get_argument_value(421)),			               -- MAIN GUN / UPK Guns (ON UPK23-250 PANEL)
			[29] = (math.floor((MainPanel:get_argument_value(194)*3.030)+ 0.1))+1,          -- Navigation Lights Off/Min/Med/Max - 4 posiciones 0,33
		} 
		
		
		-- right rpm

		local sw_table_4 =
		{	
			[1] = Helios_Util.Convert_SW (MainPanel:get_argument_value(256)),	   -- Drop Wing Fuel Tanks Cover
			[2] = Helios_Util.Convert_SW (MainPanel:get_argument_value(265)),      -- Mech clock left lever
			[3] = Helios_Util.Convert_SW (MainPanel:get_argument_value(268)),      -- Mech clock right lever
			[4] = Helios_Util.Convert_SW (MainPanel:get_argument_value(326)),      -- Gear Handle Fixator
			[5] = Helios_Util.Convert_SW (MainPanel:get_argument_value(327)),      -- Gear Up/Neutral/Down - 3 posiciones 1.00, 0.00, -1.00
			[6] = Helios_Util.Convert_SW (MainPanel:get_argument_value(329)),      -- Secure Canopy Lever
			[7] = Helios_Util.Convert_SW (MainPanel:get_argument_value(328)),      -- Hermetize Canopy Lever
			[8] = Helios_Util.Convert_SW (math.floor(MainPanel:get_argument_value(1)+0.5)),        -- Canopy Open/Close
			[9] = string.format ( "%02.f", math.floor((MainPanel:get_argument_value(192)*13)+ 0.05))  -- SRZO Channel Selector - 13 Channels from 0 - 12
			-- warning 9 uses 2 characters
		} 
		

	Helios_Udp.Send("23", string.format("%s", table.concat(sw_table,"") ) )		-- switches table 1 >>>	"ADI", "Turn Needle"
	Helios_Udp.Send("2000", string.format("%s", table.concat(sw_table_2,"") ) )	-- switches table 2 >>>	"UHF Radio", "Fequency"
	Helios_Udp.Send("20", string.format("%s", table.concat(sw_table_3,"") ) )		-- switches table 3 >>>	"ADI", "Bank Steering Bar Offset"
	Helios_Udp.Send("21", string.format("%s", table.concat(sw_table_4,"") ) )		-- switches table 4 >>>	"ADI", "Pitch Steering Bar Offset"

	
	
	
	

	Helios_Udp.Flush()
end
	

-- Format: device,button number, multiplier
-- arguments with multiplier 100, 101,102 or >300 are special conversion cases, and are computed in different way
	
-- DC & AC buses & giro devices 1 - 2
Helios_Mig21Bis.ExportArguments["50,3001"] = "1,3001,1"	-- Battery On/Off  165 2 > "Fire System", "Left Engine Fire Pull" 102 --
Helios_Mig21Bis.ExportArguments["50,3002"] = "1,3002,1"	-- Battery Heat On/Off  155 2 > "Fire System", "APU Fire Pull" 103 --
Helios_Mig21Bis.ExportArguments["50,3003"] = "1,3003,1"	-- DC Generator On/Off  166 2 > "Fire System", "Right Engine Fire Pull"104  --
Helios_Mig21Bis.ExportArguments["39,3001"] = "2,3004,1"	-- AC Generator On/Off  169 2 > "Mechanical", "Landing Gear Lever" 716 --
Helios_Mig21Bis.ExportArguments["7,3004"] = "2,3005,1"		-- PO-750 Inverter #1 On/Off  153 2 > "AHCP", "TGP Power" 378 --
Helios_Mig21Bis.ExportArguments["7,3006"] = "2,3006,1"		-- PO-750 Inverter #2 On/Off  154 2 > "AHCP", "HUD Day/Night" 380 --
Helios_Mig21Bis.ExportArguments["7,3007"] = "2,3007,1"		-- Emergency Inverter  164 2 > "AHCP", "HUD Norm/Standbyh" 381 --
-- GIRO 21
Helios_Mig21Bis.ExportArguments["7,3008"] = "21,3008,1"	-- Giro, NPP, SAU, RLS Signal, KPP Power On/Off  162 2 > "AHCP", "CICU Power" 382 --
Helios_Mig21Bis.ExportArguments["7,3009"] = "21,3009,1"	-- DA-200 Signal, Giro, NPP, RLS, SAU Power On/Off  163 2 > "AHCP", "Datalink Power" 383 --
-- FUEL_PUMPS & FUEL_SYSTEM  4
Helios_Mig21Bis.ExportArguments["46,3008"] = "4,3010,1"	-- Fuel Tanks 3rd Group, Fuel Pump  159 2 > "Navigation Mode Select Panel", "Able - Stow" 621 --
Helios_Mig21Bis.ExportArguments["1,3001"] = "4,3011,1"		-- Fuel Tanks 1st Group, Fuel Pump  160 2 > "Electrical", "APU Generator" 241 --
Helios_Mig21Bis.ExportArguments["49,3007"] = "4,3012,1"	-- Drain Fuel Tank, Fuel Pump  161 2 > "Electrical", "Emergency Flood" 243 --
Helios_Mig21Bis.ExportArguments["41,3009"] = "5,3013,1"	-- Fuel Quantity Set  274 axis 0.02>  "Environmental Control", "Flow Level" 284  --
-- ENGINE START DEVICE 3
Helios_Mig21Bis.ExportArguments["1,3004"] = "3,3014,1"		-- APU On/Off  302 2 > "Electrical", "AC Generator - Left" 244 --
Helios_Mig21Bis.ExportArguments["1,3005"] = "3,3015,1"		-- Engine Cold / Normal Start  288 2 > "Electrical", "AC Generator - Right" 245 --
Helios_Mig21Bis.ExportArguments["2,3001"] = "3,3016,1"	-- Start Engine  289 btn > "Left MFCD", "OSB1" 300 --
Helios_Mig21Bis.ExportArguments["1,3006"] = "3,3017,1"		-- Engine Emergency Air Start  301 2 > "Electrical", "Battery" 246 --
Helios_Mig21Bis.ExportArguments["2,3002"] = "3,3238,1"	-- Engine Stop/Lock  616 btn > "Left MFCD", "OSB2" 301
-- ACCELEROMETER 35
Helios_Mig21Bis.ExportArguments["2,3003"] = "35,3018,1"	-- Accelerometer Reset  228 btn > "Left MFCD", "OSB3" 302 --
-- PITOT TUBES and related things that use dc bus for heating 27
Helios_Mig21Bis.ExportArguments["40,3002"] = "27,3019,1"	-- Pitot tube Selector Main/Emergency 229 2 > "Oxygen System", "Dilution Lever" 602 --
Helios_Mig21Bis.ExportArguments["40,3001"] = "27,3020,1"	-- Pitot tube/Periscope/Clock Heat  279 2 > "Oxygen System", "Supply Lever" 603 --
Helios_Mig21Bis.ExportArguments["4,3008"] = "27,3021,1"	-- Secondary Pitot Tube Heat  280 2 > "CMSP", "ECM Pod Jettison" 358 --
-- DA-200 34
Helios_Mig21Bis.ExportArguments["38,3013"] = "34,3203,1"	-- variometer Set  261 axis lim 0.0001   (-1,1) > "Autopilot", "Yaw Trim" 192 --
-- ENGINE 6
Helios_Mig21Bis.ExportArguments["41,3002"] = "6,3022,1"	-- Anti surge doors - Auto/Manual 308 2 > "Environmental Control", "Windshield Defog/Deice" 276 --
Helios_Mig21Bis.ExportArguments["41,3005"] = "6,3023,1"	-- Afterburner/Maximum Off/On  300 2 > "Environmental Control", "Pitot heat" 279 --
Helios_Mig21Bis.ExportArguments["41,3006"] = "6,3024,1"	-- Emergency Afterburner Off/On  320 2 > "Environmental Control", "Bleed Air" 280 --
-- FIRE EXTINGUISHER 53 
Helios_Mig21Bis.ExportArguments["49,3012"] = "53,3025,1"	-- Fire Extinguisher Off/On  303 2 > "Light System", "Nose Illumination" 291 --
Helios_Mig21Bis.ExportArguments["49,3013"] = "53,3026,1"	-- Fire Extinguisher Cover  324 2 > "Light System", "Signal Lights" 294 --
Helios_Mig21Bis.ExportArguments["2,3004"] = "53,3027,1"	-- Fire Extinguisher  325 btn > "Left MFCD", "OSB4" 303 --
-- Radio  55 intercom 25
Helios_Mig21Bis.ExportArguments["36,3001"] = "22,3041,1"	-- Radio System On/Off  173 2 > "Fuel System", "External Wing Tank Boost Pump" 106 --
Helios_Mig21Bis.ExportArguments["36,3002"] = "22,3042,1"	-- Radio / Compass  208 2 > "Fuel System", "External Fuselage Tank Boost Pump" 107 --
Helios_Mig21Bis.ExportArguments["36,3003"] = "22,3043,1"	-- Squelch On/Off  209 2 > "Fuel System", "Tank Gate" 108 --
Helios_Mig21Bis.ExportArguments["54,3011"] = "22,3044,1"	-- Radio Volume  210 axis 0.1 >  "UHF Radio", "Volume" 171   --
Helios_Mig21Bis.ExportArguments["51,3007"] = "22,3045,1"	-- Radio Channel  211 multi sw 20 0.05 > "TACAN", "Volumne" 261 --
Helios_Mig21Bis.ExportArguments["2,3005"] = "55,3046,1"	-- Radio PTT  315 btn > "Left MFCD", "OSB5" 304
-- ARK 24
Helios_Mig21Bis.ExportArguments["36,3004"] = "24,3047,1"	-- ARK On/Off  174 2 > "Fuel System", "Cross Feed" 109 --
Helios_Mig21Bis.ExportArguments["58,3002"] = "24,3048,1"	-- ARK Sound  198 axis 0.1 > "Intercom", "INT Volume" 221  --
Helios_Mig21Bis.ExportArguments["2,3006"] = "24,3049,1"	-- ARK Change  212 btn > "Left MFCD", "OSB6" 305 --
Helios_Mig21Bis.ExportArguments["53,3005"] = "24,3050,1"	-- ARK Channel  213 multi sw 10 0.1 > "ILS", "Volume" 249 --
Helios_Mig21Bis.ExportArguments["52,3002"] = "24,3051,1"	-- ARK Zone  189 multi sw lim 8 0.14 > "Stall Warning", "Peak Volume" 705 --
Helios_Mig21Bis.ExportArguments["36,3005"] = "24,3052,1"	-- ARK Mode - Antenna / Compass  197 2 > "Fuel System", "Boost Pump Left Wing" 110 --
Helios_Mig21Bis.ExportArguments["36,3006"] = "24,3053,1"	-- Marker Far/Near  254 2 > "Fuel System", "Boost Pump Right Wing"	 111 --
-- RSBN 25
Helios_Mig21Bis.ExportArguments["22,3005"] = "25,3054,1"	-- RSBN On/Off  176 2 > "AAP", "CDU Power" 476  
Helios_Mig21Bis.ExportArguments["43,3016"] = "25,3055,103"	-- RSBN Mode Land/Navigation/Descend  240 multi sw lim 3 0.5 > "IFF", "M-1 Switch" 202 --
Helios_Mig21Bis.ExportArguments["22,3006"] = "25,3056,1"	-- RSBN / ARK  340 2 > "AAP", "EGI Power" 477 --
Helios_Mig21Bis.ExportArguments["2,3007"] = "25,3057,1"	-- RSBN Identify  294 btn > "Left MFCD", "OSB7" 306 --
Helios_Mig21Bis.ExportArguments["2,3008"] = "25,3080,1"	-- RSBN self-test  347 btn > "Left MFCD", "OSB8" 307 --
--RSBN Panel 25
Helios_Mig21Bis.ExportArguments["58,3004"] = "25,3058,1"	-- RSBN Sound  345 axis 0.1 > "Intercom", "FM Volume" 223  --
Helios_Mig21Bis.ExportArguments["12,3003"] = "25,3059,1"	-- RSBN Navigation  351 multi sw 100 0.01 > "TISL", "Altitude above target tens of thousands of feet" 624 --
Helios_Mig21Bis.ExportArguments["12,3004"] = "25,3060,1"	-- PRMG Landing  352 multi sw 100 0.01  >   "TISL", "Altitude above target thousands of feet" 626 --
Helios_Mig21Bis.ExportArguments["2,3009"] = "25,3061,1"	-- RSBN Reset  366 btn > "Left MFCD", "OSB9" 308 --
Helios_Mig21Bis.ExportArguments["44,3002"] = "25,3062,1"	-- RSBN Bearing  367 2 > "HARS", "Mode" 270 --
Helios_Mig21Bis.ExportArguments["44,3003"] = "25,3063,1"	-- RSBN Distance  368 2 > "HARS", "Hemisphere Selector" 273 --
-- SAU 8
Helios_Mig21Bis.ExportArguments["37,3001"] = "8,3064,1"	-- SAU On/Off 179 2 > "Engine System", "Left Engine Fuel Flow Control" 122 --
Helios_Mig21Bis.ExportArguments["37,3002"] = "8,3065,1"	-- SAU Pitch On/Off 180 2 > "Engine System", "Right Engine Fuel Flow Control" 123 --
Helios_Mig21Bis.ExportArguments["2,3010"] = "8,3066,1"	-- SAU - Stabilize  	343 btn > "Left MFCD", "OSB10" 309
Helios_Mig21Bis.ExportArguments["2,3011"] = "8,3067,1"	-- SAU cancel current mode  	376 btn > "Left MFCD", "OSB11" 310
Helios_Mig21Bis.ExportArguments["2,3012"] = "8,3068,1"	-- SAU - Recovery 	377 btn > "Left MFCD", "OSB12" 311
Helios_Mig21Bis.ExportArguments["37,3005"] = "8,3069,1"	-- SAU Preset - Limit Altitude 344 2 > "Engine System", "APU" 126 --
Helios_Mig21Bis.ExportArguments["2,3013"] = "8,3070,1"	-- SAU - Landing - Command  	341 btn > "Left MFCD", "OSB13" 312
Helios_Mig21Bis.ExportArguments["2,3014"] = "8,3071,1"	-- SAU - Landing - Auto  	342 btn > "Left MFCD", "OSB14" 313
Helios_Mig21Bis.ExportArguments["2,3015"] = "8,3072,1"	-- SAU Reset/Off  	348 btn > "Left MFCD", "OSB15" 314  --
-- LIGHTS 46
Helios_Mig21Bis.ExportArguments["58,3006"] = "46,3231,1"	-- Cockpit Texts Back-light  612 axis 0.1 +300 dwn> "Intercom", "VHF Volume"  225  --
Helios_Mig21Bis.ExportArguments["58,3008"] = "46,3232,1"	-- Instruments Back-light  156 axis 0.1 +300 dwn>   "Intercom", "UHF Volume"  227  --
Helios_Mig21Bis.ExportArguments["58,3010"] = "46,3233,1"	-- Main Red Lights  157 axis 0.1 +300 dwn>          "Intercom", "AIM Volume"  229  --
Helios_Mig21Bis.ExportArguments["58,3012"] = "46,3234,1"	-- Main White Lights  222 axis 0.1 +300 dwn>        "Intercom", "IFF Volume"  231  --
Helios_Mig21Bis.ExportArguments["49,3018"] = "46,3032,1"	-- Navigation Lights Off/Min/Med/Max  194 multi sw 4 0.33 >  "Light System", "Refueling Lighting Dial" 116 --
Helios_Mig21Bis.ExportArguments["43,3015"] = "46,3333,103"	-- Landing Lights Off/Taxi/Land  323 mlti sw lim 3 0.5 > 	"IFF", "Audio Light Switch", 201 
-- SPO 37
Helios_Mig21Bis.ExportArguments["69,3003"] = "37,3083,1"	-- SPO-10 RWR On/Off 202 2 > "KY-58 Secure Voice", "Delay" 780 --
Helios_Mig21Bis.ExportArguments["2,3016"] = "37,3084,1"	-- SPO-10 Test 226 btn > "Left MFCD", "OSB16" 315 --
Helios_Mig21Bis.ExportArguments["69,3007"] = "37,3085,1"	-- SPO-10 Night / Day  	227 2 > "KY-58 Secure Voice", "Power Switch" 784 --
Helios_Mig21Bis.ExportArguments["58,3014"] = "37,3086,1"	-- SPO-10 Volume  	225 axis 0.1 > "Intercom", "ILS Volume" 233  --
-- SRZO IFF
Helios_Mig21Bis.ExportArguments["38,3030"] = "38,3087,1"	-- SRZO IFF Coder/Decoder On/Off 188 2 > "Autopilot", "Emergency Brake" 772 --
Helios_Mig21Bis.ExportArguments["49,3016"] = "38,3088,1"	-- SRZO Codes 192 multi sw 12 0.08 >  "Light System", "Weapon Station Lights Brightness" 195 --
Helios_Mig21Bis.ExportArguments["38,3015"] = "38,3089,1"	-- IFF System 'Type 81' On/Off 346 2 > "Autopilot", "Speed Brake Emergency Retract" 174 --
Helios_Mig21Bis.ExportArguments["38,3016"] = "38,3210,1"	-- Emergency Transmitter Cover 190 2 > "Autopilot", "Pitch/Roll Emergency Override" 175
Helios_Mig21Bis.ExportArguments["38,3023"] = "38,3211,1"	-- Emergency Transmitter On/Off 191 2 > "Autopilot", "Flaps Emergency Retract" 183
Helios_Mig21Bis.ExportArguments["38,3024"] = "38,3229,1"	-- SRZO Self Destruct Cover 427 2 > "Autopilot", "Manual Reversion Flight Control System Switch" 184
Helios_Mig21Bis.ExportArguments["2,3017"] = "38,3230,1"	-- SRZO Self Destruct 428 btn > "Left MFCD", "OSB17" 316 --
-- SOD (increase radar signal for ATC radar, most likely won't be implemented)  39
Helios_Mig21Bis.ExportArguments["41,3008"] = "39,3090,1"	-- SOD IFF On/Off 200 2 > "Environmental Control", "Main Air Supply" 283 --
Helios_Mig21Bis.ExportArguments["2,3018"] = "39,3091,1"	-- SOD Identify 199 btn > "Left MFCD", "OSB18" 317 --
Helios_Mig21Bis.ExportArguments["43,3017"] = "39,3092,103"	-- SOD Wave Selector 3/1/2 201 multi sw 3 0.5 > "IFF", "M-2 Switch" 203 --
Helios_Mig21Bis.ExportArguments["44,3005"] = "39,3093,1"	-- SOD Modes 204 multi sw 5 0.25 > "HARS", "Latitude Correction" 271 --
-- RADAR 40
Helios_Mig21Bis.ExportArguments["43,3018"] = "40,3094,103"	-- Radar Off/Prep/On 205 multi sw 3 0.5 > "IFF", "M-3/A Switch" 204 --
Helios_Mig21Bis.ExportArguments["43,3019"] = "40,3095,103"	-- Low Altitude Off/Comp/On 206 multi sw 3 0.5 > "IFF", "M-C Switch" 205 --
Helios_Mig21Bis.ExportArguments["49,3004"] = "40,3096,1"	-- Locked Beam On/Off 207 2 > "Light System", "Accelerometer & Compass Lights" 295 --
Helios_Mig21Bis.ExportArguments["2,3019"] = "40,3097,1"	-- Radar Screen Magnetic Reset 266 btn > "Left MFCD", "OSB19" 318 --
Helios_Mig21Bis.ExportArguments["2,3020"] = "40,3098,1"	-- Radar Interferes - Continues 330 btn > "Left MFCD", "OSB20" 319
Helios_Mig21Bis.ExportArguments["3,3001"] = "40,3099,1"	-- Radar Interferes - Temporary 331 btn > "Right MFCD", "OSB1" 326
Helios_Mig21Bis.ExportArguments["3,3002"] = "40,3100,1"	-- Radar Interferes - Passive	 332 btn > "Right MFCD", "OSB2" 327
Helios_Mig21Bis.ExportArguments["3,3003"] = "40,3101,1"	-- Radar Interferes - Weather 333 btn > "Right MFCD", "OSB3" 328
Helios_Mig21Bis.ExportArguments["3,3004"] = "40,3102,1"	-- Radar Interferes - IFF 334 btn > "Right MFCD", "OSB4" 329
Helios_Mig21Bis.ExportArguments["3,3005"] = "40,3103,1"	-- Radar Interferes - Low Speed 335 btn > "Right MFCD", "OSB5" 330
Helios_Mig21Bis.ExportArguments["3,3006"] = "40,3104,1"	-- Radar Interferes - Self-test 336 btn > "Right MFCD", "OSB6" 331
Helios_Mig21Bis.ExportArguments["3,3007"] = "40,3105,1"	-- Radar Interferes - Reset 337 btn > "Right MFCD", "OSB7" 332
Helios_Mig21Bis.ExportArguments["3,3008"] = "40,3190,1"	-- Lock Target  378 btn >  "Right MFCD", "OSB8"   333                   STICK
Helios_Mig21Bis.ExportArguments["58,3016"] = "40,3239,1"	-- Radar Polar Filter 623 axis 0.1 > "Intercom", "TCN Volume" 235  --
-- SPRD 48                3,3010
Helios_Mig21Bis.ExportArguments["36,3007"] = "48,3106,1"	-- SPRD (RATO) System On/Off 167 2 > "Fuel System", "Boost Pump Main Fuseloge Left" 112 --
Helios_Mig21Bis.ExportArguments["36,3008"] = "48,3107,1"	-- SPRD (RATO) Drop System On/Off 168 2 > "Fuel System", "Boost Pump Main Fuseloge Right" 113 --
Helios_Mig21Bis.ExportArguments["36,3009"] = "48,3108,1"	-- SPRD (RATO) Start Cover 252 2 > "Fuel System", "Signal Amplifier" 114 --
Helios_Mig21Bis.ExportArguments["3,3009"] = "48,3110,1"	-- SPRD (RATO) Start 253 btn > "Right MFCD", "OSB9" 334 --
Helios_Mig21Bis.ExportArguments["36,3012"] = "48,3109,1"	-- SPRD (RATO)t Drop Cover 317 2 > "Fuel System", "Fill Disable Wing Left" 117 --
Helios_Mig21Bis.ExportArguments["3,3010"] = "48,3111,1"	-- SPRD (RATO) Drop 318 btn > "Right MFCD", "OSB10" 335 --
-- SPS 10
Helios_Mig21Bis.ExportArguments["53,3001"] = "10,3112,1"	-- SPS System Off/On 293 2 > "ILS", "Power" 247 --
-- ARU 11
Helios_Mig21Bis.ExportArguments["67,3001"] = "11,3113,1"	-- ARU System - Manual/Auto 295 2 > "Radar Altimeter", "Normal/Disabled" 130 --
Helios_Mig21Bis.ExportArguments["38,3021"] = "11,3114,1"	-- ARU System - Low Speed/Neutral/High Speed 296 spr 3 sw -1 0 1 > "Autopilot", "Alieron Emergency Disengage"  177
Helios_Mig21Bis.ExportArguments["38,3022"] = "11,3115,1"	-- ARU System - Low Speed/Neutral/High Speed 296 spr 3 sw -1 0 1 > "Autopilot", "Elevator Emergency Disengage"  180
-- Airbrake 12
Helios_Mig21Bis.ExportArguments["36,3013"] = "12,3116,1"	-- Airbrake - Out/In 316 2 > "Fuel System", "Fill Disable Wing Right" 118
-- Gear brakes
Helios_Mig21Bis.ExportArguments["36,3014"] = "13,3117,1"	-- ABS Off/On 299 2 > "Fuel System", "Fill Disable Main Left" 119 --
Helios_Mig21Bis.ExportArguments["36,3015"] = "13,3118,1"	-- Nosegear Brake Off/On 238 2 > "Fuel System", "Fill Disable Main Right" 120 --
Helios_Mig21Bis.ExportArguments["36,3016"] = "13,3119,1"	-- Emergency Brake 237 2 > "Fuel System", "Refuel Control Lever" 121 --
-- Gears 14
Helios_Mig21Bis.ExportArguments["54,3010"] = "14,3120,1"	-- Gear Handle Fixator 326 2 > "UHF Radio", "Squelch" 170 --
Helios_Mig21Bis.ExportArguments["50,3004"] = "14,3121,1"	-- Gear Up/Neutral/Down 327 multi sw 3 1.0 > "Fire System", "Discharge Switch" 105 ----------- -1 0 1
Helios_Mig21Bis.ExportArguments["12,3008"] = "14,3122,1"	-- Main Gears Emergency Release Handle 223 axis 0.2 > "TISL Code Wheel 4" 642 --
Helios_Mig21Bis.ExportArguments["54,3014"] = "14,3123,1"	-- Nose Gear Emergency Release Handle 281 2 > "UHF Radio", "Cover" 734 --
-- Flaps 15
Helios_Mig21Bis.ExportArguments["12,3010"] = "15,3124,1"	-- Flaps Neutral 311 2 > "TISL", "Enter" 628 --
Helios_Mig21Bis.ExportArguments["12,3011"] = "15,3125,1"	-- Flaps Take-Off 312 2 > "TISL", "OverTemp" 630 --
Helios_Mig21Bis.ExportArguments["12,3012"] = "15,3126,1"	-- Flaps Landing 313 2 > "TISL", "Bite" 632 --
Helios_Mig21Bis.ExportArguments["12,3013"] = "15,3127,1"	-- Flaps Reset buttons 314 btn > "TISL", "Track" 634 --
-- Drag chute 16
Helios_Mig21Bis.ExportArguments["3,3012"] = "16,3128,1"	-- Release Drag Chute 298 btn > "Right MFCD", "OSB12" 337 --
Helios_Mig21Bis.ExportArguments["43,3022"] = "16,3129,1"	-- Drop Drag Chute Cover 304 2 > "IFF", "IFF On/Out" 208 --
Helios_Mig21Bis.ExportArguments["3,3013"] = "16,3130,1"	-- Drop Drag Chute 305 btn > "Right MFCD", "OSB13" 338 --
--TRIMER
Helios_Mig21Bis.ExportArguments["38,3031"] = "9,3131,1"	-- Trimmer On/Off" 172 2 > "Autopilot", "HARS-SAS Override/Norm" 196 --
-- KONUS 17
Helios_Mig21Bis.ExportArguments["58,3001"] = "17,3133,1"	-- Nosecone On/Off 170 2 > "Intercom", "INT Switch" 222 --
Helios_Mig21Bis.ExportArguments["58,3003"] = "17,3134,1"	-- Nosecone Control - Manual/Auto 309 2 > "Intercom", "FM Switch" 224 --
Helios_Mig21Bis.ExportArguments["12,3005"] = "17,3135,1"	-- Nosecone manual position controller 236 axis 0.05 > "TISL", "TISL Code Wheel 1" 636  --
-- SOPLO 18
Helios_Mig21Bis.ExportArguments["58,3005"] = "18,3136,1"	-- Engine Nozzle 2 Position Emergency Control 291 2 > "Intercom", "VHF Switch" 226 --
--MAIN_HYDRO and BUSTER_HYDRO   44 
Helios_Mig21Bis.ExportArguments["58,3007"] = "44,3137,1"	-- Emergency Hydraulic Pump On/Off 171 2 > "Intercom", "UHF Switch" 228 --
Helios_Mig21Bis.ExportArguments["58,3009"] = "44,3138,1"	-- Aileron Booster - Off/On 319 2 >        "Intercom", "AIM Switch" 230 --
--KPP 28
Helios_Mig21Bis.ExportArguments["58,3011"] = "28,3139,1"	-- KPP Main/Emergency 177 2 > "Intercom", "IFF Switch" 232 --
Helios_Mig21Bis.ExportArguments["3,3014"] = "28,3140,1"	-- KPP Cage 259 btn > "Right MFCD", "OSB14" 339 --
Helios_Mig21Bis.ExportArguments["9,3064"] = "28,3141,301"	-- KPP Set 260 axis lim 0.0001 > "CDU", "Blank" 469 rocker --
Helios_Mig21Bis.ExportArguments["9,3065"] = "28,3141,301"	-- KPP Set 260 axis lim 0.0001 > "CDU", "Blank" 469 rocker --
--IAS / TAS / KSI (NPP) 23
Helios_Mig21Bis.ExportArguments["58,3013"] = "23,3142,1"	-- NPP On/Off 178 2 > "Intercom", "ILS Switch" 234 --
Helios_Mig21Bis.ExportArguments["3,3015"] = "23,3143,1"	-- NPP Adjust 258 btn > "Right MFCD", "OSB15" 340  --
--Helios_Mig21Bis.ExportArguments["47,3001"] = "23,3144,1"	-- NPP Course set 263 axis 0.1 > "ADI", "Pitch Trim Knob" 22  --
Helios_Mig21Bis.ExportArguments["9,3062"] = "23,3144,302"	-- NPP Course set 263 axis 0.1 > "CDU", "Page" 463 rocker  --
Helios_Mig21Bis.ExportArguments["9,3063"] = "23,3144,302"	-- NPP Course set 263 axis 0.1 > "CDU", "Page" 463 rocker  --
-- ALTIMETER and radioALTIMETER 32 33
Helios_Mig21Bis.ExportArguments["58,3015"] = "33,3145,1"	-- Radio Altimeter/Marker On/Off 175 2 > "Intercom", "TCN Switch" 236 --
Helios_Mig21Bis.ExportArguments["5,3007"] = "33,3146,1"	-- Dangerous Altitude Warning Set 284 multi sw 8 0.14 > "CMSC", "RWR Volume" 368 --
Helios_Mig21Bis.ExportArguments["9,3066"] = "32,3073,300"	-- Altimeter pressure knob 262 axis lim 0.02 -1 0 1> "CDU", "+/-" 472  rocker --
Helios_Mig21Bis.ExportArguments["9,3067"] = "32,3073,300"	-- Altimeter pressure knob 262 axis lim 0.02 -1 0 1> "CDU", "+/-" 472  rocker --
--OXYGENE_SYSTEM 19
Helios_Mig21Bis.ExportArguments["58,3017"] = "19,3147,1"	-- Helmet Air Condition Off/On 285 2 > "Intercom", "Hot Mic Switch" 237 --
Helios_Mig21Bis.ExportArguments["39,3008"] = "19,3148,1"	-- Emergency Oxygen Off/On 286 2 > "Mechanical", "Auxiliary Landing Gear Handle" 718 --
Helios_Mig21Bis.ExportArguments["39,3010"] = "19,3149,1"	-- Mixture/Oxygen 287 2 > "Mechanical", "Seat Arm Handle" 733 --
--CANOPY 43
Helios_Mig21Bis.ExportArguments["8,3010"] = "43,3150,1"	-- Hermetize Canopy 328 2 > "UFC", "0" 395 --
Helios_Mig21Bis.ExportArguments["8,3011"] = "43,3151,1"	-- Secure Canopy 329 2 > "UFC", "Space" 396
Helios_Mig21Bis.ExportArguments["3,3016"] = "43,3152,1"	-- Canopy Open 375 btn > "Right MFCD", "OSB16" 341
Helios_Mig21Bis.ExportArguments["3,3017"] = "43,3194,1"	-- Canopy Close 385 btn > "Right MFCD", "OSB17" 342
Helios_Mig21Bis.ExportArguments["3,3018"] = "43,3153,1"	-- -- Canopy Anti Ice 239 btn > "Right MFCD", "OSB18" 343 --
Helios_Mig21Bis.ExportArguments["8,3012"] = "43,3154,1"	-- Canopy Emergency Release Handle 224 2 > "UFC", "Display Hack Time" 394
Helios_Mig21Bis.ExportArguments["0,0000"] = "43,3272,1"	-- Canopy Ventilation System 649 lever > ojo difieren los ids
-- ASP Gunsight 41
Helios_Mig21Bis.ExportArguments["8,3013"] = "41,3155,1"	-- ASP Optical sight On/Off 186 2 >         "UFC", "Select Funciton Mode"      397 --
Helios_Mig21Bis.ExportArguments["8,3014"] = "41,3156,1"	-- -- ASP Main Mode - Manual/Auto 241 2 >      "UFC", "Select Letter Mode"     398 --
Helios_Mig21Bis.ExportArguments["8,3015"] = "41,3157,1"	-- -- ASP Mode - Bombardment/Shooting 242 2 >  "UFC", "Clear"       399 --
Helios_Mig21Bis.ExportArguments["8,3016"] = "41,3158,1"	-- -- ASP Mode - Missiles-Rockets/Gun 243 2 >  "UFC", "Enter"        400 --
Helios_Mig21Bis.ExportArguments["8,3017"] = "41,3159,1"	-- ASP Mode - Giro/Missile 244 2 >          "UFC", "Create Overhead Mark Point"  401 --
Helios_Mig21Bis.ExportArguments["8,3018"] = "41,3160,1"	-- Pipper On/Off 249 2 >                    "UFC", "Display and Adjust Altitude Alert Values"  402 --
Helios_Mig21Bis.ExportArguments["8,3030"] = "41,3161,1"	-- Fix net On/Off 250 2 >                   "UFC", "FWD"    531 --
Helios_Mig21Bis.ExportArguments["49,3009"] = "41,3162,1"	-- Target Size 245 axis 0.1 >                      "Light System", "Formation Lights"            288  --
Helios_Mig21Bis.ExportArguments["49,3001"] = "41,3163,1"	-- Intercept Angle 246 axis 0.1 >                  "Light System", "Engine Instrument Lights"    290  --
Helios_Mig21Bis.ExportArguments["49,3002"] = "41,3164,1"	-- Scale Backlights control 247 axis 0.1 >         "Light System", "Flight Instruments Lights"   292  --
Helios_Mig21Bis.ExportArguments["49,3003"] = "41,3165,1"	-- Pipper light control 248 axis 0.1 >             "Light System", "Auxillary instrument Lights" 293  --
Helios_Mig21Bis.ExportArguments["49,3005"] = "41,3166,1"	-- Fix Net light control 251 axis 0.1 >            "Light System", "Flood Light"                 296  --
Helios_Mig21Bis.ExportArguments["49,3006"] = "41,3213,1"	-- TDC Range / Pipper Span control 384 axis 0.1 >  "Light System", "Console Lights"              297  --
-- WEAPON_CONTROL 42
Helios_Mig21Bis.ExportArguments["9,3015"] = "42,3167,1"	-- Missiles - Rockets Heat On/Off  181 2 >          "CDU", "1"  425 --
Helios_Mig21Bis.ExportArguments["9,3016"] = "42,3168,1"	-- Missiles - Rockets Launch On/Off  182 2 >        "CDU", "2"  426 --
Helios_Mig21Bis.ExportArguments["9,3017"] = "42,3169,1"	-- Pylon 1-2 Power On/Off  183 2 >                  "CDU", "3"  427 --
Helios_Mig21Bis.ExportArguments["9,3018"] = "42,3170,1"	-- Pylon 3-4 Power On/Off  184 2 >                  "CDU", "4"  428 --
Helios_Mig21Bis.ExportArguments["9,3019"] = "42,3171,1"	-- GS-23 Gun On/Off  185 2 >                        "CDU", "5"  429 --
Helios_Mig21Bis.ExportArguments["9,3020"] = "42,3172,1"	-- Guncam On/Off  187 2 >                           "CDU", "6"  430 --
Helios_Mig21Bis.ExportArguments["9,3021"] = "42,3173,1"	-- Tactical Drop Cover  277 2 >                     "CDU", "7"  431 --
Helios_Mig21Bis.ExportArguments["9,3022"] = "42,3174,1"	-- Tactical Drop  278 2 >                           "CDU", "8"  432 --
Helios_Mig21Bis.ExportArguments["9,3023"] = "42,3175,1"	-- Emergency Missile/Rocket Launcher Cover  275 2 > "CDU", "9"  433 --
Helios_Mig21Bis.ExportArguments["3,3019"] = "42,3176,1"	-- Emergency Missile/Rocket Launcher  276 btn > "Right MFCD", "OSB19" 344 --
Helios_Mig21Bis.ExportArguments["9,3024"] = "42,3177,1"	-- Drop Wing Fuel Tanks Cover  256 2 >				"CDU", "0" 434 --
Helios_Mig21Bis.ExportArguments["3,3020"] = "42,3178,1"	-- Drop Wing Fuel Tanks"  257 btn > "Right MFCD", "OSB20" 345 --
Helios_Mig21Bis.ExportArguments["8,3001"] = "42,3196,1"	-- Drop Center Fuel Tank  386 btn > "UFC", "1"  385        STICK
Helios_Mig21Bis.ExportArguments["8,3031"] = "42,3179,1"	-- Drop Payload - Outer Pylons Cover  269 2 > "UFC", "MID" 532 --
Helios_Mig21Bis.ExportArguments["8,3002"] = "42,3180,1"	-- Drop Payload - Outer Pylons  270 btn > "UFC", "2" 386 --
Helios_Mig21Bis.ExportArguments["8,3032"] = "42,3181,1"	-- Drop Payload - Inner Pylons Cover  271 2 > "UFC", "AFT" 533 --
Helios_Mig21Bis.ExportArguments["8,3003"] = "42,3182,1"	-- Drop Payload - Inner Pylons  272 btn > "UFC", "3" 387 --
Helios_Mig21Bis.ExportArguments["24,3001"] = "42,3183,1"	-- -- Weapon Mode - Air/Ground  230 2 > "UFC", "Master Caution" 403 --
Helios_Mig21Bis.ExportArguments["43,3020"] = "42,3184,103"	-- Weapon Mode - IR Missile/Neutral/SAR Missile  231 multi sw 3 0.5 > "IFF", "RAD Test/Monitor Switch" 206 --
Helios_Mig21Bis.ExportArguments["8,3004"] = "42,3185,1"	-- Activate Gun Loading Pyro - 1  232 btn > "UFC", "4"  388
Helios_Mig21Bis.ExportArguments["8,3005"] = "42,3186,1"	-- Activate Gun Loading Pyro - 2  233 btn > "UFC", "5" 389
Helios_Mig21Bis.ExportArguments["8,3006"] = "42,3187,1"	-- Activate Gun Loading Pyro - 3  234 btn > "UFC", "6" 390
Helios_Mig21Bis.ExportArguments["52,3001"] = "42,3188,1"	-- Weapon Selector  235 multi sw 11 0.10 > "Stall Warning", "Stall Volume" 704 ------------
Helios_Mig21Bis.ExportArguments["49,3015"] = "42,3189,1"	-- Missile Seeker Sound  297 axis 0.1 > "Light System", "Refuel Status Indexer Brightness" 193  --
--HELMET_VISOR
Helios_Mig21Bis.ExportArguments["3,3011"] = "45,3205,1"	-- Helmet Heat - Manual/Auto  306 2 > "Right MFCD", "OSB11" 336 --
Helios_Mig21Bis.ExportArguments["8,3007"] = "45,3206,1"	-- Helmet Quick Heat  310 btn >  "UFC", "7" 391 --
Helios_Mig21Bis.ExportArguments["12,3014"] = "45,3207,1"	-- Helmet visor - off/on  369 2 > "IFFCC", "Ext Stores Jettison" 101
--AIR CONDITIONING
Helios_Mig21Bis.ExportArguments["0,0000"] = "50,3208,1"	-- Cockpit Air Condition Off/Cold/Auto/Warm  292 multi sw 4 0.33 > ----------------NOT SIMULATED-----------------------------------------------------------
-- SARPP
Helios_Mig21Bis.ExportArguments["5,3001"] = "49,3209,1"	-- SARPP-12 Flight Data Recorder On/Off  193 2 > "CMSC", "Cycle JMR Program Button" 365
--Dummy buttons/switches
Helios_Mig21Bis.ExportArguments["5,3002"] = "40,3254,1"	-- Radar emission - Cover  632 2 >            "CMSC", "Cycle MWS Program Button"   366 --
Helios_Mig21Bis.ExportArguments["5,3003"] = "40,3255,1"	-- Radar emission - Combat/Training  633 2 >  "CMSC", "Priority Button"));         369 --
Helios_Mig21Bis.ExportArguments["5,3004"] = "17,3260,1"	-- 1.7 Mach Test Button - Cover  638 2 >      "CMSC", "Separate Button"));         370
Helios_Mig21Bis.ExportArguments["5,3005"] = "17,3261,1"	-- 1.7 Mach Test Button  639 2 >              "CMSC", "Unknown Button"));          371 --
-- IAB PBK-3
Helios_Mig21Bis.ExportArguments["46,3001"] = "56,3197,1"	-- Emergency Jettison  387 2 >                       "Navigation Mode Select Panel", "HARS"  605 --
Helios_Mig21Bis.ExportArguments["46,3002"] = "56,3198,1"	-- Emergency Jettison Armed / Not Armed  388 2 >     "Navigation Mode Select Panel", "EGI"   607 --
Helios_Mig21Bis.ExportArguments["46,3003"] = "56,3199,1"	-- Tactical Jettison  389 2 >                        "Navigation Mode Select Panel", "TISL"  609 --
Helios_Mig21Bis.ExportArguments["46,3004"] = "56,3200,1"	-- Special AB / Missile-Rocket-Bombs-Cannon  390 2 > "Navigation Mode Select Panel", "STEERPT"  611 --
Helios_Mig21Bis.ExportArguments["46,3005"] = "56,3201,1"	-- Brake Chute  391 2 >                              "Navigation Mode Select Panel", "ANCHR" 613 --
Helios_Mig21Bis.ExportArguments["46,3006"] = "56,3202,1"	-- Detonation Air / Ground  392 2 >                  "Navigation Mode Select Panel", "TCN"   615 --
-- SPS 141-100
Helios_Mig21Bis.ExportArguments["9,3001"] = "57,3214,1"	-- On / Off  393 2 >             "CDU", "LSK 3L"  410 --
Helios_Mig21Bis.ExportArguments["9,3002"] = "57,3215,1"	-- Transmit / Receive  394 2 >   "CDU", "LSK 5L"  411 --
Helios_Mig21Bis.ExportArguments["9,3003"] = "57,3216,1"	-- Program I / II  395 2 >       "CDU", "LSK 7L"  412 --
Helios_Mig21Bis.ExportArguments["9,3004"] = "57,3217,1"	-- Continuous / Impulse  396 2 > "CDU", "LSK 9L"  413 --
Helios_Mig21Bis.ExportArguments["8,3008"] = "57,3218,1"	-- Test  397 btn >  "UFC", "8" 392  --
Helios_Mig21Bis.ExportArguments["9,3005"] = "57,3219,1"	-- Dispenser Auto / Manual  398 2 > "CDU", "LSK 3R" 414 --
Helios_Mig21Bis.ExportArguments["43,3021"] = "57,3220,103"	-- Off / Parallel / Full  399 multi sw 3 0.5 > "IFF", "Ident/Mic Switch" 207 --
Helios_Mig21Bis.ExportArguments["9,3006"] = "57,3221,1"	-- Manual Activation button - Cover  400 2 > "CDU", "LSK 5R" 415 --
Helios_Mig21Bis.ExportArguments["8,3009"] = "57,3222,1"	-- Manual Activation button  401 btn >  "UFC", "9" 393 --
-- GUV Control Box 
Helios_Mig21Bis.ExportArguments["9,3007"] = "42,3223,1"	-- On / Off  420 2 >            "CDU", "LSK 7R"  416 --
Helios_Mig21Bis.ExportArguments["9,3008"] = "42,3224,1"	-- MAIN GUN / UPK Guns  421 2 > "CDU", "LSK 9R"  417 --
Helios_Mig21Bis.ExportArguments["9,3027"] = "42,3225,1"	-- LOAD 1  422 2 > "CDU", "A"  437 --
Helios_Mig21Bis.ExportArguments["9,3028"] = "42,3226,1"	-- LOAD 2  425 2 > "CDU", "B"  438 --
Helios_Mig21Bis.ExportArguments["9,3029"] = "42,3227,1"	-- LOAD 3  424 2 > "CDU", "C"  439 --
-- Warning lights
Helios_Mig21Bis.ExportArguments["9,3030"] = "47,3034,1"	-- Check Warning Lights T4    369 2 >  "CDU", "D" 440 --
Helios_Mig21Bis.ExportArguments["9,3031"] = "47,3035,1"	-- Check Warning Lights T10   370 2 >  "CDU", "E" 441 --
Helios_Mig21Bis.ExportArguments["9,3032"] = "47,3036,1"	-- Check Warning Lights T4-2  371 2 >  "CDU", "F" 442 --
Helios_Mig21Bis.ExportArguments["9,3033"] = "47,3037,1"	-- Check Warning Lights T4-3  372 2 >  "CDU", "G" 443 --
Helios_Mig21Bis.ExportArguments["9,3034"] = "47,3038,1"	-- Check Warning Lights T10-2 373 2 >  "CDU", "H" 444 --
Helios_Mig21Bis.ExportArguments["9,3035"] = "47,3039,1"	-- Check Warning Lights PPS   374 2 >  "CDU", "I" 445 --
Helios_Mig21Bis.ExportArguments["9,3036"] = "47,3040,1"	-- SORC   255 2 > "CDU", "J" 446   --
-- Clock
Helios_Mig21Bis.ExportArguments["43,3021"] = "26,3249,1"	-- Mech clock left lever 265 multi sw 3  1 0 -1  > "IFF", "Ident/Mic Switch" 207 --
Helios_Mig21Bis.ExportArguments["58,3018"] = "26,3251,1"	-- Mech clock left lever 264 axis  0.04 > "Intercom", "Master Volume" 238
Helios_Mig21Bis.ExportArguments["9,3037"] = "26,3252,1"	-- Mech clock right lever 268 btn  > "CDU", "K" 447 --
Helios_Mig21Bis.ExportArguments["41,3003"] = "26,3253,1"	-- Mech clock right lever  267 axis  0.05 -015 0.15 > "Environmental Control", "Canopy Defog" 277 -- 
