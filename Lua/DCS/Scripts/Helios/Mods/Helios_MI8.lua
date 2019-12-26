Helios_MI8 = {}

Helios_MI8.Name = "Mi-8MT"
Helios_MI8.FlamingCliffsAircraft = false

Helios_MI8.ExportArguments = {}

function Helios_MI8.HighImportance(data)
	local _LAST_ONE = 0 -- used to mark the end of the tables
	local MainPanel = GetDevice(0)

	-- radios information
	local R863_ = GetDevice(38)
	local R828_ = GetDevice(39)
	local R863__ON = 0
	local R863__freq= 0
	local R828__ON = 0
	local R828__freq= 0

	R863__freq = R863_:get_frequency()
	
	if (R863_:is_on()) then
		R863__ON = 1
	end
	
	R828__freq = R828_:get_frequency()
	
	if (R828_:is_on()) then
		R828__ON = 1
	end

	-- Pilot console instruments

	local uv26 = Helios_MI8.Get_UV26()
	local CompassHeading = MainPanel:get_argument_value(25)
	local CompassHeading_copilot = MainPanel:get_argument_value(101)	
	local bearing_needle = MainPanel:get_argument_value(28)	* 360	
	if bearing_needle > 180 then bearing_needle = bearing_needle-360 end   -- convert Bearing Needle from 0,360 to -180,180 for helios russian HSI
	local bearing_needle_copilot = MainPanel:get_argument_value(104)* 360	
	if bearing_needle_copilot > 180 then bearing_needle_copilot = bearing_needle_copilot-360 end   -- convert Bearing Needle from 0,360 to -180,180 for helios russian HSI copilot
	local CommandedCourse = MainPanel:get_argument_value(27) + MainPanel:get_argument_value(25) -- convert Commanded Course for helios russian HSI pilot
	local CommandedCourse_copilot = MainPanel:get_argument_value(103) + MainPanel:get_argument_value(101) -- convert Commanded Course for helios russian HSI pilot

	Helios_Udp.Send("190", string.format("%s",   uv26  ) )				
	Helios_Udp.Send("192", string.format("%.3f", math.floor(bearing_needle*1000) + (bearing_needle/100) ) )
	Helios_Udp.Send("193", string.format("%.5f", math.floor(CompassHeading*1000) + (CommandedCourse/100) ) )
	Helios_Udp.Send("194", string.format("%.3f", math.floor(bearing_needle_copilot*1000) + (bearing_needle_copilot/100) ) )
	Helios_Udp.Send("195", string.format("%.5f", math.floor(CompassHeading_copilot*1000) + (CommandedCourse_copilot/100) ) )


	----[[	
	local instruments_table =
	{	
		[1] =	MainPanel:get_argument_value(24), 			--IAS pilot
		[2] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(904),{-50.0, 0, 70.0},{-1.0, 0.0, 1.0}),   -- RAM_Temp
		[3] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(16),{-30, -20, -10, -5, -2, -1, 0, 1, 2, 5, 10, 20, 30},{-1.0, -0.71, -0.43, -0.23, -0.09, -0.05, 0, 0.05, 0.09, 0.23, 0.43, 0.71, 1.0}),	--Variometer 
		[4] =	MainPanel:get_argument_value(22),           -- TurnNeedle 	pilot
		[5] =	MainPanel:get_argument_value(23),           -- Slipball		pilot
		[6] =	MainPanel:get_argument_value(25),           -- CompassHeading pilot
		[7] =	MainPanel:get_argument_value(27) + MainPanel:get_argument_value(25), -- convert Commanded Course for helios russian HSI  CommandedCourse pilot
		[8] =	bearing_needle,						        -- bearing needle	pilot								
		[9] =	MainPanel:get_argument_value(41),           -- Engine_RPM_R								
		[10] = 	MainPanel:get_argument_value(40),           -- Engine_RPM_L								
		[11] = 	MainPanel:get_argument_value(42)*110 ,      -- RotorRPM										
		[12] = 	MainPanel:get_argument_value(36)*15 ,       -- RotorPitch								
		[13] = 	MainPanel:get_argument_value(43)*1200,      -- LeftEngineTemperature						
		[14] = 	MainPanel:get_argument_value(45)*1200,      -- RightEngineTemperature 						
		[15] = 	MainPanel:get_argument_value(19),     -- Altimeter								
		[16] = 	MainPanel:get_argument_value(13)*180,       -- AGB_3K_Left_roll								
		[17] = 	(MainPanel:get_argument_value(12)*-180)/2,  -- AGB_3K_Left_pitch						
		[18] = 	MainPanel:get_argument_value(34),  			-- RALT											
		[19] = 	MainPanel:get_argument_value(31),  			-- RALT_danger_alt							
		[20] = 	MainPanel:get_argument_value(830),          -- diss15_hover_x							
		[21] = 	MainPanel:get_argument_value(828),          -- diss15_hover_y							
		[22] = 	MainPanel:get_argument_value(829),          -- diss15_hover_z 							
		[23] = 	MainPanel:get_argument_value(404),          -- hydro_pressure_main						
		[24] = 	MainPanel:get_argument_value(405),          -- hydro_pressure_aux						
		[25] = 	MainPanel:get_argument_value(402), 	   		-- APU_temperature								
		[26] = 	MainPanel:get_argument_value(403),          -- APU_pressure								
		[27] = 	MainPanel:get_argument_value(526),          -- DC_voltage								
		[28] = 	MainPanel:get_argument_value(527),          -- DC_battery_I_current						
		[29] = 	MainPanel:get_argument_value(528),          -- DC_battery_II_current					
		[30] = 	MainPanel:get_argument_value(529),          -- DC_VU_I_current								
		[31] = 	MainPanel:get_argument_value(530),	        -- DC_VU_II_current
		[32] = 	MainPanel:get_argument_value(531),          -- DC_VU_III_current								
		[33] = 	MainPanel:get_argument_value(532),          -- AC_voltage  									
		[34] = 	MainPanel:get_argument_value(533),          -- AC_generator_I_current						
		[35] = 	MainPanel:get_argument_value(534),          -- AC_generator_II_current					
		[36] = 	MainPanel:get_argument_value(493),	        -- DC_APU_current								
		[37] = 	MainPanel:get_argument_value(371),          -- AntiIce_ampermeter 							
		[38] = 	MainPanel:get_argument_value(126),  		-- SPUU_pointer									
		[39] = 	MainPanel:get_argument_value(122),  		-- autopilot_yaw_indicator					
		[40] = 	MainPanel:get_argument_value(124),  		-- autopilot_pitch_indicator	 					
		[41] = 	MainPanel:get_argument_value(123)* 3.03,    -- autopilot_roll_indicator  						
		[42] = 	MainPanel:get_argument_value(125),          -- autopilot_altitude_indicator  					
		[43] = 	MainPanel:get_argument_value(119),			-- autopilot_yaw_scale  							
		[44] = 	MainPanel:get_argument_value(120),			-- autopilot_roll_scale  							
		[45] = 	MainPanel:get_argument_value(121),			-- autopilot_pitch_scale	 						
		[46] = 	MainPanel:get_argument_value(111), 			-- oils_p_main_reductor  							
		[47] = 	MainPanel:get_argument_value(114)+ 0.25,  	-- oils_t_main_reductor  							
		[48] = 	MainPanel:get_argument_value(113)+ 0.25,  	-- oils_temp_tail_reductor  						
		[49] = 	MainPanel:get_argument_value(112)+ 0.25,  	-- oils_temp_intermediate_reductor  				
		[50] = 	MainPanel:get_argument_value(115), 			-- oils_p_left_engine  							
		[51] = 	MainPanel:get_argument_value(116)+ 0.25,	-- oils_t_left_engine  							
		[52] = 	MainPanel:get_argument_value(117),			-- oils_p_right_engine  							
		[53] = 	MainPanel:get_argument_value(118) + 0.25,	-- oils_t_right_engine  							
		[54] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(736),{0, 1, 2, 3, 4, 5, 6, 7, 8, 9},{0.0, 0.101, 0.199, 0.302, 0.400, 0.502, 0.601, 0.697, 0.801, 0.898}), -- R828_channel								
		[55] = 	MainPanel:get_argument_value(62), 			-- FuelScaleUpper  								
		[56] = 	MainPanel:get_argument_value(791),			-- diss15_drift_angle  							
		[57] = 	MainPanel:get_argument_value(795),			-- diss15_W_shutter  								
		[58] = 	MainPanel:get_argument_value(832),			-- VD_10K_L_10_Ind 						
		[59] = 	MainPanel:get_argument_value(792), -- 0 to 1                -- diss15_W_hundreds  							
		[60] = 	MainPanel:get_argument_value(793), -- 0 to 1                -- diss15_W_tens	 								
		[61] = 	MainPanel:get_argument_value(794), -- 0 to 1                -- diss15_W_ones  								
		[62] = 	MainPanel:get_argument_value(833),			-- VD_10K_L_100_Ind							
		[63] = 	MainPanel:get_argument_value(805), -- 0 to 1 inversed       -- diss15_coord_forward  							
		[64] = 	MainPanel:get_argument_value(806),         -- diss15_coord_X_hundreds  						
		[65] = 	MainPanel:get_argument_value(807),         -- diss15_coord_X_tens  			
		[66] = 	MainPanel:get_argument_value(808),         -- diss15_coord_X_ones  							
		[67] = 	MainPanel:get_argument_value(802),         -- diss15_coord_right  							
		[68] = 	MainPanel:get_argument_value(799),         -- diss15_coord_Z_hundreds  						
		[69] = 	MainPanel:get_argument_value(800),         -- diss15_coord_Z_tens  							
		[70] = 	MainPanel:get_argument_value(801),         -- diss15_coord_Z_ones  							
		[71] = 	MainPanel:get_argument_value(811),         -- diss15_coord_angle_hundreds  					
		[72] = 	MainPanel:get_argument_value(812),         -- diss15_coord_angle_tens  						
		[73] = 	MainPanel:get_argument_value(813),         -- diss15_coord_angle_ones  						
		[74] = 	MainPanel:get_argument_value(814),         -- diss15_coord_angle_minutes  					
		[75] = 	MainPanel:get_argument_value(39), 	       -- EnginesMode  									
		[76] = 	MainPanel:get_argument_value(37), 	       -- LeftEngineMode  								
		[77] = 	MainPanel:get_argument_value(38), 	       -- RightEngineMode  								
		[78] = 	MainPanel:get_argument_value(577),         -- AMMO_CNT1_1  									
		[79] = 	MainPanel:get_argument_value(578),         -- AMMO_CNT1_2  									
		[80] = 	MainPanel:get_argument_value(580),         -- AMMO_CNT2_1  									
		[81] = 	MainPanel:get_argument_value(581),         -- AMMO_CNT2_2  									
		[82] = 	MainPanel:get_argument_value(583),         -- AMMO_CNT3_1  									
		[83] = 	MainPanel:get_argument_value(584),         -- AMMO_CNT3_2  									
		[84] = 	MainPanel:get_argument_value(49)*12 ,      -- CLOCK_currtime_hours  							
		[85] = 	MainPanel:get_argument_value(50)*60 ,      -- CLOCK_currtime_minutes  						
		[86] = 	MainPanel:get_argument_value(51)*60 ,      -- CLOCK_currtime_seconds  						
		[87] = 	MainPanel:get_argument_value(52)*12 ,      -- CLOCK_flight_hours  							
		[88] = 	MainPanel:get_argument_value(53)*60 ,      -- CLOCK_flight_minutes  							
		[89] = 	MainPanel:get_argument_value(56),       -- CLOCK_flight_time_meter_status  				
		[90] = 	MainPanel:get_argument_value(54)*60 ,      -- CLOCK_seconds_meter_time_minutes  				
		[91] = 	MainPanel:get_argument_value(55)*60,       -- CLOCK_seconds_meter_time_seconds  				
		[92] = 	MainPanel:get_argument_value(320),         -- air_system_pressure  							
		[93] = 	MainPanel:get_argument_value(321),         -- air_system_brake_pressure  					
		[94] = 	MainPanel:get_argument_value(681),         -- ARC_9_Signal  														
		[95] = 	MainPanel:get_argument_value(675),         -- ARC_9_Backup_100_rotary  						
		[96] = 	MainPanel:get_argument_value(450),        -- ARC_9_Backup_10_rotary  
		[97] =	MainPanel:get_argument_value(678),         -- ARC_9_Main_100_rotary  						
		[98] =	MainPanel:get_argument_value(452),         -- ARC_9_Main_10_rotary  												
		[99] =	MainPanel:get_argument_value(192),         -- engines_throttle	  							
		[100] =	MainPanel:get_argument_value(745),	       -- Jadro_1A_Frequency_Selector_1MHz  				
		[101] =	MainPanel:get_argument_value(746),	       -- Jadro_1A_Frequency_Selector_100kHz  			
		[102] =	MainPanel:get_argument_value(747),         -- Jadro_1A_Frequency_Selector_10kHz	  			
		[103] =	MainPanel:get_argument_value(748),	       -- Jadro_1A_Frequency_Selector_Left_mouse_1kHz   	
		[104] =	MainPanel:get_argument_value(750),	       -- Jadro_1A_Frequency_Selector_1MHz_SLAVE  		
		[105] =	MainPanel:get_argument_value(749),         -- Jadro_1A_Frequency_Selector_Right_mouse_100Hz 	
		[106] =	MainPanel:get_argument_value(28),	       -- rmi_needle  									
		[107] =	MainPanel:get_argument_value(21),          -- Baro_press  			
		[108] =	MainPanel:get_argument_value(14),   							--AGB_3K_Left_failure_flag                                                                      				
		[109] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(907),{-1.0, 0, 1.0},{-1.0, 0.343, 1.0}),                 -- G_Meter  				
		[110] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(908),{1.0, 3.0},{0.343, 1.0}),                           -- G_Meter_Max  			
		[111] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(909),{-1.0, 0.0 ,0.5, 1.0},{-1.0, 0.0, 0.174, 0.343}),   -- G_Meter_Min  			
		[112] =	MainPanel:get_argument_value(834),			-- VD_10K_R_10_Ind					
		[113] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(63),{-70.0, -30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0, 70.0},{-0.7, -0.296, -0.227, -0.125, 0.003, 0.132, 0.233, 0.302, 0.693}),  --SalonTemperature	
		[114] =	MainPanel:get_argument_value(790), 			--IAS copilot
		[115] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(95),{-30, -20, -10, -5, -2, -1, 0, 1, 2, 5, 10, 20, 30},{-1.0, -0.71, -0.43, -0.23, -0.09, -0.05, 0, 0.05, 0.09, 0.23, 0.43, 0.71, 1.0}),	--Variometer copilot
		[116] =	MainPanel:get_argument_value(101),           -- CompassHeading copilot
		[117] =	MainPanel:get_argument_value(103) + MainPanel:get_argument_value(101), -- convert Commanded Course for helios russian HSI  CommandedCourse copilot
		[118] =	bearing_needle_copilot,						        -- bearing needle	copilot	
		[119] =	MainPanel:get_argument_value(789),           -- Engine_RPM_R	copilot							
		[120] =	MainPanel:get_argument_value(788),           -- Engine_RPM_L		copilot								
		[121] =	MainPanel:get_argument_value(787)*110 ,      -- RotorRPM	copilot	MainPanel:get_argument_value(789),  				
		[122] = MainPanel:get_argument_value(98),     -- Altimeter	big needle copilot
		[123] = MainPanel:get_argument_value(92)*180,       -- AGB_3K_roll		copilot	
		[124] = (MainPanel:get_argument_value(91)*-180)/2,  -- AGB_3K_pitch	copilot					
		[125] = Helios_Util.ValueConvert(MainPanel:get_argument_value(100),{661.0, 790.0},{-0.051, 0.668}), -- Baro_press  	copilot
		[126] = R863__freq,
		[127] = R828__freq,
		[128] = R863__ON,
		[129] = R828__ON,
		[130] = MainPanel:get_argument_value(104),   --rmi needle right
		[131] =	MainPanel:get_argument_value(93),   							--AGB_3K_Right_failure_flag  
		[132] =	MainPanel:get_argument_value(835),			-- VD_10K_R_100_Ind
		[133] =	MainPanel:get_argument_value(20),			-- Altimeter	small needle pilot
		[134] =	MainPanel:get_argument_value(99),			-- Altimeter	small needle copilot
		[135] =	MainPanel:get_argument_value(100)			-- QFE copilot		
	}	

	-- exporting instruments data
	for a=1, #instruments_table do
		Helios_Udp.Send(tostring(a), string.format("%0.3f",  instruments_table[a] ) )
	end

	-- lamps table >>>> YAW
	local lamps_table =
	{	
		[1] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(33)),      -- RALT_warning_flag
		[2] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(30)),      -- RALT_lamp
		[3] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(831)),		-- hover_lamp_off
		[4] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(783)),     -- lamp_AP_pitch_roll_on
		[5] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(72)),      -- lamp_VIBRATION_LEFT_HIGH
		[6] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(73)),      -- lamp_VIBRATION_RIGHT_HIGH
		[7] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(74)),      -- lamp_FIRE
		[8] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(76)),      -- lamp_LEFT_ENG_TURN_OFF
		[9] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(77)),      -- lamp_RIGHT_ENG_TURN_OFF
		[10] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(68)),     -- lamp_CLOG_TF_LEFT
		[11] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(69)),     -- lamp_CLOG_TF_RIGHT
		[12] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(70)),     -- lamp_CHIP_LEFT_ENG
		[13] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(71)),     -- lamp_CHIP_RIGHT_ENG
		[14] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(78)),     -- lamp_FT_LEFT_HIGH
		[15] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(79)),     -- lamp_FT_RIGHT_HIGH
		[16] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(80)),     -- lamp_OIL_PRESSURE_LEFT
		[17] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(81)),     -- lamp_OIL_PRESSURE_RIGHT
		[18] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(82)),     -- lamp_ER_LEFT
		[19] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(83)),     -- lamp_ER_RIGHT
		[20] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(84)),     -- lamp_EEC_LEFT_OFF
		[21] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(85)),     -- lamp_EEC_RIGHT_OFF
		[22] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(86)),     -- lamp_CIRCUIT_FROM_BATTERY
		[23] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(873)),    -- lamp_CHIP_MAIN_REDUCTOR
		[24] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(874)),    -- lamp_CHIP_INTER_REDUCTOR
		[25] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(875)),    -- lamp_CHIP_TAIL_REDUCTOR
		[26] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(377)),    -- lamp_LEFT_ENG_FIRE
		[27] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(378)),    -- lamp_RIGHT_ENG_FIRE
		[28] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(379)),    -- lamp_KO50_FIRE
		[29] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(380)),    -- lamp_REDUC_AI9_FIRE
		[30] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(381)),    -- lamp_FIRE_LENG_1_QUEUE
		[31] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(382)),    -- lamp_FIRE_RENG_1_QUEUE
		[32] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(383)),    -- lamp_FIRE_KO50_1_QUEUE
		[33] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(384)),    -- lamp_FIRE_REDUCT_1_QUEUE
		[34] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(385)),    -- lamp_FIRE_LENG_2_QUEUE
		[35] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(386)),    -- lamp_FIRE_RENG_2_QUEUE
		[36] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(387)),    -- lamp_FIRE_KO50_2_QUEUE
		[37] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(388)),    -- lamp_FIRE_REDUCT_2_QUEUE
		[38] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(407)),    -- lamp_HYDRO_main_on
		[39] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(408)),    -- lamp_HYDRO_aux_on
		[40] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(414)),    -- lamp_APD9_on
		[41] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(416)),    -- lamp_APD9_oil_pressure
		[42] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(417)),    -- lamp_APD9_rpm
		[43] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(418)),    -- lamp_APD9_rpm_high
		[44] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(420)),    -- lamp_APD_on
		[45] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(424)),    -- lamp_APD_starter_on
		[46] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(434)),    -- lamp_FUEL_left_closed
		[47] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(435)),    -- lamp_FUEL_right_closed
		[48] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(436)),    -- lamp_FUEL_ring_closed
		[49] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(441)),    -- lamp_FUEL_center_on
		[50] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(442)),    -- lamp_FUEL_left_on
		[51] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(443)),    -- lamp_FUEL_right_on
		[52] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(398)),    -- lamp_CHECK_SENSORS
		[53] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(504)),    -- lamp_ELEC_turn_VU1
		[54] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(505)),    -- lamp_ELEC_turn_VU2
		[55] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(506)),    -- lamp_ELEC_turn_VU3
		[56] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(507)),    -- lamp_ELEC_DC_ground
		[57] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(508)),    -- lamp_ELEC_test_equipment
		[58] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(543)),    -- lamp_ELEC_gen1_fail	
		[59] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(544)),    -- lamp_ELEC_gen2_fail
		[60] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(545)),    -- lamp_ELEC_AC_ground	
		[61] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(546)),    -- lamp_ELEC_PO_500
		[62] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(509)),	-- lamp_LEFT_PZU_ON
		[63] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(510)),	-- lamp_RIGHT_PZU_ON 
		[64] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(781)),    -- lamp_AP_heading_on
		[65] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(782)),    -- lamp_AP_heading_off	
		[66] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(783)),    -- lamp_AP_pitch_roll_on
		[67] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(784)),	-- lamp_AP_height_on
		[68] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(785)),	-- lamp_AP_height_off 
		[69] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(316)),	-- lamp_ENGINE_RT_LEFT_ON 
		[70] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(317)),    -- lamp_ENGINE_RT_RIGHT_ON
		[71] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(318)),    -- lamp_SARPP_ON	
		[72] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(326)),    -- lamp_LOCK_OPEN
		[73] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(327)),	-- lamp_DOORS_OPEN
		[74] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(340)),	-- lamp_TURN_ON_RI_65
		[75] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(360)),	-- lamp_FROST
		[76] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(362)),	-- lamp_LEFT_ENG_HEATING
		[77] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(363)),    -- lamp_RIGHT_ENG_HEATING
		[78] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(361)),    -- lamp_ANTI_ICE_ON
		[79] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(364)),    -- lamp_LEFT_PZU_FRONT
		[80] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(365)),	-- lamp_RIGHT_PZU_FRONT
		[81] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(366)),	-- lamp_LEFT_PZU_BACK
		[82] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(367)),	-- lamp_RIGHT_PZU_BACK
		[83] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(373)),    -- lamp_SECTION_1
		[84] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(375)),    -- lamp_SECTION_2
		[85] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(374)),    -- lamp_SECTION_3
		[86] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(376)),	-- lamp_SECTION_4
		[87] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(368)),	-- lamp_RIO_heating_ok
		[88] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(461)),	-- lamp_HEATER
		[89] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(462)),	-- lamp_IGNITION
		[90] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(463)),    -- lamp_KO50_ON
		[91] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(341)),    -- lamp_LEFT_PITOT_HEATER_OK
		[92] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(490)),    -- lamp_RIGHT_PITOT_HEATER_OK
		[93] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(509)),	-- lamp_LEFT_PZU_ON
		[94] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(510)),	-- lamp_RIGHT_PZU_ON
		[95] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(873)),    -- lamp_CHIP_MAIN_REDUCTOR
		[96] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(874)),    -- lamp_CHIP_INTER_REDUCTOR
		[97] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(875)),    -- lamp_CHIP_TAIL_REDUCTOR
		[98] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(64)),		-- lamp_300_Left   (low fuel?)
		[99] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(65)),		-- lamp_DISS_OFF   (doppler Off?)
		[100] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(555)),     -- lamp_BD1
		[101] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(556)),     -- lamp_BD2
		[102] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(557)),     -- lamp_BD3
		[103] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(558)),     -- lamp_BD4
		[104] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(559)),     -- lamp_BD5
		[105] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(560)),     -- lamp_BD6
		[106] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(711)),     -- lamp_BD1Bomb
		[107] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(712)),     -- lamp_BD2Bomb
		[108] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(713)),     -- lamp_BD3Bomb
		[109] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(714)),     -- lamp_BD4Bomb
		[110] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(715)),     -- lamp_BD5Bomb
		[111] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(716)),     -- lamp_BD6Bomb
		[112] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(562)),     -- lamp_PUS1
		[113] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(563)),     -- lamp_PUS3
		[114] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(564)),     -- lamp_PUS4
		[115] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(565)),     -- lamp_PUS6
		[116] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(561)),     -- lamp_EmergExplode
		[117] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(705)),     -- lamp_EmergExplodeSec
		[118] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(710)),     -- lamp_BV_Net_On
		[119] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(566)),     -- lamp_RS_Net_On
		[120] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(567)),     -- lamp_GUV_Net_On
		[121] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(568)),     -- lamp_FKP_On
		[122] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(778)),     -- lamp_Caution_Weap 1
		[123] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(586)),     -- lamp_Caution_Weap 2
		[124] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(587)),     -- lamp_Caution_Weap 3
		[125] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(588)),     -- lamp_Caution_Weap 4
		[126] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(786)),     -- SPUU52_lamp
		[127] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(823)),     -- diss15_check_work_lamp
		[128] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(824)),     -- diss15_check_failM_lamp
		[129] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(825)),     -- diss15_check_failC_lamp
		[130] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(822)),     -- diss15_check_control_lamp
		[131] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(796)),     -- diss15_W_memory_lamp
		[132] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(817)),     -- diss15_coord_on_lamp
		[133] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(458)),     -- ARC_UD_Narrow_Lamp
		[134] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(459)),     -- ARC_UD_Wide_Lamp
		[135] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(460)),     -- ARC_UD_Pulse_Lamp
		[136] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(827)),     -- PU_26_GA_Lamp
		[137] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(849)),     -- Jadro_ASU_Lamp
		[138] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(848)),     -- Jadro_Ctl_Lamp
		[139] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(850)),     -- Jadro_Breakdown_Lamp
		[140] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(892)),     -- UV26_Left
		[141] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(891)),     -- UV26_Right
		[142] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(740)),     -- R828_ASU tune lamp
		[143] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(306)),     -- lamp_Record_P503B
		[144] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(325)),     -- Descent Siren
		[145] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(302)),     -- lamp_IFF_KD
		[146] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(303)),     -- lamp_IFF_KP
		[147] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(912)),     -- lamp_IFF_TurnOnReserve
		[148] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(87))       -- lamp_IFF_Failure
	} 
	-- flag values in index 1001
	for a=1, #lamps_table do
		Helios_Udp.Send(tostring(a + 1000), string.format("%1d",  lamps_table[a] ) )
	end

	----------------------------------------------------------
	---- ok, now lets send all this MI-8 data across DCS general interface to Helios
	----------------------------------------------------------			

	-- gauges and instruments 2  


	Helios_Udp.Flush()
end


function Helios_MI8.LowImportance(MainPanel)

	Helios_Udp.Send("3001", string.format("%1d", MainPanel:get_argument_value(497) ) ) -- Standby Generator Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_1
	Helios_Udp.Send("3002", string.format("%1d", MainPanel:get_argument_value(496) ) ) -- Battery 2 Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_2
	Helios_Udp.Send("3003", string.format("%1d", MainPanel:get_argument_value(495) ) ) -- Battery 1 Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_3
	Helios_Udp.Send("3004", string.format("%1d", MainPanel:get_argument_value(502) ) ) -- DC Ground Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_4
	Helios_Udp.Send("3005", string.format("%1d", MainPanel:get_argument_value(500) ) ) -- Rectifier 2 Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_5
	Helios_Udp.Send("3006", string.format("%1d", MainPanel:get_argument_value(501) ) ) -- Rectifier 3 Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_6
	Helios_Udp.Send("3007", string.format("%1d", MainPanel:get_argument_value(499) ) ) -- Rectifier 1 Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_7
	Helios_Udp.Send("3008", string.format("%1d", MainPanel:get_argument_value(503) ) ) -- Equipment Test Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_8
	Helios_Udp.Send("3009", string.format("%1d", MainPanel:get_argument_value(540) ) ) -- AC Ground Power Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_9
	Helios_Udp.Send("3010", string.format("%1d", MainPanel:get_argument_value(538) ) ) -- Generator 1 Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_10
	Helios_Udp.Send("3011", string.format("%1d", MainPanel:get_argument_value(539) ) ) -- Generator 2 Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_11
	Helios_Udp.Send("3012", string.format("%1d", MainPanel:get_argument_value(148) ) ) -- Net on Rectifier Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_12
	Helios_Udp.Send("3013", string.format("%1d", MainPanel:get_argument_value(147) ) ) -- Net on Rectifier Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_13
	Helios_Udp.Send("3031", string.format("%1d", MainPanel:get_argument_value(590) ) ) -- CB BW ESBR, ON/OFF >> TOGLEE_SWITCH :: TSwitch_31
	Helios_Udp.Send("3032", string.format("%1d", MainPanel:get_argument_value(591) ) ) -- CB Explode, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_32
	Helios_Udp.Send("3033", string.format("%1d", MainPanel:get_argument_value(592) ) ) -- CB Control, ON/OFF_mi8	>> TOGLEE_SWITCH :: TSwitch_33
	Helios_Udp.Send("3034", string.format("%1d", MainPanel:get_argument_value(593) ) ) -- CB Equipment, ON/OFF >> TOGLEE_SWITCH :: TSwitch_34
	Helios_Udp.Send("3035", string.format("%1d", MainPanel:get_argument_value(594) ) ) -- CB RS/GUV Fire, ON/OFF >> TOGLEE_SWITCH :: TSwitch_35
	Helios_Udp.Send("3036", string.format("%1d", MainPanel:get_argument_value(595) ) ) -- CB RS/GUV Warning, ON/OFF >> TOGLEE_SWITCH :: TSwitch_36
	Helios_Udp.Send("3037", string.format("%1d", MainPanel:get_argument_value(596) ) ) -- CB ESBR Heating, ON/OFF >> TOGLEE_SWITCH :: TSwitch_37
	Helios_Udp.Send("3038", string.format("%1d", MainPanel:get_argument_value(597) ) ) -- CB 311, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_38
	Helios_Udp.Send("3039", string.format("%1d", MainPanel:get_argument_value(598) ) ) -- CB GUV: Outer 800 Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_39
	Helios_Udp.Send("3040", string.format("%1d", MainPanel:get_argument_value(599) ) ) -- CB GUV: Outer 800 Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_40
	Helios_Udp.Send("3041", string.format("%1d", MainPanel:get_argument_value(600) ) ) -- CB GUV: Inner Left 622 Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_41
	Helios_Udp.Send("3042", string.format("%1d", MainPanel:get_argument_value(601) ) ) -- CB GUV: Inner Left 622 Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_42
	Helios_Udp.Send("3043", string.format("%1d", MainPanel:get_argument_value(602) ) ) -- CB GUV: Inner Right 622 Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_43
	Helios_Udp.Send("3044", string.format("%1d", MainPanel:get_argument_value(603) ) ) -- CB GUV: Inner Right 622 Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_44
	Helios_Udp.Send("3045", string.format("%1d", MainPanel:get_argument_value(604) ) ) -- CB Electric Launch 800 Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_45
	Helios_Udp.Send("3046", string.format("%1d", MainPanel:get_argument_value(605) ) ) -- CB Electric Launch 800 Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_46
	Helios_Udp.Send("3047", string.format("%1d", MainPanel:get_argument_value(606) ) ) -- CB PKT, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_47
	Helios_Udp.Send("3048", string.format("%1d", MainPanel:get_argument_value(607) ) ) -- CB Emergency Jettison: Bombs and GUV, ON/OFF >> TOGLEE_SWITCH :: TSwitch_48
	Helios_Udp.Send("3049", string.format("%1d", MainPanel:get_argument_value(608) ) ) -- CB Emergency Jettison: Power, ON/OFF >> TOGLEE_SWITCH :: TSwitch_49
	Helios_Udp.Send("3050", string.format("%1d", MainPanel:get_argument_value(609) ) ) -- CB Emergency Jettison: Armed, ON/OFF >> TOGLEE_SWITCH :: TSwitch_50
	Helios_Udp.Send("3051", string.format("%1d", MainPanel:get_argument_value(610) ) ) -- CB Signal Flare, ON/OFF >> TOGLEE_SWITCH :: TSwitch_51
	Helios_Udp.Send("3052", string.format("%1d", MainPanel:get_argument_value(611) ) ) -- CB APU Start, ON/OFF >> TOGLEE_SWITCH :: TSwitch_52
	Helios_Udp.Send("3053", string.format("%1d", MainPanel:get_argument_value(612) ) ) -- CB APU Ignition, ON/OFF >> TOGLEE_SWITCH :: TSwitch_53
	Helios_Udp.Send("3054", string.format("%1d", MainPanel:get_argument_value(613) ) ) -- CB Engine Start, ON/OFF >> TOGLEE_SWITCH :: TSwitch_54
	Helios_Udp.Send("3055", string.format("%1d", MainPanel:get_argument_value(614) ) ) -- CB Engine Ignition, ON/OFF >> TOGLEE_SWITCH :: TSwitch_55
	Helios_Udp.Send("3056", string.format("%1d", MainPanel:get_argument_value(615) ) ) -- CB RPM CONTROL, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_56
	Helios_Udp.Send("3057", string.format("%1d", MainPanel:get_argument_value(616) ) ) -- CB NONAME, ON/OFF >> TOGLEE_SWITCH :: TSwitch_57
	Helios_Udp.Send("3058", string.format("%1d", MainPanel:get_argument_value(617) ) ) -- CB Lock Opening Control Main, ON/OFF >> TOGLEE_SWITCH :: TSwitch_58
	Helios_Udp.Send("3059", string.format("%1d", MainPanel:get_argument_value(618) ) ) -- CB Lock Opening Control Reserve, ON/OFF >> TOGLEE_SWITCH :: TSwitch_59
	Helios_Udp.Send("3060", string.format("%1d", MainPanel:get_argument_value(619) ) ) -- CB TURN INDICATOR, ON/OFF >> TOGLEE_SWITCH :: TSwitch_60
	Helios_Udp.Send("3061", string.format("%1d", MainPanel:get_argument_value(620) ) ) -- CB Autopilot: Main, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_61
	Helios_Udp.Send("3062", string.format("%1d", MainPanel:get_argument_value(621) ) ) -- CB Autopilot: Friction, ON/OFF >> TOGLEE_SWITCH :: TSwitch_62
	Helios_Udp.Send("3063", string.format("%1d", MainPanel:get_argument_value(622) ) ) -- CB Autopilot: Electric Clutches, ON/OFF >> TOGLEE_SWITCH :: TSwitch_63
	Helios_Udp.Send("3064", string.format("%1d", MainPanel:get_argument_value(623) ) ) -- CB Hydraulics: Main, ON/OFF >> TOGLEE_SWITCH :: TSwitch_64
	Helios_Udp.Send("3065", string.format("%1d", MainPanel:get_argument_value(624) ) ) -- CB Hydraulics: Auxiliary, ON/OFF >> TOGLEE_SWITCH :: TSwitch_65
	Helios_Udp.Send("3066", string.format("%1d", MainPanel:get_argument_value(625) ) ) -- CB Radio: SPU (Intercom), ON/OFF >> TOGLEE_SWITCH :: TSwitch_66
	Helios_Udp.Send("3067", string.format("%1d", MainPanel:get_argument_value(626) ) ) -- CB Radio: Altimeter, ON/OFF >> TOGLEE_SWITCH :: TSwitch_67
	Helios_Udp.Send("3068", string.format("%1d", MainPanel:get_argument_value(627) ) ) -- CB Radio: Command Radio Station (R-863), ON/OFF >> TOGLEE_SWITCH :: TSwitch_68
	Helios_Udp.Send("3069", string.format("%1d", MainPanel:get_argument_value(628) ) ) -- CB Radio: 6201, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_69
	Helios_Udp.Send("3070", string.format("%1d", MainPanel:get_argument_value(629) ) ) -- CB Fuel System: Bypass Valve, ON/OFF >> TOGLEE_SWITCH :: TSwitch_70
	Helios_Udp.Send("3071", string.format("%1d", MainPanel:get_argument_value(630) ) ) -- CB Fuel System: Left Valve, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_71
	Helios_Udp.Send("3072", string.format("%1d", MainPanel:get_argument_value(631) ) ) -- CB Fuel System: Right Valve, ON/OFF >> TOGLEE_SWITCH :: TSwitch_72
	Helios_Udp.Send("3073", string.format("%1d", MainPanel:get_argument_value(632) ) ) -- CB Fuel System: Fuelmeter, ON/OFF >> TOGLEE_SWITCH :: TSwitch_73
	Helios_Udp.Send("3074", string.format("%1d", MainPanel:get_argument_value(633) ) ) -- CB Fuel System: Center Tank Pump, ON/OFF >> TOGLEE_SWITCH :: TSwitch_74
	Helios_Udp.Send("3075", string.format("%1d", MainPanel:get_argument_value(634) ) ) -- CB Fuel System: Left Tank Pump, ON/OFF >> TOGLEE_SWITCH :: TSwitch_75
	Helios_Udp.Send("3076", string.format("%1d", MainPanel:get_argument_value(635) ) ) -- CB Fuel System: Right Tank Pump, ON/OFF >> TOGLEE_SWITCH :: TSwitch_76
	Helios_Udp.Send("3077", string.format("%1d", MainPanel:get_argument_value(636) ) ) -- CB T-819, ON/OFF >> TOGLEE_SWITCH :: TSwitch_77
	Helios_Udp.Send("3078", string.format("%1d", MainPanel:get_argument_value(637) ) ) -- CB SPUU-52, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_78
	Helios_Udp.Send("3079", string.format("%1d", MainPanel:get_argument_value(638) ) ) -- CB Fire Protection System: Signalization, ON/OFF >> TOGLEE_SWITCH :: TSwitch_79
	Helios_Udp.Send("3080", string.format("%1d", MainPanel:get_argument_value(639) ) ) -- CB Fire Protection System: 1 Queue Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_80
	Helios_Udp.Send("3081", string.format("%1d", MainPanel:get_argument_value(640) ) ) -- CB Fire Protection System: 1 Queue Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_81
	Helios_Udp.Send("3082", string.format("%1d", MainPanel:get_argument_value(641) ) ) -- CB Fire Protection System: 2 Queue Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_82
	Helios_Udp.Send("3083", string.format("%1d", MainPanel:get_argument_value(642) ) ) -- CB Fire Protection System: 2 Queue Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_83
	Helios_Udp.Send("3084", string.format("%1d", MainPanel:get_argument_value(643) ) ) -- CB Radio: Radio Compass MW(ARC-9), ON/OFF	>> TOGLEE_SWITCH :: TSwitch_84
	Helios_Udp.Send("3085", string.format("%1d", MainPanel:get_argument_value(644) ) ) -- CB Radio: Radio Compass VHF(ARC-UD), ON/OFF >> TOGLEE_SWITCH :: TSwitch_85
	Helios_Udp.Send("3086", string.format("%1d", MainPanel:get_argument_value(645) ) ) -- CB Radio: Doppler Navigator, ON/OFF >> TOGLEE_SWITCH :: TSwitch_86
	Helios_Udp.Send("3087", string.format("%1d", MainPanel:get_argument_value(646) ) ) -- CB Radio: Radio Meter, ON/OFF >> TOGLEE_SWITCH :: TSwitch_87
	Helios_Udp.Send("3088", string.format("%1d", MainPanel:get_argument_value(647) ) ) -- CB Headlights: Left: Control, ON/OFF >> TOGLEE_SWITCH :: TSwitch_88
	Helios_Udp.Send("3089", string.format("%1d", MainPanel:get_argument_value(648) ) ) -- CB Headlights: Left: Light, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_89
	Helios_Udp.Send("3090", string.format("%1d", MainPanel:get_argument_value(649) ) ) -- CB Headlights: Right: Control, ON/OFF >> TOGLEE_SWITCH :: TSwitch_90
	Helios_Udp.Send("3091", string.format("%1d", MainPanel:get_argument_value(650) ) ) -- CB Headlights: Right: Light, ON/OFF >> TOGLEE_SWITCH :: TSwitch_91
	Helios_Udp.Send("3092", string.format("%1d", MainPanel:get_argument_value(651) ) ) -- CB ANO, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_92
	Helios_Udp.Send("3093", string.format("%1d", MainPanel:get_argument_value(652) ) ) -- CB Wing Lights, ON/OFF >> TOGLEE_SWITCH :: TSwitch_93
	Helios_Udp.Send("3094", string.format("%1d", MainPanel:get_argument_value(653) ) ) -- CB Check Lamps/Flasher, ON/OFF >> TOGLEE_SWITCH :: TSwitch_94
	Helios_Udp.Send("3095", string.format("%1d", MainPanel:get_argument_value(918) ) ) -- CB PRF-4 Light Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_95
	Helios_Udp.Send("3096", string.format("%1d", MainPanel:get_argument_value(919) ) ) -- CB PRF-4 Light Right, ON/OFF >> TOGLEE_SWITCH :: TSwitch_96
	Helios_Udp.Send("3097", string.format("%1d", MainPanel:get_argument_value(656) ) ) -- CB Defrost System: Control, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_97
	Helios_Udp.Send("3098", string.format("%1d", MainPanel:get_argument_value(657) ) ) -- CB Defrost System: Left Engine, ON/OFF >> TOGLEE_SWITCH :: TSwitch_98
	Helios_Udp.Send("3099", string.format("%1d", MainPanel:get_argument_value(658) ) ) -- CB Defrost System: Right Engine, ON/OFF >> TOGLEE_SWITCH :: TSwitch_99
	Helios_Udp.Send("3100", string.format("%1d", MainPanel:get_argument_value(659) ) ) -- CB Defrost System: RIO-3, ON/OFF >> TOGLEE_SWITCH :: TSwitch_100
	Helios_Udp.Send("3101", string.format("%1d", MainPanel:get_argument_value(660) ) ) -- CB Defrost System: Glass, ON/OFF >> TOGLEE_SWITCH :: TSwitch_101
	Helios_Udp.Send("3102", string.format("%1d", MainPanel:get_argument_value(661) ) ) -- CB Wiper Left, ON/OFF >> TOGLEE_SWITCH :: TSwitch_102
	Helios_Udp.Send("3103", string.format("%1d", MainPanel:get_argument_value(662) ) ) -- CB Wiper Right, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_103
	Helios_Udp.Send("3104", string.format("%1d", MainPanel:get_argument_value(663) ) ) -- CB RIO-3, ON/OFF >> TOGLEE_SWITCH :: TSwitch_104
	Helios_Udp.Send("3105", string.format("%1d", MainPanel:get_argument_value(664) ) ) -- CB Heater KO-50, ON/OFF >> TOGLEE_SWITCH :: TSwitch_105
	Helios_Udp.Send("3106", string.format("%1d", MainPanel:get_argument_value(522) ) ) -- Battery Heating Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_106
	Helios_Udp.Send("3107", string.format("%1d", MainPanel:get_argument_value(438) ) ) -- Feed Tank Pump Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_107
	Helios_Udp.Send("3108", string.format("%1d", MainPanel:get_argument_value(439) ) ) -- Left Tank Pump Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_108
	Helios_Udp.Send("3109", string.format("%1d", MainPanel:get_argument_value(440) ) ) -- Right Tank Pump Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_109
	Helios_Udp.Send("3110", string.format("%1d", MainPanel:get_argument_value(427) ) ) -- Left Shutoff Valve Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_110
	Helios_Udp.Send("3111", string.format("%1d", MainPanel:get_argument_value(429) ) ) -- Right Shutoff Valve Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_111
	Helios_Udp.Send("3112", string.format("%1d", MainPanel:get_argument_value(426) ) ) -- Left Shutoff Valve Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_112
	Helios_Udp.Send("3113", string.format("%1d", MainPanel:get_argument_value(428) ) ) -- Right Shutoff Valve Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_113
	Helios_Udp.Send("3114", string.format("%1d", MainPanel:get_argument_value(431) ) ) -- Crossfeed Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_114
	Helios_Udp.Send("3115", string.format("%1d", MainPanel:get_argument_value(430) ) ) -- Crossfeed Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_115
	Helios_Udp.Send("3116", string.format("%1d", MainPanel:get_argument_value(433) ) ) -- Bypass Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_116
	Helios_Udp.Send("3117", string.format("%1d", MainPanel:get_argument_value(432) ) ) -- Bypass Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_117
	Helios_Udp.Send("3118", string.format("%1d", MainPanel:get_argument_value(204) ) ) -- Left Engine Stop Lever >> TOGLEE_SWITCH :: TSwitch_118
	Helios_Udp.Send("3119", string.format("%1d", MainPanel:get_argument_value(206) ) ) -- Right Engine Stop Lever >> TOGLEE_SWITCH :: TSwitch_119
	Helios_Udp.Send("3120", string.format("%1d", MainPanel:get_argument_value(208) ) ) -- Rotor Brake Handle, UP/DOWN >> TOGLEE_SWITCH :: TSwitch_120
	Helios_Udp.Send("3121", string.format("%1d", MainPanel:get_argument_value(167) ) ) -- Left Engine EEC Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_121
	Helios_Udp.Send("3122", string.format("%1d", MainPanel:get_argument_value(173) ) ) -- Right Engine EEC Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_122
	Helios_Udp.Send("3123", string.format("%1d", MainPanel:get_argument_value(168) ) ) -- Left Engine ER Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_123
	Helios_Udp.Send("3124", string.format("%1d", MainPanel:get_argument_value(172) ) ) -- Right Engine ER Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_124
	Helios_Udp.Send("3125", string.format("%1d", MainPanel:get_argument_value(406) ) ) -- Main Hydraulic Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_125
	Helios_Udp.Send("3126", string.format("%1d", MainPanel:get_argument_value(410) ) ) -- Auxiliary Hydraulic Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_126
	Helios_Udp.Send("3127", string.format("%1d", MainPanel:get_argument_value(409) ) ) -- Auxiliary Hydraulic Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_127
	Helios_Udp.Send("3128", string.format("%1d", MainPanel:get_argument_value(35) ) ) -- Radar Altimeter Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_128
	Helios_Udp.Send("3129", string.format("%1d", MainPanel:get_argument_value(858) ) ) -- HSI Radio Compass Selector Switch, ARC-9/ARC-UD >> TOGLEE_SWITCH :: TSwitch_129
	Helios_Udp.Send("3130", string.format("%1d", MainPanel:get_argument_value(921) ) ) -- Weapon Safe/Armed Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_130
	Helios_Udp.Send("3131", string.format("%1d", MainPanel:get_argument_value(707) ) ) -- Emergency Explode Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_131
	Helios_Udp.Send("3132", string.format("%1d", MainPanel:get_argument_value(706) ) ) -- Emergency Explode Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_132
	Helios_Udp.Send("3133", string.format("%1d", MainPanel:get_argument_value(708) ) ) -- Emergency Bomb Release Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_133
	Helios_Udp.Send("3134", string.format("%1d", MainPanel:get_argument_value(717) ) ) -- Main Bombs Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_134
	Helios_Udp.Send("3135", string.format("%1d", MainPanel:get_argument_value(720) ) ) -- ESBR Heating Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_135
	Helios_Udp.Send("3136", string.format("%1d", MainPanel:get_argument_value(731) ) ) -- ESBR Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_136
	Helios_Udp.Send("3137", string.format("%1d", MainPanel:get_argument_value(570) ) ) -- Emergency Explode Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_137
	Helios_Udp.Send("3138", string.format("%1d", MainPanel:get_argument_value(569) ) ) -- Emergency Explode Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_138
	Helios_Udp.Send("3139", string.format("%1d", MainPanel:get_argument_value(571) ) ) -- Emergency Release Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_139
	Helios_Udp.Send("3140", string.format("%1d", MainPanel:get_argument_value(575) ) ) -- RS/GUV Selector Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_140
	Helios_Udp.Send("3141", string.format("%1d", MainPanel:get_argument_value(349) ) ) -- 800_or_624_622_800 Switch >> TOGLEE_SWITCH :: TSwitch_141
	Helios_Udp.Send("3142", string.format("%1d", MainPanel:get_argument_value(348) ) ) -- 800 or 624_622_800 Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_142
	Helios_Udp.Send("3143", string.format("%1d", MainPanel:get_argument_value(573) ) ) -- Mine Arms Main Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_143
	Helios_Udp.Send("3144", string.format("%1d", MainPanel:get_argument_value(905) ) ) -- PKT Selector Switch, FLIGHT ENGINEER/PILOT >> TOGLEE_SWITCH :: TSwitch_144
	Helios_Udp.Send("3145", string.format("%1d", MainPanel:get_argument_value(185) ) ) -- Left Fire RS Button Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_145
	Helios_Udp.Send("3146", string.format("%1d", MainPanel:get_argument_value(228) ) ) -- Right Fire RS Button Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_146
	Helios_Udp.Send("3147", string.format("%1d", MainPanel:get_argument_value(352) ) ) -- Gun Camera Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_147
	Helios_Udp.Send("3148", string.format("%1d", MainPanel:get_argument_value(523) ) ) -- Flasher Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_148
	Helios_Udp.Send("3149", string.format("%1d", MainPanel:get_argument_value(525) ) ) -- Transparent Switch, DAY/NIGHT >> TOGLEE_SWITCH :: TSwitch_149
	Helios_Udp.Send("3150", string.format("%1d", MainPanel:get_argument_value(332) ) ) -- SPUU-52 Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_150
	--Helios_Udp.Send("3151", string.format("%1d", MainPanel:get_argument_value(127) ) ) -- SPUU-52 Control Engage Button >> TOGLEE_SWITCH :: TSwitch_151
	Helios_Udp.Send("3152", string.format("%1d", MainPanel:get_argument_value(399) ) ) -- Fire Detector Test Switch >> TOGLEE_SWITCH :: TSwitch_152
	Helios_Udp.Send("3153", string.format("%1d", MainPanel:get_argument_value(400) ) ) -- Squib Test Switch >> TOGLEE_SWITCH :: TSwitch_153
	Helios_Udp.Send("3154", string.format("%1d", MainPanel:get_argument_value(353) ) ) -- Defrost Mode Switch, AUTO/MANUAL >> TOGLEE_SWITCH :: TSwitch_154
	Helios_Udp.Send("3155", string.format("%1d", MainPanel:get_argument_value(355) ) ) -- Left Engine Heater Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_155
	Helios_Udp.Send("3156", string.format("%1d", MainPanel:get_argument_value(356) ) ) -- Right Engine Heater Switch, MANUAL/AUTO >> TOGLEE_SWITCH :: TSwitch_156
	Helios_Udp.Send("3157", string.format("%1d", MainPanel:get_argument_value(357) ) ) -- Glass Heater Switch, MANUAL/AUTO >> TOGLEE_SWITCH :: TSwitch_157
	Helios_Udp.Send("3158", string.format("%1d", MainPanel:get_argument_value(358) ) ) -- Ice Detector Heater Switch, MANUAL/AUTO >> TOGLEE_SWITCH :: TSwitch_158
	Helios_Udp.Send("3159", string.format("%1d", MainPanel:get_argument_value(519) ) ) -- Left Pitot Heater Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_159
	Helios_Udp.Send("3160", string.format("%1d", MainPanel:get_argument_value(520) ) ) -- Right Pitot Heater Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_160
	Helios_Udp.Send("3161", string.format("%1d", MainPanel:get_argument_value(483) ) ) -- Doppler Navigator Power Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_161
	Helios_Udp.Send("3162", string.format("%1d", MainPanel:get_argument_value(797) ) ) -- Test/Work Switch >> TOGLEE_SWITCH :: TSwitch_162
	Helios_Udp.Send("3163", string.format("%1d", MainPanel:get_argument_value(798) ) ) -- Land/Sea Switch	>> TOGLEE_SWITCH :: TSwitch_163
	Helios_Udp.Send("3164", string.format("%1d", MainPanel:get_argument_value(487) ) ) -- Right Attitude Indicator Power Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_164
	Helios_Udp.Send("3165", string.format("%1d", MainPanel:get_argument_value(335) ) ) -- Left Attitude Indicator Power Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_165
	Helios_Udp.Send("3166", string.format("%1d", MainPanel:get_argument_value(336) ) ) -- VK-53 Power Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_166
	Helios_Udp.Send("3167", string.format("%1d", MainPanel:get_argument_value(485) ) ) -- GMC Power Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_167
	Helios_Udp.Send("3168", string.format("%1d", MainPanel:get_argument_value(470) ) ) -- GMC Hemisphere Selection Switch, NORTH/SOUTH >> TOGLEE_SWITCH :: TSwitch_168
	Helios_Udp.Send("3169", string.format("%1d", MainPanel:get_argument_value(517) ) ) -- Left Engine Dust Protection Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_169
	Helios_Udp.Send("3170", string.format("%1d", MainPanel:get_argument_value(518) ) ) -- Right Engine Dust Protection Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_170
	Helios_Udp.Send("3171", string.format("%1d", MainPanel:get_argument_value(515) ) ) -- Tip Lights Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_171
	Helios_Udp.Send("3172", string.format("%1d", MainPanel:get_argument_value(516) ) ) -- Strobe Light Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_172
	Helios_Udp.Send("3173", string.format("%1d", MainPanel:get_argument_value(836) ) ) -- Taxi Light Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_173
	Helios_Udp.Send("3174", string.format("%1d", MainPanel:get_argument_value(479) ) ) -- 5.5V Lights Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_174
	Helios_Udp.Send("3175", string.format("%1d", MainPanel:get_argument_value(511) ) ) -- Cargo Cabin Duty Lights Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_175
	Helios_Udp.Send("3176", string.format("%1d", MainPanel:get_argument_value(512) ) ) -- Cargo Cabin Common Lights Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_176
	Helios_Udp.Send("3177", string.format("%1d", MainPanel:get_argument_value(553) ) ) -- Radio/ICS Switch >> TOGLEE_SWITCH :: TSwitch_177
	Helios_Udp.Send("3178", string.format("%1d", MainPanel:get_argument_value(551) ) ) -- Network 1/2 Switch (N/F) >> TOGLEE_SWITCH :: TSwitch_178
	Helios_Udp.Send("3179", string.format("%1d", MainPanel:get_argument_value(845) ) ) -- Radio/ICS Switch >> TOGLEE_SWITCH :: TSwitch_179
	Helios_Udp.Send("3180", string.format("%1d", MainPanel:get_argument_value(843) ) ) -- Network 1/2 Switch (N/F) >> TOGLEE_SWITCH :: TSwitch_180
	Helios_Udp.Send("3181", string.format("%1d", MainPanel:get_argument_value(480) ) ) -- Laryngophone Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_181
	Helios_Udp.Send("3182", string.format("%1d", MainPanel:get_argument_value(369) ) ) -- R-863, Modulation Switch, FM/AM >> TOGLEE_SWITCH :: TSwitch_182
	Helios_Udp.Send("3183", string.format("%1d", MainPanel:get_argument_value(132) ) ) -- R-863, Unit Switch, DIAL/MEMORY >> TOGLEE_SWITCH :: TSwitch_183
	Helios_Udp.Send("3184", string.format("%1d", MainPanel:get_argument_value(155) ) ) -- R-863, Squelch Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_184
	Helios_Udp.Send("3185", string.format("%1d", MainPanel:get_argument_value(153) ) ) -- R-863, Emergency Receiver Switch, ON/OFF (N/F) >> TOGLEE_SWITCH :: TSwitch_185
	Helios_Udp.Send("3186", string.format("%1d", MainPanel:get_argument_value(154) ) ) -- R-863, ARC Switch, ON/OFF (N/F) >> TOGLEE_SWITCH :: TSwitch_186
	Helios_Udp.Send("3187", string.format("%1d", MainPanel:get_argument_value(739) ) ) -- R-828, Squelch Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_187
	Helios_Udp.Send("3188", string.format("%1d", MainPanel:get_argument_value(756) ) ) -- R-828, Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_188
	Helios_Udp.Send("3189", string.format("%1d", MainPanel:get_argument_value(757) ) ) -- R-828, Compass Switch, COMM/NAV >> TOGLEE_SWITCH :: TSwitch_189
	Helios_Udp.Send("3190", string.format("%1d", MainPanel:get_argument_value(484) ) ) -- Jadro 1A, Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_190
	Helios_Udp.Send("3191", string.format("%1d", MainPanel:get_argument_value(338) ) ) -- RI-65 Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_191
	Helios_Udp.Send("3192", string.format("%1d", MainPanel:get_argument_value(295) ) ) -- RI-65 Amplifier Switch, ON/OFF	>> TOGLEE_SWITCH :: TSwitch_192
	Helios_Udp.Send("3193", string.format("%1d", MainPanel:get_argument_value(453) ) ) -- ARC-UD, Sensitivity Switch, MORE/LESS >> TOGLEE_SWITCH :: TSwitch_193
	Helios_Udp.Send("3194", string.format("%1d", MainPanel:get_argument_value(454) ) ) -- ARC-UD, Wave Switch, MW/D >> TOGLEE_SWITCH :: TSwitch_194
	Helios_Udp.Send("3195", string.format("%1d", MainPanel:get_argument_value(481) ) ) -- ARC-UD, Lock Switch, LOCK/UNLOCK >> TOGLEE_SWITCH :: TSwitch_195
	Helios_Udp.Send("3196", string.format("%1d", MainPanel:get_argument_value(521) ) ) -- Clock Heating Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_196
	Helios_Udp.Send("3197", string.format("%1d", MainPanel:get_argument_value(910) ) ) -- CMD Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_197
	Helios_Udp.Send("3198", string.format("%1d", MainPanel:get_argument_value(913) ) ) -- CMD Flares Amount Switch, COUNTER/PROGRAMMING >> TOGLEE_SWITCH :: TSwitch_198
	Helios_Udp.Send("3199", string.format("%1d", MainPanel:get_argument_value(930) ) ) -- Parking Brake Handle >> TOGLEE_SWITCH :: TSwitch_199
	Helios_Udp.Send("3200", string.format("%1d", MainPanel:get_argument_value(334) ) ) -- Left Fan Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_200
	Helios_Udp.Send("3201", string.format("%1d", MainPanel:get_argument_value(488) ) ) -- Right Fan Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_201
	Helios_Udp.Send("3202", string.format("%1d", MainPanel:get_argument_value(469) ) ) -- ARC-9, Dialer Switch, MAIN/BACKUP >> TOGLEE_SWITCH :: TSwitch_202
	Helios_Udp.Send("3203", string.format("%1d", MainPanel:get_argument_value(444) ) ) -- ARC-9, TLF/TLG Switch >> TOGLEE_SWITCH :: TSwitch_203
	Helios_Udp.Send("3204", string.format("%1d", MainPanel:get_argument_value(199) ) ) -- Tactical Cargo Release Button Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_204
	Helios_Udp.Send("3205", string.format("%1d", MainPanel:get_argument_value(197) ) ) -- Emergency Cargo Release Button Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_205
	Helios_Udp.Send("3206", string.format("%1d", MainPanel:get_argument_value(324) ) ) -- External Cargo Automatic Dropping, ON/OFF >> TOGLEE_SWITCH :: TSwitch_206
	Helios_Udp.Send("3207", string.format("%1d", MainPanel:get_argument_value(282) ) ) -- Signal Flares Cassette 1 Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_207
	Helios_Udp.Send("3208", string.format("%1d", MainPanel:get_argument_value(283) ) ) -- Signal Flares Cassette 2 Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_208
	Helios_Udp.Send("3209", string.format("%1d", MainPanel:get_argument_value(467) ) ) -- KO-50 Fan Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_209
	Helios_Udp.Send("3210", string.format("%1d", MainPanel:get_argument_value(315) ) ) -- SARPP-12 Mode Switch, MANUAL/AUTO >> TOGLEE_SWITCH :: TSwitch_210
	Helios_Udp.Send("3211", string.format("%1d", MainPanel:get_argument_value(305) ) ) -- Recorder P-503B Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_211
	Helios_Udp.Send("3212", string.format("%1d", MainPanel:get_argument_value(301) ) ) -- IFF Transponder Device Selector Switch, WORK/RESERVE >> TOGLEE_SWITCH :: TSwitch_212
	Helios_Udp.Send("3213", string.format("%1d", MainPanel:get_argument_value(300) ) ) -- IFF Transponder Device Mode Switch, 1/2 >> TOGLEE_SWITCH :: TSwitch_213
	Helios_Udp.Send("3214", string.format("%1d", MainPanel:get_argument_value(296) ) ) -- IFF Transponder Erase Button Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_214
	Helios_Udp.Send("3215", string.format("%1d", MainPanel:get_argument_value(298) ) ) -- IFF Transponder Disaster Switch Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_215
	Helios_Udp.Send("3216", string.format("%1d", MainPanel:get_argument_value(299) ) ) -- IFF Transponder Disaster Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_216
	-- buttons
	Helios_Udp.Send("2001", string.format("%.1f", MainPanel:get_argument_value(882) ) ) -- CB Group 1 ON >> PUSH_BUTTONS :: PB_1
	Helios_Udp.Send("2002", string.format("%.1f", MainPanel:get_argument_value(883) ) ) -- CB Group 4 ON >> PUSH_BUTTONS :: PB_2
	Helios_Udp.Send("2003", string.format("%.1f", MainPanel:get_argument_value(884) ) ) -- CB Group 7 ON >> PUSH_BUTTONS :: PB_3
	Helios_Udp.Send("2004", string.format("%.1f", MainPanel:get_argument_value(885) ) ) -- CB Group 2 ON >> PUSH_BUTTONS :: PB_4
	Helios_Udp.Send("2005", string.format("%.1f", MainPanel:get_argument_value(886) ) ) -- CB Group 5 ON >> PUSH_BUTTONS :: PB_5
	Helios_Udp.Send("2006", string.format("%.1f", MainPanel:get_argument_value(887) ) ) -- CB Group 8 ON >> PUSH_BUTTONS :: PB_6
	Helios_Udp.Send("2007", string.format("%.1f", MainPanel:get_argument_value(888) ) ) -- CB Group 3 ON >> PUSH_BUTTONS :: PB_7
	Helios_Udp.Send("2008", string.format("%.1f", MainPanel:get_argument_value(889) ) ) -- CB Group 6 ON >> PUSH_BUTTONS :: PB_8
	Helios_Udp.Send("2009", string.format("%.1f", MainPanel:get_argument_value(890) ) ) -- CB Group 9 ON >> PUSH_BUTTONS :: PB_9
	Helios_Udp.Send("2010", string.format("%.1f", MainPanel:get_argument_value(413) ) ) -- APU Start Button - Push to start APU >> PUSH_BUTTONS :: PB_10
	Helios_Udp.Send("2011", string.format("%.1f", MainPanel:get_argument_value(415) ) ) -- APU Stop Button - Push to stop APU >> PUSH_BUTTONS :: PB_11
	Helios_Udp.Send("2012", string.format("%.1f", MainPanel:get_argument_value(419) ) ) -- Engine Start Button - Push to start engine >> PUSH_BUTTONS :: PB_12
	Helios_Udp.Send("2013", string.format("%.1f", MainPanel:get_argument_value(421) ) ) -- Abort Start Engine Button - Push to abort start >> PUSH_BUTTONS :: PB_13
	Helios_Udp.Send("2014", string.format("%.1f", MainPanel:get_argument_value(310) ) ) -- Vibration Sensor Test Button - Push to test >> PUSH_BUTTONS :: PB_14
	Helios_Udp.Send("2015", string.format("%.1f", MainPanel:get_argument_value(311) ) ) -- Cold Temperature Sensor Test Button - Push to test >> PUSH_BUTTONS :: PB_15
	Helios_Udp.Send("2016", string.format("%.1f", MainPanel:get_argument_value(312) ) ) -- Hot Temperature Sensor Test Button - Push to test >> PUSH_BUTTONS :: PB_16
	Helios_Udp.Send("2017", string.format("%.1f", MainPanel:get_argument_value(313) ) ) -- Left Engine Temperature Regulator Test Button - Push to test >> PUSH_BUTTONS :: PB_17
	Helios_Udp.Send("2018", string.format("%.1f", MainPanel:get_argument_value(314) ) ) -- Right Engine Temperature Regulator Test Button - Push to test >> PUSH_BUTTONS :: PB_18
	Helios_Udp.Send("2019", string.format("%.1f", MainPanel:get_argument_value(411) ) ) -- Auxiliary Hydraulic Shut Off Button - Push to shut off >> PUSH_BUTTONS :: PB_19
	--Helios_Udp.Send("2020", string.format("%.1f", MainPanel:get_argument_value(183) ) ) -- Autopilot Off Left Button >> PUSH_BUTTONS :: PB_20
	--Helios_Udp.Send("2021", string.format("%.1f", MainPanel:get_argument_value(226) ) ) -- Autopilot Off Right Button >> PUSH_BUTTONS :: PB_21
	--Helios_Udp.Send("2022", string.format("%.1f", MainPanel:get_argument_value(184) ) ) -- Trimmer Left Button >> PUSH_BUTTONS :: PB_22
	--Helios_Udp.Send("2023", string.format("%.1f", MainPanel:get_argument_value(227) ) ) -- Trimmer Right Button >> PUSH_BUTTONS :: PB_23
	Helios_Udp.Send("2024", string.format("%.1f", MainPanel:get_argument_value(709) ) ) -- Emergency Bomb Release Switch, ON/OFF >> PUSH_BUTTONS :: PB_24
	Helios_Udp.Send("2025", string.format("%.1f", MainPanel:get_argument_value(718) ) ) -- Lamps Check Button - Push to check >> PUSH_BUTTONS :: PB_25
	Helios_Udp.Send("2026", string.format("%.1f", MainPanel:get_argument_value(572) ) ) -- Emergency Release Switch >> PUSH_BUTTONS :: PB_26
	Helios_Udp.Send("2027", string.format("%.1f", MainPanel:get_argument_value(576) ) ) -- Lamps Check Button - Push to check >> PUSH_BUTTONS :: PB_27
	Helios_Udp.Send("2028", string.format("%.1f", MainPanel:get_argument_value(574) ) ) -- PUS Arming Button - Push to arm >> PUSH_BUTTONS :: PB_28
	Helios_Udp.Send("2029", string.format("%.1f", MainPanel:get_argument_value(186) ) ) -- Left Fire RS Button >> PUSH_BUTTONS :: PB_29
	Helios_Udp.Send("2030", string.format("%.1f", MainPanel:get_argument_value(229) ) ) -- Right Fire RS Button >> PUSH_BUTTONS :: PB_30
	Helios_Udp.Send("2031", string.format("%.1f", MainPanel:get_argument_value(389) ) ) -- Main Discharge Left Engine Button >> PUSH_BUTTONS :: PB_31
	Helios_Udp.Send("2032", string.format("%.1f", MainPanel:get_argument_value(390) ) ) -- Main Discharge Right Engine Button >> PUSH_BUTTONS :: PB_32
	Helios_Udp.Send("2033", string.format("%.1f", MainPanel:get_argument_value(391) ) ) -- Main Discharge KO-50 Button >> PUSH_BUTTONS :: PB_33
	Helios_Udp.Send("2034", string.format("%.1f", MainPanel:get_argument_value(392) ) ) -- Main Discharge APU GEAR Button >> PUSH_BUTTONS :: PB_34
	Helios_Udp.Send("2035", string.format("%.1f", MainPanel:get_argument_value(393) ) ) -- Alternate Discharge Left Engine Button >> PUSH_BUTTONS :: PB_35
	Helios_Udp.Send("2036", string.format("%.1f", MainPanel:get_argument_value(394) ) ) -- Alternate Discharge Right Engine Button >> PUSH_BUTTONS :: PB_36
	Helios_Udp.Send("2037", string.format("%.1f", MainPanel:get_argument_value(395) ) ) -- Alternate Discharge KO-50 Button >> PUSH_BUTTONS :: PB_37
	Helios_Udp.Send("2038", string.format("%.1f", MainPanel:get_argument_value(396) ) ) -- Alternate Discharge APU GEAR Button >> PUSH_BUTTONS :: PB_38
	Helios_Udp.Send("2039", string.format("%.1f", MainPanel:get_argument_value(397) ) ) -- Turn Off Fire Signal Button >> PUSH_BUTTONS :: PB_39
	Helios_Udp.Send("2040", string.format("%.1f", MainPanel:get_argument_value(354) ) ) -- Defrost OFF Button - Push to turn off >> PUSH_BUTTONS :: PB_40
	Helios_Udp.Send("2041", string.format("%.1f", MainPanel:get_argument_value(359) ) ) -- Ice Detector Heater Test Button - Push to test >> PUSH_BUTTONS :: PB_41
	Helios_Udp.Send("2042", string.format("%.1f", MainPanel:get_argument_value(339) ) ) -- Left Pitot Heater Test Button - Push to test >> PUSH_BUTTONS :: PB_42
	Helios_Udp.Send("2043", string.format("%.1f", MainPanel:get_argument_value(482) ) ) -- Right Pitot Heater Test Button - Push to test >> PUSH_BUTTONS :: PB_43
	Helios_Udp.Send("2044", string.format("%.1f", MainPanel:get_argument_value(818) ) ) -- Turn Off Coordinates Calculator Button >> PUSH_BUTTONS :: PB_44
	Helios_Udp.Send("2045", string.format("%.1f", MainPanel:get_argument_value(819) ) ) -- Turn On Coordinates Calculator Button >> PUSH_BUTTONS :: PB_45
	Helios_Udp.Send("2046", string.format("%.1f", MainPanel:get_argument_value(815) ) ) -- Decrease Map Angle Button >> PUSH_BUTTONS :: PB_46
	Helios_Udp.Send("2047", string.format("%.1f", MainPanel:get_argument_value(816) ) ) -- Increase Map Angle Button >> PUSH_BUTTONS :: PB_47
	Helios_Udp.Send("2048", string.format("%.1f", MainPanel:get_argument_value(809) ) ) -- Decrease Path KM Button >> PUSH_BUTTONS :: PB_48
	Helios_Udp.Send("2049", string.format("%.1f", MainPanel:get_argument_value(810) ) ) -- Increase Path KM Button >> PUSH_BUTTONS :: PB_49
	Helios_Udp.Send("2050", string.format("%.1f", MainPanel:get_argument_value(803) ) ) -- Decrease Deviation KM Button >> PUSH_BUTTONS :: PB_50
	Helios_Udp.Send("2051", string.format("%.1f", MainPanel:get_argument_value(804) ) ) -- Increase Deviation KM Button >> PUSH_BUTTONS :: PB_51
	Helios_Udp.Send("2052", string.format("%.1f", MainPanel:get_argument_value(90) ) ) -- Right Attitude Indicator Cage Knob - Push to cage >> PUSH_BUTTONS :: PB_52
	Helios_Udp.Send("2053", string.format("%.1f", MainPanel:get_argument_value(11) ) ) -- Left Attitude Indicator Cage Knob - Push to cage >> PUSH_BUTTONS :: PB_53
	Helios_Udp.Send("2054", string.format("%.1f", MainPanel:get_argument_value(322) ) ) -- ANO Code Button >> PUSH_BUTTONS :: PB_54
	Helios_Udp.Send("2055", string.format("%.1f", MainPanel:get_argument_value(552) ) ) -- Circular Call Button (N/F) >> PUSH_BUTTONS :: PB_55
	Helios_Udp.Send("2056", string.format("%.1f", MainPanel:get_argument_value(846) ) ) -- Circular Call Button (N/F) >> PUSH_BUTTONS :: PB_56
	Helios_Udp.Send("2057", string.format("%.1f", MainPanel:get_argument_value(738) ) ) -- R-828, Radio Tuner Button >> PUSH_BUTTONS :: PB_57
	Helios_Udp.Send("2058", string.format("%.1f", MainPanel:get_argument_value(742) ) ) -- Jadro 1A, Control Button >> PUSH_BUTTONS :: PB_58
	Helios_Udp.Send("2059", string.format("%.1f", MainPanel:get_argument_value(292) ) ) -- RI-65 OFF Button >> PUSH_BUTTONS :: PB_59
	Helios_Udp.Send("2060", string.format("%.1f", MainPanel:get_argument_value(293) ) ) -- RI-65 Repeat Button >> PUSH_BUTTONS :: PB_60
	Helios_Udp.Send("2061", string.format("%.1f", MainPanel:get_argument_value(294) ) ) -- RI-65 Check Button >> PUSH_BUTTONS :: PB_61
	Helios_Udp.Send("2062", string.format("%.1f", MainPanel:get_argument_value(672) ) ) -- ARC-UD, Control Button >> PUSH_BUTTONS :: PB_62
	Helios_Udp.Send("2063", string.format("%.1f", MainPanel:get_argument_value(673) ) ) -- ARC-UD, Left Antenna Button >> PUSH_BUTTONS :: PB_63
	Helios_Udp.Send("2064", string.format("%.1f", MainPanel:get_argument_value(674) ) ) -- ARC-UD, Right Antenna Button >> PUSH_BUTTONS :: PB_64
	Helios_Udp.Send("2065", string.format("%.1f", MainPanel:get_argument_value(914) ) ) -- CMD Num of Sequences Button >> PUSH_BUTTONS :: PB_65
	Helios_Udp.Send("2066", string.format("%.1f", MainPanel:get_argument_value(862) ) ) -- CMD Dispense Interval Button >> PUSH_BUTTONS :: PB_66
	Helios_Udp.Send("2067", string.format("%.1f", MainPanel:get_argument_value(863) ) ) -- CMD Num in Sequence Button >> PUSH_BUTTONS :: PB_67
	Helios_Udp.Send("2068", string.format("%.1f", MainPanel:get_argument_value(866) ) ) -- CMD Start Dispense Button >> PUSH_BUTTONS :: PB_68
	Helios_Udp.Send("2069", string.format("%.1f", MainPanel:get_argument_value(911) ) ) -- Start/Stop Dispense Button >> PUSH_BUTTONS :: PB_69
	Helios_Udp.Send("2070", string.format("%.1f", MainPanel:get_argument_value(864) ) ) -- CMD Reset to Default Program Button >> PUSH_BUTTONS :: PB_70
	Helios_Udp.Send("2071", string.format("%.1f", MainPanel:get_argument_value(865) ) ) -- CMD Stop Dispense Button >> PUSH_BUTTONS :: PB_71
	Helios_Udp.Send("2072", string.format("%.1f", MainPanel:get_argument_value(881) ) ) -- Wheel Brakes Handle >> PUSH_BUTTONS :: PB_72
	Helios_Udp.Send("2073", string.format("%.1f", MainPanel:get_argument_value(925) ) ) -- Accelerometer Reset Button - Push to reset >> PUSH_BUTTONS :: PB_73
	Helios_Udp.Send("2074", string.format("%.1f", MainPanel:get_argument_value(200) ) ) -- Tactical Cargo Release Button - Push to release >> PUSH_BUTTONS :: PB_74
	Helios_Udp.Send("2075", string.format("%.1f", MainPanel:get_argument_value(198) ) ) -- Emergency Cargo Release Button - Push to release >> PUSH_BUTTONS :: PB_75
	Helios_Udp.Send("2076", string.format("%.1f", MainPanel:get_argument_value(284) ) ) -- Signal Flares Cassette 1 Launch Red Button >> PUSH_BUTTONS :: PB_76
	Helios_Udp.Send("2077", string.format("%.1f", MainPanel:get_argument_value(285) ) ) -- Signal Flares Cassette 1 Launch Green Button >> PUSH_BUTTONS :: PB_77
	Helios_Udp.Send("2078", string.format("%.1f", MainPanel:get_argument_value(286) ) ) -- Signal Flares Cassette 1 Launch Yellow Button >> PUSH_BUTTONS :: PB_78
	Helios_Udp.Send("2079", string.format("%.1f", MainPanel:get_argument_value(287) ) ) -- Signal Flares Cassette 1 Launch White Button >> PUSH_BUTTONS :: PB_79
	Helios_Udp.Send("2080", string.format("%.1f", MainPanel:get_argument_value(288) ) ) -- Signal Flares Cassette 2 Launch Red Button >> PUSH_BUTTONS :: PB_80
	Helios_Udp.Send("2081", string.format("%.1f", MainPanel:get_argument_value(289) ) ) -- Signal Flares Cassette 2 Launch Green Button >> PUSH_BUTTONS :: PB_81
	Helios_Udp.Send("2082", string.format("%.1f", MainPanel:get_argument_value(290) ) ) -- Signal Flares Cassette 2 Launch Yellow Button >> PUSH_BUTTONS :: PB_82
	Helios_Udp.Send("2083", string.format("%.1f", MainPanel:get_argument_value(291) ) ) -- Signal Flares Cassette 2 Launch White Button >> PUSH_BUTTONS :: PB_83
	Helios_Udp.Send("2084", string.format("%.1f", MainPanel:get_argument_value(464) ) ) -- KO-50 Heater Start Button - Push to start >> PUSH_BUTTONS :: PB_84
	Helios_Udp.Send("2085", string.format("%.1f", MainPanel:get_argument_value(297) ) ) -- IFF Transponder Erase Button - Push to erase >> PUSH_BUTTONS :: PB_85
	Helios_Udp.Send("2086", string.format("%.1f", MainPanel:get_argument_value(323) ) ) -- Alarm Bell Button - Push to turn on >> PUSH_BUTTONS :: PB_86
	Helios_Udp.Send("2087", string.format("%.1f", MainPanel:get_argument_value(134) ) ) -- Autopilot Heading ON Button >> PUSH_BUTTONS :: PB_87
	Helios_Udp.Send("2088", string.format("%.1f", MainPanel:get_argument_value(135) ) ) -- Autopilot Heading OFF Button >> PUSH_BUTTONS :: PB_88
	Helios_Udp.Send("2089", string.format("%.1f", MainPanel:get_argument_value(138) ) ) -- Autopilot Pitch/Roll ON Button >> PUSH_BUTTONS :: PB_89
	Helios_Udp.Send("2090", string.format("%.1f", MainPanel:get_argument_value(144) ) ) -- Autopilot Altitude ON Button >> PUSH_BUTTONS :: PB_90
	Helios_Udp.Send("2091", string.format("%.1f", MainPanel:get_argument_value(145) ) ) -- Autopilot Altitude OFF Button >> PUSH_BUTTONS :: PB_91
	Helios_Udp.Send("2092", string.format("%.1f", MainPanel:get_argument_value(127) ) ) --  SPUU-52 Control Engage Button 	127  >> PUSH_BUTTONS :: PB_92
	Helios_Udp.Send("2093", string.format("%.1f", MainPanel:get_argument_value(32) ) ) -- Radio Altimeter Test Button - Push to test >> PUSH_BUTTONS :: PB_93 
	Helios_Udp.Send("2094", string.format("%.1f", MainPanel:get_argument_value(59) ) ) -- Mech clock right lever >> PUSH_BUTTONS :: PB_94 
	-- 3 way switchs
	Helios_Udp.Send("5001", string.format("%1d", MainPanel:get_argument_value(541) ) ) -- 115V Inverter Switch, MANUAL/OFF/AUTO >> TREE_WAY_SWITCH :: 3WSwitch_A_1
	Helios_Udp.Send("5002", string.format("%1d", MainPanel:get_argument_value(542) ) ) -- 36V Inverter Switch, MANUAL/OFF/AUTO >> TREE_WAY_SWITCH :: 3WSwitch_A_2
	Helios_Udp.Send("5003", string.format("%1d", MainPanel:get_argument_value(149) ) ) -- 36V Transformer Switch, MAIN/OFF/AUXILIARY >> TREE_WAY_SWITCH :: 3WSwitch_A_3
	Helios_Udp.Send("5004", string.format("%1d", MainPanel:get_argument_value(412) ) ) -- APU Start Mode Switch, START/COLD CRANKING/FALSE START >> TREE_WAY_SWITCH :: 3WSwitch_A_4
	Helios_Udp.Send("5005", string.format("%1d", MainPanel:get_argument_value(422) ) ) -- Engine Selector Switch, LEFT/OFF/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_5
	Helios_Udp.Send("5006", string.format("%1d", MainPanel:get_argument_value(423) ) ) -- Engine Start Mode Switch, START/OFF/COLD CRANKING >> TREE_WAY_SWITCH :: 3WSwitch_A_6
	Helios_Udp.Send("5203", string.format("%0.1f", MainPanel:get_argument_value(437) ) ) -- Refueling Control Switch, REFUEL/OFF/CHECK >> TREE_WAY_SWITCH :: 3WSwitch_C_203
	Helios_Udp.Send("5008", string.format("%1d", MainPanel:get_argument_value(342) ) ) -- 8/16/4 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_8
	Helios_Udp.Send("5009", string.format("%1d", MainPanel:get_argument_value(343) ) ) -- 1-2-5-6/AUTO/3-4 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_9
	Helios_Udp.Send("5010", string.format("%1d", MainPanel:get_argument_value(344) ) ) -- UPK/PKT/RS Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_10
	Helios_Udp.Send("5011", string.format("%1d", MainPanel:get_argument_value(345) ) ) -- CUTOFF Switch, ON/OFF >> TREE_WAY_SWITCH :: 3WSwitch_A_11
	Helios_Udp.Send("5012", string.format("%1d", MainPanel:get_argument_value(150) ) ) -- Check Switch, LAMPS/OFF/FLASHER >> TREE_WAY_SWITCH :: 3WSwitch_A_12
	Helios_Udp.Send("5013", string.format("%1d", MainPanel:get_argument_value(472) ) ) -- GMC Mode Switch, MC/DG/AC(N/F) >> TREE_WAY_SWITCH :: 3WSwitch_A_13
	Helios_Udp.Send("5014", string.format("%1d", MainPanel:get_argument_value(837) ) ) -- Left Landing Light Switch, LIGHT/OFF/RETRACT >> TREE_WAY_SWITCH :: 3WSwitch_A_14
	Helios_Udp.Send("5015", string.format("%1d", MainPanel:get_argument_value(838) ) ) -- Right Landing Light Switch, LIGHT/OFF/RETRACT >> TREE_WAY_SWITCH :: 3WSwitch_A_15
	Helios_Udp.Send("5016", string.format("%1d", MainPanel:get_argument_value(513) ) ) -- ANO Switch, BRIGHT/OFF/DIM >> TREE_WAY_SWITCH :: 3WSwitch_A_16
	Helios_Udp.Send("5017", string.format("%1d", MainPanel:get_argument_value(514) ) ) -- Formation Lights Switch, BRIGHT/OFF/DIM >> TREE_WAY_SWITCH :: 3WSwitch_A_17
	Helios_Udp.Send("5018", string.format("%1d", MainPanel:get_argument_value(333) ) ) -- Left Ceiling Light Switch, RED/OFF/WHITE >> TREE_WAY_SWITCH :: 3WSwitch_A_18
	Helios_Udp.Send("5019", string.format("%1d", MainPanel:get_argument_value(489) ) ) -- Right Ceiling Light Switch, RED/OFF/WHITE >> TREE_WAY_SWITCH :: 3WSwitch_A_19
	Helios_Udp.Send("6116", string.format("%.2f", MainPanel:get_argument_value(370) ) ) -- R-863, Radio Channel Selector Knob >>  axis B116		
	Helios_Udp.Send("5202", string.format("%0.1f", MainPanel:get_argument_value(859) ) ) -- CMD Board Flares Dispensers Switch, LEFT/BOTH/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_C_201
	Helios_Udp.Send("5023", string.format("%1d", MainPanel:get_argument_value(465) ) ) -- KO-50 Heater Mode Switch, MANUAL/OFF/AUTO >> TREE_WAY_SWITCH :: 3WSwitch_A_23
	Helios_Udp.Send("5024", string.format("%1d", MainPanel:get_argument_value(466) ) ) -- KO-50 Heater Regime Switch, FILLING/FULL/MEDIUM >> TREE_WAY_SWITCH :: 3WSwitch_A_24
	Helios_Udp.Send("5025", string.format("%1d", MainPanel:get_argument_value(425) ) ) -- Engine Ignition Check Switch, LEFT/OFF/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_25
	--Helios_Udp.Send("5026", string.format("%1d", MainPanel:get_argument_value(202) ) ) -- Readjust Free Turbine RPM Switch, MORE/OFF/LESS >> TREE_WAY_SWITCH :: 3WSwitch_A_26
	Helios_Udp.Send("5027", string.format("%1d", MainPanel:get_argument_value(867) ) ) -- Readjust Free Turbine RPM Switch, MORE/OFF/LESS >> TREE_WAY_SWITCH :: 3WSwitch_A_27
	Helios_Udp.Send("5028", string.format("%1d", MainPanel:get_argument_value(169) ) ) -- Left Engine FT Check Switch, ST1/WORK/ST2 >> TREE_WAY_SWITCH :: 3WSwitch_A_28
	Helios_Udp.Send("5029", string.format("%1d", MainPanel:get_argument_value(171) ) ) -- Right Engine FT Check Switch, ST1/WORK/ST2 >> TREE_WAY_SWITCH :: 3WSwitch_A_29
	Helios_Udp.Send("5030", string.format("%1d", MainPanel:get_argument_value(170) ) ) -- CT Check Switch, RIGHT/WORK/LEFT >> TREE_WAY_SWITCH :: 3WSwitch_A_30
	Helios_Udp.Send("5031", string.format("%1d", MainPanel:get_argument_value(476) ) ) -- GMC Control Switch, 0/CONTROL/300 >> TREE_WAY_SWITCH :: 3WSwitch_A_31
	Helios_Udp.Send("5032", string.format("%1d", MainPanel:get_argument_value(477) ) ) -- GMC Course Setting Switch, CCW/OFF/CW) >> TREE_WAY_SWITCH :: 3WSwitch_A_32
	Helios_Udp.Send("5033", string.format("%1d", MainPanel:get_argument_value(447) ) ) -- ARC-9, Loop Control Switch, LEFT/OFF/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_33

	-- axis
	Helios_Udp.Send("6010", string.format("%0.2f", MainPanel:get_argument_value(498) ) ) -- Standby Generator Voltage Adjustment Rheostat >> AXIS :: Axis_A_10
	Helios_Udp.Send("6011", string.format("%0.2f", MainPanel:get_argument_value(536) ) ) -- Generator 1 Voltage Adjustment Rheostat >> AXIS :: Axis_A_11
	Helios_Udp.Send("6012", string.format("%0.2f", MainPanel:get_argument_value(537) ) ) -- Generator 2 Voltage Adjustment Rheostat >> AXIS :: Axis_A_12
	--Helios_Udp.Send("6013", string.format("%0.2f", MainPanel:get_argument_value(0) ) ) -- Left Engine Throttle >> AXIS :: Axis_A_13
	--Helios_Udp.Send("6014", string.format("%0.2f", MainPanel:get_argument_value(0) ) ) -- Right Engine Throttle >> AXIS :: Axis_A_14
	Helios_Udp.Send("6015", string.format("%0.2f", MainPanel:get_argument_value(346) ) ) -- Burst Length Knob >> AXIS :: Axis_A_15
	Helios_Udp.Send("6016", string.format("%0.2f", MainPanel:get_argument_value(89) ) ) -- Right Attitude Indicator Zero Pitch Knob >> AXIS :: Axis_A_16 / TSwicth 9
	Helios_Udp.Send("6017", string.format("%0.2f", MainPanel:get_argument_value(10) ) ) -- Left Attitude Indicator Zero Pitch Knob >> AXIS :: Axis_A_17 / TSwicth 10
	Helios_Udp.Send("6102", string.format("%0.2f", MainPanel:get_argument_value(474) ) ) -- GMC Latitude Selection Knob >> AXIS :: Axis_B_102
	Helios_Udp.Send("6018", string.format("%0.2f", MainPanel:get_argument_value(280) ) ) -- Left Red Lights Brightness Group 1 Rheostat >> AXIS :: Axis_A_18
	Helios_Udp.Send("6019", string.format("%0.2f", MainPanel:get_argument_value(281) ) ) -- Left Red Lights Brightness Group 2 Rheostat >> AXIS :: Axis_A_19
	Helios_Udp.Send("6020", string.format("%0.2f", MainPanel:get_argument_value(491) ) ) -- Right Red Lights Brightness Group 1 Rheostat >> AXIS :: Axis_A_20
	Helios_Udp.Send("6021", string.format("%0.2f", MainPanel:get_argument_value(492) ) ) -- Right Red Lights Brightness Group 2 Rheostat >> AXIS :: Axis_A_21
	Helios_Udp.Send("6022", string.format("%0.2f", MainPanel:get_argument_value(894) ) ) -- Central Red Lights Brightness Group 1 Rheostat >> AXIS :: Axis_A_22
	Helios_Udp.Send("6023", string.format("%0.2f", MainPanel:get_argument_value(895) ) ) -- Central Red Lights Brightness Group 2 Rheostat >> AXIS :: Axis_A_23
	Helios_Udp.Send("6024", string.format("%0.2f", MainPanel:get_argument_value(924) ) ) -- 5.5V Lights Brightness Rheostat >> AXIS :: Axis_A_24
	Helios_Udp.Send("6103", string.format("%0.2f", MainPanel:get_argument_value(549) ) ) -- Common Volume Knob >> AXIS :: Axis_B_103
	Helios_Udp.Send("6104", string.format("%0.2f", MainPanel:get_argument_value(548) ) ) -- Listening Volume Knob >> AXIS :: Axis_B_104
	Helios_Udp.Send("6105", string.format("%0.2f", MainPanel:get_argument_value(841) ) ) -- Common Volume Knob >> AXIS :: Axis_B_105
	Helios_Udp.Send("6106", string.format("%0.2f", MainPanel:get_argument_value(840) ) ) -- Listening Volume Knob >> AXIS :: Axis_B_106
	Helios_Udp.Send("6107", string.format("%0.2f", MainPanel:get_argument_value(156) ) ) -- R-863, Volume Knob >> AXIS :: Axis_B_107
	Helios_Udp.Send("6108", string.format("%0.2f", MainPanel:get_argument_value(737) ) ) -- R-828, Volume Knob >> AXIS :: Axis_B_108
	Helios_Udp.Send("6109", string.format("%0.2f", MainPanel:get_argument_value(743) ) ) -- Jadro 1A, Volume Knob >> AXIS :: Axis_B_109
	Helios_Udp.Send("6110", string.format("%0.2f", MainPanel:get_argument_value(455) ) ) -- ARC-UD, Volume Knob >> AXIS :: Axis_B_110
	Helios_Udp.Send("6025", string.format("%0.2f", MainPanel:get_argument_value(589) ) ) -- Sight Brightness Knob >> AXIS :: Axis_A_25
	--Helios_Udp.Send("6026", string.format("%0.2f", MainPanel:get_argument_value(855) ) ) -- Sight Limb Knob >> AXIS :: Axis_A_26
	Helios_Udp.Send("6111", string.format("%0.2f", MainPanel:get_argument_value(448) ) ) -- ARC-9, Volume Knob >> AXIS :: Axis_B_111
	Helios_Udp.Send("6112", string.format("%0.2f", MainPanel:get_argument_value(449) ) ) -- ARC-9, Backup Frequency Tune Knob >> AXIS :: Axis_B_112
	Helios_Udp.Send("6113", string.format("%0.2f", MainPanel:get_argument_value(451) ) ) -- ARC-9, Main Frequency Tune Knob >> AXIS :: Axis_B_113
	Helios_Udp.Send("6114", string.format("%0.2f", MainPanel:get_argument_value(468) ) ) -- KO-50 Target Temperature Knob >> AXIS :: Axis_B_114
	Helios_Udp.Send("6027", string.format("%0.2f", MainPanel:get_argument_value(308) ) ) -- Recorder P-503B Backlight Brightness Knob >> AXIS :: Axis_A_27
	Helios_Udp.Send("6028", string.format("%0.2f", MainPanel:get_argument_value(675) ) ) -- ARC-9, Backup 100kHz Rotary Knob>>  AXIS  :: Axis_A_28
	Helios_Udp.Send("6029", string.format("%0.2f", MainPanel:get_argument_value(450) ) ) -- ARC-9, Backup 10kHz Rotary Knob>>  AXIS  :: Axis_A_29
	Helios_Udp.Send("6030", string.format("%0.2f", MainPanel:get_argument_value(678) ) ) -- ARC-9, Main 100kHz Rotary Knob >>  AXIS  :: Axis_A_30
	Helios_Udp.Send("6031", string.format("%0.2f", MainPanel:get_argument_value(452) ) ) --ARC-9, Main 10kHz Rotary Knob >>  AXIS  :: Axis_A_31
	Helios_Udp.Send("6032", string.format("%0.2f", MainPanel:get_argument_value(60) ) ) -- Mech clock right lever >>  AXIS  :: Axis_A_32
	-- multi pos switch
	Helios_Udp.Send("6101", string.format("%0.2f", MainPanel:get_argument_value(128) ) ) -- SPUU-52 Adjustment Knob >> AXIS :: Axis_B_101
	Helios_Udp.Send("7051", string.format("%0.1f", MainPanel:get_argument_value(535) ) ) -- AC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_51
	Helios_Udp.Send("7052", string.format("%0.1f", MainPanel:get_argument_value(494) ) ) -- DC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_52
	Helios_Udp.Send("7001", string.format("%0.1f", MainPanel:get_argument_value(61) ) ) -- Fuel Meter Switch, OFF/SUM/LEFT/RIGHT/FEED/ADDITIONAL >> MULTI_POS_SWITCH :: Multi6PosSwitch_1
	Helios_Udp.Send("7002", string.format("%0.1f", MainPanel:get_argument_value(719) ) ) -- Pod Variants Selector Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_2
	Helios_Udp.Send("6115", string.format("%0.2f", MainPanel:get_argument_value(730) ) ) -- ESBR Position Selector Switch >> AXIS :: Axis_B_115
	Helios_Udp.Send("7053", string.format("%0.1f", MainPanel:get_argument_value(401) ) ) -- Check Fire Circuits Switch, OFF/CONTROL/1/2/3/4/5/6 >> MULTI_POS_SWITCH :: Multi11PosSwitch_53
	Helios_Udp.Send("7054", string.format("%0.1f", MainPanel:get_argument_value(372) ) ) -- Defrost System Amperemeter Selector Switch >> MULTI_POS_SWITCH :: Multi11PosSwitch_54
	Helios_Udp.Send("7055", string.format("%0.1f", MainPanel:get_argument_value(735) ) ) -- R-828, Radio Channel Selector Knob >> MULTI_POS_SWITCH :: Multi11PosSwitch_55
	Helios_Udp.Send("7003", string.format("%0.1f", MainPanel:get_argument_value(826) ) ) -- Doppler Navigator Mode Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_3
	Helios_Udp.Send("7004", string.format("%0.1f", MainPanel:get_argument_value(550) ) ) -- Radio Source Selector Switch, R-863/JADRO-1A/R-828/NF/ARC-9/ARC-UD >> MULTI_POS_SWITCH :: Multi6PosSwitch_4
	Helios_Udp.Send("7005", string.format("%0.1f", MainPanel:get_argument_value(842) ) ) -- Radio Source Selector Switch, R-863/JADRO-1A/R-828/NF/ARC-9/ARC-UD >> MULTI_POS_SWITCH :: Multi6PosSwitch_5

	Helios_Udp.Send("3014", string.format("%1d", math.floor( (MainPanel:get_argument_value(741)+0.5)))) -- Jadro 1A, Squelch Switch >> TOGLEE_SWITCH :: TSwitch_14
	Helios_Udp.Send("5201", string.format("%0.1f", MainPanel:get_argument_value(744) ) ) -- Jadro 1A, Mode Switch, OFF/OM/AM") , >> TREE_WAY_SWITCH :: 3WSwitch_C_201
	Helios_Udp.Send("7006", string.format("%0.1f", MainPanel:get_argument_value(456) ) ) -- ARC-UD, Mode Switch, OFF/NARROW/WIDE/PULSE/RC >> MULTI_POS_SWITCH :: Multi6PosSwitch_6
	Helios_Udp.Send("7007", string.format("%0.1f", MainPanel:get_argument_value(457) ) ) -- ARC-UD, Channel Selector Switch, 1/2/3/4/5/6 >> MULTI_POS_SWITCH :: Multi6PosSwitch_7
	Helios_Udp.Send("7008", string.format("%0.1f", MainPanel:get_argument_value(446) ) ) -- ARC-9, Mode Selector Switch, OFF/COMP/ANT/LOOP >> MULTI_POS_SWITCH :: Multi6PosSwitch_8
	Helios_Udp.Send("5101", string.format("%0.1f", MainPanel:get_argument_value(839) ) ) -- Static Pressure System Mode Selector, LEFT/COMMON/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_B_101
	Helios_Udp.Send("7009", string.format("%0.1f", math.floor((MainPanel:get_argument_value(304)*10)+ 0.5)/10 ) ) -- IFF Transponder Mode Selector Switch, AUTO/KD/+-15/KP >> MULTI_POS_SWITCH :: Multi6PosSwitch_9
	Helios_Udp.Send("7010", string.format("%0.1f", MainPanel:get_argument_value(347) ) ) -- In800Out/800inOr624/622 Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_10
	Helios_Udp.Send("7011", string.format("%0.1f", MainPanel:get_argument_value(350) ) ) -- Left PYROCARTRIDGE Switch, I/II/III >> MULTI_POS_SWITCH :: Multi6PosSwitch_11
	Helios_Udp.Send("7012", string.format("%0.1f", MainPanel:get_argument_value(351) ) ) -- Right PYROCARTRIDGE Switch, I/II/III >> MULTI_POS_SWITCH :: Multi6PosSwitch_12
	Helios_Udp.Send("7013", string.format("%0.1f", MainPanel:get_argument_value(331) ) ) -- Left Windscreen Wiper Control Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_13
	Helios_Udp.Send("7014", string.format("%0.1f", MainPanel:get_argument_value(478) ) ) -- Right Windscreen Wiper Control Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_14
	Helios_Udp.Send("4001", string.format("%1d", MainPanel:get_argument_value(163) ) ) -- R-863, 10MHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_1
	Helios_Udp.Send("4002", string.format("%1d", MainPanel:get_argument_value(164) ) ) -- R-863, 1MHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_2
	Helios_Udp.Send("4003", string.format("%1d", MainPanel:get_argument_value(165) ) ) -- R-863, 100kHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_3
	Helios_Udp.Send("4004", string.format("%1d", MainPanel:get_argument_value(166) ) ) -- R-863, 1kHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_4

	--rockers
	Helios_Udp.Send("8101", string.format("%1d", MainPanel:get_argument_value(129) ) ) -- SPUU-52 Test Switch, P/OFF/t >> ROCKER_AABB :: Rocker_C_101
	Helios_Udp.Send("8102", string.format("%1d", MainPanel:get_argument_value(146) ) ) -- Autopilot Altitude Channel Control (Right Button - UP; Left Button - Down)>> ROCKER_AABB :: Rocker_C_102
	Helios_Udp.Send("8051", string.format("%1d", MainPanel:get_argument_value(57) ) ) -- -- Mech clock left lever button 1 >> ROCKER_ABAB :: Rocker_B_51
				
	Helios_Udp.Flush()
end





function Helios_MI8.ProcessInput(data)
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
		lConvDevice = Helios_MI8.ExportArguments[sIndex] 	
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

function Helios_MI8.Get_UV26()
	local li = Helios_Util.GetListIndicator(4)  -- use 5 in DCS1.5     use 4 DCSin 1.5.4
	if not li then return "   " end
	if not li.txt_digits then return "   " end
	return li.txt_digits
end

-- Format: device,button number, multiplier
-- arguments with multiplier >100  are special conversion cases, and are computed in different way

--                      Extended       	MI8

--toggle_switches:
Helios_MI8.ExportArguments["2,3001"] ="1, 3001,1" -- Standby Generator Switch, ON/OFF 	         497
Helios_MI8.ExportArguments["2,3002"] ="1, 3002,1" -- Battery 2 Switch, ON/OFF 			         496
Helios_MI8.ExportArguments["2,3003"] ="1, 3003,1" -- Battery 1 Switch, ON/OFF 			         495
Helios_MI8.ExportArguments["2,3004"] ="1, 3004,1" -- DC Ground Power Switch, ON/OFF 		     502
Helios_MI8.ExportArguments["2,3005"] ="1, 3005,1" -- Rectifier 2 Switch, ON/OFF			     500
Helios_MI8.ExportArguments["2,3006"] ="1, 3006,1" -- Rectifier 3 Switch, ON/OFF, 			     501
Helios_MI8.ExportArguments["2,3007"] ="1, 3007,1" -- Rectifier 1 Switch, ON/OFF 			     499
Helios_MI8.ExportArguments["2,3008"] ="1, 3009,1" -- Equipment Test Switch, ON/OFF 		     503
Helios_MI8.ExportArguments["2,3009"] ="1, 3014,1" -- AC Ground Power Switch, ON/OFF		     540
Helios_MI8.ExportArguments["2,3010"] ="1, 3015,1" -- Generator 1 Switch, ON/OFF 			     538
Helios_MI8.ExportArguments["2,3011"] ="1, 3016,1" -- Generator 2 Switch, ON/OFF 			     539
Helios_MI8.ExportArguments["2,3012"] ="1, 3019,1" -- Net on Rectifier Switch, ON/OFF 		     148
Helios_MI8.ExportArguments["2,3013"] ="1, 3021,1" -- Net on Rectifier Switch Cover, OPEN/CLOSE  147
Helios_MI8.ExportArguments["2,3031"] ="1, 3031,1" -- CB BW ESBR, ON/OFF			             		590
Helios_MI8.ExportArguments["2,3032"] ="1, 3032,1" -- CB Explode, ON/OFF			             		591
Helios_MI8.ExportArguments["2,3033"] ="1, 3033,1" -- CB Control, ON/OFF_mi8		             		592
Helios_MI8.ExportArguments["2,3034"] ="1, 3034,1" -- CB Equipment, ON/OFF		                 		593
Helios_MI8.ExportArguments["2,3035"] ="1, 3035,1" -- CB RS/GUV Fire, ON/OFF		             		594
Helios_MI8.ExportArguments["2,3036"] ="1, 3036,1" -- CB RS/GUV Warning, ON/OFF	                 		595
Helios_MI8.ExportArguments["2,3037"] ="1, 3037,1" -- CB ESBR Heating, ON/OFF		             		596
Helios_MI8.ExportArguments["2,3038"] ="1, 3038,1" -- CB 311, ON/OFF						     		597
Helios_MI8.ExportArguments["2,3039"] ="1, 3039,1" -- CB GUV: Outer 800 Left, ON/OFF		     		598
Helios_MI8.ExportArguments["2,3040"] ="1, 3040,1" -- CB GUV: Outer 800 Right, ON/OFF		     		599
Helios_MI8.ExportArguments["2,3041"] ="1, 3041,1" -- CB GUV: Inner Left 622 Left, ON/OFF	     		600
Helios_MI8.ExportArguments["2,3042"] ="1, 3042,1" -- CB GUV: Inner Left 622 Right, ON/OFF       		601
Helios_MI8.ExportArguments["2,3043"] ="1, 3043,1" -- CB GUV: Inner Right 622 Left, ON/OFF       		602
Helios_MI8.ExportArguments["2,3044"] ="1, 3044,1" -- CB GUV: Inner Right 622 Right, ON/OFF      		603
Helios_MI8.ExportArguments["2,3045"] ="1, 3045,1" -- CB Electric Launch 800 Left, ON/OFF	        	604
Helios_MI8.ExportArguments["2,3046"] ="1, 3046,1" -- CB Electric Launch 800 Right, ON/OFF          	605
Helios_MI8.ExportArguments["2,3047"] ="1, 3047,1" -- CB PKT, ON/OFF						        	606
Helios_MI8.ExportArguments["2,3048"] ="1, 3048,1" -- CB Emergency Jettison: Bombs and GUV, ON/OFF  	607
Helios_MI8.ExportArguments["2,3049"] ="1, 3049,1" -- CB Emergency Jettison: Power, ON/OFF		    	608
Helios_MI8.ExportArguments["2,3050"] ="1, 3050,1" -- CB Emergency Jettison: Armed, ON/OFF		    	609
Helios_MI8.ExportArguments["2,3051"] ="1, 3051,1" -- CB Signal Flare, ON/OFF							610
Helios_MI8.ExportArguments["2,3052"] ="1, 3052,1" -- CB APU Start, ON/OFF						    	611
Helios_MI8.ExportArguments["2,3053"] ="1, 3053,1" -- CB APU Ignition, ON/OFF					    	612
Helios_MI8.ExportArguments["2,3054"] ="1, 3054,1" -- CB Engine Start, ON/OFF					    	613
Helios_MI8.ExportArguments["2,3055"] ="1, 3055,1" -- CB Engine Ignition, ON/OFF				    	614
Helios_MI8.ExportArguments["2,3056"] ="1, 3056,1" -- CB RPM CONTROL, ON/OFF					    	615
Helios_MI8.ExportArguments["2,3057"] ="1, 3057,1" -- CB NONAME, ON/OFF						        	616
Helios_MI8.ExportArguments["2,3058"] ="1, 3058,1" -- CB Lock Opening Control Main, ON/OFF	        	617
Helios_MI8.ExportArguments["2,3059"] ="1, 3059,1" -- CB Lock Opening Control Reserve, ON/OFF	    	618
Helios_MI8.ExportArguments["2,3060"] ="1, 3060,1" -- CB TURN INDICATOR, ON/OFF,				    	619
Helios_MI8.ExportArguments["2,3061"] ="1, 3061,1" -- CB Autopilot: Main, ON/OFF				        620
Helios_MI8.ExportArguments["2,3062"] ="1, 3062,1" -- CB Autopilot: Friction, ON/OFF			        621
Helios_MI8.ExportArguments["2,3063"] ="1, 3063,1" -- CB Autopilot: Electric Clutches, ON/OFF		    622
Helios_MI8.ExportArguments["2,3064"] ="1, 3064,1" -- CB Hydraulics: Main, ON/OFF					    623
Helios_MI8.ExportArguments["2,3065"] ="1, 3065,1" -- CB Hydraulics: Auxiliary, ON/OFF			        624
Helios_MI8.ExportArguments["2,3066"] ="1, 3066,1" -- CB Radio: SPU (Intercom), ON/OFF				    625
Helios_MI8.ExportArguments["2,3067"] ="1, 3067,1" -- CB Radio: Altimeter, ON/OFF						626
Helios_MI8.ExportArguments["2,3068"] ="1, 3068,1" -- CB Radio: Command Radio Station (R-863), ON/OFF	627
Helios_MI8.ExportArguments["2,3069"] ="1, 3069,1" -- CB Radio: 6201, ON/OFF							628
Helios_MI8.ExportArguments["2,3070"] ="1, 3070,1" -- CB Fuel System: Bypass Valve, ON/OFF	            629
Helios_MI8.ExportArguments["2,3071"] ="1, 3071,1" -- CB Fuel System: Left Valve, ON/OFF		        630
Helios_MI8.ExportArguments["2,3072"] ="1, 3072,1" -- CB Fuel System: Right Valve, ON/OFF		        631
Helios_MI8.ExportArguments["2,3073"] ="1, 3073,1" -- CB Fuel System: Fuelmeter, ON/OFF		            632
Helios_MI8.ExportArguments["2,3074"] ="1, 3074,1" -- CB Fuel System: Center Tank Pump, ON/OFF          633
Helios_MI8.ExportArguments["2,3075"] ="1, 3075,1" -- CB Fuel System: Left Tank Pump, ON/OFF	        634
Helios_MI8.ExportArguments["2,3076"] ="1, 3076,1" -- CB Fuel System: Right Tank Pump, ON/OFF	        635
Helios_MI8.ExportArguments["2,3077"] ="1, 3077,1" -- CB T-819, ON/OFF,						            636
Helios_MI8.ExportArguments["2,3078"] ="1, 3078,1" -- CB SPUU-52, ON/OFF						        637
Helios_MI8.ExportArguments["2,3079"] ="1, 3079,1" -- CB Fire Protection System: Signalization, ON/OFF	638
Helios_MI8.ExportArguments["2,3080"] ="1, 3080,1" -- CB Fire Protection System: 1 Queue Left, ON/OFF	639
Helios_MI8.ExportArguments["2,3081"] ="1, 3081,1" -- CB Fire Protection System: 1 Queue Right, ON/OFF	640
Helios_MI8.ExportArguments["2,3082"] ="1, 3082,1" -- CB Fire Protection System: 2 Queue Left, ON/OFF   641
Helios_MI8.ExportArguments["2,3083"] ="1, 3083,1" -- CB Fire Protection System: 2 Queue Right, ON/OFF	642
Helios_MI8.ExportArguments["2,3084"] ="1, 3084,1" -- CB Radio: Radio Compass MW(ARC-9), ON/OFF		    643
Helios_MI8.ExportArguments["2,3085"] ="1, 3085,1" -- CB Radio: Radio Compass VHF(ARC-UD), ON/OFF		644
Helios_MI8.ExportArguments["2,3086"] ="1, 3086,1" -- CB Radio: Doppler Navigator, ON/OFF				645
Helios_MI8.ExportArguments["2,3087"] ="1, 3087,1" -- CB Radio: Radio Meter, ON/OFF					    646
Helios_MI8.ExportArguments["2,3088"] ="1, 3088,1" -- CB Headlights: Left: Control, ON/OFF	            647
Helios_MI8.ExportArguments["2,3089"] ="1, 3089,1" -- CB Headlights: Left: Light, ON/OFF	            648
Helios_MI8.ExportArguments["2,3090"] ="1, 3090,1" -- CB Headlights: Right: Control, ON/OFF             649
Helios_MI8.ExportArguments["2,3091"] ="1, 3091,1" -- CB Headlights: Right: Light, ON/OFF               650
Helios_MI8.ExportArguments["2,3092"] ="1, 3092,1" -- CB ANO, ON/OFF						            651
Helios_MI8.ExportArguments["2,3093"] ="1, 3093,1" -- CB Wing Lights, ON/OFF				            652
Helios_MI8.ExportArguments["2,3094"] ="1, 3094,1" -- CB Check Lamps/Flasher, ON/OFF		            653
Helios_MI8.ExportArguments["2,3095"] ="1, 3095,1" -- CB PRF-4 Light Left, ON/OFF		                918
Helios_MI8.ExportArguments["2,3096"] ="1, 3096,1" -- CB PRF-4 Light Right, ON/OFF			            919
Helios_MI8.ExportArguments["2,3097"] ="1, 3097,1" -- CB Defrost System: Control, ON/OFF	            656
Helios_MI8.ExportArguments["2,3098"] ="1, 3098,1" -- CB Defrost System: Left Engine, ON/OFF            657
Helios_MI8.ExportArguments["2,3099"] ="1, 3099,1" -- CB Defrost System: Right Engine, ON/OFF           658
Helios_MI8.ExportArguments["2,3100"] ="1, 3100,1" -- CB Defrost System: RIO-3, ON/OFF		            659
Helios_MI8.ExportArguments["2,3101"] ="1, 3101,1" -- CB Defrost System: Glass, ON/OFF		            660
Helios_MI8.ExportArguments["2,3102"] ="1, 3102,1" -- CB Wiper Left, ON/OFF,				            661
Helios_MI8.ExportArguments["2,3103"] ="1, 3103,1" -- CB Wiper Right, ON/OFF				            662
Helios_MI8.ExportArguments["2,3104"] ="1, 3104,1" -- CB RIO-3, ON/OFF						            663
Helios_MI8.ExportArguments["2,3105"] ="1, 3105,1" -- CB Heater KO-50, ON/OFF                           664
Helios_MI8.ExportArguments["2,3106"] ="1, 3106,1" -- Battery Heating Switch, ON/OFF 		522
Helios_MI8.ExportArguments["2,3107"] ="2, 3006,1" --  Feed Tank Pump Switch, ON/OFF				 438
Helios_MI8.ExportArguments["2,3108"] ="2, 3003,1" --  Left Tank Pump Switch, ON/OFF				 439
Helios_MI8.ExportArguments["2,3109"] ="2, 3005,1" --  Right Tank Pump Switch, ON/OFF				 440
Helios_MI8.ExportArguments["2,3110"] ="2, 3001,1" --  Left Shutoff Valve Switch, ON/OFF			 427
Helios_MI8.ExportArguments["2,3111"] ="2, 3002,1" --  Right Shutoff Valve Switch, ON/OFF			 429
Helios_MI8.ExportArguments["2,3112"] ="2, 3009,1" --  Left Shutoff Valve Switch Cover, OPEN/CLOSE	 426
Helios_MI8.ExportArguments["2,3113"] ="2, 3010,1" --  Right Shutoff Valve Switch Cover, OPEN/CLOSE	 428
Helios_MI8.ExportArguments["2,3114"] ="2, 3004,1" --  Crossfeed Switch, ON/OFF						 431
Helios_MI8.ExportArguments["2,3115"] ="2, 3011,1" --  Crossfeed Switch Cover, OPEN/CLOSE			 430
Helios_MI8.ExportArguments["2,3116"] ="2, 3007,1" --  Bypass Switch, ON/OFF					     433
Helios_MI8.ExportArguments["2,3117"] ="2, 3012,1" --  Bypass Switch Cover, OPEN/CLOSE				 432
Helios_MI8.ExportArguments["2,3118"] ="3, 3009,1" --  Left Engine Stop Lever			 204
Helios_MI8.ExportArguments["2,3119"] ="3, 3010,1" --  Right Engine Stop Lever 		     206
Helios_MI8.ExportArguments["2,3120"] ="3, 3011,1" --  Rotor Brake Handle, UP/DOWN		 208
Helios_MI8.ExportArguments["2,3121"] ="3, 3001,1" --  Left Engine EEC Switch, ON/OFF		 167
Helios_MI8.ExportArguments["2,3122"] ="3, 3003,1" --  Right Engine EEC Switch, ON/OFF		 173
Helios_MI8.ExportArguments["2,3123"] ="3, 3052,1" --  Left Engine ER Switch, ON/OFF	     168
Helios_MI8.ExportArguments["2,3124"] ="3, 3053,1" --  Right Engine ER Switch, ON/OFF		 172
Helios_MI8.ExportArguments["2,3125"] ="4, 3001,1" --  Main Hydraulic Switch, ON/OFF 				 406
Helios_MI8.ExportArguments["2,3126"] ="4, 3002,1" --  Auxiliary Hydraulic Switch, ON/OFF 		     410
Helios_MI8.ExportArguments["2,3127"] ="4, 3006,1" --  Auxiliary Hydraulic Switch Cover, OPEN/CLOSE	 409
Helios_MI8.ExportArguments["2,3128"] ="18, 3003,1" --  Radar Altimeter Power Switch, ON/OFF	 35
Helios_MI8.ExportArguments["2,3129"] ="34, 3003,1" --  HSI Radio Compass Selector Switch, ARC-9/ARC-UD	 858
Helios_MI8.ExportArguments["2,3130"] ="12, 3027,1" --  Weapon Safe/Armed Switch, ON/OFF 				921
Helios_MI8.ExportArguments["2,3131"] ="12, 3007,1" --  Emergency Explode Switch, ON/OFF 				707
Helios_MI8.ExportArguments["2,3132"] ="12, 3049,1" --  Emergency Explode Switch Cover, OPEN/CLOSE 		706
Helios_MI8.ExportArguments["2,3133"] ="12, 3050,1" --  Emergency Bomb Release Switch Cover, OPEN/CLOSE 708
Helios_MI8.ExportArguments["2,3134"] ="12, 3002,1" --  Main Bombs Switch, ON/OFF 						717
Helios_MI8.ExportArguments["2,3135"] ="12, 3012,1" --  ESBR Heating Switch, ON/OFF 					720
Helios_MI8.ExportArguments["2,3136"] ="12, 3028,1" --  ESBR Switch, ON/OFF 							731
Helios_MI8.ExportArguments["2,3137"] ="12, 3004,1" --  Emergency Explode Switch, ON/OFF 		main		570
Helios_MI8.ExportArguments["2,3138"] ="12, 3051,1" --  Emergency Explode Switch Cover, OPEN/CLOSE 	main	569
Helios_MI8.ExportArguments["2,3139"] ="12, 3052,1" --  Emergency Release Switch Cover, OPEN/CLOSE 	main	571
Helios_MI8.ExportArguments["2,3140"] ="12, 3030,1" --  RS/GUV Selector Switch, ON/OFF 					575
Helios_MI8.ExportArguments["2,3141"] ="12, 3041,1" --  800_or_624_622_800 Switch 						349
Helios_MI8.ExportArguments["2,3142"] ="12, 3053,1" --  800 or 624_622_800 Switch Cover, OPEN/CLOSE 	348
Helios_MI8.ExportArguments["2,3143"] ="12, 3076,1" --  Mine Arms Main Switch, ON/OFF 					573
Helios_MI8.ExportArguments["2,3144"] ="12, 3077,1" --  PKT Selector Switch, FLIGHT ENGINEER/PILOT 		905
--Helios_MI8.ExportArguments["2,3145"] ="12, 3084,1" --  Left Fire RS Button Cover, OPEN/CLOSE 			185
--Helios_MI8.ExportArguments["2,3146"] ="12, 3085,1" --  Right Fire RS Button Cover, OPEN/CLOSE 			228
Helios_MI8.ExportArguments["2,3147"] ="12, 3098,1" --  Gun Camera Switch, ON/OFF 						352
Helios_MI8.ExportArguments["2,3148"] ="21, 3005,1" --  Flasher Switch, ON/OFF 			523
Helios_MI8.ExportArguments["2,3149"] ="21, 3006,1" --  Transparent Switch, DAY/NIGHT 	525
Helios_MI8.ExportArguments["2,3150"] ="8, 3005,1" 	--  SPUU-52 Power Switch, ON/OFF 	332
--Helios_MI8.ExportArguments["2,3151"] ="8, 3001,1" 	--  DISPONIBLE
Helios_MI8.ExportArguments["2,3152"] ="19, 3010,1" --  Fire Detector Test Switch 		399
Helios_MI8.ExportArguments["2,3153"] ="19, 3011,1" --  Squib Test Switch 				400
Helios_MI8.ExportArguments["2,3154"] ="3, 3030,1" --  Defrost Mode Switch, AUTO/MANUAL 		353
Helios_MI8.ExportArguments["2,3155"] ="3, 3032,1" --  Left Engine Heater Switch, ON/OFF 		523
Helios_MI8.ExportArguments["2,3156"] ="3, 3033,1" --  Right Engine Heater Switch, MANUAL/AUTO 	356
Helios_MI8.ExportArguments["2,3157"] ="3, 3034,1" --  Glass Heater Switch, MANUAL/AUTO 		357
Helios_MI8.ExportArguments["2,3158"] ="3, 3035,1" --  Ice Detector Heater Switch, MANUAL/AUTO	127
Helios_MI8.ExportArguments["2,3159"] ="3, 3038,1" --  Left Pitot Heater Switch, ON/OFF 		519
Helios_MI8.ExportArguments["2,3160"] ="3, 3039,1" --  Right Pitot Heater Switch, ON/OFF		520
Helios_MI8.ExportArguments["2,3161"] ="15, 3001,1" --  Doppler Navigator Power Switch, ON/OFF	483
Helios_MI8.ExportArguments["2,3162"] ="15, 3011,1" --  Test/Work Switch						797
Helios_MI8.ExportArguments["2,3163"] ="15, 3012,1" --  Land/Sea Switch							798
Helios_MI8.ExportArguments["2,3164"] ="7, 3004,1" --  Right Attitude Indicator Power Switch, ON/OFF	487
Helios_MI8.ExportArguments["2,3165"] ="6, 3004,1" --  Left Attitude Indicator Power Switch, ON/OFF		335
Helios_MI8.ExportArguments["2,3166"] ="32, 3001,1" --  VK-53 Power Switch, ON/OFF			336
Helios_MI8.ExportArguments["2,3167"] ="14, 3001,1" --  GMC Power Switch, ON/OFF					 485
Helios_MI8.ExportArguments["2,3168"] ="14, 3002,1" -- GMC Hemisphere Selection Switch, NORTH/SOUTH  470
Helios_MI8.ExportArguments["2,3169"] ="3, 3028,1" -- Left Engine Dust Protection Switch, ON/OFF  517
Helios_MI8.ExportArguments["2,3170"] ="3, 3029,1" -- Right Engine Dust Protection Switch, ON/OFF 518
Helios_MI8.ExportArguments["2,3171"] ="9, 3014,1" -- Tip Lights Switch, ON/OFF     515
Helios_MI8.ExportArguments["2,3172"] ="9, 3015,1" -- Strobe Light Switch, ON/OFF   516
Helios_MI8.ExportArguments["2,3173"] ="9, 3017,1" -- Taxi Light Switch, ON/OFF     836
Helios_MI8.ExportArguments["2,3174"] ="46, 3004,1" -- 5.5V Lights Switch, ON/OFF 			   		479
Helios_MI8.ExportArguments["2,3175"] ="46, 3022,1" -- Cargo Cabin Duty Lights Switch, ON/OFF   	511
Helios_MI8.ExportArguments["2,3176"] ="46, 3023,1" -- Cargo Cabin Common Lights Switch, ON/OFF   	512
Helios_MI8.ExportArguments["2,3177"] ="36, 3004,1" -- Radio/ICS Switch 			553
Helios_MI8.ExportArguments["2,3178"] ="36, 3007,1" -- Network 1/2 Switch (N/F)		551
Helios_MI8.ExportArguments["2,3179"] ="36, 3012,1" -- Radio/ICS Switch 			845 copilot
Helios_MI8.ExportArguments["2,3180"] ="36, 3013,1" -- Network 1/2 Switch (N/F)   	843 copilot
Helios_MI8.ExportArguments["2,3181"] ="36, 3006,1" -- Laryngophone Switch, ON/OFF 					   480
Helios_MI8.ExportArguments["2,3182"] ="38, 3001,1" -- R-863, Modulation Switch, FM/AM 				   369
Helios_MI8.ExportArguments["2,3183"] ="38, 3002,1" -- R-863, Unit Switch, DIAL/MEMORY 				   132
Helios_MI8.ExportArguments["2,3184"] ="38, 3004,1" -- R-863, Squelch Switch, ON/OFF 				   155
Helios_MI8.ExportArguments["2,3185"] ="38, 3010,1" -- R-863, Emergency Receiver Switch, ON/OFF (N/F)  153
Helios_MI8.ExportArguments["2,3186"] ="38, 3011,1" -- R-863, ARC Switch, ON/OFF (N/F) 				   154
Helios_MI8.ExportArguments["2,3187"] ="39, 3004,1" -- R-828, Squelch Switch, ON/OFF				   739
Helios_MI8.ExportArguments["2,3188"] ="39, 3005,1" -- R-828, Power Switch, ON/OFF 					   756
Helios_MI8.ExportArguments["2,3189"] ="39, 3006,1" -- R-828, Compass Switch, COMM/NAV 				   757
Helios_MI8.ExportArguments["2,3190"] ="37, 3013,1" -- Jadro 1A, Power Switch, ON/OFF 				   484
Helios_MI8.ExportArguments["2,3191"] ="11, 3006,1" -- RI-65 Power Switch, ON/OFF 	 	338
Helios_MI8.ExportArguments["2,3192"] ="36, 3021,1" -- RI-65 Amplifier Switch, ON/OFF"	295
Helios_MI8.ExportArguments["2,3193"] ="41, 3002,1" -- ARC-UD, Sensitivity Switch, MORE/LESS 453
Helios_MI8.ExportArguments["2,3194"] ="41, 3003,1" -- ARC-UD, Wave Switch, MW/D, 			 454
Helios_MI8.ExportArguments["2,3195"] ="41, 3012,1" -- ARC-UD, Lock Switch, LOCK/UNLOCK 	 481
Helios_MI8.ExportArguments["2,3196"] ="45, 3006,1" -- Clock Heating Switch, ON/OFF 	 521
Helios_MI8.ExportArguments["2,3197"] ="48, 3010,1" -- CMD Power Switch, ON/OFF 					 910
Helios_MI8.ExportArguments["2,3198"] ="48, 3003,1" -- CMD Flares Amount Switch, COUNTER/PROGRAMMING 913
--Helios_MI8.ExportArguments["2,3199"] ="7, 3024,1" -- Parking Brake Handle 		930	
Helios_MI8.ExportArguments["2,3200"] ="17, 3020,1" -- Left Fan Switch, ON/OFF  	334
Helios_MI8.ExportArguments["2,3201"] ="17, 3021,1" -- Right Fan Switch, ON/OFF 	488
Helios_MI8.ExportArguments["2,3202"] ="40, 3011,1" -- ARC-9, Dialer Switch, MAIN/BACKUP 469
Helios_MI8.ExportArguments["2,3203"] ="40, 3002,1" -- ARC-9, TLF/TLG Switch 		 	444
Helios_MI8.ExportArguments["2,3204"] ="51, 3002,1" -- Tactical Cargo Release Button Cover, OPEN/CLOSE	199
Helios_MI8.ExportArguments["2,3205"] ="51, 3004,1" -- Emergency Cargo Release Button Cover, OPEN/CLOSE 197
Helios_MI8.ExportArguments["2,3206"] ="51, 3005,1" -- External Cargo Automatic Dropping, ON/OFF 		324
Helios_MI8.ExportArguments["2,3207"] ="52, 3001,1" -- Signal Flares Cassette 1 Power Switch, ON/OFF   282
Helios_MI8.ExportArguments["2,3208"] ="52, 3006,1" -- Signal Flares Cassette 2 Power Switch, ON/OFF   283
Helios_MI8.ExportArguments["2,3209"] ="53, 3002,1" -- KO-50 Fan Switch, ON/OFF   467
Helios_MI8.ExportArguments["2,3210"] ="55, 3001,1" -- SARPP-12 Mode Switch, MANUAL/AUTO 315
Helios_MI8.ExportArguments["2,3211"] ="56, 3001,1" -- Recorder P-503B Power Switch, ON/OFF  305
Helios_MI8.ExportArguments["2,3212"] ="57, 3002,1" -- IFF Transponder Device Selector Switch, WORK/RESERVE	301
Helios_MI8.ExportArguments["2,3213"] ="57, 3003,1" -- IFF Transponder Device Mode Switch, 1/2				300
Helios_MI8.ExportArguments["2,3214"] ="57, 3004,1" -- IFF Transponder Erase Button Cover, OPEN/CLOSE		296
Helios_MI8.ExportArguments["2,3215"] ="57, 3006,1" -- IFF Transponder Disaster Switch Cover, OPEN/CLOSE	    298
Helios_MI8.ExportArguments["2,3216"] ="57, 3007,1" -- IFF Transponder Disaster Switch, ON/OFF				299
Helios_MI8.ExportArguments["2,3014"] ="37, 3008,0.7" -- Jadro 1A, Squelch Switch			   741			
--Push buttons
Helios_MI8.ExportArguments["1,3001"] ="1, 3022,1" --  CB Group 1 ON    882
Helios_MI8.ExportArguments["1,3002"] ="1, 3025,1" --  CB Group 4 ON    883
Helios_MI8.ExportArguments["1,3003"] ="1, 3028,1" --  CB Group 7 ON    884
Helios_MI8.ExportArguments["1,3004"] ="1, 3023,1" --  CB Group 2 ON    885
Helios_MI8.ExportArguments["1,3005"] ="1, 3026,1" --  CB Group 5 ON    886
Helios_MI8.ExportArguments["1,3006"] ="1, 3029,1" --  CB Group 8 ON    887
Helios_MI8.ExportArguments["1,3007"] ="1, 3024,1" --  CB Group 3 ON    888
Helios_MI8.ExportArguments["1,3008"] ="1, 3027,1" --  CB Group 6 ON    889
Helios_MI8.ExportArguments["1,3009"] ="1, 3030,1" --  CB Group 9 ON    890
Helios_MI8.ExportArguments["1,3010"] ="3, 3026,1" --  APU Start Button - Push to start APU 			413
Helios_MI8.ExportArguments["1,3011"] ="3, 3007,1" --  APU Stop Button - Push to stop APU 			    415
Helios_MI8.ExportArguments["1,3012"] ="3, 3005,1" --  Engine Start Button - Push to start engine 	    419
Helios_MI8.ExportArguments["1,3013"] ="3, 3006,1" --  Abort Start Engine Button - Push to abort start  421
Helios_MI8.ExportArguments["1,3014"] ="3, 3021,1" --  Vibration Sensor Test Button - Push to test 				    	310
Helios_MI8.ExportArguments["1,3015"] ="3, 3023,1" --  Cold Temperature Sensor Test Button - Push to test 		    	311
Helios_MI8.ExportArguments["1,3016"] ="3, 3022,1" --  Hot Temperature Sensor Test Button - Push to test 				312
Helios_MI8.ExportArguments["1,3017"] ="3, 3019,1" --  Left Engine Temperature Regulator Test Button - Push to test  	313
Helios_MI8.ExportArguments["1,3018"] ="3, 3020,1" --  Right Engine Temperature Regulator Test Button - Push to test    314
Helios_MI8.ExportArguments["1,3019"] ="4, 3003,1" --  Auxiliary Hydraulic Shut Off Button - Push to shut off    		411
Helios_MI8.ExportArguments["1,3020"] ="16, 3029,1" --  Autopilot Off Left Button 	183
Helios_MI8.ExportArguments["1,3021"] ="16, 3030,1" --  Autopilot Off Right Button  226
Helios_MI8.ExportArguments["1,3022"] ="16, 3031,1" --  Trimmer Left Button 		184
Helios_MI8.ExportArguments["1,3023"] ="16, 3032,1" --  Trimmer Right Button 		227
Helios_MI8.ExportArguments["1,3024"] ="12, 3032,1" --  Emergency Bomb Release Switch, ON/OFF 		709
Helios_MI8.ExportArguments["1,3025"] ="12, 3014,1" --  Lamps Check Button - Push to check 		718
Helios_MI8.ExportArguments["1,3026"] ="12, 3005,1" --  Emergency Release Switch main				572
Helios_MI8.ExportArguments["1,3027"] ="12, 3026,1" --  Lamps Check Button - Push to check 	  	576
Helios_MI8.ExportArguments["1,3028"] ="12, 3031,1" --  PUS Arming Button - Push to arm 		574
--Helios_MI8.ExportArguments["1,3029"] ="12, 3082,1" --  Left Fire RS Button 						186
--Helios_MI8.ExportArguments["1,3030"] ="12, 3083,1" --  Right Fire RS Button 						229
Helios_MI8.ExportArguments["1,3031"] ="19, 3001,1" --  Main Discharge Left Engine Button 		389
Helios_MI8.ExportArguments["1,3032"] ="19, 3002,1" --  Main Discharge Right Engine Button 	    390
Helios_MI8.ExportArguments["1,3033"] ="19, 3003,1" --  Main Discharge KO-50 Button 			391
Helios_MI8.ExportArguments["1,3034"] ="19, 3004,1" --  Main Discharge APU GEAR Button 		    392
Helios_MI8.ExportArguments["1,3035"] ="19, 3005,1" --  Alternate Discharge Left Engine Button  393
Helios_MI8.ExportArguments["1,3036"] ="19, 3006,1" --  Alternate Discharge Right Engine Button 394
Helios_MI8.ExportArguments["1,3037"] ="19, 3007,1" --  Alternate Discharge KO-50 Button 		395
Helios_MI8.ExportArguments["1,3038"] ="19, 3008,1" --  Alternate Discharge APU GEAR Button 	396
Helios_MI8.ExportArguments["1,3039"] ="19, 3009,1" --  Turn Off Fire Signal Button 			397
Helios_MI8.ExportArguments["1,3040"] ="3, 3031,1" --  Defrost OFF Button - Push to turn off 			354
Helios_MI8.ExportArguments["1,3041"] ="3, 3036,1" --  Ice Detector Heater Test Button - Push to test  	359
Helios_MI8.ExportArguments["1,3042"] ="3, 3040,1" --  Left Pitot Heater Test Button - Push to test    	339
Helios_MI8.ExportArguments["1,3043"] ="3, 3041,1" --  Right Pitot Heater Test Button - Push to test   	482
Helios_MI8.ExportArguments["1,3044"] ="15, 3002,1" --  Turn Off Coordinates Calculator Button 	818
Helios_MI8.ExportArguments["1,3045"] ="15, 3003,1" --  Turn On Coordinates Calculator Button 	819
Helios_MI8.ExportArguments["1,3046"] ="15, 3004,1" --  Decrease Map Angle Button 				815
Helios_MI8.ExportArguments["1,3047"] ="15, 3005,1" --  Increase Map Angle Button 				816
Helios_MI8.ExportArguments["1,3048"] ="15, 3006,1" --  Decrease Path KM Button 				809
Helios_MI8.ExportArguments["1,3049"] ="15, 3007,1" --  Increase Path KM Button 				810
Helios_MI8.ExportArguments["1,3050"] ="15, 3008,1" --  Decrease Deviation KM Button 			803
Helios_MI8.ExportArguments["1,3051"] ="15, 3009,1" --  Increase Deviation KM Button 			804
Helios_MI8.ExportArguments["1,3052"] ="7, 3002,1" --  Right Attitude Indicator Cage Knob - Push to cage 90
Helios_MI8.ExportArguments["1,3053"] ="6, 3002,1" --  Left Attitude Indicator Cage Knob - Push to cage  11
Helios_MI8.ExportArguments["1,3054"] ="9, 3016,1" --  ANO Code Button  322
Helios_MI8.ExportArguments["1,3055"] ="36, 3008,1" -- Circular Call Button (N/F)  552
Helios_MI8.ExportArguments["1,3056"] ="36, 3014,1" -- Circular Call Button (N/F)  846
Helios_MI8.ExportArguments["1,3057"] ="39, 3003,1" -- R-828, Radio Tuner Button  738
Helios_MI8.ExportArguments["1,3058"] ="37, 3009,1" -- Jadro 1A, Control Button  742
Helios_MI8.ExportArguments["1,3059"] ="36, 3014,1" -- RI-65 OFF Button 	 292
Helios_MI8.ExportArguments["1,3060"] ="39, 3003,1" -- RI-65 Repeat Button   293
Helios_MI8.ExportArguments["1,3061"] ="37, 3009,1" -- RI-65 Check Button    294
Helios_MI8.ExportArguments["1,3062"] ="41, 3006,1" -- ARC-UD, Control Button 		 672
Helios_MI8.ExportArguments["1,3063"] ="41, 3007,1" -- ARC-UD, Left Antenna Button   673
Helios_MI8.ExportArguments["1,3064"] ="41, 3008,1" -- ARC-UD, Right Antenna Button  674
Helios_MI8.ExportArguments["1,3065"] ="48, 3004,1" -- CMD Num of Sequences Button 			914
Helios_MI8.ExportArguments["1,3066"] ="48, 3006,1" -- CMD Dispense Interval Button 		862
Helios_MI8.ExportArguments["1,3067"] ="48, 3005,1" -- CMD Num in Sequence Button 			863
Helios_MI8.ExportArguments["1,3068"] ="48, 3007,1" -- CMD Start Dispense Button 			866
Helios_MI8.ExportArguments["1,3069"] ="48, 3013,1" -- Start/Stop Dispense Button 			911
Helios_MI8.ExportArguments["1,3070"] ="48, 3008,1" -- CMD Reset to Default Program Button 	864
Helios_MI8.ExportArguments["1,3071"] ="48, 3009,1" -- CMD Stop Dispense Button 			865
--Helios_MI8.ExportArguments["1,3072"] ="17, 3017,1" -- Wheel Brakes Handle 						  881
Helios_MI8.ExportArguments["1,3073"] ="17, 3006,1" -- Accelerometer Reset Button - Push to reset 925
Helios_MI8.ExportArguments["1,3074"] ="51, 3001,1" -- Tactical Cargo Release Button - Push to release   200
Helios_MI8.ExportArguments["1,3075"] ="51, 3003,1" -- Emergency Cargo Release Button - Push to release  198
Helios_MI8.ExportArguments["1,3076"] ="52, 3003,1" -- Signal Flares Cassette 1 Launch Red Button	   284
Helios_MI8.ExportArguments["1,3077"] ="52, 3002,1" -- Signal Flares Cassette 1 Launch Green Button    285
Helios_MI8.ExportArguments["1,3078"] ="52, 3005,1" -- Signal Flares Cassette 1 Launch Yellow Button   286
Helios_MI8.ExportArguments["1,3079"] ="52, 3004,1" -- Signal Flares Cassette 1 Launch White Button    287
Helios_MI8.ExportArguments["1,3080"] ="52, 3008,1" -- Signal Flares Cassette 2 Launch Red Button	   288
Helios_MI8.ExportArguments["1,3081"] ="52, 3007,1" -- Signal Flares Cassette 2 Launch Green Button    289
Helios_MI8.ExportArguments["1,3082"] ="52, 3010,1" -- Signal Flares Cassette 2 Launch Yellow Button   290
Helios_MI8.ExportArguments["1,3083"] ="52, 3009,1" -- Signal Flares Cassette 2 Launch White Button    291
Helios_MI8.ExportArguments["1,3084"] ="53, 3001,1" -- KO-50 Heater Start Button - Push to start    464
Helios_MI8.ExportArguments["1,3085"] ="57, 3005,1" -- IFF Transponder Erase Button - Push to erase 297
Helios_MI8.ExportArguments["1,3086"] ="20, 3001,1" -- Alarm Bell Button - Push to turn on          323
Helios_MI8.ExportArguments["1,3087"] ="16,3003,1" -- Autopilot Heading ON Button >> PUSH_BUTTONS :: PB_87
Helios_MI8.ExportArguments["1,3088"] ="16,3005,1" -- Autopilot Heading OFF Button >> PUSH_BUTTONS :: PB_88
Helios_MI8.ExportArguments["1,3089"] ="16,3002,1" -- Autopilot Pitch/Roll ON Button >> PUSH_BUTTONS :: PB_89
Helios_MI8.ExportArguments["1,3090"] ="16,3001,1" -- Autopilot Altitude ON Button >> PUSH_BUTTONS :: PB_90
Helios_MI8.ExportArguments["1,3091"] ="16,3004,1" -- Autopilot Altitude OFF Button >> PUSH_BUTTONS :: PB_91
Helios_MI8.ExportArguments["1,3092"] ="8, 3001,1" 	-- SPUU-52 Control Engage Button 	127  >> PUSH_BUTTONS :: PB_92
Helios_MI8.ExportArguments["1,3093"] ="18,3002,1" -- Radio Altimeter Test Button - Push to test >> PUSH_BUTTONS :: PB_93 
Helios_MI8.ExportArguments["1,3094"] ="45,3004,1" -- Mech clock right lever >> PUSH_BUTTONS :: PB_94 	
--tree way switches
Helios_MI8.ExportArguments["3,3001"] ="1,3012,1" -- 115V Inverter Switch, MANUAL/OFF/AUTO >> TREE_WAY_SWITCH :: 3WSwitch_A_1
Helios_MI8.ExportArguments["3,3002"] ="1,3013,1" -- 36V Inverter Switch, MANUAL/OFF/AUTO >> TREE_WAY_SWITCH :: 3WSwitch_A_2
Helios_MI8.ExportArguments["3,3003"] ="1,3020,1" -- 36V Transformer Switch, MAIN/OFF/AUXILIARY >> TREE_WAY_SWITCH :: 3WSwitch_A_3
Helios_MI8.ExportArguments["3,3004"] ="3,3012,1" -- APU Start Mode Switch, START/COLD CRANKING/FALSE START >> TREE_WAY_SWITCH :: 3WSwitch_A_4
Helios_MI8.ExportArguments["3,3005"] ="3,3008,1" -- Engine Selector Switch, LEFT/OFF/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_5
Helios_MI8.ExportArguments["3,3006"] ="3,3027,1" -- Engine Start Mode Switch, START/OFF/COLD CRANKING >> TREE_WAY_SWITCH :: 3WSwitch_A_6
Helios_MI8.ExportArguments["3,3203"] ="2,3014,1" -- Refueling Control Switch, REFUEL/OFF/CHECK >> TREE_WAY_SWITCH :: 3WSwitch_C_203
Helios_MI8.ExportArguments["3,3008"] ="12,3020,1" -- 8/16/4 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_8
Helios_MI8.ExportArguments["3,3009"] ="12,3021,1" -- 1-2-5-6/AUTO/3-4 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_9
Helios_MI8.ExportArguments["3,3010"] ="12,3022,1" -- UPK/PKT/RS Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_10
Helios_MI8.ExportArguments["3,3011"] ="12,3006,1" -- CUTOFF Switch, ON/OFF >> TREE_WAY_SWITCH :: 3WSwitch_A_11
Helios_MI8.ExportArguments["3,3012"] ="21,3007,1" -- Check Switch, LAMPS/OFF/FLASHER >> TREE_WAY_SWITCH :: 3WSwitch_A_12
Helios_MI8.ExportArguments["3,3013"] ="14,3004,1" -- GMC Mode Switch, MC/DG/AC(N/F) >> TREE_WAY_SWITCH :: 3WSwitch_A_13
Helios_MI8.ExportArguments["3,3014"] ="9,3018,1" -- Left Landing Light Switch, LIGHT/OFF/RETRACT >> TREE_WAY_SWITCH :: 3WSwitch_A_14
Helios_MI8.ExportArguments["3,3015"] ="9,3019,1" -- Right Landing Light Switch, LIGHT/OFF/RETRACT >> TREE_WAY_SWITCH :: 3WSwitch_A_15
Helios_MI8.ExportArguments["3,3016"] ="9,3012,1" -- ANO Switch, BRIGHT/OFF/DIM >> TREE_WAY_SWITCH :: 3WSwitch_A_16
Helios_MI8.ExportArguments["3,3017"] ="9,3013,1" -- Formation Lights Switch, BRIGHT/OFF/DIM >> TREE_WAY_SWITCH :: 3WSwitch_A_17
Helios_MI8.ExportArguments["3,3018"] ="46,3002,1" -- Left Ceiling Light Switch, RED/OFF/WHITE >> TREE_WAY_SWITCH :: 3WSwitch_A_18
Helios_MI8.ExportArguments["3,3019"] ="46,3003,1" -- Right Ceiling Light Switch, RED/OFF/WHITE >> TREE_WAY_SWITCH :: 3WSwitch_A_19
Helios_MI8.ExportArguments["4,3116"] ="38,3003,1" -- R-863, Radio Channel Selector Knob >> axis b116
Helios_MI8.ExportArguments["3,3202"] ="48,3002,1" -- CMD Board Flares Dispensers Switch, LEFT/BOTH/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_C_202
Helios_MI8.ExportArguments["3,3023"] ="53,3003,1" -- KO-50 Heater Mode Switch, MANUAL/OFF/AUTO >> TREE_WAY_SWITCH :: 3WSwitch_A_23
Helios_MI8.ExportArguments["3,3024"] ="53,3004,1" -- KO-50 Heater Regime Switch, FILLING/FULL/MEDIUM >> TREE_WAY_SWITCH :: 3WSwitch_A_24
Helios_MI8.ExportArguments["3,3025"] ="3,3074,1" -- Engine Ignition Check Switch, LEFT/OFF/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_25
--Helios_MI8.ExportArguments["3,3026"] ="3,3063,1" -- Readjust Free Turbine RPM Switch, MORE/OFF/LESS >> TREE_WAY_SWITCH :: 3WSwitch_A_26
Helios_MI8.ExportArguments["3,3027"] ="3,3064,1" -- Readjust Free Turbine RPM Switch, MORE/OFF/LESS >> TREE_WAY_SWITCH :: 3WSwitch_A_27
Helios_MI8.ExportArguments["3,3028"] ="3,3050,1" -- Left Engine FT Check Switch, ST1/WORK/ST2 >> TREE_WAY_SWITCH :: 3WSwitch_A_28
Helios_MI8.ExportArguments["3,3029"] ="3,3051,1" -- Right Engine FT Check Switch, ST1/WORK/ST2 >> TREE_WAY_SWITCH :: 3WSwitch_A_29
Helios_MI8.ExportArguments["3,3030"] ="3,3054,1" -- CT Check Switch, RIGHT/WORK/LEFT >> TREE_WAY_SWITCH :: 3WSwitch_A_30
Helios_MI8.ExportArguments["3,3031"] ="14,3003,1" -- GMC Control Switch, 0/CONTROL/300 >> TREE_WAY_SWITCH :: 3WSwitch_A_31
Helios_MI8.ExportArguments["3,3032"] ="14,3005,1" -- GMC Course Setting Switch, CCW/OFF/CW) >> TREE_WAY_SWITCH :: 3WSwitch_A_32
Helios_MI8.ExportArguments["3,3033"] ="40,3010,1" -- ARC-9, Loop Control Switch, LEFT/OFF/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_33	
-- axis
Helios_MI8.ExportArguments["4,3010"] ="1,3010,1" -- Standby Generator Voltage Adjustment Rheostat >> AXIS :: Axis_A_10
Helios_MI8.ExportArguments["4,3011"] ="1,3011,1" -- Generator 1 Voltage Adjustment Rheostat >> AXIS :: Axis_A_11
Helios_MI8.ExportArguments["4,3012"] ="1,3018,1" -- Generator 2 Voltage Adjustment Rheostat >> AXIS :: Axis_A_12
Helios_MI8.ExportArguments["4,3013"] ="3,3071,1" -- Left Engine Throttle >> AXIS :: Axis_A_13
Helios_MI8.ExportArguments["4,3014"] ="3,3072,1" -- Right Engine Throttle >> AXIS :: Axis_A_14
Helios_MI8.ExportArguments["4,3015"] ="12,3043,1" -- Burst Length Knob >> AXIS :: Axis_A_15
Helios_MI8.ExportArguments["12,3010"] ="7,3003,0.01" -- Right Attitude Indicator Zero Pitch Knob >> TOGLEE_SWITCH :: TSwitch_B_10
Helios_MI8.ExportArguments["12,3009"] ="6,3003,0.01" -- Left Attitude Indicator Zero Pitch Knob >>  TOGLEE_SWITCH :: TSwitch_B_9
Helios_MI8.ExportArguments["4,3102"] ="14,3006,1" -- GMC Latitude Selection Knob >> AXIS :: Axis_B_102
Helios_MI8.ExportArguments["4,3018"] ="46,3005,1" -- Left Red Lights Brightness Group 1 Rheostat >> AXIS :: Axis_A_18
Helios_MI8.ExportArguments["4,3019"] ="46,3006,1" -- Left Red Lights Brightness Group 2 Rheostat >> AXIS :: Axis_A_19
Helios_MI8.ExportArguments["4,3020"] ="46,3007,1" -- Right Red Lights Brightness Group 1 Rheostat >> AXIS :: Axis_A_20
Helios_MI8.ExportArguments["4,3021"] ="46,3008,1" -- Right Red Lights Brightness Group 2 Rheostat >> AXIS :: Axis_A_21
Helios_MI8.ExportArguments["4,3022"] ="46,3009,1" -- Central Red Lights Brightness Group 1 Rheostat >> AXIS :: Axis_A_22
Helios_MI8.ExportArguments["4,3023"] ="46,3010,1" -- Central Red Lights Brightness Group 2 Rheostat >> AXIS :: Axis_A_23
Helios_MI8.ExportArguments["4,3024"] ="46,3011,1" -- 5.5V Lights Brightness Rheostat >> AXIS :: Axis_A_24
Helios_MI8.ExportArguments["4,3103"] ="36,3001,1" -- Common Volume Knob >> AXIS :: Axis_B_103
Helios_MI8.ExportArguments["4,3104"] ="36,3002,1" -- Listening Volume Knob >> AXIS :: Axis_B_104
Helios_MI8.ExportArguments["4,3105"] ="36,3009,1" -- Common Volume Knob >> AXIS :: Axis_B_105
Helios_MI8.ExportArguments["4,3106"] ="36,3010,1" -- Listening Volume Knob >> AXIS :: Axis_B_106
Helios_MI8.ExportArguments["4,3107"] ="38,3005,1" -- R-863, Volume Knob >> AXIS :: Axis_B_107
Helios_MI8.ExportArguments["4,3108"] ="39,3002,1" -- R-828, Volume Knob >> AXIS :: Axis_B_108
Helios_MI8.ExportArguments["4,3109"] ="37,3007,1" -- Jadro 1A, Volume Knob >> AXIS :: Axis_B_109
Helios_MI8.ExportArguments["4,3110"] ="41,3005,1" -- ARC-UD, Volume Knob >> AXIS :: Axis_B_110
Helios_MI8.ExportArguments["4,3025"] ="47,3001,1" -- Sight Brightness Knob >> AXIS :: Axis_A_25
Helios_MI8.ExportArguments["4,3026"] ="47,3003,1" -- Sight Limb Knob >> AXIS :: Axis_A_26
Helios_MI8.ExportArguments["4,3111"] ="40,3001,1" -- ARC-9, Volume Knob >> AXIS :: Axis_B_111
Helios_MI8.ExportArguments["4,3112"] ="40,3004,1" -- ARC-9, Backup Frequency Tune Knob >> AXIS :: Axis_B_112
Helios_MI8.ExportArguments["4,3113"] ="40,3007,1" -- ARC-9, Main Frequency Tune Knob >> AXIS :: Axis_B_113
Helios_MI8.ExportArguments["4,3114"] ="53,3005,1" -- KO-50 Target Temperature Knob >> AXIS :: Axis_B_114
Helios_MI8.ExportArguments["4,3027"] ="56,3002,1" -- Recorder P-503B Backlight Brightness Knob >> AXIS :: Axis_A_27
Helios_MI8.ExportArguments["4,3028"] ="40,3005,1" -- ARC-9, Backup 100kHz Rotary Knob>>  AXIS  :: Axis_A_28
Helios_MI8.ExportArguments["4,3029"] ="40,3006,1" -- ARC-9, Backup 10kHz Rotary Knob>>  AXIS  :: Axis_A_29
Helios_MI8.ExportArguments["4,3030"] ="40,3008,1" -- ARC-9, Main 100kHz Rotary Knob >>  AXIS  :: Axis_A_30
Helios_MI8.ExportArguments["4,3031"] ="40,3009,1" --ARC-9, Main 10kHz Rotary Knob >>  AXIS  :: Axis_A_31
--switches
Helios_MI8.ExportArguments["12,3011"] ="16,3009,0.1" -- Autopilot Heading Adjustment Knob >> TSwitch_B_11
Helios_MI8.ExportArguments["12,3012"] ="16,3008,0.1" -- Autopilot Roll Adjustment Knob >> TSwitch_B_12
Helios_MI8.ExportArguments["12,3013"] ="16,3010,0.1" -- Autopilot Pitch Adjustment Knob >> TSwitch_B_13
Helios_MI8.ExportArguments["12,3014"] ="26,3001,0.1" -- Baro Pressure QFE Knob >> TSwitch_B_14
Helios_MI8.ExportArguments["12,3015"] ="27,3001,0.1" -- Baro Pressure QFE Knob >> TSwitch_B_15
Helios_MI8.ExportArguments["12,3016"] ="30,3001,0.1" -- Variometer Adjustment Knob >> TSwitch_B_16
Helios_MI8.ExportArguments["12,3017"] ="31,3001,0.1" -- Variometer Adjustment Knob >> TSwitch_B_17
Helios_MI8.ExportArguments["12,3018"] ="34,3001,0.1" -- HSI Course Set Knob >> TSwitch_B_18
Helios_MI8.ExportArguments["12,3019"] ="35,3001,0.1" -- HSI Course Set Knob >> TSwitch_B_19
Helios_MI8.ExportArguments["12,3020"] ="8,3002,0.1" -- SPUU-52 Adjustment Knob >>  TSwitch_B_20
--multiswitch
Helios_MI8.ExportArguments["5,3051"] ="1,3017,1" -- AC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_51
Helios_MI8.ExportArguments["5,3052"] ="1,3008,1" -- DC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_52
Helios_MI8.ExportArguments["5,3001"] ="2,3008,1" -- Fuel Meter Switch, OFF/SUM/LEFT/RIGHT/FEED/ADDITIONAL >> MULTI_POS_SWITCH :: Multi6PosSwitch_1
Helios_MI8.ExportArguments["5,3002"] ="12,3013,1" -- Pod Variants Selector Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_2
Helios_MI8.ExportArguments["4,3115"] ="12,3029,1" -- ESBR Position Selector Switch >>MULTI_POS_SWITCH :: Multi21PosSwitch_101
Helios_MI8.ExportArguments["5,3053"] ="19,3012,1" -- Check Fire Circuits Switch, OFF/CONTROL/1/2/3/4/5/6 >> MULTI_POS_SWITCH :: Multi11PosSwitch_53
Helios_MI8.ExportArguments["5,3054"] ="3,3037,1" -- Defrost System Amperemeter Selector Switch >> MULTI_POS_SWITCH :: Multi11PosSwitch_54
Helios_MI8.ExportArguments["5,3055"] ="39,3001,1" -- R-828, Radio Channel Selector Knob >> MULTI_POS_SWITCH :: Multi11PosSwitch_55
Helios_MI8.ExportArguments["5,3003"] ="15,3010,1" -- Doppler Navigator Mode Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_3
Helios_MI8.ExportArguments["5,3004"] ="36,3003,1" -- Radio Source Selector Switch, R-863/JADRO-1A/R-828/NF/ARC-9/ARC-UD >> MULTI_POS_SWITCH :: Multi6PosSwitch_4
Helios_MI8.ExportArguments["5,3005"] ="36,3011,1" -- Radio Source Selector Switch, R-863/JADRO-1A/R-828/NF/ARC-9/ARC-UD >> MULTI_POS_SWITCH :: Multi6PosSwitch_5
Helios_MI8.ExportArguments["3,3201"] ="37,3001,1" -- Jadro 1A, Mode Switch, OFF/OM/AM") , >> TREE_WAY_SWITCH :: 3WSwitch_C_201
Helios_MI8.ExportArguments["5,3006"] ="41,3001,1" -- ARC-UD, Mode Switch, OFF/NARROW/WIDE/PULSE/RC >> MULTI_POS_SWITCH :: Multi6PosSwitch_6
Helios_MI8.ExportArguments["5,3007"] ="41,3004,1" -- ARC-UD, Channel Selector Switch, 1/2/3/4/5/6 >> MULTI_POS_SWITCH :: Multi6PosSwitch_7
Helios_MI8.ExportArguments["5,3008"] ="40,3003,1" -- ARC-9, Mode Selector Switch, OFF/COMP/ANT/LOOP >> MULTI_POS_SWITCH :: Multi6PosSwitch_8
Helios_MI8.ExportArguments["3,3101"] ="25,3001,1" -- Static Pressure System Mode Selector, LEFT/COMMON/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_B_101
Helios_MI8.ExportArguments["5,3009"] ="57,3001,1" -- IFF Transponder Mode Selector Switch, AUTO/KD/+-15/KP >> MULTI_POS_SWITCH :: Multi6PosSwitch_9
Helios_MI8.ExportArguments["5,3010"] ="12,3042,1" -- In800Out/800inOr624/622 Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_10
Helios_MI8.ExportArguments["5,3011"] ="12,3044,1" -- Left PYROCARTRIDGE Switch, I/II/III >> MULTI_POS_SWITCH :: Multi6PosSwitch_11
Helios_MI8.ExportArguments["5,3012"] ="12,3045,1" -- Right PYROCARTRIDGE Switch, I/II/III >> MULTI_POS_SWITCH :: Multi6PosSwitch_12	
Helios_MI8.ExportArguments["5,3013"] ="17,3025,1" -- Left Windscreen Wiper Control Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_13
Helios_MI8.ExportArguments["5,3014"] ="17,3026,1" -- Right Windscreen Wiper Control Switch >> MULTI_POS_SWITCH :: Multi6PosSwitch_14	
Helios_MI8.ExportArguments["12,3001"] ="38,3006,0.1" -- R-863, 10MHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_1
Helios_MI8.ExportArguments["12,3002"] ="38,3007,0.1" -- R-863, 1MHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_2
Helios_MI8.ExportArguments["12,3003"] ="38,3008,0.1" -- R-863, 100kHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_3
Helios_MI8.ExportArguments["12,3004"] ="38,3009,0.1" -- R-863, 1kHz Rotary Knob >> TOGLEE_SWITCH :: TSwitch_B_4
Helios_MI8.ExportArguments["12,3005"] ="37,3002,0.1" -- Jadro 1A, Frequency Selector, 1MHz >> TOGLEE_SWITCH :: TSwitch_B_5
Helios_MI8.ExportArguments["12,3006"] ="37,3003,0.1" -- Jadro 1A, Frequency Selector, 100kHz >> TOGLEE_SWITCH :: TSwitch_B_6
Helios_MI8.ExportArguments["12,3007"] ="37,3004,0.1" -- Jadro 1A, Frequency Selector, 10kHz >> TOGLEE_SWITCH :: TSwitch_B_7
Helios_MI8.ExportArguments["12,3008"] ="37,3005,0.1" -- Jadro 1A, Frequency Selector, Left mouse - 1kHz >> TOGLEE_SWITCH :: TSwitch_B_8
Helios_MI8.ExportArguments["12,3021"] ="37,3006,0.1" -- Jadro 1A, Frequency Selector, Right mouse - 100Hz >> TOGLEE_SWITCH :: TSwitch_B_21
Helios_MI8.ExportArguments["12,3022"] ="18,3001,0.05" -- Dangerous RALT Knob >> TOGLEE_SWITCH :: TSwitch_B_22

--Helios_MI8.ExportArguments["4,3032"] ="3,3067,0.1" --Throttle (RMB press, hold and move)>>  AXIS  :: Axis_A_32
Helios_MI8.ExportArguments["12,3023"] ="3,3067,0.05" -- Throttle (RMB press, hold and move) >> TOGLEE_SWITCH :: TSwitch_B_23
Helios_MI8.ExportArguments["12,3024"] ="45,3003,0.05" -- Mech clock left lever LEVER>> TOGLEE_SWITCH :: TSwitch_B_24
Helios_MI8.ExportArguments["12,3025"] ="45,3005,0.15" -- Mech clock right lever LEVER>> TOGLEE_SWITCH :: TSwitch_B_25
-- rockers
Helios_MI8.ExportArguments["10,3001"] ="8,3003,1" -- SPUU-52 Test Switch, P/OFF/t  P>> ROCKER_AABB :: Rocker_C_101
Helios_MI8.ExportArguments["10,3002"] ="8,3004,1" -- SPUU-52 Test Switch, P/OFF/t  t>> ROCKER_AABB :: Rocker_C_101
Helios_MI8.ExportArguments["10,3003"] ="16,3007,1" -- Autopilot Altitude Channel Control (Right Button - UP; Left Button - Down)>> ROCKER_AABB :: Rocker_C_102
Helios_MI8.ExportArguments["10,3004"] ="16,3006,1" -- Autopilot Altitude Channel Control (Right Button - UP; Left Button - Down)>> ROCKER_AABB :: Rocker_C_102
Helios_MI8.ExportArguments["8,3001"] ="45,3001,1" -- Mech clock left lever BUTON1>> ROCKER_ABAB :: Rocker_B_51
Helios_MI8.ExportArguments["8,3002"] ="45,3002,1" -- Mech clock left lever BUTON2>> ROCKER_ABAB :: Rocker_B_51
