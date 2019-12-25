Helios_F14 = {}

Helios_F14.Name = "F-14B"
Helios_F14.FlamingCliffsAircraft = false
Helios_F14.ExportArguments = {}

function  Helios_F14.ProcessInput(data)
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
		lConvDevice = Helios_F14.ExportArguments[sIndex] 	
		lArgument = Helios_Util.Split(string.sub(lConvDevice,1),",")
		min_clamp = 0
		max_clamp = 1
			
					
			lDevice = GetDevice(lArgument[1])    -- data conversions between switches extended and UH1H
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
				if lArgument[3]=="107" then   -- convert 0.0  1.0  to -1.0  0.0
				 local temporal= lCommandArgs[3]
					lCommandArgs[3] = temporal-1
					lArgument[3] = 1
					
				end
				
				if lArgument[3]=="108" then   -- comando directo de lomac

				 LoSetCommand(lArgument[2],up) -- aqui vendra el comando a enviar al dcs
				
				else 
				
					lDevice:performClickableAction(lArgument[2],lCommandArgs[3]*lArgument[3])  
				--log.write('Helios clickeable', lArgument[2], lCommandArgs[3])
				end
				
				
				
			end
		
    end 

	
	
end


function Helios_F14.HighImportance(mainPanelDevice)



	local MainPanel = GetDevice(0)
	local pilot_IAS_scale=	MainPanel:get_argument_value(2128)     -- IAS scale
	
	local instruments_table =
	{	
			[1] =	MainPanel:get_argument_value(19109), 	-- compas scale
			[2] =	MainPanel:get_argument_value(700),		-- compas needle
			[3] =	MainPanel:get_argument_value(699),		-- compas course neddle
			[4] =	MainPanel:get_argument_value(702),     	-- compas small scale
			[5] =	MainPanel:get_argument_value(704),     	-- compas digit 1
			[6] =	MainPanel:get_argument_value(703),     	-- compas digit 2
			[7] =	MainPanel:get_argument_value(19105),    -- compas off flag
			[8] =	MainPanel:get_argument_value(305), 		-- Altimeter  stby flag
			[9] =	MainPanel:get_argument_value(112),     	-- Altimeter readout digit 1
			[10] = 	MainPanel:get_argument_value(262),     	-- Altimeter readout digit 2
			[11] = 	MainPanel:get_argument_value(300),     	-- Altimeter readout digit 3
			[12] = 	MainPanel:get_argument_value(301),     	-- Altimeter Local barometric pressure digit 1
			[13] = 	MainPanel:get_argument_value(302),     	-- Altimeter Local barometric pressure digit 2
			[14] = 	MainPanel:get_argument_value(303),     	-- Altimeter Local barometric pressure digit 3
			[15] = 	MainPanel:get_argument_value(304),     	-- Altimeter Local barometric pressure digit 4
			[16] = 	MainPanel:get_argument_value(104),     	-- Altimeter needle
			[17] = 	MainPanel:get_argument_value(3001),  	-- ADI pitch
			[18] = 	MainPanel:get_argument_value(3002),     -- ADI bank
			[19] = 	MainPanel:get_argument_value(19100),    -- ADI off flag
			[20] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(15076),{0, 0.37, 1},{-1, 0.0, 1.0}) ,    -- G meter max needle  -1,1
			[21] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(15077),{0, 0.37, 1},{-1, 0.0, 1.0}) ,    -- G meter min needle	-1,1
			[22] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(110),{0, 0.37, 1},{-1, 0.0, 1.0}) ,   	-- G meter g neddle	-1,1
			[23] = 	MainPanel:get_argument_value(2129),     -- IAS needle
			[24] = 	MainPanel:get_argument_value(2126)-pilot_IAS_scale,     -- IAS mark 1 (scale attached)
			[25] = 	MainPanel:get_argument_value(2125)-pilot_IAS_scale,     -- IAS mark 2 (scale attached)
			[26] = 	pilot_IAS_scale,     -- IAS scale
			[27] = 	MainPanel:get_argument_value(2003),     -- AOA indicator bar
			[28] = 	MainPanel:get_argument_value(2001),     -- Sweep square mark
			[29] = 	MainPanel:get_argument_value(2002),     -- Sweep indicator bar
			[30] = 	MainPanel:get_argument_value(2047),     -- Sweep triangle mark
			[31] = 	MainPanel:get_argument_value(15094),	-- Sweep EMERG flag
			[32] = 	MainPanel:get_argument_value(15095),     -- Sweep OVER flag
			[33] = 	MainPanel:get_argument_value(6501),     -- Sleep indicator	-1,1
			[34] = 	MainPanel:get_argument_value(6500),     -- Sleep indicator ball	-1,1
			[35] = 	MainPanel:get_argument_value(9221),     -- Station status ﬂag indicator 1
			[36] = 	MainPanel:get_argument_value(9222),	    -- Station status ﬂag indicator 2
			[37] = 	MainPanel:get_argument_value(9223),     -- Station status ﬂag indicator 3
			[38] = 	MainPanel:get_argument_value(9224),  	-- Station status ﬂag indicator 4
			[39] = 	MainPanel:get_argument_value(9225),  	-- Station status ﬂag indicator 5
			[40] = 	MainPanel:get_argument_value(9226),  	-- Station status ﬂag indicator 6
			[41] = 	MainPanel:get_argument_value(9227),    	-- Station status ﬂag indicator 7
			[42] = 	MainPanel:get_argument_value(9228),     -- Station status ﬂag indicator 8
			[43] = 	MainPanel:get_argument_value(4060),		-- Rounds digit 1
			[44] = 	MainPanel:get_argument_value(4061),		-- Rounds digit 2
			[45] = 	MainPanel:get_argument_value(4062),		-- Rounds digit 3
			[46] = 	MainPanel:get_argument_value(1054),		-- Fuel AFT & L bar
			[47] = 	MainPanel:get_argument_value(1055),  	-- Fuel FWD & R bar
			[48] = 	MainPanel:get_argument_value(6020),     -- Fuel BINGO digit 1
			[49] = 	MainPanel:get_argument_value(6021),    	-- Fuel BINGO digit 2
			[50] = 	MainPanel:get_argument_value(6022),    	-- Fuel BINGO digit 3
			[51] = 	MainPanel:get_argument_value(6010),    	-- Fuel TOTAL digit 1
			[52] = 	MainPanel:get_argument_value(6011),     -- Fuel TOTAL digit 2
			[53] = 	MainPanel:get_argument_value(6012),     -- Fuel TOTAL digit 3
			[54] = 	MainPanel:get_argument_value(6000),     -- Fuel L digit 1
			[55] = 	MainPanel:get_argument_value(6001),     -- Fuel L digit 2
			[56] = 	MainPanel:get_argument_value(6004),     -- Fuel R digit 1
			[57] = 	MainPanel:get_argument_value(6005),     -- Fuel R digit 2
			[58] = 	MainPanel:get_argument_value(1057),     -- RPM L bar (from 0 to 0.045 OFF flag activated)
			[59] = 	MainPanel:get_argument_value(1058),     -- RPM R bar (from 0 to 0.045 OFF flag activated)
			[60] = 	MainPanel:get_argument_value(1059),     -- TIT L bar (from 0 to 0.045 OFF flag activated)
			[61] = 	MainPanel:get_argument_value(1060),		-- TIT R bar (from 0 to 0.045 OFF flag activated)
			[62] = 	MainPanel:get_argument_value(1061),     -- FF L bar  (from 0 to 0.045 OFF flag activated)
			[63] = 	MainPanel:get_argument_value(1062),     -- FF R bar  (from 0 to 0.045 OFF flag activated)
			[64] = 	MainPanel:get_argument_value(1063),     -- Hydro FLT needle
			[65] = 	MainPanel:get_argument_value(1064),     -- Hydro COMB needle
			[66] = 	MainPanel:get_argument_value(1023),	    -- Hydro SPOIL flag
			[67] = 	MainPanel:get_argument_value(1024),     -- Hydro HI flag
			[68] = 	MainPanel:get_argument_value(1025),  	-- Hydro LOW flag
			[69] = 	MainPanel:get_argument_value(1065),	    -- Oil Press R
			[70] = 	MainPanel:get_argument_value(1066),     -- Oil Press L
			[71] = 	MainPanel:get_argument_value(1067),  	-- Exhaust Nozzle position indicatro R
			[72] = 	MainPanel:get_argument_value(1068),  	-- Exhaust Nozzle position indicatro L
			[73] = 	MainPanel:get_argument_value(1090),		-- Control Surface Position Indicator - Horiz tail neddle 1
			[74] = 	MainPanel:get_argument_value(1091),		-- Control Surface Position Indicator - Horiz tail neddle 2
			[75] = 	MainPanel:get_argument_value(1092),		-- Control Surface Position Indicator - Rudder neddle 1
			[76] = 	MainPanel:get_argument_value(1093),		-- Control Surface Position Indicator - Rudder neddle 2
			[77] = 	MainPanel:get_argument_value(8315),		-- Control Surface Position Indicator - Spoiler DN flag 1
			[78] = 	MainPanel:get_argument_value(8316),		-- Control Surface Position Indicator - Spoiler DN flag 2
			[79] = 	MainPanel:get_argument_value(8317),		-- Control Surface Position Indicator - Spoiler DN flag 3
			[80] = 	MainPanel:get_argument_value(8318),		-- Control Surface Position Indicator - Spoiler DN flag 4
			[81] = 	MainPanel:get_argument_value(8319),		-- Control Surface Position Indicator - Spoiler UP/DOWN flag 1
			[82] = 	MainPanel:get_argument_value(8320),		-- Control Surface Position Indicator - Spoiler UP/DOWN flag 2
			[83] = 	MainPanel:get_argument_value(8321),		-- Control Surface Position Indicator - Spoiler dUP/DOWN flag 3
			[84] = 	MainPanel:get_argument_value(8322),		-- Control Surface Position Indicator - Spoiler UP/DOWN flag 4
			[85] =  Helios_Util.ValueConvert((MainPanel:get_argument_value(103)),{ 0.000, 0.1166, 0.2279, 0.3356, 0.4506, 0.4878, 0.5212, 0.5546, 0.5880, 0.6251, 0.6585, 0.7142, 0.7699, 0.8255, 0.8812, 0.9629 },{ 0.000, 0.161, 0.278, 0.380, 0.466, 0.492, 0.517, 0.540, 0.565, 0.594, 0.623, 0.673, 0.724, 0.779, 0.846, 0.940 }) ,		-- RALT needle  Fix
			[86] = 	MainPanel:get_argument_value(4154),		-- RALT mark
			[87] = 	MainPanel:get_argument_value(2124),		-- RALT off flag
			[88] = 	MainPanel:get_argument_value(106),		-- VVI needle
			[89] = 	MainPanel:get_argument_value(8300),     -- Wheels-Flaps Position Indicator - gears N off
			[90] = 	MainPanel:get_argument_value(8301),     -- Wheels-Flaps Position Indicator - gears N down/up
			[91] = 	MainPanel:get_argument_value(8302),     -- Wheels-Flaps Position Indicator - gears L down/up
			[92] = 	MainPanel:get_argument_value(8303),     -- Wheels-Flaps Position Indicator - gears L off
			[93] = 	MainPanel:get_argument_value(8304),     -- Wheels-Flaps Position Indicator - gears R off
			[94] = 	MainPanel:get_argument_value(8305),     -- Wheels-Flaps Position Indicator - gears R down/up
			[95] = 	MainPanel:get_argument_value(8306),		-- Wheels-Flaps Position Indicator - speed brakes off
			[96] = 	MainPanel:get_argument_value(8307),     -- Wheels-Flaps Position Indicator - speed brakes partial
			[97] = 	MainPanel:get_argument_value(8308),     -- Wheels-Flaps Position Indicator - speed brakes extended/retracted
			[98] = 	MainPanel:get_argument_value(8309),     -- Wheels-Flaps Position Indicator - SLATS off
			[99] = 	MainPanel:get_argument_value(8310),     -- Wheels-Flaps Position Indicator - SLATS extended/retracted
			[100] = MainPanel:get_argument_value(8311),	    -- Wheels-Flaps Position Indicator - FLAPS needle
			[101] = MainPanel:get_argument_value(1096),     -- Clock hours
			[102] = MainPanel:get_argument_value(1097),     -- Clock minutes
			[103] = MainPanel:get_argument_value(1098),	    -- Clock seconds
			[104] = MainPanel:get_argument_value(935),    	-- Cabin Pressure Altimeter needle
			[105] = MainPanel:get_argument_value(9260),     -- Emergency Brake Pressure Indicator PARK
			[106] = MainPanel:get_argument_value(9261),	    -- Emergency Brake Pressure Indicator AUX
			[107] = MainPanel:get_argument_value(1026),     -- AHRS_LatCorrectionDial
			[108] = MainPanel:get_argument_value(412),	    -- COMP_IND_SYNC_NEEDLE
			[109] = MainPanel:get_argument_value(98),	    -- datapages
			[110] =	MainPanel:get_argument_value(5550), 	-- CAP_light_CLEAR 			
			[111] =	MainPanel:get_argument_value(5551),		-- CAP_light_SW 				
			[112] =	MainPanel:get_argument_value(5552),		-- CAP_light_NE 				
			[113] =	MainPanel:get_argument_value(5553),     -- CAP_light_ENTER 			
			[114] =	MainPanel:get_argument_value(5554),     -- CAP_light_1 				
			[115] =	MainPanel:get_argument_value(5555),     -- CAP_light_2 				
			[116] =	MainPanel:get_argument_value(5556),    	-- CAP_light_3 				
			[117] =	MainPanel:get_argument_value(5557), 	-- CAP_light_4 				
			[118] =	MainPanel:get_argument_value(5558),     -- CAP_light_5 				
			[119] = MainPanel:get_argument_value(5559),     -- CAP_light_6 				
			[120] = MainPanel:get_argument_value(5560),     -- CAP_light_7 				
			[121] = MainPanel:get_argument_value(5561),     -- CAP_light_8 				
			[122] = MainPanel:get_argument_value(5562),     -- CAP_light_9 				
			[123] = MainPanel:get_argument_value(5563),     -- CAP_light_0 				
			[124] = MainPanel:get_argument_value(5564),     -- CAP_light_msg_btn6 			
			[125] = MainPanel:get_argument_value(5565),     -- CAP_light_msg_btn7 			
			[126] = MainPanel:get_argument_value(5566),  	-- CAP_light_msg_btn8 			
			[127] = MainPanel:get_argument_value(5567),     -- CAP_light_msg_btn9 			
			[128] = MainPanel:get_argument_value(5568),   	-- CAP_light_msg_btn1 			
			[129] = MainPanel:get_argument_value(5569),    	-- CAP_light_msg_btn2 			
			[130] = MainPanel:get_argument_value(5570),    	-- CAP_light_msg_btn3 			
			[131] = MainPanel:get_argument_value(5571),     -- CAP_light_msg_btn4 			
			[132] = MainPanel:get_argument_value(5572),     -- CAP_light_msg_btn5 			
			[133] = MainPanel:get_argument_value(5573),     -- CAP_light_TNG_NBR 			
			[134] = MainPanel:get_argument_value(5574),     -- CAP_light_PGM_RESTART 		
			[135] = MainPanel:get_argument_value(5590),     -- CAP_light_msg_btn10 		
			[136] = MainPanel:get_argument_value(6111),     -- DDD_mode_light_rdr 			
			[137] = MainPanel:get_argument_value(6112),     -- DDD_mode_light_ir 			
			[138] = MainPanel:get_argument_value(6113),     -- DDD_mode_light_iff 			
			[139] = MainPanel:get_argument_value(6114),     -- DDD_mode_light_pdstt 		
			[140] = MainPanel:get_argument_value(6115),		-- DDD_mode_light_pstt 		
			[141] = MainPanel:get_argument_value(6116),     -- DDD_mode_light_pdsearch 	
			[142] = MainPanel:get_argument_value(6117),     -- DDD_mode_light_rws 			
			[143] = MainPanel:get_argument_value(6118),     -- DDD_mode_light_tws_auto 	
			[144] = MainPanel:get_argument_value(6119),     -- DDD_mode_light_tws_man 		
			[145] = MainPanel:get_argument_value(6120),	    -- DDD_mode_light_psearch 		
			[146] = MainPanel:get_argument_value(6121),     -- CCM_mode_light_spl 			
			[147] = MainPanel:get_argument_value(6122),  	-- CCM_mode_light_altoff 		
			[148] = MainPanel:get_argument_value(6123),  	-- CCM_mode_light_vgs 			
			[149] = MainPanel:get_argument_value(6125),  	-- TID_trackhold_light 		
			[150] = MainPanel:get_argument_value(6126),    	-- TID_CLSN_light 				
			[151] = MainPanel:get_argument_value(6127),     -- TID_option_light_riddsbl 	
			[152] = MainPanel:get_argument_value(6128),		-- TID_option_light_altnum 	
			[153] = MainPanel:get_argument_value(6129),		-- TID_option_light_symelem 	
			[154] = MainPanel:get_argument_value(6130),		-- TID_option_light_datalink 	
			[155] = MainPanel:get_argument_value(6131),		-- TID_option_light_jam 		
			[156] = MainPanel:get_argument_value(6132),  	-- TID_option_light_nonattk 	
			[157] = MainPanel:get_argument_value(6133),     -- TID_option_light_LZ 		
			[158] = MainPanel:get_argument_value(6134),    	-- TID_option_light_velvec 	
			[159] = MainPanel:get_argument_value(6135),    	-- HCU_mode_light_TVIR 		
			[160] = MainPanel:get_argument_value(6136),    	-- HCU_mode_light_RDR 			
			[161] = MainPanel:get_argument_value(6137),     -- HCU_mode_light_DDD 			
			[162] = MainPanel:get_argument_value(6138),    -- HCU_mode_light_TID 	
			[163] = MainPanel:get_argument_value(2117),    	-- FUEL_TotalFuelRIO10k		
			[164] = MainPanel:get_argument_value(2118),     -- FUEL_TotalFuelRIO1k 		
			[165] = MainPanel:get_argument_value(2119),     -- FUEL_TotalFuelRIO100	
			[166] = MainPanel:get_argument_value(2000),     -- clock timer minutes
			[167] = MainPanel:get_argument_value(15091),     -- Sweep OFF flag		
			[168] = MainPanel:get_argument_value(15092),      -- Sweep AUTO flag	
			[169] = MainPanel:get_argument_value(15093),      -- Sweep MAN flag
			[170] = MainPanel:get_argument_value(2270),     -- WEAP_Gun_lead_Hundreds		
			[171] = MainPanel:get_argument_value(2271),     -- WEAP_Gun_lead_Tens 			
			[172] = MainPanel:get_argument_value(2272),     -- WEAP_Gun_lead_Ones 			
			[173] = MainPanel:get_argument_value(2273),      -- WEAP_Gun_elevation plus minus 					
			[174] =  MainPanel:get_argument_value(392),       -- CMDS_Chaff_Counter_Roller_10 	
			[175] = MainPanel:get_argument_value(393),     	-- CMDS_Chaff_Counter_Roller_1  	
			[176] =  MainPanel:get_argument_value(394),     	-- CMDS_Flare_Counter_Roller_10 
			[177] =  MainPanel:get_argument_value(395),     	-- CMDS_Flare_Counter_Roller_1  
			[178] =  MainPanel:get_argument_value(396),     	-- CMDS_Jammer_Counter_Roller_10
			[179] = MainPanel:get_argument_value(397),     	-- CMDS_Jammer_Counter_Roller_1 
			[180] = MainPanel:get_argument_value(6100),     -- DDD_range_roller  		
			[181] = MainPanel:get_argument_value(6101),     -- TID_readout_src_roller 
			[182] = MainPanel:get_argument_value(6102),     -- DDD_radar_mode 		
			[183] = MainPanel:get_argument_value(6103),     -- TID_steering_roller 
			[184] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(2121),{0, 0.57, 1},{-1, 0.0, 1.0}) ,     -- RADAR_Elevation_arrow
			[185] = Helios_Util.ValueConvert(MainPanel:get_argument_value(2122),{0, 0.57, 1},{-1, 0.0, 1.0}) ,     	-- TCS_Elevation_arrow 		
			[186] = MainPanel:get_argument_value(414),     -- TACAN_NFO_RIO_INDICATOR 
			[187] = MainPanel:get_argument_value(11600),     	-- CMDS_Flare_Counter_Roller_1  
			[188] = MainPanel:get_argument_value(11601),     	-- CMDS_Jammer_Counter_Roller_10
			[189] = MainPanel:get_argument_value(11602),     	-- CMDS_Jammer_Counter_Roller_1 
			[190] = MainPanel:get_argument_value(673),     -- LANTIRN_OPERSTBY 	
			[191] = MainPanel:get_argument_value(674),     -- LANTIRN_IMUGPS 		
			[192] = MainPanel:get_argument_value(675),     -- LANTIRN_LGPFLIR 	
			[193] = MainPanel:get_argument_value(676),     -- LANTIRN_MUXEGU 					
			[194] = MainPanel:get_argument_value(677),     -- LANTIRN_LASERSERVO 	
			[195] = MainPanel:get_argument_value(678),     -- LANTIRN_FLIRTCS 
			[196] = MainPanel:get_argument_value(666),     -- LANTIRN panel visibility
			[197] = MainPanel:get_argument_value(2006),     -- TID Range   -1, 1
			[198] = MainPanel:get_argument_value(81),     -- Radar elevation center   -1, 1
			[199] = MainPanel:get_argument_value(82)     -- Radar azimuth center   -1, 1




	}	

		-- exporting instruments data
		for a=1, 199 do
			Helios_Udp.Send(tostring(a), string.format("%0.3f",  instruments_table[a] ) )
		end

		local RIO_IAS_Scale=MainPanel:get_argument_value(251)
		
		--rio instruments
		Helios_Udp.Send("6160", string.format("%.3f", MainPanel:get_argument_value(20104) ) ) -- RIOALTI_NeedleBaro 	>> AXIS :: Axis_B_160
		Helios_Udp.Send("6161", string.format("%.3f", MainPanel:get_argument_value(20112) ) ) -- RIOALTI_ThousandsL 	>> AXIS :: Axis_B_161
		Helios_Udp.Send("6162", string.format("%.3f", MainPanel:get_argument_value(20262) ) ) -- RIOALTI_ThousandsR  	>> AXIS :: Axis_B_162
		Helios_Udp.Send("6163", string.format("%.3f", MainPanel:get_argument_value(20300) ) ) -- RIOALTI_HundredsWhite  >> AXIS :: Axis_B_163
		Helios_Udp.Send("6164", string.format("%.3f", MainPanel:get_argument_value(20301) ) ) -- RIOALTI_HundredsSmall1 >> AXIS :: Axis_B_164
		Helios_Udp.Send("6165", string.format("%.3f", MainPanel:get_argument_value(20302) ) ) -- RIOALTI_HundredsSmall2 >> AXIS :: Axis_B_165	
		Helios_Udp.Send("6166", string.format("%.3f", MainPanel:get_argument_value(20303) ) ) -- RIOALTI_HundredsSmall3 >> AXIS :: Axis_B_166
		Helios_Udp.Send("6167", string.format("%.3f", MainPanel:get_argument_value(20304) ) ) -- RIOALTI_HundredsSmall4 >> AXIS :: Axis_B_167
		Helios_Udp.Send("6168", string.format("%.3f", MainPanel:get_argument_value(20305) ) ) -- RIOALTI_STDBYcard  	>> AXIS :: Axis_B_168
		Helios_Udp.Send("6169", string.format("%.3f", MainPanel:get_argument_value(250) ) ) -- AIRSPD_Needle_RIO 	>> AXIS :: Axis_B_169	
		Helios_Udp.Send("6170", string.format("%.3f", RIO_IAS_Scale ) ) 						-- AIRSPD_Inner_RIO  	>> AXIS :: Axis_B_170
		Helios_Udp.Send("6171", string.format("%.3f", MainPanel:get_argument_value(252)-RIO_IAS_Scale ) ) -- AIRSPD_Bug1_RIO  	>> AXIS :: Axis_B_171
		Helios_Udp.Send("6172", string.format("%.3f", MainPanel:get_argument_value(253)-RIO_IAS_Scale ) ) -- AIRSPD_Bug2_RIO  	>> AXIS :: Axis_B_172
		Helios_Udp.Send("6173", string.format("%.3f", MainPanel:get_argument_value(705) ) ) 	-- HI_RIO_Roller1		>> AXIS :: Axis_B_173
		Helios_Udp.Send("6174", string.format("%.3f", MainPanel:get_argument_value(706) ) ) 	-- HI_RIO_Roller2		>> AXIS :: Axis_B_174
		Helios_Udp.Send("6175", string.format("%.3f", MainPanel:get_argument_value(707) ) ) 	-- HI_RIO_Roller3		>> AXIS :: Axis_B_175	
		Helios_Udp.Send("6176", string.format("%.3f", MainPanel:get_argument_value(29109) ) ) 	-- BDHI_CompassRing_RIO	>> AXIS :: Axis_B_176
		Helios_Udp.Send("6177", string.format("%.3f", MainPanel:get_argument_value(29105) ) ) 	-- BDHI_CompassFlag_RIO	>> AXIS :: Axis_B_177
		Helios_Udp.Send("6178", string.format("%.3f", MainPanel:get_argument_value(20699) ) ) 	-- BDHI_NeedleTCN_RIO	>> AXIS :: Axis_B_178
		Helios_Udp.Send("6179", string.format("%.3f", MainPanel:get_argument_value(20700) ) ) 	-- BDHI_NeedleADF_RIO	>> AXIS :: Axis_B_179
		Helios_Udp.Send("6180", string.format("%.3f", MainPanel:get_argument_value(4150) ) ) -- RIO_CLOCK_Hours 			>> AXIS :: Axis_B_180
		Helios_Udp.Send("6181", string.format("%.3f", MainPanel:get_argument_value(4151) ) ) -- RIO_CLOCK_Minutes 			>> AXIS :: Axis_B_181
		Helios_Udp.Send("6182", string.format("%.3f", MainPanel:get_argument_value(4152) ) ) -- RIO_CLOCK_TimerSeconds 		>> AXIS :: Axis_B_182
		Helios_Udp.Send("6183", string.format("%.3f", MainPanel:get_argument_value(4153) ) ) -- RIO_CLOCK_Timer 		  	>> AXIS :: Axis_B_183
		Helios_Udp.Send("6184", string.format("%.3f", MainPanel:get_argument_value(19900) ) ) 	-- STDBYADI_RIO_off  	>> AXIS :: Axis_B_184
		Helios_Udp.Send("6185", string.format("%.3f", MainPanel:get_argument_value(3333) ) ) 	-- STDBYADI_RIO_Pitch 	>> AXIS :: Axis_B_185	
		Helios_Udp.Send("6186", string.format("%.3f", MainPanel:get_argument_value(19901) ) ) 	-- STDBYADI_RIO_Roll  	>> AXIS :: Axis_B_186	
		Helios_Udp.Send("6187", string.format("%.3f", MainPanel:get_argument_value(752) ) ) 	-- Throtle R 	>> AXIS :: Axis_B_187	
		Helios_Udp.Send("6188", string.format("%.3f", MainPanel:get_argument_value(753) ) ) 	-- Throtle L   	>> AXIS :: Axis_B_188			
	

	
	
		
	local lamps_table =
	{	
		[1] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(701)),     	-- emergency store jett light
		[2] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9200)),     	-- master caution lamp
		[3] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9201)),		-- Hot trig
		[4] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9202)),     	-- collision
		[5] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9203)),     	-- seam lock
		[6] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9204)),     	-- gun rate high
		[7] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9205)),     	-- gun rate low
		[8] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9206)),     	-- sw cool on
		[9] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9207)),     	-- sw cool off
		[10] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9208)),    	-- msl prep on
		[11] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9209)),   	-- msl prep off
		[12] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9210)),   	-- normal
		[13] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9211)),   	-- brist
		[14] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9350)),   	-- weels
		[15] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9351)),   	-- brakes
		[16] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9352)),   	-- acl sap
		[17] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9353)),    	-- nws enga
		[18] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9354)),    	-- auto thro
		[19] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9355)),    	-- stall R
		[20] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9356)),    	-- stall L
		[21] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9357)),    	-- sam
		[22] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9358)),    	-- aaa
		[23] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9359)),    	-- ai
		[24] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9360)),    	-- adj a/c
		[25] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9361)),    	-- landing chk
		[26] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9362)),    	-- acl ready
		[27] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9363)),    	-- a/p cplr
		[28] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9364)),    	-- cmd control
		[29] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9365)),    	-- 10 seconds
		[30] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9366)),    	-- tilt
		[31] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9367)),    	-- voice
		[32] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9368)),    	-- auto thro
		[33] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(9369)),    	-- a/p ref
		[34] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15001)),    	-- gear op
		[35] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15014)),    	-- r fire
		[36] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15015)),    	-- l fire
		[37] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15016)),   	-- Lgen
		[38] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15017)),   	-- L oil hot
		[39] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15018)),   	-- L fuel press
		[40] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15019)),   	-- eng fire em
		[41] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15020)),   	-- r gen
		[42] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15021)),   	-- r fuel press
		[43] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15022)),   	-- r oil hot
		[44] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15023)),   	-- wing sweep
		[45] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15024)),   	-- aux fire ext
		[46] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15025)),   	-- yaw stap op
		[47] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15026)),    	-- yaw stab out
		[48] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15027)),    	-- canopy
		[49] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15028)),    	-- cadc
		[50] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15029)),    	-- L fuel low
		[51] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15030)),    	-- wshd hot
		[52] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15031)),   	-- emerg jett
		[53] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15033)),   	-- bingo
		[54] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15034)),   	-- hyd press
		[55] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15035)),   	-- r fuel low
		[56] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15036)),    	-- mach trim
		[57] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15037)),    	-- pitch stab
		[58] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15038)),    	-- bleed duct
		[59] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15039)),    	-- roll stab 1
		[60] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15040)),    	-- pitch stab
		[61] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15041)),   	-- auto pilot
		[62] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15044)),   	-- R ramps
		[63] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15045)),   	-- launch bar
		[64] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15046)),    	-- flap
		[65] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15047)),    	-- hz tail auth
		[66] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15048)),    	-- oil press
		[67] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15049)),    	-- L ramps
		[68] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15050)),    	-- ladder
		[69] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15051)),   	-- R inlet
		[70] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15052)),   	-- inlet ice
		[71] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15053)),   	-- rudder auth
		[72] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15054)),   	-- L inlet
		[73] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15055)),   	-- ahrs
		[74] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15056)),    	-- roll stab 2
		[75] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15057)),    	-- spoilers
		[76] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15058)),    	-- trans/rect
		[77] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15060)),    	-- inter trim
		[78] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15061)),   	-- L eng sec
		[79] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15062)),   	-- rats
		[80] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15063)),   	-- start valve
		[81] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15064)),   	-- R eng sec
		[82] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15070)),    	-- wave off
		[83] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15071)),    	-- wing sweep
		[84] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15072)),    	-- reduce spd
		[85] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15073)),    	-- alt low
		[86] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(19107)),    	-- ralt lamp
		[87] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(3760)),    	-- Approach Indexer green
		[88] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(3761)),    	-- Approach Indexer amber
		[89] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(3762)),   	-- Approach Indexer red
		[90] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(8050)),    	-- TACAN go lamp
		[91] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(8051)),    	-- TACAN no go lamp
		[92] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2200)),     	-- rAnnunc_MCAUT  	
		[93] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2201)),		-- rAnnunc_IFF 		
		[94] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2202)),     	-- rAnnunc_RCV 		
		[95] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2203)),     	-- rAnnunc_XMIT  		
		[96] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2204)),     	-- rAnnunc_SAM  		
		[97] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2205)),     	-- rAnnunc_AAA  		
		[98] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2206)),     	-- rAnnunc_CW  		
		[99] =  Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2208)),     	-- rAnnunc_AI  		
		[100] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2209)),    	-- rAnnunc_CDHOT  	
		[101] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2210)),   	-- rAnnunc_CABINPRESS 
		[102] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2211)),   	-- rAnnunc_FUELLOW  	
		[103] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2212)),   	-- rAnnunc_CANOPY  	
		[104] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2213)),   	-- rAnnunc_FUZEHV  	
		[105] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2214)),   	-- rAnnunc_RDRENABLED 
		[106] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2215)),   	-- rAnnunc_COOLINGAIR 
		[107] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2216)),    	-- rAnnunc_MSLCOND  	
		[108] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2217)),    	-- rAnnunc_AWG9COND  	
		[109] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2218)),    	-- rAnnunc_NAVCOMP  	
		[110] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2219)),    	-- rAnnunc_FILMLOW  	
		[111] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2220)),    	-- rAnnunc_IMU  		
		[112] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2221)),    	-- rAnnunc_AHRS  		
		[113] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2222)),    	-- rAnnunc_WAVEOFF  	
		[114] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2223)),    	-- rAnnunc_LANDCHK  	
		[115] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2224)),    	-- rAnnunc_ACLBEAC  	
		[116] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2225)),    	-- rAnnunc_ACLRDY  	
		[117] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2226)),    	-- rAnnunc_APCPLR  	
		[118] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2227)),    	-- rAnnunc_10SEC  	
		[119] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2228)),    	-- rAnnunc_ADJAC  	
		[120] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2229)),    	-- rAnnunc_VOICE  	
		[121] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2230)),    	-- rAnnunc_TILT  		
		[122] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2231)),    	-- rAnnunc_CMDCHG  	
		[123] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2232)),    	-- rAnnunc_ALTCHG  	
		[124] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2233)),    	-- rAnnunc_MONALT  	
		[125] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2234)),    	-- rAnnunc_MANUAL  	
		[126] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2235)),    	-- rAnnunc_SPDCHG  	
		[127] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2236)),   	-- rAnnunc_MONSPD  	
		[128] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2237)),   	-- rAnnunc_CMDCTRL  	
		[129] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2238)),   	-- rAnnunc_CHGCHN  	
		[130] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2239)),   	-- rAnnunc_HDGCHN  	
		[131] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2240)),   	-- rAnnunc_CANCRPY  	
		[132] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2241)),   	-- rAnnunc_FWDVEC  	
		[133] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2242)),   	-- rAnnunc_AFTVEC  	
		[134] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2243)),   	-- rAnnunc_COIVEC  	
		[135] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2244)),   	-- rAnnunc_NOMSG  	
		[136] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2245)),   	-- rAnnunc_TOWAYPT  	
		[137] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2246)),    	-- rAnnunc_HANDOVER  	
		[138] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2247)),    	-- rAnnunc_ORBIT  	
		[139] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2248)),    	-- rAnnunc_CHALNGE  	
		[140] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2249)),    	-- rAnnunc_ARM1  		
		[141] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2250)),    	-- rAnnunc_ARM2  		
		[142] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2251)),   	-- rAnnunc_ARM3  		
		[143] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2252)),   	-- rAnnunc_NOTCMD  	
		[144] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2253)),   	-- rAnnunc_FRELAN  	
		[145] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2254)),   	-- rAnnunc_DISGAGE  	
		[146] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2255)),    	-- rAnnunc_ABORT  	
		[147] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2256)),    	-- rAnnunc_BEACON  	
		[148] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2257)),    	-- rAnnunc_BEACDUB  	
		[149] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2258)),    	-- rAnnunc_DROP  		
		[150] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2259)),    	-- rAnnunc_BEACOFF  	
		[151] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2260)),   	-- rAnnunc_RETBASE 
		[152] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2199)),    	-- rAnnunc_OXYLOW 		
		[153] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(490)),     	-- TID_STBY_LIGHT 			
		[154] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(491)),     	-- TID_READY_LIGHT 			
		[155] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(2016)),     	-- ACLS_TEST_LIGHT			
		[156] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(492)),     	-- RIO_LAUNCH_LIGHT 			
		[157] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(493)),     	-- DECM_LIGHT 				
		[158] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(8052)),     	-- RIO_IFF_TEST_LIGHT 		
		[159] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(8053)),     	-- RIO_IFF_REPLY_LIGHT 		
		[160] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15002)),		-- Refuel_probe_light	
		[161] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15090)),     -- Hook_Light 				
		[162] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(8892)),     	-- TACAN_LIGHT_NOGO_RIO 	
		[163] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(8893)),     	-- TACAN_LIGHT_GO_RIO
		[164] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(92)),     -- RECORD_standby_lamp 
		[165] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(93)),     --	RECORD_rec_lamp	
		[166] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(94)),     	-- RECORD_endoftape_lamp 
		[167] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15010)),     --	 MASTER_TEST_Go
		[168] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(15011)),     	-- MASTER_TEST_NoGo 
		[169] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(290)),     	--PILOT_TACAN_Indicator_PLT 
		[170] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(291)),     	-- PILOT_TACAN_Indicator_NFO 
		[171] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(407)),     -- HCU_POWER_RESET_LIGHT	
		[172] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(408)),     -- HCU_WCS_POWER_LIGHT
		[173] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(409)),      -- HCU_IR_STBY_LIGHT	
		[174] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(6135)),     	-- 	HCU_mode_light_TVIR
		[175] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(6136)),     	--	HCU_mode_light_RDR
		[176] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(6137)),     	-- 	HCU_mode_light_DDD 
		[177] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(6138)),     	--	HCU_mode_light_TID
		[178] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(11503)),     -- DDD_ANT_TRK_light
		[179] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(11504)),     	--DDD_RDROT_light
		[180] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(11505)),     	-- DDD_JAT_light 
		[181] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(11506)),    	 -- DDD_IROT_light
		[182] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(679)),     -- LANTIRN_IBIT
		[183] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(680))    	-- LANTIRN_LASERARMED

	
	} 
		--flag values in index 1001
		for a=1001, 1183 do
			Helios_Udp.Send(tostring(a), string.format("%1d",  lamps_table[a-1000] ) )
		end
					


					
	Helios_Udp.Flush()
end





function Helios_F14.LowImportance(MainPanel)
	--local MainPanel = GetDevice(0)
	
	
Helios_Udp.Send("2001", string.format("%.1f", MainPanel:get_argument_value(1071) ) ) -- MASTER RESET >> PUSH_BUTTONS :: PB_1
Helios_Udp.Send("2002", string.format("%.1f", MainPanel:get_argument_value(497) ) ) -- Launch Bar Abort >> PUSH_BUTTONS :: PB_2
Helios_Udp.Send("2003", string.format("%.1f", MainPanel:get_argument_value(15083) ) ) -- Fire Ext Bottle - Left >> PUSH_BUTTONS :: PB_3
Helios_Udp.Send("2004", string.format("%.1f", MainPanel:get_argument_value(15082) ) ) -- Fire Ext Bottle - Right >> PUSH_BUTTONS :: PB_4
Helios_Udp.Send("2005", string.format("%.1f", MainPanel:get_argument_value(1041) ) ) -- HSD Test >> PUSH_BUTTONS :: PB_5
Helios_Udp.Send("2006", string.format("%.1f", MainPanel:get_argument_value(2024) ) ) -- ECMD Test >> PUSH_BUTTONS :: PB_6
Helios_Udp.Send("2007", string.format("%.1f", MainPanel:get_argument_value(292) ) ) -- TACAN CMD Button >> PUSH_BUTTONS :: PB_7
Helios_Udp.Send("2008", string.format("%.1f", MainPanel:get_argument_value(135) ) ) -- TACAN CMD Button >> PUSH_BUTTONS :: PB_8
Helios_Udp.Send("2009", string.format("%.1f", MainPanel:get_argument_value(2115) ) ) -- TACAN BIT >> PUSH_BUTTONS :: PB_9
Helios_Udp.Send("2010", string.format("%.1f", MainPanel:get_argument_value(371) ) ) -- TACAN BIT >> PUSH_BUTTONS :: PB_10
Helios_Udp.Send("2011", string.format("%.1f", MainPanel:get_argument_value(911) ) ) -- AN/ARA-63 BIT Button >> PUSH_BUTTONS :: PB_11
Helios_Udp.Send("2012", string.format("%.1f", MainPanel:get_argument_value(8115) ) ) -- UHF ARC-159 Read >> PUSH_BUTTONS :: PB_12
Helios_Udp.Send("2013", string.format("%.1f", MainPanel:get_argument_value(16009) ) ) -- UHF ARC-159 Load >> PUSH_BUTTONS :: PB_13
Helios_Udp.Send("2014", string.format("%.1f", MainPanel:get_argument_value(16010) ) ) -- UHF ARC-159 Tone >> PUSH_BUTTONS :: PB_14
Helios_Udp.Send("2015", string.format("%.1f", MainPanel:get_argument_value(361) ) ) -- KY-28 ZEROIZE >> PUSH_BUTTONS :: PB_15
Helios_Udp.Send("2016", string.format("%.1f", MainPanel:get_argument_value(15004) ) ) -- UHF Radio Remote Display Test >> PUSH_BUTTONS :: PB_16
Helios_Udp.Send("2017", string.format("%.1f", MainPanel:get_argument_value(405) ) ) -- UHF Radio Remote Display Test >> PUSH_BUTTONS :: PB_17
Helios_Udp.Send("2018", string.format("%.1f", MainPanel:get_argument_value(15003) ) ) -- VHF/UHF Radio Remote Display Test >> PUSH_BUTTONS :: PB_18
Helios_Udp.Send("2019", string.format("%.1f", MainPanel:get_argument_value(391) ) ) -- AN/ALE-37 Flare Salvo >> PUSH_BUTTONS :: PB_19
Helios_Udp.Send("2020", string.format("%.1f", MainPanel:get_argument_value(216) ) ) -- AN/ALE-37 Programmer Reset >> PUSH_BUTTONS :: PB_20
Helios_Udp.Send("2021", string.format("%.1f", MainPanel:get_argument_value(228) ) ) -- Accelerometer Reset >> PUSH_BUTTONS :: PB_21
Helios_Udp.Send("2022", string.format("%.1f", MainPanel:get_argument_value(0) ) ) -- VDI filter >> PUSH_BUTTONS :: PB_22
Helios_Udp.Send("2023", string.format("%.1f", MainPanel:get_argument_value(1048) ) ) -- ACM Jettison >> PUSH_BUTTONS :: PB_23
Helios_Udp.Send("2024", string.format("%.1f", MainPanel:get_argument_value(9199) ) ) -- Master Caution Reset >> PUSH_BUTTONS :: PB_24
Helios_Udp.Send("2025", string.format("%.1f", MainPanel:get_argument_value(1000) ) ) -- Clock Timer Start/Stop/Reset >> PUSH_BUTTONS :: PB_25
Helios_Udp.Send("2026", string.format("%.1f", MainPanel:get_argument_value(1053) ) ) -- Clock Timer Start/Stop/Reset >> PUSH_BUTTONS :: PB_26
Helios_Udp.Send("2027", string.format("%.1f", MainPanel:get_argument_value(226) ) ) -- TID Non attack >> PUSH_BUTTONS :: PB_27
Helios_Udp.Send("2028", string.format("%.1f", MainPanel:get_argument_value(1118) ) ) -- TID Jam strobe >> PUSH_BUTTONS :: PB_28
Helios_Udp.Send("2029", string.format("%.1f", MainPanel:get_argument_value(1117) ) ) -- TID Data link >> PUSH_BUTTONS :: PB_29
Helios_Udp.Send("2030", string.format("%.1f", MainPanel:get_argument_value(1116) ) ) -- TID Sym Elem >> PUSH_BUTTONS :: PB_30
Helios_Udp.Send("2031", string.format("%.1f", MainPanel:get_argument_value(1115) ) ) -- TID Alt num >> PUSH_BUTTONS :: PB_31
Helios_Udp.Send("2032", string.format("%.1f", MainPanel:get_argument_value(2004) ) ) -- TID Reject Image Device disable N-F >> PUSH_BUTTONS :: PB_32
Helios_Udp.Send("2033", string.format("%.1f", MainPanel:get_argument_value(2113) ) ) -- TID Launch zone >> PUSH_BUTTONS :: PB_33
Helios_Udp.Send("2034", string.format("%.1f", MainPanel:get_argument_value(2114) ) ) -- TID Velocity vector >> PUSH_BUTTONS :: PB_34
Helios_Udp.Send("2035", string.format("%.1f", MainPanel:get_argument_value(52) ) ) -- collision steering >> PUSH_BUTTONS :: PB_35
Helios_Udp.Send("2036", string.format("%.1f", MainPanel:get_argument_value(53) ) ) -- TID track hold >> PUSH_BUTTONS :: PB_36
Helios_Udp.Send("2037", string.format("%.1f", MainPanel:get_argument_value(2013) ) ) -- Power reset >> PUSH_BUTTONS :: PB_37
Helios_Udp.Send("2038", string.format("%.1f", MainPanel:get_argument_value(2014) ) ) -- Light test >> PUSH_BUTTONS :: PB_38
Helios_Udp.Send("2039", string.format("%.1f", MainPanel:get_argument_value(40) ) ) -- RADAR 5 NM >> PUSH_BUTTONS :: PB_39
Helios_Udp.Send("2040", string.format("%.1f", MainPanel:get_argument_value(41) ) ) -- RADAR 10 NM >> PUSH_BUTTONS :: PB_40
Helios_Udp.Send("2041", string.format("%.1f", MainPanel:get_argument_value(42) ) ) -- RADAR 20 NM >> PUSH_BUTTONS :: PB_41
Helios_Udp.Send("2042", string.format("%.1f", MainPanel:get_argument_value(43) ) ) -- RADAR 50 NM >> PUSH_BUTTONS :: PB_42
Helios_Udp.Send("2043", string.format("%.1f", MainPanel:get_argument_value(44) ) ) -- RADAR 100 NM >> PUSH_BUTTONS :: PB_43
Helios_Udp.Send("2044", string.format("%.1f", MainPanel:get_argument_value(45) ) ) -- RADAR 200 NM >> PUSH_BUTTONS :: PB_44
Helios_Udp.Send("2045", string.format("%.1f", MainPanel:get_argument_value(0) ) ) -- DDD filter >> PUSH_BUTTONS :: PB_45
Helios_Udp.Send("2046", string.format("%.1f", MainPanel:get_argument_value(10) ) ) -- RADAR pulse search >> PUSH_BUTTONS :: PB_46
Helios_Udp.Send("2047", string.format("%.1f", MainPanel:get_argument_value(11) ) ) -- RADAR track while scan manual >> PUSH_BUTTONS :: PB_47
Helios_Udp.Send("2048", string.format("%.1f", MainPanel:get_argument_value(12) ) ) -- RADAR track while scan auto >> PUSH_BUTTONS :: PB_48
Helios_Udp.Send("2049", string.format("%.1f", MainPanel:get_argument_value(13) ) ) -- RADAR range while scan >> PUSH_BUTTONS :: PB_49
Helios_Udp.Send("2050", string.format("%.1f", MainPanel:get_argument_value(14) ) ) -- RADAR pulse doppler search >> PUSH_BUTTONS :: PB_50
Helios_Udp.Send("2051", string.format("%.1f", MainPanel:get_argument_value(15) ) ) -- RADAR pulse single target track >> PUSH_BUTTONS :: PB_51
Helios_Udp.Send("2052", string.format("%.1f", MainPanel:get_argument_value(9916) ) ) -- RADAR pulse doppler single target track >> PUSH_BUTTONS :: PB_52
Helios_Udp.Send("2053", string.format("%.1f", MainPanel:get_argument_value(17) ) ) -- DDD Interrogate Friend or Foe >> PUSH_BUTTONS :: PB_53
Helios_Udp.Send("2054", string.format("%.1f", MainPanel:get_argument_value(18) ) ) -- DDD Infrared N-F >> PUSH_BUTTONS :: PB_54
Helios_Udp.Send("2055", string.format("%.1f", MainPanel:get_argument_value(19) ) ) -- DDD RADAR >> PUSH_BUTTONS :: PB_55
Helios_Udp.Send("2056", string.format("%.1f", MainPanel:get_argument_value(1812) ) ) -- CCM SPL N-F >> PUSH_BUTTONS :: PB_56
Helios_Udp.Send("2057", string.format("%.1f", MainPanel:get_argument_value(1813) ) ) -- CCM ALT DIFF N-F >> PUSH_BUTTONS :: PB_57
Helios_Udp.Send("2058", string.format("%.1f", MainPanel:get_argument_value(1814) ) ) -- CCM VGS N-F >> PUSH_BUTTONS :: PB_58
Helios_Udp.Send("2059", string.format("%.1f", MainPanel:get_argument_value(74) ) ) -- A/A Launch >> PUSH_BUTTONS :: PB_59
Helios_Udp.Send("2060", string.format("%.1f", MainPanel:get_argument_value(9964) ) ) -- Next Launch >> PUSH_BUTTONS :: PB_60
Helios_Udp.Send("2061", string.format("%.1f", MainPanel:get_argument_value(123) ) ) -- CAP btn 5 >> PUSH_BUTTONS :: PB_61
Helios_Udp.Send("2062", string.format("%.1f", MainPanel:get_argument_value(124) ) ) -- CAP btn 4 >> PUSH_BUTTONS :: PB_62
Helios_Udp.Send("2063", string.format("%.1f", MainPanel:get_argument_value(125) ) ) -- CAP btn 3 >> PUSH_BUTTONS :: PB_63
Helios_Udp.Send("2064", string.format("%.1f", MainPanel:get_argument_value(126) ) ) -- CAP btn 2 >> PUSH_BUTTONS :: PB_64
Helios_Udp.Send("2065", string.format("%.1f", MainPanel:get_argument_value(127) ) ) -- CAP btn 1 >> PUSH_BUTTONS :: PB_65
Helios_Udp.Send("2066", string.format("%.1f", MainPanel:get_argument_value(128) ) ) -- CAP TNG NBR >> PUSH_BUTTONS :: PB_66
Helios_Udp.Send("2067", string.format("%.1f", MainPanel:get_argument_value(129) ) ) -- CAP btn 10 >> PUSH_BUTTONS :: PB_67
Helios_Udp.Send("2068", string.format("%.1f", MainPanel:get_argument_value(130) ) ) -- CAP btn 9 >> PUSH_BUTTONS :: PB_68
Helios_Udp.Send("2069", string.format("%.1f", MainPanel:get_argument_value(131) ) ) -- CAP btn 8 >> PUSH_BUTTONS :: PB_69
Helios_Udp.Send("2070", string.format("%.1f", MainPanel:get_argument_value(132) ) ) -- CAP btn 7 >> PUSH_BUTTONS :: PB_70
Helios_Udp.Send("2071", string.format("%.1f", MainPanel:get_argument_value(133) ) ) -- CAP btn 6 >> PUSH_BUTTONS :: PB_71
Helios_Udp.Send("2072", string.format("%.1f", MainPanel:get_argument_value(134) ) ) -- CAP PGM RSTRT >> PUSH_BUTTONS :: PB_72
Helios_Udp.Send("2073", string.format("%.1f", MainPanel:get_argument_value(117) ) ) -- ACLS test >> PUSH_BUTTONS :: PB_73
Helios_Udp.Send("2074", string.format("%.1f", MainPanel:get_argument_value(185) ) ) -- IFF test N-F >> PUSH_BUTTONS :: PB_74
Helios_Udp.Send("2075", string.format("%.1f", MainPanel:get_argument_value(186) ) ) -- IFF reply N-F >> PUSH_BUTTONS :: PB_75
Helios_Udp.Send("2076", string.format("%.1f", MainPanel:get_argument_value(670) ) ) -- Video Output Toggle (TCS/LANTIRN) >> PUSH_BUTTONS :: PB_76
Helios_Udp.Send("2077", string.format("%.1f", MainPanel:get_argument_value(669) ) ) -- LANTIRN Operate Mode (Unstow) >> PUSH_BUTTONS :: PB_77
Helios_Udp.Send("2078", string.format("%.1f", MainPanel:get_argument_value(671) ) ) -- LANTIRN IBIT >> PUSH_BUTTONS :: PB_78
Helios_Udp.Send("2079", string.format("%.1f", MainPanel:get_argument_value(16000) ) ) -- Gun rate >> PUSH_BUTTONS :: PB_79
Helios_Udp.Send("2080", string.format("%.1f", MainPanel:get_argument_value(16001) ) ) -- Sidewinder cool >> PUSH_BUTTONS :: PB_80
Helios_Udp.Send("2081", string.format("%.1f", MainPanel:get_argument_value(16002) ) ) -- Missile prepare >> PUSH_BUTTONS :: PB_81
Helios_Udp.Send("2082", string.format("%.1f", MainPanel:get_argument_value(16003) ) ) -- Missile mode >> PUSH_BUTTONS :: PB_82
Helios_Udp.Send("2083", string.format("%.1f", MainPanel:get_argument_value(239) ) ) -- Emergency stores jettison >> PUSH_BUTTONS :: PB_83
Helios_Udp.Send("2084", string.format("%.1f", MainPanel:get_argument_value(136) ) ) -- CAP LONG 6 >> PUSH_BUTTONS :: PB_84
Helios_Udp.Send("2085", string.format("%.1f", MainPanel:get_argument_value(137) ) ) -- CAP LAT 1 >> PUSH_BUTTONS :: PB_85
Helios_Udp.Send("2086", string.format("%.1f", MainPanel:get_argument_value(138) ) ) -- CAP NBR 2 >> PUSH_BUTTONS :: PB_86
Helios_Udp.Send("2087", string.format("%.1f", MainPanel:get_argument_value(139) ) ) -- CAP 7 >> PUSH_BUTTONS :: PB_87
Helios_Udp.Send("2088", string.format("%.1f", MainPanel:get_argument_value(140) ) ) -- CAP HDG 8 >> PUSH_BUTTONS :: PB_88
Helios_Udp.Send("2089", string.format("%.1f", MainPanel:get_argument_value(141) ) ) -- CAP SPD 3 >> PUSH_BUTTONS :: PB_89
Helios_Udp.Send("2090", string.format("%.1f", MainPanel:get_argument_value(143) ) ) -- CAP ALT 4 >> PUSH_BUTTONS :: PB_90
Helios_Udp.Send("2091", string.format("%.1f", MainPanel:get_argument_value(142) ) ) -- CAP 9 >> PUSH_BUTTONS :: PB_91
Helios_Udp.Send("2092", string.format("%.1f", MainPanel:get_argument_value(144) ) ) -- CAP BRG 0 >> PUSH_BUTTONS :: PB_92
Helios_Udp.Send("2093", string.format("%.1f", MainPanel:get_argument_value(145) ) ) -- CAP RNG 5 >> PUSH_BUTTONS :: PB_93
Helios_Udp.Send("2094", string.format("%.1f", MainPanel:get_argument_value(146) ) ) -- CAP N+E >> PUSH_BUTTONS :: PB_94
Helios_Udp.Send("2095", string.format("%.1f", MainPanel:get_argument_value(147) ) ) -- CAP S-W >> PUSH_BUTTONS :: PB_95
Helios_Udp.Send("2096", string.format("%.1f", MainPanel:get_argument_value(148) ) ) -- CAP clear >> PUSH_BUTTONS :: PB_96
Helios_Udp.Send("2097", string.format("%.1f", MainPanel:get_argument_value(149) ) ) -- CAP enter >> PUSH_BUTTONS :: PB_97
Helios_Udp.Send("2098", string.format("%.1f", MainPanel:get_argument_value(16020) ) ) -- Radar Altimeter Control Knob BTN >> PUSH_BUTTONS :: PB_98
Helios_Udp.Send("2099", string.format("%.1f", MainPanel:get_argument_value(16014) ) ) -- Compass HDG Slave Knob/nPush >> PUSH_BUTTONS :: PB_99
Helios_Udp.Send("2100", string.format("%.1f", MainPanel:get_argument_value(929) ) ) -- Air Source Ram >> PUSH_BUTTONS :: PB_100
Helios_Udp.Send("2101", string.format("%.1f", MainPanel:get_argument_value(933) ) ) -- Air Source Off >> PUSH_BUTTONS :: PB_101
Helios_Udp.Send("2102", string.format("%.1f", MainPanel:get_argument_value(930) ) ) -- Air Source Left Engine >> PUSH_BUTTONS :: PB_102
Helios_Udp.Send("2103", string.format("%.1f", MainPanel:get_argument_value(931) ) ) -- Air Source Right Engine >> PUSH_BUTTONS :: PB_103
Helios_Udp.Send("2104", string.format("%.1f", MainPanel:get_argument_value(932) ) ) -- Air Source Both Engines >> PUSH_BUTTONS :: PB_104
Helios_Udp.Send("2105", string.format("%.1f", MainPanel:get_argument_value(1002) ) ) -- Navigation Steer Commands: TACAN >> PUSH_BUTTONS :: PB_105
Helios_Udp.Send("2106", string.format("%.1f", MainPanel:get_argument_value(1003) ) ) -- Navigation Steer Commands: Destination >> PUSH_BUTTONS :: PB_106
Helios_Udp.Send("2107", string.format("%.1f", MainPanel:get_argument_value(1004) ) ) -- Navigation Steer Commands: AWL PCD >> PUSH_BUTTONS :: PB_107
Helios_Udp.Send("2108", string.format("%.1f", MainPanel:get_argument_value(1005) ) ) -- Navigation Steer Commands: Vector >> PUSH_BUTTONS :: PB_108
Helios_Udp.Send("2109", string.format("%.1f", MainPanel:get_argument_value(1006) ) ) -- Navigation Steer Commands: Manual >> PUSH_BUTTONS :: PB_109
Helios_Udp.Send("2110", string.format("%.1f", MainPanel:get_argument_value(1015) ) ) -- HUD Take-Off Mode >> PUSH_BUTTONS :: PB_110
Helios_Udp.Send("2111", string.format("%.1f", MainPanel:get_argument_value(1014) ) ) -- HUD Cruise Mode >> PUSH_BUTTONS :: PB_111
Helios_Udp.Send("2112", string.format("%.1f", MainPanel:get_argument_value(1013) ) ) -- HUD Air-to-Air Mode >> PUSH_BUTTONS :: PB_112
Helios_Udp.Send("2113", string.format("%.1f", MainPanel:get_argument_value(1012) ) ) -- HUD Air-to-Ground Mode >> PUSH_BUTTONS :: PB_113
Helios_Udp.Send("2114", string.format("%.1f", MainPanel:get_argument_value(1011) ) ) -- HUD Landing Mode >> PUSH_BUTTONS :: PB_114
Helios_Udp.Send("3001", string.format("%1d", MainPanel:get_argument_value(631) ) ) -- Hydraulic Isolation Switch >> TOGLEE_SWITCH :: TSwitch_1
Helios_Udp.Send("3002", string.format("%1d", MainPanel:get_argument_value(629) ) ) -- Hydraulic Transfer Pump Switch >> TOGLEE_SWITCH :: TSwitch_2
Helios_Udp.Send("3003", string.format("%1d", MainPanel:get_argument_value(2100) ) ) -- Stow Inlet Ramps Left Switch >> TOGLEE_SWITCH :: TSwitch_3
Helios_Udp.Send("3004", string.format("%1d", MainPanel:get_argument_value(2101) ) ) -- Stow Inlet Ramps Right Switch >> TOGLEE_SWITCH :: TSwitch_4
Helios_Udp.Send("3005", string.format("%1d", MainPanel:get_argument_value(2106) ) ) -- AFCS Stability Augmentation - Pitch >> TOGLEE_SWITCH :: TSwitch_5
Helios_Udp.Send("3006", string.format("%1d", MainPanel:get_argument_value(2107) ) ) -- AFCS Stability Augmentation - Roll >> TOGLEE_SWITCH :: TSwitch_6
Helios_Udp.Send("3007", string.format("%1d", MainPanel:get_argument_value(2108) ) ) -- AFCS Stability Augmentation - Yaw >> TOGLEE_SWITCH :: TSwitch_7
Helios_Udp.Send("3008", string.format("%1d", MainPanel:get_argument_value(2110) ) ) -- Autopilot - Altitude Hold >> TOGLEE_SWITCH :: TSwitch_8
Helios_Udp.Send("3009", string.format("%1d", MainPanel:get_argument_value(2112) ) ) -- Autopilot - Engage >> TOGLEE_SWITCH :: TSwitch_9
Helios_Udp.Send("3010", string.format("%1d", MainPanel:get_argument_value(12300) ) ) -- Left Engine Fuel Cutoff >> TOGLEE_SWITCH :: TSwitch_10
Helios_Udp.Send("3011", string.format("%1d", MainPanel:get_argument_value(12301) ) ) -- Right Engine Fuel Cutoff >> TOGLEE_SWITCH :: TSwitch_11
Helios_Udp.Send("3012", string.format("%1d", MainPanel:get_argument_value(2105) ) ) -- Engine Airstart >> TOGLEE_SWITCH :: TSwitch_12
Helios_Udp.Send("3013", string.format("%1d", MainPanel:get_argument_value(16007) ) ) -- Left Engine Mode >> TOGLEE_SWITCH :: TSwitch_13
Helios_Udp.Send("3014", string.format("%1d", MainPanel:get_argument_value(16008) ) ) -- Right Engine Mode >> TOGLEE_SWITCH :: TSwitch_14
Helios_Udp.Send("3015", string.format("%1d", MainPanel:get_argument_value(16005) ) ) -- Asymmetric Thrust Limiter Cover >> TOGLEE_SWITCH :: TSwitch_15
Helios_Udp.Send("3016", string.format("%1d", MainPanel:get_argument_value(16006) ) ) -- Asymmetric Thrust Limiter >> TOGLEE_SWITCH :: TSwitch_16
Helios_Udp.Send("3017", string.format("%1d", MainPanel:get_argument_value(1074) ) ) -- Fuel Dump >> TOGLEE_SWITCH :: TSwitch_17
Helios_Udp.Send("3018", string.format("%1d", MainPanel:get_argument_value(926) ) ) -- Emergency Generator Switch >> TOGLEE_SWITCH :: TSwitch_18
Helios_Udp.Send("3019", string.format("%1d", MainPanel:get_argument_value(8114) ) ) -- Pilot Oxygen On >> TOGLEE_SWITCH :: TSwitch_19
Helios_Udp.Send("3020", string.format("%1d", MainPanel:get_argument_value(119) ) ) -- RIO Oxygen On >> TOGLEE_SWITCH :: TSwitch_20
Helios_Udp.Send("3021", string.format("%1d", MainPanel:get_argument_value(939) ) ) -- Cabin Pressure Dump >> TOGLEE_SWITCH :: TSwitch_21
Helios_Udp.Send("3022", string.format("%1d", MainPanel:get_argument_value(940) ) ) -- Temp Auto / Man >> TOGLEE_SWITCH :: TSwitch_22
Helios_Udp.Send("3023", string.format("%1d", MainPanel:get_argument_value(938) ) ) -- Ram Air >> TOGLEE_SWITCH :: TSwitch_23
Helios_Udp.Send("3024", string.format("%1d", MainPanel:get_argument_value(915) ) ) -- Hook Bypass >> TOGLEE_SWITCH :: TSwitch_24
Helios_Udp.Send("3025", string.format("%1d", MainPanel:get_argument_value(918) ) ) -- Taxi Light >> TOGLEE_SWITCH :: TSwitch_25
Helios_Udp.Send("3026", string.format("%1d", MainPanel:get_argument_value(919) ) ) -- Position Lights Flash >> TOGLEE_SWITCH :: TSwitch_26
Helios_Udp.Send("3027", string.format("%1d", MainPanel:get_argument_value(923) ) ) -- Anti-Collision Lights >> TOGLEE_SWITCH :: TSwitch_27
Helios_Udp.Send("3028", string.format("%1d", MainPanel:get_argument_value(1010) ) ) -- VDI Power On/Off >> TOGLEE_SWITCH :: TSwitch_28
Helios_Udp.Send("3029", string.format("%1d", MainPanel:get_argument_value(1009) ) ) -- HUD Power On/Off >> TOGLEE_SWITCH :: TSwitch_29
Helios_Udp.Send("3030", string.format("%1d", MainPanel:get_argument_value(1008) ) ) -- HSD/ECMD Power On/Off >> TOGLEE_SWITCH :: TSwitch_30
Helios_Udp.Send("3031", string.format("%1d", MainPanel:get_argument_value(1016) ) ) -- HSD Display Mode >> TOGLEE_SWITCH :: TSwitch_31
Helios_Udp.Send("3032", string.format("%1d", MainPanel:get_argument_value(1017) ) ) -- HSD ECM Override >> TOGLEE_SWITCH :: TSwitch_32

Helios_Udp.Send("3035", string.format("%1d", MainPanel:get_argument_value(373) ) ) -- TACAN Mode Normal/Inverse >> TOGLEE_SWITCH :: TSwitch_35
Helios_Udp.Send("3036", string.format("%1d", MainPanel:get_argument_value(372) ) ) -- TACAN Channel X/Y >> TOGLEE_SWITCH :: TSwitch_36
Helios_Udp.Send("3037", string.format("%1d", MainPanel:get_argument_value(910) ) ) -- AN/ARA-63 Power Switch >> TOGLEE_SWITCH :: TSwitch_37
Helios_Udp.Send("3038", string.format("%1d", MainPanel:get_argument_value(380) ) ) -- V/UHF 2 ANT Switch >> TOGLEE_SWITCH :: TSwitch_38
Helios_Udp.Send("3039", string.format("%1d", MainPanel:get_argument_value(2035) ) ) -- UHF ARC-159 Squelch Switch >> TOGLEE_SWITCH :: TSwitch_39
Helios_Udp.Send("3040", string.format("%1d", MainPanel:get_argument_value(359) ) ) -- VHF/UHF ARC-182 FM/AM Switch >> TOGLEE_SWITCH :: TSwitch_40
Helios_Udp.Send("3041", string.format("%1d", MainPanel:get_argument_value(351) ) ) -- VHF/UHF ARC-182 Squelch Switch >> TOGLEE_SWITCH :: TSwitch_41
Helios_Udp.Send("3042", string.format("%1d", MainPanel:get_argument_value(2139) ) ) -- AN/ALR-67 Power >> TOGLEE_SWITCH :: TSwitch_42
Helios_Udp.Send("3043", string.format("%1d", MainPanel:get_argument_value(906) ) ) -- Compass N-S Hemisphere >> TOGLEE_SWITCH :: TSwitch_43
Helios_Udp.Send("3044", string.format("%1d", MainPanel:get_argument_value(902) ) ) -- Inboard Spoiler Override Cover >> TOGLEE_SWITCH :: TSwitch_44
Helios_Udp.Send("3045", string.format("%1d", MainPanel:get_argument_value(903) ) ) -- Outboard Spoiler Override Cover >> TOGLEE_SWITCH :: TSwitch_45
Helios_Udp.Send("3046", string.format("%1d", MainPanel:get_argument_value(908) ) ) -- Inboard Spoiler Override >> TOGLEE_SWITCH :: TSwitch_46
Helios_Udp.Send("3047", string.format("%1d", MainPanel:get_argument_value(907) ) ) -- Outboard Spoiler Override >> TOGLEE_SWITCH :: TSwitch_47
Helios_Udp.Send("3048", string.format("%1d", MainPanel:get_argument_value(1019) ) ) -- VDI Display Mode >> TOGLEE_SWITCH :: TSwitch_48
Helios_Udp.Send("3049", string.format("%1d", MainPanel:get_argument_value(1018) ) ) -- VDI Landing Mode >> TOGLEE_SWITCH :: TSwitch_49
Helios_Udp.Send("3050", string.format("%1d", MainPanel:get_argument_value(1021) ) ) -- HUD De-clutter On/Off >> TOGLEE_SWITCH :: TSwitch_50
Helios_Udp.Send("3051", string.format("%1d", MainPanel:get_argument_value(1020) ) ) -- HUD AWL Mode >> TOGLEE_SWITCH :: TSwitch_51
Helios_Udp.Send("3052", string.format("%1d", MainPanel:get_argument_value(2007) ) ) -- HCU TCS mode >> TOGLEE_SWITCH :: TSwitch_52
Helios_Udp.Send("3053", string.format("%1d", MainPanel:get_argument_value(2008) ) ) -- HCU radar mode >> TOGLEE_SWITCH :: TSwitch_53
Helios_Udp.Send("3054", string.format("%1d", MainPanel:get_argument_value(2009) ) ) -- HCU DDD mode >> TOGLEE_SWITCH :: TSwitch_54
Helios_Udp.Send("3055", string.format("%1d", MainPanel:get_argument_value(2010) ) ) -- HCU TID mode >> TOGLEE_SWITCH :: TSwitch_55
--Helios_Udp.Send("3056", string.format("%1d", MainPanel:get_argument_value(38) ) ) -- Automatic Gain Control N-F >> TOGLEE_SWITCH :: TSwitch_56
--Helios_Udp.Send("3057", string.format("%1d", MainPanel:get_argument_value(3900) ) ) -- Parametric amplifier N-F >> TOGLEE_SWITCH :: TSwitch_57
Helios_Udp.Send("3058", string.format("%1d", MainPanel:get_argument_value(83) ) ) -- Stabilize >> TOGLEE_SWITCH :: TSwitch_58
-- Helios_Udp.Send("3059", string.format("%1d", MainPanel:get_argument_value(88) ) ) -- TCS FOV >> TOGLEE_SWITCH :: TSwitch_59
Helios_Udp.Send("3060", string.format("%1d", MainPanel:get_argument_value(60) ) ) -- Bomb single/pairs >> TOGLEE_SWITCH :: TSwitch_60
Helios_Udp.Send("3061", string.format("%1d", MainPanel:get_argument_value(61) ) ) -- Bomb step/ripple >> TOGLEE_SWITCH :: TSwitch_61
Helios_Udp.Send("3062", string.format("%1d", MainPanel:get_argument_value(62) ) ) -- A/G gun mode >> TOGLEE_SWITCH :: TSwitch_62
Helios_Udp.Send("3063", string.format("%1d", MainPanel:get_argument_value(66) ) ) -- Jettison racks/weapons >> TOGLEE_SWITCH :: TSwitch_63
Helios_Udp.Send("3064", string.format("%1d", MainPanel:get_argument_value(73) ) ) -- Jettison left tank >> TOGLEE_SWITCH :: TSwitch_64
Helios_Udp.Send("3065", string.format("%1d", MainPanel:get_argument_value(67) ) ) -- Jettison right tank >> TOGLEE_SWITCH :: TSwitch_65
Helios_Udp.Send("3066", string.format("%1d", MainPanel:get_argument_value(65) ) ) -- Jettison station 3 >> TOGLEE_SWITCH :: TSwitch_66
Helios_Udp.Send("3067", string.format("%1d", MainPanel:get_argument_value(69) ) ) -- Jettison station 4 >> TOGLEE_SWITCH :: TSwitch_67
Helios_Udp.Send("3068", string.format("%1d", MainPanel:get_argument_value(70) ) ) -- Jettison station 5 >> TOGLEE_SWITCH :: TSwitch_68
Helios_Udp.Send("3069", string.format("%1d", MainPanel:get_argument_value(64) ) ) -- Jettison station 6 >> TOGLEE_SWITCH :: TSwitch_69
Helios_Udp.Send("3070", string.format("%1d", MainPanel:get_argument_value(175) ) ) -- Datalink Antenna N-F >> TOGLEE_SWITCH :: TSwitch_70
Helios_Udp.Send("3071", string.format("%1d", MainPanel:get_argument_value(176) ) ) -- Datalink Reply N-F >> TOGLEE_SWITCH :: TSwitch_71
Helios_Udp.Send("3072", string.format("%1d", MainPanel:get_argument_value(177) ) ) -- Datalink CAINS/TAC >> TOGLEE_SWITCH :: TSwitch_72
Helios_Udp.Send("3073", string.format("%1d", MainPanel:get_argument_value(181) ) ) -- IFF M4 N-F >> TOGLEE_SWITCH :: TSwitch_73
Helios_Udp.Send("3074", string.format("%1d", MainPanel:get_argument_value(668) ) ) -- LANTIRN Laser Arm Switch >> TOGLEE_SWITCH :: TSwitch_74
Helios_Udp.Send("3075", string.format("%1d", MainPanel:get_argument_value(630) ) ) -- Hydraulic Transfer Pump Switch Cover >> TOGLEE_SWITCH :: TSwitch_75
Helios_Udp.Send("3076", string.format("%1d", MainPanel:get_argument_value(615) ) ) -- Hydraulic Emergency Flight Control Switch Cover >> TOGLEE_SWITCH :: TSwitch_76
Helios_Udp.Send("3077", string.format("%1d", MainPanel:get_argument_value(496) ) ) -- Launch Bar Abort Switch Cover >> TOGLEE_SWITCH :: TSwitch_77
Helios_Udp.Send("3078", string.format("%1d", MainPanel:get_argument_value(1094) ) ) -- Fuel Feed Cover >> TOGLEE_SWITCH :: TSwitch_78
Helios_Udp.Send("3079", string.format("%1d", MainPanel:get_argument_value(927) ) ) -- Emergency Generator Switch Cover >> TOGLEE_SWITCH :: TSwitch_79
Helios_Udp.Send("3080", string.format("%1d", MainPanel:get_argument_value(150) ) ) -- KY-28 ZEROIZE Cover >> TOGLEE_SWITCH :: TSwitch_80
Helios_Udp.Send("3081", string.format("%1d", MainPanel:get_argument_value(15096) ) ) -- Emergency Wing Sweep Handle TUMB >> TOGLEE_SWITCH :: TSwitch_81
Helios_Udp.Send("3082", string.format("%1d", MainPanel:get_argument_value(2127) ) ) -- Airspeed Indicator Bug Knob TUMB >> TOGLEE_SWITCH :: TSwitch_82
Helios_Udp.Send("3083", string.format("%1d", MainPanel:get_argument_value(326) ) ) -- Landing Gear Lever TUMB >> TOGLEE_SWITCH :: TSwitch_83
Helios_Udp.Send("3084", string.format("%1d", MainPanel:get_argument_value(16015) ) ) -- Landing Gear Lever emergency TUMB >> TOGLEE_SWITCH :: TSwitch_84
Helios_Udp.Send("3085", string.format("%1d", MainPanel:get_argument_value(238) ) ) -- Hook Extension Handle TUMB >> TOGLEE_SWITCH :: TSwitch_85
Helios_Udp.Send("3086", string.format("%1d", MainPanel:get_argument_value(15078) ) ) -- Hook Extension Handle cycle emergency mode TUMB >> TOGLEE_SWITCH :: TSwitch_86
Helios_Udp.Send("3088", string.format("%1d", MainPanel:get_argument_value(15098) ) ) -- Master Test Selector pull/push >> TOGLEE_SWITCH :: TSwitch_88
Helios_Udp.Send("3089", string.format("%1d", MainPanel:get_argument_value(19100) ) ) -- Standby ADI Knob TUMB >> TOGLEE_SWITCH :: TSwitch_89
Helios_Udp.Send("3090", string.format("%1d", MainPanel:get_argument_value(6155) ) ) -- RIO Standby ADI Knob TUMB >> TOGLEE_SWITCH :: TSwitch_90
Helios_Udp.Send("5001", string.format("%1d", MainPanel:get_argument_value(928) ) ) -- Hydraulic Emergency Flight Control Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_1
Helios_Udp.Send("5002", string.format("%1d", MainPanel:get_argument_value(1072) ) ) -- Anti-Skid Spoiler BK Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_2
Helios_Udp.Send("5003", string.format("%1d", MainPanel:get_argument_value(2109) ) ) -- Autopilot - Vector / Automatic Carrier Landing >> TREE_WAY_SWITCH :: 3WSwitch_A_3
Helios_Udp.Send("5004", string.format("%1d", MainPanel:get_argument_value(2111) ) ) -- Autopilot - Heading / Ground Track >> TREE_WAY_SWITCH :: 3WSwitch_A_4
Helios_Udp.Send("5005", string.format("%1d", MainPanel:get_argument_value(2104) ) ) -- Throttle Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_5
Helios_Udp.Send("5006", string.format("%1d", MainPanel:get_argument_value(2103) ) ) -- Throttle Temp >> TREE_WAY_SWITCH :: 3WSwitch_A_6
Helios_Udp.Send("5007", string.format("%1d", MainPanel:get_argument_value(941) ) ) -- Engine/Probe Anti-Ice >> TREE_WAY_SWITCH :: 3WSwitch_A_7
Helios_Udp.Send("5008", string.format("%1d", MainPanel:get_argument_value(2102) ) ) -- Engine Crank >> TREE_WAY_SWITCH :: 3WSwitch_A_8
Helios_Udp.Send("5009", string.format("%1d", MainPanel:get_argument_value(1095) ) ) -- Fuel Feed >> TREE_WAY_SWITCH :: 3WSwitch_A_9
Helios_Udp.Send("5010", string.format("%1d", MainPanel:get_argument_value(1001) ) ) -- Wing/Ext Trans >> TREE_WAY_SWITCH :: 3WSwitch_A_10
Helios_Udp.Send("5011", string.format("%1d", MainPanel:get_argument_value(1073) ) ) -- Refuel Probe >> TREE_WAY_SWITCH :: 3WSwitch_A_11
Helios_Udp.Send("5012", string.format("%1d", MainPanel:get_argument_value(937) ) ) -- Left Generator Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_12
Helios_Udp.Send("5013", string.format("%1d", MainPanel:get_argument_value(936) ) ) -- Right Generator Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_13
Helios_Udp.Send("5014", string.format("%1d", MainPanel:get_argument_value(942) ) ) -- Wind Shield Air >> TREE_WAY_SWITCH :: 3WSwitch_A_14
Helios_Udp.Send("5015", string.format("%1d", MainPanel:get_argument_value(924) ) ) -- Red Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_15
Helios_Udp.Send("5016", string.format("%1d", MainPanel:get_argument_value(921) ) ) -- White Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_16
Helios_Udp.Send("5017", string.format("%1d", MainPanel:get_argument_value(913) ) ) -- Position Lights Wing >> TREE_WAY_SWITCH :: 3WSwitch_A_17
Helios_Udp.Send("5018", string.format("%1d", MainPanel:get_argument_value(916) ) ) -- Position Lights Tail >> TREE_WAY_SWITCH :: 3WSwitch_A_18
Helios_Udp.Send("5019", string.format("%1d", MainPanel:get_argument_value(194) ) ) -- Red Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_19
Helios_Udp.Send("5020", string.format("%1d", MainPanel:get_argument_value(159) ) ) -- White Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_20
Helios_Udp.Send("5021", string.format("%1d", MainPanel:get_argument_value(2044) ) ) -- ICS Function Selector >> TREE_WAY_SWITCH :: 3WSwitch_A_21
Helios_Udp.Send("5022", string.format("%1d", MainPanel:get_argument_value(402) ) ) -- ICS Function Selector >> TREE_WAY_SWITCH :: 3WSwitch_A_22
Helios_Udp.Send("5023", string.format("%1d", MainPanel:get_argument_value(381) ) ) -- XMTR SEL Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_23
Helios_Udp.Send("5024", string.format("%1d", MainPanel:get_argument_value(382) ) ) -- KY MODE Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_24
Helios_Udp.Send("5025", string.format("%1d", MainPanel:get_argument_value(390) ) ) -- AN/ALE-37 Power/Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_25
Helios_Udp.Send("5026", string.format("%1d", MainPanel:get_argument_value(398) ) ) -- AN/ALE-37 Flare Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_26
Helios_Udp.Send("5027", string.format("%1d", MainPanel:get_argument_value(905) ) ) -- Compass Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_27
Helios_Udp.Send("5028", string.format("%1d", MainPanel:get_argument_value(1047) ) ) -- Master Arm Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_28
Helios_Udp.Send("5029", string.format("%1d", MainPanel:get_argument_value(2011) ) ) -- TV/IR switch >> TREE_WAY_SWITCH :: 3WSwitch_A_29
Helios_Udp.Send("5030", string.format("%1d", MainPanel:get_argument_value(2012) ) ) -- WCS switch >> TREE_WAY_SWITCH :: 3WSwitch_A_30
Helios_Udp.Send("5031", string.format("%1d", MainPanel:get_argument_value(34) ) ) -- Aspect >> TREE_WAY_SWITCH :: 3WSwitch_A_31
Helios_Udp.Send("5032", string.format("%1d", MainPanel:get_argument_value(35) ) ) -- Closing Velocity scale >> TREE_WAY_SWITCH :: 3WSwitch_A_32
Helios_Udp.Send("5033", string.format("%1d", MainPanel:get_argument_value(36) ) ) -- Target size N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_33
Helios_Udp.Send("5034", string.format("%1d", MainPanel:get_argument_value(37) ) ) -- Main Lobe Clutter filter >> TREE_WAY_SWITCH :: 3WSwitch_A_34
Helios_Udp.Send("5035", string.format("%1d", MainPanel:get_argument_value(87) ) ) -- TCS Acquisition >> TREE_WAY_SWITCH :: 3WSwitch_A_35
Helios_Udp.Send("5036", string.format("%1d", MainPanel:get_argument_value(89) ) ) -- TCS Slave >> TREE_WAY_SWITCH :: 3WSwitch_A_36
Helios_Udp.Send("5037", string.format("%1d", MainPanel:get_argument_value(90) ) ) -- Record power N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_37
Helios_Udp.Send("5038", string.format("%1d", MainPanel:get_argument_value(63) ) ) -- Mech fuse >> TREE_WAY_SWITCH :: 3WSwitch_A_38
Helios_Udp.Send("5039", string.format("%1d", MainPanel:get_argument_value(75) ) ) -- Missile option >> TREE_WAY_SWITCH :: 3WSwitch_A_39
Helios_Udp.Send("5040", string.format("%1d", MainPanel:get_argument_value(68) ) ) -- Jettison station 1 >> TREE_WAY_SWITCH :: 3WSwitch_A_40
Helios_Udp.Send("5041", string.format("%1d", MainPanel:get_argument_value(71) ) ) -- Jettison station 8 >> TREE_WAY_SWITCH :: 3WSwitch_A_41
Helios_Udp.Send("5042", string.format("%1d", MainPanel:get_argument_value(413) ) ) -- Datalink Power >> TREE_WAY_SWITCH :: 3WSwitch_A_42
Helios_Udp.Send("5043", string.format("%1d", MainPanel:get_argument_value(191) ) ) -- Datalink Antijam N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_43
Helios_Udp.Send("5044", string.format("%1d", MainPanel:get_argument_value(96) ) ) -- Beacon Power >> TREE_WAY_SWITCH :: 3WSwitch_A_44
Helios_Udp.Send("5045", string.format("%1d", MainPanel:get_argument_value(161) ) ) -- IFF audio/light N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_45
Helios_Udp.Send("5046", string.format("%1d", MainPanel:get_argument_value(162) ) ) -- IFF M1 N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_46
Helios_Udp.Send("5047", string.format("%1d", MainPanel:get_argument_value(163) ) ) -- IFF M2 N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_47
Helios_Udp.Send("5048", string.format("%1d", MainPanel:get_argument_value(164) ) ) -- IFF M3/A N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_48
Helios_Udp.Send("5049", string.format("%1d", MainPanel:get_argument_value(165) ) ) -- IFF MC N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_49
Helios_Udp.Send("5050", string.format("%1d", MainPanel:get_argument_value(166) ) ) -- IFF RAD N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_50
Helios_Udp.Send("5051", string.format("%1d", MainPanel:get_argument_value(167) ) ) -- IFF Ident N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_51
Helios_Udp.Send("5052", string.format("%1d", MainPanel:get_argument_value(95) ) ) -- Liquid cooling >> TREE_WAY_SWITCH :: 3WSwitch_A_52
Helios_Udp.Send("5053", string.format("%1d", MainPanel:get_argument_value(307) ) ) -- Altimeter Mode Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_53
Helios_Udp.Send("5054", string.format("%1d", MainPanel:get_argument_value(20307) ) ) -- Altimeter Mode Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_54
Helios_Udp.Send("5055", string.format("%1d", MainPanel:get_argument_value(1075) ) ) -- Nose Strut Compression Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_55
Helios_Udp.Send("5056", string.format("%1d", MainPanel:get_argument_value(1076) ) ) -- Fuel Quantity Selector >> TREE_WAY_SWITCH :: 3WSwitch_A_56
Helios_Udp.Send("5057", string.format("%1d", MainPanel:get_argument_value(354) ) ) -- VHF/UHF ARC-182 100MHz & 10MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_57
Helios_Udp.Send("5058", string.format("%1d", MainPanel:get_argument_value(355) ) ) -- VHF/UHF ARC-182 1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_58
Helios_Udp.Send("5059", string.format("%1d", MainPanel:get_argument_value(356) ) ) -- VHF/UHF ARC-182 0.1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_59
Helios_Udp.Send("5060", string.format("%1d", MainPanel:get_argument_value(357) ) ) -- VHF/UHF ARC-182 0.025MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_60
Helios_Udp.Send("5061", string.format("%1d", MainPanel:get_argument_value(2137) ) ) -- AN/ALR-67 Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_61
Helios_Udp.Send("5062", string.format("%1d", MainPanel:get_argument_value(2140) ) ) -- AN/ALR-67 Test >> TREE_WAY_SWITCH :: 3WSwitch_A_62
Helios_Udp.Send("5063", string.format("%1d", MainPanel:get_argument_value(389) ) ) -- AN/ALE-37 Chaff Dispense >> TREE_WAY_SWITCH :: 3WSwitch_A_63
Helios_Udp.Send("5064", string.format("%1d", MainPanel:get_argument_value(388) ) ) -- AN/ALE-37 Flare Dispense >> TREE_WAY_SWITCH :: 3WSwitch_A_64
Helios_Udp.Send("5065", string.format("%1d", MainPanel:get_argument_value(387) ) ) -- AN/ALE-37 Jammer Dispense >> TREE_WAY_SWITCH :: 3WSwitch_A_65
Helios_Udp.Send("5066", string.format("%1d", MainPanel:get_argument_value(84) ) ) -- VSL switch >> TREE_WAY_SWITCH :: 3WSwitch_A_66
Helios_Udp.Send("5067", string.format("%1d", MainPanel:get_argument_value(78) ) ) -- Selective jettison >> TREE_WAY_SWITCH :: 3WSwitch_A_67
Helios_Udp.Send("5068", string.format("%1d", MainPanel:get_argument_value(2030) ) ) -- UHF ARC-159 100MHz & 10MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_68
Helios_Udp.Send("5069", string.format("%1d", MainPanel:get_argument_value(2029) ) ) -- UHF ARC-159 1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_69
Helios_Udp.Send("5070", string.format("%1d", MainPanel:get_argument_value(2028) ) ) -- UHF ARC-159 0.1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_70
Helios_Udp.Send("5071", string.format("%1d", MainPanel:get_argument_value(2026) ) ) -- UHF ARC-159 0.025MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_71
Helios_Udp.Send("5072", string.format("%1d", MainPanel:get_argument_value(190) ) ) -- ECM Display Data/ADF >> TREE_WAY_SWITCH :: 3WSwitch_A_72
Helios_Udp.Send("5073", string.format("%1d", MainPanel:get_argument_value(2042)/2 ) ) -- TACAN Mode Normal/Inverse >> TREE_WAY_SWITCH :: 3WSwitch_A_73  uses -2 , 2
Helios_Udp.Send("5074", string.format("%1d", MainPanel:get_argument_value(2043)/2 ) ) -- TACAN Channel X/Y >> TREE_WAY_SWITCH :: 3WSwitch_A_74  uses -2 , 2
Helios_Udp.Send("5075", string.format("%1d", MainPanel:get_argument_value(88)/2 ) ) -- TCS FOV >> TREE_WAY_SWITCH :: 3WSwitch_A_75  uses -2 , 2
Helios_Udp.Send("5076", string.format("%1d", MainPanel:get_argument_value(38)/2 ) ) -- Automatic Gain Control N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_76  uses -2 , 2
Helios_Udp.Send("5077", string.format("%1d", MainPanel:get_argument_value(3900)/2 ) ) -- Parametric amplifier N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_77  uses -2 , 2




Helios_Udp.Send("6001", string.format("%.2f", MainPanel:get_argument_value(306) ) ) -- Altimeter Pressure Setting >> AXIS :: Axis_A_1
Helios_Udp.Send("6002", string.format("%.2f", MainPanel:get_argument_value(20306) ) ) -- Altimeter Pressure Setting >> AXIS :: Axis_A_2
Helios_Udp.Send("6003", string.format("%.2f", MainPanel:get_argument_value(225) ) ) -- Flaps Lever >> AXIS :: Axis_A_3
Helios_Udp.Send("6004", string.format("%.2f", MainPanel:get_argument_value(1050) ) ) -- BINGO Fuel Level Knob >> AXIS :: Axis_A_4
Helios_Udp.Send("6005", string.format("%.2f", MainPanel:get_argument_value(1039) ) ) -- HSD Selected Heading >> AXIS :: Axis_A_5
Helios_Udp.Send("6006", string.format("%.2f", MainPanel:get_argument_value(1040) ) ) -- HSD Selected Course >> AXIS :: Axis_A_6
Helios_Udp.Send("6007", string.format("%.2f", MainPanel:get_argument_value(1043) ) ) -- HSD Brightness >> AXIS :: Axis_A_7
Helios_Udp.Send("6008", string.format("%.2f", MainPanel:get_argument_value(2023) ) ) -- ECMD Brightness >> AXIS :: Axis_A_8
Helios_Udp.Send("6009", string.format("%.2f", MainPanel:get_argument_value(2036) ) ) -- TACAN Volume >> AXIS :: Axis_A_9
Helios_Udp.Send("6010", string.format("%.2f", MainPanel:get_argument_value(375) ) ) -- TACAN Volume >> AXIS :: Axis_A_10
Helios_Udp.Send("6011", string.format("%.2f", MainPanel:get_argument_value(2040) ) ) -- ALR-67 Volume >> AXIS :: Axis_A_11
Helios_Udp.Send("6012", string.format("%.2f", MainPanel:get_argument_value(2039) ) ) -- Sidewinder Volume >> AXIS :: Axis_A_12
Helios_Udp.Send("6013", string.format("%.2f", MainPanel:get_argument_value(2047) ) ) -- ICS Volume >> AXIS :: Axis_A_13
Helios_Udp.Send("6014", string.format("%.2f", MainPanel:get_argument_value(400) ) ) -- ICS Volume >> AXIS :: Axis_A_14
Helios_Udp.Send("6015", string.format("%.2f", MainPanel:get_argument_value(2031) ) ) -- UHF ARC-159 Volume Pilot >> AXIS :: Axis_A_15
Helios_Udp.Send("6016", string.format("%.2f", MainPanel:get_argument_value(383) ) ) -- UHF ARC-159 Volume RIO >> AXIS :: Axis_A_16
Helios_Udp.Send("6017", string.format("%.2f", MainPanel:get_argument_value(2027) ) ) -- UHF ARC-159 Display Brightness >> AXIS :: Axis_A_17
Helios_Udp.Send("6018", string.format("%.2f", MainPanel:get_argument_value(350) ) ) -- VHF/UHF ARC-182 Volume RIO >> AXIS :: Axis_A_18
Helios_Udp.Send("6019", string.format("%.2f", MainPanel:get_argument_value(2038) ) ) -- VHF/UHF ARC-182 Volume Pilot >> AXIS :: Axis_A_19
Helios_Udp.Send("6020", string.format("%.2f", MainPanel:get_argument_value(360) ) ) -- VHF/UHF ARC-182 Display Brightness >> AXIS :: Axis_A_20
Helios_Udp.Send("6021", string.format("%.2f", MainPanel:get_argument_value(1031) ) ) -- UHF Radio Remote Display Brightness >> AXIS :: Axis_A_21
Helios_Udp.Send("6022", string.format("%.2f", MainPanel:get_argument_value(406) ) ) -- UHF Radio Remote Display Brightness >> AXIS :: Axis_A_22
Helios_Udp.Send("6023", string.format("%.2f", MainPanel:get_argument_value(1030) ) ) -- VHF/UHF Radio Remote Display Brightness >> AXIS :: Axis_A_23
Helios_Udp.Send("6024", string.format("%.2f", MainPanel:get_argument_value(9950) ) ) -- DECM ALQ-100 Volume >> AXIS :: Axis_A_24
Helios_Udp.Send("6025", string.format("%.2f", MainPanel:get_argument_value(16011) ) ) -- AN/ALR-67 Display Brightness >> AXIS :: Axis_A_25
Helios_Udp.Send("6026", string.format("%.2f", MainPanel:get_argument_value(376) ) ) -- AN/ALR-67 Display Brightness >> AXIS :: Axis_A_26
Helios_Udp.Send("6027", string.format("%.2f", MainPanel:get_argument_value(2138) ) ) -- AN/ALR-67 Volume >> AXIS :: Axis_A_27
Helios_Udp.Send("6028", string.format("%.2f", MainPanel:get_argument_value(386) ) ) -- AN/ALE-37 Chaff Counter >> AXIS :: Axis_A_28
Helios_Udp.Send("6029", string.format("%.2f", MainPanel:get_argument_value(385) ) ) -- AN/ALE-37 Flare Counter >> AXIS :: Axis_A_29
Helios_Udp.Send("6030", string.format("%.2f", MainPanel:get_argument_value(399) ) ) -- AN/ALE-37 Jammer Counter >> AXIS :: Axis_A_30
Helios_Udp.Send("6031", string.format("%.2f", MainPanel:get_argument_value(909) ) ) -- Compass LAT Correction >> AXIS :: Axis_A_31
Helios_Udp.Send("6032", string.format("%.2f", MainPanel:get_argument_value(1000) ) ) -- Gun Elevation Lead Adjustment >> AXIS :: Axis_A_32
Helios_Udp.Send("6033", string.format("%.2f", MainPanel:get_argument_value(1022) ) ) -- Gun Ammunition Counter Adjustment >> AXIS :: Axis_A_33
Helios_Udp.Send("6034", string.format("%.2f", MainPanel:get_argument_value(1007) ) ) -- HUD Pitch Ladder Brightness >> AXIS :: Axis_A_34
Helios_Udp.Send("6035", string.format("%.2f", MainPanel:get_argument_value(1034) ) ) -- HUD Trim" >> AXIS :: Axis_A_35
Helios_Udp.Send("6036", string.format("%.2f", MainPanel:get_argument_value(1035) ) ) -- VSDI Screen Trim >> AXIS :: Axis_A_36
Helios_Udp.Send("6037", string.format("%.2f", MainPanel:get_argument_value(1038) ) ) -- VDI Screen Contrast >> AXIS :: Axis_A_37
Helios_Udp.Send("6038", string.format("%.2f", MainPanel:get_argument_value(1036) ) ) -- VSDI Screen Brightness >> AXIS :: Axis_A_38
Helios_Udp.Send("6039", string.format("%.2f", MainPanel:get_argument_value(1037) ) ) -- HUD Brightness >> AXIS :: Axis_A_39
Helios_Udp.Send("6040", string.format("%.2f", MainPanel:get_argument_value(1051) ) ) -- Clock Wind >> AXIS :: Axis_A_40
Helios_Udp.Send("6041", string.format("%.2f", MainPanel:get_argument_value(1052) ) ) -- Clock Wind >> AXIS :: Axis_A_41
Helios_Udp.Send("6042", string.format("%.2f", MainPanel:get_argument_value(48) ) ) -- TID Brightness >> AXIS :: Axis_A_42
Helios_Udp.Send("6043", string.format("%.2f", MainPanel:get_argument_value(49) ) ) -- TID Contrast >> AXIS :: Axis_A_43
Helios_Udp.Send("6044", string.format("%.2f", MainPanel:get_argument_value(20) ) ) -- IR gain N-F >> AXIS :: Axis_A_44
Helios_Udp.Send("6045", string.format("%.2f", MainPanel:get_argument_value(21) ) ) -- IR volume N-F >> AXIS :: Axis_A_45
Helios_Udp.Send("6046", string.format("%.2f", MainPanel:get_argument_value(22) ) ) -- IR threshold N-F >> AXIS :: Axis_A_46
Helios_Udp.Send("6047", string.format("%.2f", MainPanel:get_argument_value(23) ) ) -- Brightness >> AXIS :: Axis_A_47
Helios_Udp.Send("6048", string.format("%.2f", MainPanel:get_argument_value(24) ) ) -- Pulse video >> AXIS :: Axis_A_48
Helios_Udp.Send("6049", string.format("%.2f", MainPanel:get_argument_value(25) ) ) -- Erase >> AXIS :: Axis_A_49
Helios_Udp.Send("6050", string.format("%.2f", MainPanel:get_argument_value(26) ) ) -- Pulse gain >> AXIS :: Axis_A_50
Helios_Udp.Send("6051", string.format("%.2f", MainPanel:get_argument_value(27) ) ) -- ACM threshold N-F >> AXIS :: Axis_A_51
Helios_Udp.Send("6052", string.format("%.2f", MainPanel:get_argument_value(28) ) ) -- JAM/JET N-F >> AXIS :: Axis_A_52
Helios_Udp.Send("6053", string.format("%.2f", MainPanel:get_argument_value(29) ) ) -- PD threshold clutter >> AXIS :: Axis_A_53
Helios_Udp.Send("6054", string.format("%.2f", MainPanel:get_argument_value(30) ) ) -- PD threshold clear N-F >> AXIS :: Axis_A_54
Helios_Udp.Send("6055", string.format("%.2f", MainPanel:get_argument_value(81) ) ) -- Radar elevation center >> AXIS :: Axis_A_55
Helios_Udp.Send("6056", string.format("%.2f", MainPanel:get_argument_value(82) ) ) -- Radar azimuth center >> AXIS :: Axis_A_56
Helios_Udp.Send("6057", string.format("%.2f", MainPanel:get_argument_value(16016) ) ) -- Record reset N-F >> AXIS :: Axis_A_57
Helios_Udp.Send("6058", string.format("%.2f", MainPanel:get_argument_value(667) ) ) -- LANTIRN Power >> AXIS :: Axis_A_58
Helios_Udp.Send("6060", string.format("%.2f", MainPanel:get_argument_value(950) ) ) -- Temperature >> AXIS :: Axis_A_60
Helios_Udp.Send("6061", string.format("%.3f", MainPanel:get_argument_value(15006) ) ) -- AoA Indexer Light Intensity >> AXIS :: Axis_A_61
Helios_Udp.Send("6062", string.format("%.3f", MainPanel:get_argument_value(15005) ) ) -- ACM Panel Light Intensity >> AXIS :: Axis_A_62
Helios_Udp.Send("6063", string.format("%.3f", MainPanel:get_argument_value(15007) ) ) -- Instrument Light Intensity >> AXIS :: Axis_A_63
Helios_Udp.Send("6064", string.format("%.3f", MainPanel:get_argument_value(15008) ) ) -- Console Light Intensity >> AXIS :: Axis_A_64
Helios_Udp.Send("6065", string.format("%.3f", MainPanel:get_argument_value(15009) ) ) -- Formation Light Intensity >> AXIS :: Axis_A_65
Helios_Udp.Send("6066", string.format("%.3f", MainPanel:get_argument_value(193) ) ) -- Instrument Light Intensity >> AXIS :: Axis_A_66
Helios_Udp.Send("6067", string.format("%.3f", MainPanel:get_argument_value(192) ) ) -- Console Light Intensity >> AXIS :: Axis_A_67
Helios_Udp.Send("6068", string.format("%.2f", MainPanel:get_argument_value(2041) ) ) -- TACAN Mode >> AXIS :: Axis_A_68
Helios_Udp.Send("6069", string.format("%.2f", MainPanel:get_argument_value(8888) ) ) -- TACAN Channel Wheel (Tens) >> AXIS :: Axis_A_69
Helios_Udp.Send("6070", string.format("%.2f", MainPanel:get_argument_value(8889) ) ) -- TACAN Channel Lever (Ones) >> AXIS :: Axis_A_70
Helios_Udp.Send("6071", string.format("%.2f", MainPanel:get_argument_value(374) ) ) -- TACAN Mode >> AXIS :: Axis_A_71
Helios_Udp.Send("6072", string.format("%.2f", MainPanel:get_argument_value(8891) ) ) -- TACAN Channel Wheel (Tens) >> AXIS :: Axis_A_72
Helios_Udp.Send("6073", string.format("%.2f", MainPanel:get_argument_value(8890) ) ) -- TACAN Channel Lever (Ones) >> AXIS :: Axis_A_73
Helios_Udp.Send("6074", string.format("%.2f", MainPanel:get_argument_value(2045) ) ) -- ICS Amplifier Selector >> AXIS :: Axis_A_74
Helios_Udp.Send("6075", string.format("%.2f", MainPanel:get_argument_value(401) ) ) -- ICS Amplifier Selector >> AXIS :: Axis_A_75
Helios_Udp.Send("6076", string.format("%.2f", MainPanel:get_argument_value(2033) ) ) -- UHF ARC-159 Freq Mode >> AXIS :: Axis_A_76
Helios_Udp.Send("6077", string.format("%.2f", MainPanel:get_argument_value(2034) ) ) -- UHF ARC-159 Function >> AXIS :: Axis_A_77
Helios_Udp.Send("6078", string.format("%.2f", MainPanel:get_argument_value(353) ) ) -- VHF/UHF ARC-182 Freq Mode >> AXIS :: Axis_A_78
Helios_Udp.Send("6079", string.format("%.2f", MainPanel:get_argument_value(358) ) ) -- VHF/UHF ARC-182 MODE >> AXIS :: Axis_A_79
Helios_Udp.Send("6080", string.format("%.2f", MainPanel:get_argument_value(116) ) ) -- KY-28 Power Mode >> AXIS :: Axis_A_80
Helios_Udp.Send("6081", string.format("%.2f", MainPanel:get_argument_value(115) ) ) -- KY-28 Radio Selector >> AXIS :: Axis_A_81
Helios_Udp.Send("6082", string.format("%.2f", MainPanel:get_argument_value(151) ) ) -- DECM ALQ-100 Power/Mode >> AXIS :: Axis_A_82
Helios_Udp.Send("6083", string.format("%.2f", MainPanel:get_argument_value(2136) ) ) -- AN/ALR-67 Display Type >> AXIS :: Axis_A_83
Helios_Udp.Send("6084", string.format("%.2f", MainPanel:get_argument_value(50) ) ) -- Navigation Mode >> AXIS :: Axis_A_84
Helios_Udp.Send("6085", string.format("%.2f", MainPanel:get_argument_value(51) ) ) -- Destination Mode >> AXIS :: Axis_A_85
Helios_Udp.Send("6086", string.format("%.2f", MainPanel:get_argument_value(2005) ) ) -- TID Mode >> AXIS :: Axis_A_86
Helios_Udp.Send("6087", string.format("%.2f", MainPanel:get_argument_value(2006) ) ) -- TID Range >> AXIS :: Axis_A_87
Helios_Udp.Send("6088", string.format("%.2f", MainPanel:get_argument_value(79) ) ) -- Radar elevation scan >> AXIS :: Axis_A_88
Helios_Udp.Send("6089", string.format("%.2f", MainPanel:get_argument_value(80) ) ) -- Radar azimuth scan >> AXIS :: Axis_A_89
Helios_Udp.Send("6090", string.format("%.2f", MainPanel:get_argument_value(91) ) ) -- Record mode N-F >> AXIS :: Axis_A_90
Helios_Udp.Send("6091", string.format("%.4f", MainPanel:get_argument_value(59) ) ) -- Weapon type wheel >> AXIS :: Axis_A_91
Helios_Udp.Send("6092", string.format("%.2f", MainPanel:get_argument_value(2022) ) ) -- Attack mode >> AXIS :: Axis_A_92
Helios_Udp.Send("6093", string.format("%.2f", MainPanel:get_argument_value(58) ) ) -- Elec fuse >> AXIS :: Axis_A_93
Helios_Udp.Send("6094", string.format("%.2f", MainPanel:get_argument_value(72) ) ) -- Missile speed gate >> AXIS :: Axis_A_94
Helios_Udp.Send("6095", string.format("%.2f", MainPanel:get_argument_value(98) ) ) -- CAP category >> AXIS :: Axis_A_95
Helios_Udp.Send("6096", string.format("%.2f", MainPanel:get_argument_value(118) ) ) -- Beacon mode >> AXIS :: Axis_A_96
Helios_Udp.Send("6097", string.format("%.2f", MainPanel:get_argument_value(183) ) ) -- IFF code N-F >> AXIS :: Axis_A_97
Helios_Udp.Send("6098", string.format("%.2f", MainPanel:get_argument_value(184) ) ) -- IFF master N-F >> AXIS :: Axis_A_98
Helios_Udp.Send("6099", string.format("%.2f", MainPanel:get_argument_value(2032) ) ) -- UHF ARC-159 Preset Channel Selector >> AXIS :: Axis_A_99
Helios_Udp.Send("6101", string.format("%.2f", MainPanel:get_argument_value(632) ) ) -- Hydraulic Hand Pump >> AXIS :: Axis_B_101
Helios_Udp.Send("6102", string.format("%.2f", MainPanel:get_argument_value(317) ) ) -- Emergency Wing Sweep Handle Cover >>. AXIS :: Axis_B_102
Helios_Udp.Send("6103", string.format("%.2f", MainPanel:get_argument_value(237) ) ) -- Parking Brake Handle >> AXIS :: Axis_B_103
Helios_Udp.Send("6104", string.format("%.2f", MainPanel:get_argument_value(1044) ) ) -- Fuel Shutoff - Right >> AXIS :: Axis_B_104
Helios_Udp.Send("6105", string.format("%.2f", MainPanel:get_argument_value(15081) ) ) -- Fuel Shutoff - Left >> AXIS :: Axis_B_105
Helios_Udp.Send("6106", string.format("%.2f", MainPanel:get_argument_value(224) ) ) -- Canopy Jettison >> AXIS :: Axis_B_106
Helios_Udp.Send("6107", string.format("%.2f", MainPanel:get_argument_value(2051) ) ) -- Canopy Jettison >> AXIS :: Axis_B_107
Helios_Udp.Send("6108", string.format("%.2f", MainPanel:get_argument_value(2049) ) ) -- Ejection CMD Lever >> AXIS :: Axis_B_108
Helios_Udp.Send("6109", string.format("%.2f", MainPanel:get_argument_value(404) ) ) -- Ejection Seat Safety >> AXIS :: Axis_B_109
Helios_Udp.Send("6110", string.format("%.2f", MainPanel:get_argument_value(498) ) ) -- Ejection Seat Safety >> AXIS :: Axis_B_110
Helios_Udp.Send("6111", string.format("%.2f", MainPanel:get_argument_value(122) ) ) -- Storage >> AXIS :: Axis_B_111
Helios_Udp.Send("6112", string.format("%.2f", MainPanel:get_argument_value(1033) ) ) -- HUD filter >> AXIS :: Axis_B_112
Helios_Udp.Send("6113", string.format("%.2f", MainPanel:get_argument_value(1046) ) ) -- Master Arm Cover >> AXIS :: Axis_B_113
Helios_Udp.Send("6114", string.format("%.2f", MainPanel:get_argument_value(1049) ) ) -- ACM Cover >> AXIS :: Axis_B_114
Helios_Udp.Send("6115", string.format("%.2f", MainPanel:get_argument_value(1069) ) ) -- Jettison aux guard >> AXIS :: Axis_B_115
Helios_Udp.Send("6116", string.format("%.2f", MainPanel:get_argument_value(384) ) ) -- mergency Wing Sweep Handle LEV >> AXIS :: Axis_B_116
Helios_Udp.Send("6117", string.format("%.2f", MainPanel:get_argument_value(308) ) ) -- Radar Altimeter Control Knob LEV >> AXIS :: Axis_B_117
Helios_Udp.Send("6118", string.format("%.2f", MainPanel:get_argument_value(310) ) ) -- Airspeed Indicator Bug Knob LEV >> AXIS :: Axis_B_118
Helios_Udp.Send("6119", string.format("%.2f", MainPanel:get_argument_value(904) ) ) -- Compass HDG Slave Knob/nPush rotate >> AXIS :: Axis_B_119
Helios_Udp.Send("6120", string.format("%.2f", MainPanel:get_argument_value(19101) ) ) -- Standby ADI Knob LEV >> AXIS :: Axis_B_120
Helios_Udp.Send("6121", string.format("%.2f", MainPanel:get_argument_value(6156) ) ) -- RIO Standby ADI Knob LEV >> AXIS :: Axis_B_121
Helios_Udp.Send("6122", string.format("%.2f", MainPanel:get_argument_value(206) ) ) -- AN/ALE-37 L10 Load Type >> AXIS :: Axis_B_122
Helios_Udp.Send("6123", string.format("%.2f", MainPanel:get_argument_value(207) ) ) -- AN/ALE-37 L20 Load Type >> AXIS :: Axis_B_123
Helios_Udp.Send("6124", string.format("%.2f", MainPanel:get_argument_value(209) ) ) -- AN/ALE-37 R10 Load Type >> AXIS :: Axis_B_124
Helios_Udp.Send("6125", string.format("%.2f", MainPanel:get_argument_value(208) ) ) -- AN/ALE-37 R20 Load Type >> AXIS :: Axis_B_125
Helios_Udp.Send("6126", string.format("%.2f", MainPanel:get_argument_value(214) ) ) -- AN/ALE-37 Chaff Burst Quantity >> AXIS :: Axis_B_126
Helios_Udp.Send("6127", string.format("%.2f", MainPanel:get_argument_value(215) ) ) -- AN/ALE-37 Chaff Burst Interval >> AXIS :: Axis_B_127
Helios_Udp.Send("6128", string.format("%.2f", MainPanel:get_argument_value(203) ) ) -- AN/ALE-37 Chaff Salvo Quantity >> AXIS :: Axis_B_128
Helios_Udp.Send("6129", string.format("%.2f", MainPanel:get_argument_value(202) ) ) -- AN/ALE-37 Chaff Salvo Interval >> AXIS :: Axis_B_129
Helios_Udp.Send("6130", string.format("%.2f", MainPanel:get_argument_value(205) ) ) -- AN/ALE-37 Flare Quantity >> AXIS :: Axis_B_130
Helios_Udp.Send("6131", string.format("%.2f", MainPanel:get_argument_value(210) ) ) -- AN/ALE-37 Flare Interval >> AXIS :: Axis_B_131
Helios_Udp.Send("6132", string.format("%.2f", MainPanel:get_argument_value(204) ) ) -- AN/ALE-37 Jammer Quantity >> AXIS :: Axis_B_132
Helios_Udp.Send("6133", string.format("%.2f", MainPanel:get_argument_value(912) ) ) -- AN/ARA-63 Channel Knob >> AXIS :: Axis_B_133
Helios_Udp.Send("6134", string.format("%.2f", MainPanel:get_argument_value(352) ) ) -- VHF/UHF ARC-182 Preset Channel Selector >> AXIS :: Axis_B_134
Helios_Udp.Send("6135", string.format("%.2f", MainPanel:get_argument_value(2262) ) ) -- IFF M3 code 1s N-F >> AXIS :: Axis_B_135
Helios_Udp.Send("6136", string.format("%.2f", MainPanel:get_argument_value(2261) ) ) -- IFF M3 code 10s N-F >> AXIS :: Axis_B_136
Helios_Udp.Send("6137", string.format("%.2f", MainPanel:get_argument_value(198) ) ) -- IFF M3 code 100s N-F >> AXIS :: Axis_B_137
Helios_Udp.Send("6138", string.format("%.2f", MainPanel:get_argument_value(199) ) ) -- IFF M3 code 1000s N-F >> AXIS :: Axis_B_138
Helios_Udp.Send("6139", string.format("%.2f", MainPanel:get_argument_value(200) ) ) -- IFF M1 code 1s N-F >> AXIS :: Axis_B_139
Helios_Udp.Send("6140", string.format("%.2f", MainPanel:get_argument_value(201) ) ) -- IFF M1 code 10s N-F >> AXIS :: Axis_B_140
Helios_Udp.Send("6141", string.format("%.2f", MainPanel:get_argument_value(211) ) ) -- AN/ALE-37 Jammer Interval Units >> AXIS :: Axis_B_141
Helios_Udp.Send("6142", string.format("%.2f", MainPanel:get_argument_value(212) ) ) -- AN/ALE-37 Jammer Interval Tens >> AXIS :: Axis_B_142
Helios_Udp.Send("6143", string.format("%.2f", MainPanel:get_argument_value(213) ) ) -- AN/ALE-37 Jammer Interval Hundreds >> AXIS :: Axis_B_143
Helios_Udp.Send("6144", string.format("%.2f", MainPanel:get_argument_value(9960) ) ) -- Weapon Interval x10ms >> AXIS :: Axis_B_144
Helios_Udp.Send("6145", string.format("%.2f", MainPanel:get_argument_value(9961) ) ) -- Weapon Interval x100ms >> AXIS :: Axis_B_145
Helios_Udp.Send("6146", string.format("%.2f", MainPanel:get_argument_value(9962) ) ) -- Weapon Quantity 10s >> AXIS :: Axis_B_146
Helios_Udp.Send("6147", string.format("%.2f", MainPanel:get_argument_value(9963) ) ) -- Weapon Quantity 1s >> AXIS :: Axis_B_147
Helios_Udp.Send("6148", string.format("%.2f", MainPanel:get_argument_value(196) ) ) -- Datalink freq 10MHz >> AXIS :: Axis_B_148
Helios_Udp.Send("6149", string.format("%.2f", MainPanel:get_argument_value(195) ) ) -- Datalink freq 1MHz >> AXIS :: Axis_B_149
Helios_Udp.Send("6150", string.format("%.2f", MainPanel:get_argument_value(197) ) ) -- Datalink freq 100kHz >> AXIS :: Axis_B_150
Helios_Udp.Send("6151", string.format("%.2f", MainPanel:get_argument_value(222) ) ) -- Datalink address high >> AXIS :: Axis_B_151
Helios_Udp.Send("6152", string.format("%.2f", MainPanel:get_argument_value(223) ) ) -- Datalink address low >> AXIS :: Axis_B_152
Helios_Udp.Send("6153", string.format("%.2f", MainPanel:get_argument_value(934) ) ) -- Master Test Selector rotate >> AXIS :: Axis_B_153 
Helios_Udp.Send("6154", string.format("%.2f", MainPanel:get_argument_value(9958) ) ) -- XMTR CHAN rio >> AXIS :: Axis_B_154
Helios_Udp.Send("6155", string.format("%.2f", MainPanel:get_argument_value(9959) ) ) -- MSL CHAN rio >> AXIS :: Axis_B_155  


	Helios_Udp.Flush()
end

-- Format: device,button number, multiplier
-- arguments with multiplier >100 are special conversion cases, and are computed in different way

--                      		Extended       	F14

	-- buttons

Helios_F14.ExportArguments["1,3001"] ="22,3058,1" -- MASTER RESET >> PUSH_BUTTONS :: PB_1
Helios_F14.ExportArguments["1,3002"] ="17,3659,1" -- Launch Bar Abort >> PUSH_BUTTONS :: PB_2
Helios_F14.ExportArguments["1,3003"] ="19,3059,1" -- Fire Ext Bottle - Left >> PUSH_BUTTONS :: PB_3
Helios_F14.ExportArguments["1,3004"] ="19,3060,1" -- Fire Ext Bottle - Right >> PUSH_BUTTONS :: PB_4
Helios_F14.ExportArguments["1,3005"] ="41,3243,1" -- HSD Test >> PUSH_BUTTONS :: PB_5
Helios_F14.ExportArguments["1,3006"] ="44,3246,1" -- ECMD Test >> PUSH_BUTTONS :: PB_6
Helios_F14.ExportArguments["1,3007"] ="47,3324,1" -- TACAN CMD Button >> PUSH_BUTTONS :: PB_7
Helios_F14.ExportArguments["1,3008"] ="47,3325,1" -- TACAN CMD Button >> PUSH_BUTTONS :: PB_8
Helios_F14.ExportArguments["1,3009"] ="47,3334,1" -- TACAN BIT >> PUSH_BUTTONS :: PB_9
Helios_F14.ExportArguments["1,3010"] ="47,3346,1" -- TACAN BIT >> PUSH_BUTTONS :: PB_10
Helios_F14.ExportArguments["1,3011"] ="48,3321,1" -- AN/ARA-63 BIT Button >> PUSH_BUTTONS :: PB_11
Helios_F14.ExportArguments["1,3012"] ="3,3377,1" -- UHF ARC-159 Read >> PUSH_BUTTONS :: PB_12
Helios_F14.ExportArguments["1,3013"] ="3,3378,1" -- UHF ARC-159 Load >> PUSH_BUTTONS :: PB_13
Helios_F14.ExportArguments["1,3014"] ="3,3379,1" -- UHF ARC-159 Tone >> PUSH_BUTTONS :: PB_14
Helios_F14.ExportArguments["1,3015"] ="2,3427,1" -- KY-28 ZEROIZE >> PUSH_BUTTONS :: PB_15
Helios_F14.ExportArguments["1,3016"] ="3,3352,1" -- UHF Radio Remote Display Test >> PUSH_BUTTONS :: PB_16
Helios_F14.ExportArguments["1,3017"] ="3,3355,1" -- UHF Radio Remote Display Test >> PUSH_BUTTONS :: PB_17
Helios_F14.ExportArguments["1,3018"] ="4,3358,1" -- VHF/UHF Radio Remote Display Test >> PUSH_BUTTONS :: PB_18
Helios_F14.ExportArguments["1,3019"] ="5,3272,1" -- AN/ALE-37 Flare Salvo >> PUSH_BUTTONS :: PB_19
Helios_F14.ExportArguments["1,3020"] ="5,3297,1" -- AN/ALE-37 Programmer Reset >> PUSH_BUTTONS :: PB_20
Helios_F14.ExportArguments["1,3021"] ="24,3488,1" -- Accelerometer Reset >> PUSH_BUTTONS :: PB_21
Helios_F14.ExportArguments["1,3022"] ="42,3234,1" -- VDI filter >> PUSH_BUTTONS :: PB_22
Helios_F14.ExportArguments["1,3023"] ="55,3138,1" -- ACM Jettison >> PUSH_BUTTONS :: PB_23
Helios_F14.ExportArguments["1,3024"] ="34,3056,1" -- Master Caution Reset >> PUSH_BUTTONS :: PB_24
Helios_F14.ExportArguments["1,3025"] ="26,3043,1" -- Clock Timer Start/Stop/Reset >> PUSH_BUTTONS :: PB_25
Helios_F14.ExportArguments["1,3026"] ="26,3698,1" -- Clock Timer Start/Stop/Reset >> PUSH_BUTTONS :: PB_26
Helios_F14.ExportArguments["1,3027"] ="43,3114,1" -- TID Non attack >> PUSH_BUTTONS :: PB_27
Helios_F14.ExportArguments["1,3028"] ="43,3115,1" -- TID Jam strobe >> PUSH_BUTTONS :: PB_28
Helios_F14.ExportArguments["1,3029"] ="43,3116,1" -- TID Data link >> PUSH_BUTTONS :: PB_29
Helios_F14.ExportArguments["1,3030"] ="43,3117,1" -- TID Sym Elem >> PUSH_BUTTONS :: PB_30
Helios_F14.ExportArguments["1,3031"] ="43,3118,1" -- TID Alt num >> PUSH_BUTTONS :: PB_31
Helios_F14.ExportArguments["1,3032"] ="43,3119,1" -- TID Reject Image Device disable N-F >> PUSH_BUTTONS :: PB_32
Helios_F14.ExportArguments["1,3033"] ="43,3120,1" -- TID Launch zone >> PUSH_BUTTONS :: PB_33
Helios_F14.ExportArguments["1,3034"] ="43,3121,1" -- TID Velocity vector >> PUSH_BUTTONS :: PB_34
Helios_F14.ExportArguments["1,3035"] ="43,3122,1" -- collision steering >> PUSH_BUTTONS :: PB_35
Helios_F14.ExportArguments["1,3036"] ="43,3123,1" -- TID track hold >> PUSH_BUTTONS :: PB_36
Helios_F14.ExportArguments["1,3037"] ="39,3631,1" -- Power reset >> PUSH_BUTTONS :: PB_37
Helios_F14.ExportArguments["1,3038"] ="39,3632,1" -- Light test >> PUSH_BUTTONS :: PB_38
Helios_F14.ExportArguments["1,3039"] ="39,3450,1" -- RADAR 5 NM >> PUSH_BUTTONS :: PB_39
Helios_F14.ExportArguments["1,3040"] ="39,3451,1" -- RADAR 10 NM >> PUSH_BUTTONS :: PB_40
Helios_F14.ExportArguments["1,3041"] ="39,3452,1" -- RADAR 20 NM >> PUSH_BUTTONS :: PB_41
Helios_F14.ExportArguments["1,3042"] ="39,3453,1" -- RADAR 50 NM >> PUSH_BUTTONS :: PB_42
Helios_F14.ExportArguments["1,3043"] ="39,3454,1" -- RADAR 100 NM >> PUSH_BUTTONS :: PB_43
Helios_F14.ExportArguments["1,3044"] ="39,3455,1" -- RADAR 200 NM >> PUSH_BUTTONS :: PB_44
Helios_F14.ExportArguments["1,3045"] ="39,3456,1" -- DDD filter >> PUSH_BUTTONS :: PB_45
Helios_F14.ExportArguments["1,3046"] ="39,3457,1" -- RADAR pulse search >> PUSH_BUTTONS :: PB_46
Helios_F14.ExportArguments["1,3047"] ="39,3458,1" -- RADAR track while scan manual >> PUSH_BUTTONS :: PB_47
Helios_F14.ExportArguments["1,3048"] ="39,3459,1" -- RADAR track while scan auto >> PUSH_BUTTONS :: PB_48
Helios_F14.ExportArguments["1,3049"] ="39,3460,1" -- RADAR range while scan >> PUSH_BUTTONS :: PB_49
Helios_F14.ExportArguments["1,3050"] ="39,3461,1" -- RADAR pulse doppler search >> PUSH_BUTTONS :: PB_50
Helios_F14.ExportArguments["1,3051"] ="39,3462,1" -- RADAR pulse single target track >> PUSH_BUTTONS :: PB_51
Helios_F14.ExportArguments["1,3052"] ="39,3463,1" -- RADAR pulse doppler single target track >> PUSH_BUTTONS :: PB_52
Helios_F14.ExportArguments["1,3053"] ="39,3464,1" -- DDD Interrogate Friend or Foe >> PUSH_BUTTONS :: PB_53
Helios_F14.ExportArguments["1,3054"] ="39,3465,1" -- DDD Infrared N-F >> PUSH_BUTTONS :: PB_54
Helios_F14.ExportArguments["1,3055"] ="39,3466,1" -- DDD RADAR >> PUSH_BUTTONS :: PB_55
Helios_F14.ExportArguments["1,3056"] ="39,3673,1" -- CCM SPL N-F >> PUSH_BUTTONS :: PB_56
Helios_F14.ExportArguments["1,3057"] ="39,3674,1" -- CCM ALT DIFF N-F >> PUSH_BUTTONS :: PB_57
Helios_F14.ExportArguments["1,3058"] ="39,3675,1" -- CCM VGS N-F >> PUSH_BUTTONS :: PB_58
Helios_F14.ExportArguments["1,3059"] ="55,3161,1" -- A/A Launch >> PUSH_BUTTONS :: PB_59
Helios_F14.ExportArguments["1,3060"] ="43,3162,1" -- Next Launch >> PUSH_BUTTONS :: PB_60
Helios_F14.ExportArguments["1,3061"] ="23,3522,1" -- CAP btn 5 >> PUSH_BUTTONS :: PB_61
Helios_F14.ExportArguments["1,3062"] ="23,3521,1" -- CAP btn 4 >> PUSH_BUTTONS :: PB_62
Helios_F14.ExportArguments["1,3063"] ="23,3520,1" -- CAP btn 3 >> PUSH_BUTTONS :: PB_63
Helios_F14.ExportArguments["1,3064"] ="23,3519,1" -- CAP btn 2 >> PUSH_BUTTONS :: PB_64
Helios_F14.ExportArguments["1,3065"] ="23,3518,1" -- CAP btn 1 >> PUSH_BUTTONS :: PB_65
Helios_F14.ExportArguments["1,3066"] ="23,3528,1" -- CAP TNG NBR >> PUSH_BUTTONS :: PB_66
Helios_F14.ExportArguments["1,3067"] ="23,3527,1" -- CAP btn 10 >> PUSH_BUTTONS :: PB_67
Helios_F14.ExportArguments["1,3068"] ="23,3526,1" -- CAP btn 9 >> PUSH_BUTTONS :: PB_68
Helios_F14.ExportArguments["1,3069"] ="23,3525,1" -- CAP btn 8 >> PUSH_BUTTONS :: PB_69
Helios_F14.ExportArguments["1,3070"] ="23,3524,1" -- CAP btn 7 >> PUSH_BUTTONS :: PB_70
Helios_F14.ExportArguments["1,3071"] ="23,3523,1" -- CAP btn 6 >> PUSH_BUTTONS :: PB_71
Helios_F14.ExportArguments["1,3072"] ="23,3529,1" -- CAP PGM RSTRT >> PUSH_BUTTONS :: PB_72
Helios_F14.ExportArguments["1,3073"] ="52,3679,1" -- ACLS test >> PUSH_BUTTONS :: PB_73
Helios_F14.ExportArguments["1,3074"] ="64,3623,1" -- IFF test N-F >> PUSH_BUTTONS :: PB_74
Helios_F14.ExportArguments["1,3075"] ="64,3624,1" -- IFF reply N-F >> PUSH_BUTTONS :: PB_75
Helios_F14.ExportArguments["1,3076"] ="43,3498,1" -- Video Output Toggle (TCS/LANTIRN) >> PUSH_BUTTONS :: PB_76
Helios_F14.ExportArguments["1,3077"] ="38,3691,1" -- LANTIRN Operate Mode (Unstow) >> PUSH_BUTTONS :: PB_77
Helios_F14.ExportArguments["1,3078"] ="38,3677,1" -- LANTIRN IBIT >> PUSH_BUTTONS :: PB_78
Helios_F14.ExportArguments["1,3079"] ="55,3130,1" -- Gun rate >> PUSH_BUTTONS :: PB_79
Helios_F14.ExportArguments["1,3080"] ="55,3139,1" -- Sidewinder cool >> PUSH_BUTTONS :: PB_80
Helios_F14.ExportArguments["1,3081"] ="55,3140,1" -- Missile prepare >> PUSH_BUTTONS :: PB_81
Helios_F14.ExportArguments["1,3082"] ="55,3141,1" -- Missile mode >> PUSH_BUTTONS :: PB_82
Helios_F14.ExportArguments["1,3083"] ="55,3142,1" -- Emergency stores jettison >> PUSH_BUTTONS :: PB_83
Helios_F14.ExportArguments["1,3084"] ="23,3541,1" -- CAP LONG 6 >> PUSH_BUTTONS :: PB_84
Helios_F14.ExportArguments["1,3085"] ="23,3536,1" -- CAP LAT 1 >> PUSH_BUTTONS :: PB_85
Helios_F14.ExportArguments["1,3086"] ="23,3537,1" -- CAP NBR 2 >> PUSH_BUTTONS :: PB_86
Helios_F14.ExportArguments["1,3087"] ="23,3542,1" -- CAP 7 >> PUSH_BUTTONS :: PB_87
Helios_F14.ExportArguments["1,3088"] ="23,3543,1" -- CAP HDG 8 >> PUSH_BUTTONS :: PB_88
Helios_F14.ExportArguments["1,3089"] ="23,3538,1" -- CAP SPD 3 >> PUSH_BUTTONS :: PB_89
Helios_F14.ExportArguments["1,3090"] ="23,3539,1" -- CAP ALT 4 >> PUSH_BUTTONS :: PB_90
Helios_F14.ExportArguments["1,3091"] ="23,3544,1" -- CAP 9 >> PUSH_BUTTONS :: PB_91
Helios_F14.ExportArguments["1,3092"] ="23,3535,1" -- CAP BRG 0 >> PUSH_BUTTONS :: PB_92
Helios_F14.ExportArguments["1,3093"] ="23,3540,1" -- CAP RNG 5 >> PUSH_BUTTONS :: PB_93
Helios_F14.ExportArguments["1,3094"] ="23,3533,1" -- CAP N+E >> PUSH_BUTTONS :: PB_94
Helios_F14.ExportArguments["1,3095"] ="23,3532,1" -- CAP S-W >> PUSH_BUTTONS :: PB_95
Helios_F14.ExportArguments["1,3096"] ="23,3531,1" -- CAP clear >> PUSH_BUTTONS :: PB_96
Helios_F14.ExportArguments["1,3097"] ="23,3534,1" -- CAP enter >> PUSH_BUTTONS :: PB_97
Helios_F14.ExportArguments["1,3098"] ="29,3485,1" -- Radar Altimeter Control Knob BTN >> PUSH_BUTTONS :: PB_98
Helios_F14.ExportArguments["1,3099"] ="51,3432,1" -- Compass HDG Slave Knob/nPush >> PUSH_BUTTONS :: PB_99
Helios_F14.ExportArguments["1,3100"] ="11,3193,1" -- Air Source Ram >> PUSH_BUTTONS :: PB_100
Helios_F14.ExportArguments["1,3101"] ="11,3194,1" -- Air Source Off >> PUSH_BUTTONS :: PB_101
Helios_F14.ExportArguments["1,3102"] ="11,3195,1" -- Air Source Left Engine >> PUSH_BUTTONS :: PB_102
Helios_F14.ExportArguments["1,3103"] ="11,3196,1" -- Air Source Right Engine >> PUSH_BUTTONS :: PB_103
Helios_F14.ExportArguments["1,3104"] ="11,3197,1" -- Air Source Both Engines >> PUSH_BUTTONS :: PB_104
Helios_F14.ExportArguments["1,3105"] ="46,3314,1" -- Navigation Steer Commands: TACAN >> PUSH_BUTTONS :: PB_105
Helios_F14.ExportArguments["1,3106"] ="46,3315,1" -- Navigation Steer Commands: Destination >> PUSH_BUTTONS :: PB_106
Helios_F14.ExportArguments["1,3107"] ="46,3318,1" -- Navigation Steer Commands: AWL PCD >> PUSH_BUTTONS :: PB_107
Helios_F14.ExportArguments["1,3108"] ="46,3316,1" -- Navigation Steer Commands: Vector >> PUSH_BUTTONS :: PB_108
Helios_F14.ExportArguments["1,3109"] ="46,3317,1" -- Navigation Steer Commands: Manual >> PUSH_BUTTONS :: PB_109
Helios_F14.ExportArguments["1,3110"] ="40,3216,1" -- HUD Take-Off Mode >> PUSH_BUTTONS :: PB_110
Helios_F14.ExportArguments["1,3111"] ="40,3217,1" -- HUD Cruise Mode >> PUSH_BUTTONS :: PB_111
Helios_F14.ExportArguments["1,3112"] ="40,3218,1" -- HUD Air-to-Air Mode >> PUSH_BUTTONS :: PB_112
Helios_F14.ExportArguments["1,3113"] ="40,3219,1" -- HUD Air-to-Ground Mode >> PUSH_BUTTONS :: PB_113
Helios_F14.ExportArguments["1,3114"] ="40,3220,1" -- HUD Landing Mode >> PUSH_BUTTONS :: PB_114
Helios_F14.ExportArguments["2,3001"] ="12,3005,1" -- Hydraulic Isolation Switch >> TOGLEE_SWITCH :: TSwitch_1
Helios_F14.ExportArguments["2,3002"] ="12,3001,1" -- Hydraulic Transfer Pump Switch >> TOGLEE_SWITCH :: TSwitch_2
Helios_F14.ExportArguments["2,3003"] ="13,3007,1" -- Stow Inlet Ramps Left Switch >> TOGLEE_SWITCH :: TSwitch_3
Helios_F14.ExportArguments["2,3004"] ="13,3008,1" -- Stow Inlet Ramps Right Switch >> TOGLEE_SWITCH :: TSwitch_4
Helios_F14.ExportArguments["2,3005"] ="21,3034,1" -- AFCS Stability Augmentation - Pitch >> TOGLEE_SWITCH :: TSwitch_5
Helios_F14.ExportArguments["2,3006"] ="21,3035,1" -- AFCS Stability Augmentation - Roll >> TOGLEE_SWITCH :: TSwitch_6
Helios_F14.ExportArguments["2,3007"] ="21,3036,1" -- AFCS Stability Augmentation - Yaw >> TOGLEE_SWITCH :: TSwitch_7
Helios_F14.ExportArguments["2,3008"] ="21,3038,1" -- Autopilot - Altitude Hold >> TOGLEE_SWITCH :: TSwitch_8
Helios_F14.ExportArguments["2,3009"] ="21,3040,1" -- Autopilot - Engage >> TOGLEE_SWITCH :: TSwitch_9
Helios_F14.ExportArguments["2,3010"] ="19,3128,1" -- Left Engine Fuel Cutoff >> TOGLEE_SWITCH :: TSwitch_10
Helios_F14.ExportArguments["2,3011"] ="19,3129,1" -- Right Engine Fuel Cutoff >> TOGLEE_SWITCH :: TSwitch_11
Helios_F14.ExportArguments["2,3012"] ="19,3050,1" -- Engine Airstart >> TOGLEE_SWITCH :: TSwitch_12
Helios_F14.ExportArguments["2,3013"] ="19,3052,1" -- Left Engine Mode >> TOGLEE_SWITCH :: TSwitch_13
Helios_F14.ExportArguments["2,3014"] ="19,3053,1" -- Right Engine Mode >> TOGLEE_SWITCH :: TSwitch_14
Helios_F14.ExportArguments["2,3015"] ="19,3055,1" -- Asymmetric Thrust Limiter Cover >> TOGLEE_SWITCH :: TSwitch_15
Helios_F14.ExportArguments["2,3016"] ="19,3054,1" -- Asymmetric Thrust Limiter >> TOGLEE_SWITCH :: TSwitch_16
Helios_F14.ExportArguments["2,3017"] ="20,3067,1" -- Fuel Dump >> TOGLEE_SWITCH :: TSwitch_17
Helios_F14.ExportArguments["2,3018"] ="14,3012,1" -- Emergency Generator Switch >> TOGLEE_SWITCH :: TSwitch_18
Helios_F14.ExportArguments["2,3019"] ="11,3190,1" -- Pilot Oxygen On >> TOGLEE_SWITCH :: TSwitch_19
Helios_F14.ExportArguments["2,3020"] ="11,3191,1" -- RIO Oxygen On >> TOGLEE_SWITCH :: TSwitch_20
Helios_F14.ExportArguments["2,3021"] ="11,3192,1" -- Cabin Pressure Dump >> TOGLEE_SWITCH :: TSwitch_21
Helios_F14.ExportArguments["2,3022"] ="11,3636,1" -- Temp Auto / Man >> TOGLEE_SWITCH :: TSwitch_22
Helios_F14.ExportArguments["2,3023"] ="11,3637,1" -- Ram Air >> TOGLEE_SWITCH :: TSwitch_23
Helios_F14.ExportArguments["2,3024"] ="25,3211,1" -- Hook Bypass >> TOGLEE_SWITCH :: TSwitch_24
Helios_F14.ExportArguments["2,3025"] ="11,3171,1" -- Taxi Light >> TOGLEE_SWITCH :: TSwitch_25
Helios_F14.ExportArguments["2,3026"] ="11,3176,1" -- Position Lights Flash >> TOGLEE_SWITCH :: TSwitch_26
Helios_F14.ExportArguments["2,3027"] ="11,3177,1" -- Anti-Collision Lights >> TOGLEE_SWITCH :: TSwitch_27
Helios_F14.ExportArguments["2,3028"] ="42,3214,1" -- VDI Power On/Off >> TOGLEE_SWITCH :: TSwitch_28
Helios_F14.ExportArguments["2,3029"] ="40,3213,1" -- HUD Power On/Off >> TOGLEE_SWITCH :: TSwitch_29
Helios_F14.ExportArguments["2,3030"] ="41,3215,1" -- HSD/ECMD Power On/Off >> TOGLEE_SWITCH :: TSwitch_30
Helios_F14.ExportArguments["2,3031"] ="41,3235,1" -- HSD Display Mode >> TOGLEE_SWITCH :: TSwitch_31
Helios_F14.ExportArguments["2,3032"] ="41,3239,1" -- HSD ECM Override >> TOGLEE_SWITCH :: TSwitch_32
 
Helios_F14.ExportArguments["2,3035"] ="47,3347,1" -- TACAN Mode Normal/Inverse >> TOGLEE_SWITCH :: TSwitch_35
Helios_F14.ExportArguments["2,3036"] ="47,3348,1" -- TACAN Channel X/Y >> TOGLEE_SWITCH :: TSwitch_36
Helios_F14.ExportArguments["2,3037"] ="48,3319,1" -- AN/ARA-63 Power Switch >> TOGLEE_SWITCH :: TSwitch_37
Helios_F14.ExportArguments["2,3038"] ="2,3598,1" -- V/UHF 2 ANT Switch >> TOGLEE_SWITCH :: TSwitch_38
Helios_F14.ExportArguments["2,3039"] ="3,3365,1" -- UHF ARC-159 Squelch Switch >> TOGLEE_SWITCH :: TSwitch_39
Helios_F14.ExportArguments["2,3040"] ="4,3419,1" -- VHF/UHF ARC-182 FM/AM Switch >> TOGLEE_SWITCH :: TSwitch_40
Helios_F14.ExportArguments["2,3041"] ="4,3407,1" -- VHF/UHF ARC-182 Squelch Switch >> TOGLEE_SWITCH :: TSwitch_41
Helios_F14.ExportArguments["2,3042"] ="54,3259,1" -- AN/ALR-67 Power >> TOGLEE_SWITCH :: TSwitch_42
Helios_F14.ExportArguments["2,3043"] ="51,3436,1" -- Compass N-S Hemisphere >> TOGLEE_SWITCH :: TSwitch_43
Helios_F14.ExportArguments["2,3044"] ="14,3428,1" -- Inboard Spoiler Override Cover >> TOGLEE_SWITCH :: TSwitch_44
Helios_F14.ExportArguments["2,3045"] ="14,3429,1" -- Outboard Spoiler Override Cover >> TOGLEE_SWITCH :: TSwitch_45
Helios_F14.ExportArguments["2,3046"] ="14,3430,1" -- Inboard Spoiler Override >> TOGLEE_SWITCH :: TSwitch_46
Helios_F14.ExportArguments["2,3047"] ="14,3431,1" -- Outboard Spoiler Override >> TOGLEE_SWITCH :: TSwitch_47
Helios_F14.ExportArguments["2,3048"] ="42,3224,1" -- VDI Display Mode >> TOGLEE_SWITCH :: TSwitch_48
Helios_F14.ExportArguments["2,3049"] ="42,3225,1" -- VDI Landing Mode >> TOGLEE_SWITCH :: TSwitch_49
Helios_F14.ExportArguments["2,3050"] ="40,3226,1" -- HUD De-clutter On/Off >> TOGLEE_SWITCH :: TSwitch_50
Helios_F14.ExportArguments["2,3051"] ="40,3227,1" -- HUD AWL Mode >> TOGLEE_SWITCH :: TSwitch_51
Helios_F14.ExportArguments["2,3052"] ="58,3096,1" -- HCU TCS mode >> TOGLEE_SWITCH :: TSwitch_52
Helios_F14.ExportArguments["2,3053"] ="58,3097,1" -- HCU radar mode >> TOGLEE_SWITCH :: TSwitch_53
Helios_F14.ExportArguments["2,3054"] ="58,3098,1" -- HCU DDD mode >> TOGLEE_SWITCH :: TSwitch_54
Helios_F14.ExportArguments["2,3055"] ="58,3099,1" -- HCU TID mode >> TOGLEE_SWITCH :: TSwitch_55

Helios_F14.ExportArguments["2,3058"] ="39,3449,1" -- Stabilize >> TOGLEE_SWITCH :: TSwitch_58


Helios_F14.ExportArguments["2,3060"] ="55,3157,1" -- Bomb single/pairs >> TOGLEE_SWITCH :: TSwitch_60
Helios_F14.ExportArguments["2,3061"] ="55,3158,1" -- Bomb step/ripple >> TOGLEE_SWITCH :: TSwitch_61
Helios_F14.ExportArguments["2,3062"] ="55,3159,1" -- A/G gun mode >> TOGLEE_SWITCH :: TSwitch_62
Helios_F14.ExportArguments["2,3063"] ="55,3160,1" -- Jettison racks/weapons >> TOGLEE_SWITCH :: TSwitch_63
Helios_F14.ExportArguments["2,3064"] ="55,3164,1" -- Jettison left tank >> TOGLEE_SWITCH :: TSwitch_64
Helios_F14.ExportArguments["2,3065"] ="55,3169,1" -- Jettison right tank >> TOGLEE_SWITCH :: TSwitch_65
Helios_F14.ExportArguments["2,3066"] ="55,3165,1" -- Jettison station 3 >> TOGLEE_SWITCH :: TSwitch_66
Helios_F14.ExportArguments["2,3067"] ="55,3166,1" -- Jettison station 4 >> TOGLEE_SWITCH :: TSwitch_67
Helios_F14.ExportArguments["2,3068"] ="55,3167,1" -- Jettison station 5 >> TOGLEE_SWITCH :: TSwitch_68
Helios_F14.ExportArguments["2,3069"] ="55,3168,1" -- Jettison station 6 >> TOGLEE_SWITCH :: TSwitch_69
Helios_F14.ExportArguments["2,3070"] ="52,3590,1" -- Datalink Antenna N-F >> TOGLEE_SWITCH :: TSwitch_70
Helios_F14.ExportArguments["2,3071"] ="52,3591,1" -- Datalink Reply N-F >> TOGLEE_SWITCH :: TSwitch_71
Helios_F14.ExportArguments["2,3072"] ="52,3592,1" -- Datalink CAINS/TAC >> TOGLEE_SWITCH :: TSwitch_72
Helios_F14.ExportArguments["2,3073"] ="64,3620,1" -- IFF M4 N-F >> TOGLEE_SWITCH :: TSwitch_73
Helios_F14.ExportArguments["2,3074"] ="38,3516,1" -- LANTIRN Laser Arm Switch >> TOGLEE_SWITCH :: TSwitch_74
Helios_F14.ExportArguments["2,3075"] ="12,3002,1" -- Hydraulic Transfer Pump Switch Cover >> TOGLEE_SWITCH :: TSwitch_75
Helios_F14.ExportArguments["2,3076"] ="12,3004,1" -- Hydraulic Emergency Flight Control Switch Cover >> TOGLEE_SWITCH :: TSwitch_76
Helios_F14.ExportArguments["2,3077"] ="17,3660,1" -- Launch Bar Abort Switch Cover >> TOGLEE_SWITCH :: TSwitch_77
Helios_F14.ExportArguments["2,3078"] ="20,3064,1" -- Fuel Feed Cover >> TOGLEE_SWITCH :: TSwitch_78
Helios_F14.ExportArguments["2,3079"] ="14,3011,1" -- Emergency Generator Switch Cover >> TOGLEE_SWITCH :: TSwitch_79
Helios_F14.ExportArguments["2,3080"] ="2,3595,1" -- KY-28 ZEROIZE Cover >> TOGLEE_SWITCH :: TSwitch_80
Helios_F14.ExportArguments["2,3081"] ="16,3030,1" -- Emergency Wing Sweep Handle TUMB >> TOGLEE_SWITCH :: TSwitch_81
Helios_F14.ExportArguments["2,3082"] ="27,3492,1" -- Airspeed Indicator Bug Knob TUMB >> TOGLEE_SWITCH :: TSwitch_82
Helios_F14.ExportArguments["2,3083"] ="17,3016,1" -- Landing Gear Lever TUMB >> TOGLEE_SWITCH :: TSwitch_83
Helios_F14.ExportArguments["2,3084"] ="17,3633,1" -- Landing Gear Lever emergency TUMB >> TOGLEE_SWITCH :: TSwitch_84
Helios_F14.ExportArguments["2,3085"] ="17,3021,1" -- Hook Extension Handle TUMB >> TOGLEE_SWITCH :: TSwitch_85
Helios_F14.ExportArguments["2,3086"] ="17,3022,1" -- Hook Extension Handle cycle emergency mode TUMB >> TOGLEE_SWITCH :: TSwitch_86
Helios_F14.ExportArguments["2,3088"] ="10,3077,1" -- Master Test Selector pull/push >> TOGLEE_SWITCH :: TSwitch_88
Helios_F14.ExportArguments["2,3089"] ="30,3545,1" -- Standby ADI Knob TUMB >> TOGLEE_SWITCH :: TSwitch_89
Helios_F14.ExportArguments["2,3090"] ="30,3547,1" -- RIO Standby ADI Knob TUMB >> TOGLEE_SWITCH :: TSwitch_90
Helios_F14.ExportArguments["3,3001"] ="12,3003,1" -- Hydraulic Emergency Flight Control Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_1
Helios_F14.ExportArguments["3,3002"] ="17,3014,1" -- Anti-Skid Spoiler BK Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_2
Helios_F14.ExportArguments["3,3003"] ="21,3037,1" -- Autopilot - Vector / Automatic Carrier Landing >> TREE_WAY_SWITCH :: 3WSwitch_A_3
Helios_F14.ExportArguments["3,3004"] ="21,3039,1" -- Autopilot - Heading / Ground Track >> TREE_WAY_SWITCH :: 3WSwitch_A_4
Helios_F14.ExportArguments["3,3005"] ="19,3045,1" -- Throttle Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_5
Helios_F14.ExportArguments["3,3006"] ="19,3047,1" -- Throttle Temp >> TREE_WAY_SWITCH :: 3WSwitch_A_6
Helios_F14.ExportArguments["3,3007"] ="19,3049,1" -- Engine/Probe Anti-Ice >> TREE_WAY_SWITCH :: 3WSwitch_A_7
Helios_F14.ExportArguments["3,3008"] ="19,3051,1" -- Engine Crank >> TREE_WAY_SWITCH :: 3WSwitch_A_8
Helios_F14.ExportArguments["3,3009"] ="20,3065,1" -- Fuel Feed >> TREE_WAY_SWITCH :: 3WSwitch_A_9
Helios_F14.ExportArguments["3,3010"] ="20,3066,1" -- Wing/Ext Trans >> TREE_WAY_SWITCH :: 3WSwitch_A_10
Helios_F14.ExportArguments["3,3011"] ="20,3068,1" -- Refuel Probe >> TREE_WAY_SWITCH :: 3WSwitch_A_11
Helios_F14.ExportArguments["3,3012"] ="14,3009,1" -- Left Generator Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_12
Helios_F14.ExportArguments["3,3013"] ="14,3010,1" -- Right Generator Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_13
Helios_F14.ExportArguments["3,3014"] ="11,3634,1" -- Wind Shield Air >> TREE_WAY_SWITCH :: 3WSwitch_A_14
Helios_F14.ExportArguments["3,3015"] ="11,3172,1" -- Red Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_15
Helios_F14.ExportArguments["3,3016"] ="11,3173,1" -- White Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_16
Helios_F14.ExportArguments["3,3017"] ="11,3174,1" -- Position Lights Wing >> TREE_WAY_SWITCH :: 3WSwitch_A_17
Helios_F14.ExportArguments["3,3018"] ="11,3175,1" -- Position Lights Tail >> TREE_WAY_SWITCH :: 3WSwitch_A_18
Helios_F14.ExportArguments["3,3019"] ="11,3600,1" -- Red Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_19
Helios_F14.ExportArguments["3,3020"] ="11,3601,1" -- White Flood Light >> TREE_WAY_SWITCH :: 3WSwitch_A_20
Helios_F14.ExportArguments["3,3021"] ="2,3383,1" -- ICS Function Selector >> TREE_WAY_SWITCH :: 3WSwitch_A_21
Helios_F14.ExportArguments["3,3022"] ="2,3390,1" -- ICS Function Selector >> TREE_WAY_SWITCH :: 3WSwitch_A_22
Helios_F14.ExportArguments["3,3023"] ="2,3399,1" -- XMTR SEL Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_23
Helios_F14.ExportArguments["3,3024"] ="2,3597,1" -- KY MODE Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_24
Helios_F14.ExportArguments["3,3025"] ="5,3267,1" -- AN/ALE-37 Power/Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_25
Helios_F14.ExportArguments["3,3026"] ="5,3273,1" -- AN/ALE-37 Flare Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_26
Helios_F14.ExportArguments["3,3027"] ="51,3434,1" -- Compass Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_27
Helios_F14.ExportArguments["3,3028"] ="55,3136,1" -- Master Arm Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_28
Helios_F14.ExportArguments["3,3029"] ="37,3100,1" -- TV/IR switch >> TREE_WAY_SWITCH :: 3WSwitch_A_29
Helios_F14.ExportArguments["3,3030"] ="39,3101,1" -- WCS switch >> TREE_WAY_SWITCH :: 3WSwitch_A_30
Helios_F14.ExportArguments["3,3031"] ="39,3467,1" -- Aspect >> TREE_WAY_SWITCH :: 3WSwitch_A_31
Helios_F14.ExportArguments["3,3032"] ="39,3468,1" -- Closing Velocity scale >> TREE_WAY_SWITCH :: 3WSwitch_A_32
Helios_F14.ExportArguments["3,3033"] ="39,3469,1" -- Target size N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_33
Helios_F14.ExportArguments["3,3034"] ="39,3470,1" -- Main Lobe Clutter filter >> TREE_WAY_SWITCH :: 3WSwitch_A_34
Helios_F14.ExportArguments["3,3035"] ="37,3495,1" -- TCS Acquisition >> TREE_WAY_SWITCH :: 3WSwitch_A_35
Helios_F14.ExportArguments["3,3036"] ="37,3496,1" -- TCS Slave >> TREE_WAY_SWITCH :: 3WSwitch_A_36
Helios_F14.ExportArguments["3,3037"] ="37,3604,1" -- Record power N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_37
Helios_F14.ExportArguments["3,3038"] ="55,3155,1" -- Mech fuse >> TREE_WAY_SWITCH :: 3WSwitch_A_38
Helios_F14.ExportArguments["3,3039"] ="55,3156,1" -- Missile option >> TREE_WAY_SWITCH :: 3WSwitch_A_39
Helios_F14.ExportArguments["3,3040"] ="55,3163,1" -- Jettison station 1 >> TREE_WAY_SWITCH :: 3WSwitch_A_40
Helios_F14.ExportArguments["3,3041"] ="55,3170,1" -- Jettison station 8 >> TREE_WAY_SWITCH :: 3WSwitch_A_41
Helios_F14.ExportArguments["3,3042"] ="52,3589,1" -- Datalink Power >> TREE_WAY_SWITCH :: 3WSwitch_A_42
Helios_F14.ExportArguments["3,3043"] ="52,3585,1" -- Datalink Antijam N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_43
Helios_F14.ExportArguments["3,3044"] ="52,3678,1" -- Beacon Power >> TREE_WAY_SWITCH :: 3WSwitch_A_44
Helios_F14.ExportArguments["3,3045"] ="64,3613,1" -- IFF audio/light N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_45
Helios_F14.ExportArguments["3,3046"] ="64,3614,1" -- IFF M1 N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_46
Helios_F14.ExportArguments["3,3047"] ="64,3615,1" -- IFF M2 N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_47
Helios_F14.ExportArguments["3,3048"] ="64,3616,1" -- IFF M3/A N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_48
Helios_F14.ExportArguments["3,3049"] ="64,3617,1" -- IFF MC N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_49
Helios_F14.ExportArguments["3,3050"] ="64,3618,1" -- IFF RAD N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_50
Helios_F14.ExportArguments["3,3051"] ="64,3619,1" -- IFF Ident N-F >> TREE_WAY_SWITCH :: 3WSwitch_A_51
Helios_F14.ExportArguments["3,3052"] ="39,3681,1" -- Liquid cooling >> TREE_WAY_SWITCH :: 3WSwitch_A_52
Helios_F14.ExportArguments["3,3053"] ="28,3487,1" -- Altimeter Mode Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_53
Helios_F14.ExportArguments["3,3054"] ="28,3490,1" -- Altimeter Mode Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_54
Helios_F14.ExportArguments["3,3055"] ="17,3019,1" -- Nose Strut Compression Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_55
Helios_F14.ExportArguments["3,3056"] ="20,3063,1" -- Fuel Quantity Selector >> TREE_WAY_SWITCH :: 3WSwitch_A_56
Helios_F14.ExportArguments["3,3057"] ="4,3409,1" -- VHF/UHF ARC-182 100MHz & 10MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_57
Helios_F14.ExportArguments["3,3058"] ="4,3410,1" -- VHF/UHF ARC-182 1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_58
Helios_F14.ExportArguments["3,3059"] ="4,3411,1" -- VHF/UHF ARC-182 0.1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_59
Helios_F14.ExportArguments["3,3060"] ="4,3412,1" -- VHF/UHF ARC-182 0.025MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_60
Helios_F14.ExportArguments["3,3061"] ="54,3256,1" -- AN/ALR-67 Mode >> TREE_WAY_SWITCH :: 3WSwitch_A_61
Helios_F14.ExportArguments["3,3062"] ="54,3261,1" -- AN/ALR-67 Test >> TREE_WAY_SWITCH :: 3WSwitch_A_62
Helios_F14.ExportArguments["3,3063"] ="5,3269,1" -- AN/ALE-37 Chaff Dispense >> TREE_WAY_SWITCH :: 3WSwitch_A_63
Helios_F14.ExportArguments["3,3064"] ="5,3270,1" -- AN/ALE-37 Flare Dispense >> TREE_WAY_SWITCH :: 3WSwitch_A_64
Helios_F14.ExportArguments["3,3065"] ="5,3271,1" -- AN/ALE-37 Jammer Dispense >> TREE_WAY_SWITCH :: 3WSwitch_A_65
Helios_F14.ExportArguments["3,3066"] ="39,3448,1" -- VSL switch >> TREE_WAY_SWITCH :: 3WSwitch_A_66
Helios_F14.ExportArguments["3,3067"] ="55,3154,1" -- Selective jettison >> TREE_WAY_SWITCH :: 3WSwitch_A_67
Helios_F14.ExportArguments["3,3068"] ="3,3367,1" -- UHF ARC-159 100MHz & 10MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_68
Helios_F14.ExportArguments["3,3069"] ="3,3368,1" -- UHF ARC-159 1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_69
Helios_F14.ExportArguments["3,3070"] ="3,3369,1" -- UHF ARC-159 0.1MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_70
Helios_F14.ExportArguments["3,3071"] ="3,3370,1" -- UHF ARC-159 0.025MHz >> TREE_WAY_SWITCH :: 3WSwitch_A_71
Helios_F14.ExportArguments["3,3072"] ="44,3250,1" -- ECM Display Data/ADF >> TREE_WAY_SWITCH :: 3WSwitch_A_72 

Helios_F14.ExportArguments["3,3073"] ="47,3335,1" -- TACAN Mode Normal/Inverse >> TOGLEE_SWITCH :: TSwitch_33  uses -2 , 2
Helios_F14.ExportArguments["3,3074"] ="47,3336,1" -- TACAN Channel X/Y >> TREE_WAY_SWITCH :: 3WSwitch_A_74   uses -2 , 2
Helios_F14.ExportArguments["3,3075"] ="37,3494,1" -- TCS FOV>> TREE_WAY_SWITCH :: 3WSwitch_A_75   uses -2 , 2
Helios_F14.ExportArguments["3,3076"] ="39,3471,1" -- TACAN Channel X/Y >> TREE_WAY_SWITCH :: 3WSwitch_A_76   uses -2 , 2
Helios_F14.ExportArguments["3,3077"] ="39,3472,1" -- TCS FOV>> TREE_WAY_SWITCH :: 3WSwitch_A_77   uses -2 , 2


Helios_F14.ExportArguments["4,3001"] ="28,3486,1" -- Altimeter Pressure Setting >> AXIS :: Axis_A_1
Helios_F14.ExportArguments["4,3002"] ="28,3489,1" -- Altimeter Pressure Setting >> AXIS :: Axis_A_2
Helios_F14.ExportArguments["4,3003"] ="18,3044,1" -- Flaps Lever >> AXIS :: Axis_A_3
Helios_F14.ExportArguments["4,3004"] ="20,3069,1" -- BINGO Fuel Level Knob >> AXIS :: Axis_A_4
Helios_F14.ExportArguments["4,3005"] ="41,3241,1" -- HSD Selected Heading >> AXIS :: Axis_A_5
Helios_F14.ExportArguments["4,3006"] ="41,3242,1" -- HSD Selected Course >> AXIS :: Axis_A_6
Helios_F14.ExportArguments["4,3007"] ="41,3240,1" -- HSD Brightness >> AXIS :: Axis_A_7
Helios_F14.ExportArguments["4,3008"] ="44,3245,1" -- ECMD Brightness >> AXIS :: Axis_A_8
Helios_F14.ExportArguments["4,3009"] ="47,3328,1" -- TACAN Volume >> AXIS :: Axis_A_9
Helios_F14.ExportArguments["4,3010"] ="47,3340,1" -- TACAN Volume >> AXIS :: Axis_A_10
Helios_F14.ExportArguments["4,3011"] ="2,3395,1" -- ALR-67 Volume >> AXIS :: Axis_A_11
Helios_F14.ExportArguments["4,3012"] ="2,3397,1" -- Sidewinder Volume >> AXIS :: Axis_A_12
Helios_F14.ExportArguments["4,3013"] ="2,3380,1" -- ICS Volume >> AXIS :: Axis_A_13
Helios_F14.ExportArguments["4,3014"] ="2,3387,1" -- ICS Volume >> AXIS :: Axis_A_14
Helios_F14.ExportArguments["4,3015"] ="3,3359,1" -- UHF ARC-159 Volume Pilot >> AXIS :: Axis_A_15
Helios_F14.ExportArguments["4,3016"] ="3,3361,1" -- UHF ARC-159 Volume RIO >> AXIS :: Axis_A_16
Helios_F14.ExportArguments["4,3017"] ="3,3363,1" -- UHF ARC-159 Display Brightness >> AXIS :: Axis_A_17
Helios_F14.ExportArguments["4,3018"] ="4,3401,1" -- VHF/UHF ARC-182 Volume RIO >> AXIS :: Axis_A_18
Helios_F14.ExportArguments["4,3019"] ="4,3403,1" -- VHF/UHF ARC-182 Volume Pilot >> AXIS :: Axis_A_19
Helios_F14.ExportArguments["4,3020"] ="4,3405,1" -- VHF/UHF ARC-182 Display Brightness >> AXIS :: Axis_A_20
Helios_F14.ExportArguments["4,3021"] ="3,3350,1" -- UHF Radio Remote Display Brightness >> AXIS :: Axis_A_21
Helios_F14.ExportArguments["4,3022"] ="3,3353,1" -- UHF Radio Remote Display Brightness >> AXIS :: Axis_A_22
Helios_F14.ExportArguments["4,3023"] ="4,3356,1" -- VHF/UHF Radio Remote Display Brightness >> AXIS :: Axis_A_23
Helios_F14.ExportArguments["4,3024"] ="53,3253,1" -- DECM ALQ-100 Volume >> AXIS :: Axis_A_24
Helios_F14.ExportArguments["4,3025"] ="54,3262,1" -- AN/ALR-67 Display Brightness >> AXIS :: Axis_A_25
Helios_F14.ExportArguments["4,3026"] ="54,3263,1" -- AN/ALR-67 Display Brightness >> AXIS :: Axis_A_26
Helios_F14.ExportArguments["4,3027"] ="2,3254,1" -- AN/ALR-67 Volume >> AXIS :: Axis_A_27
Helios_F14.ExportArguments["4,3028"] ="5,3275,1" -- AN/ALE-37 Chaff Counter >> AXIS :: Axis_A_28
Helios_F14.ExportArguments["4,3029"] ="5,3277,1" -- AN/ALE-37 Flare Counter >> AXIS :: Axis_A_29
Helios_F14.ExportArguments["4,3030"] ="5,3279,1" -- AN/ALE-37 Jammer Counter >> AXIS :: Axis_A_30
Helios_F14.ExportArguments["4,3031"] ="51,3438,1" -- Compass LAT Correction >> AXIS :: Axis_A_31
Helios_F14.ExportArguments["4,3032"] ="55,3131,1" -- Gun Elevation Lead Adjustment >> AXIS :: Axis_A_32
Helios_F14.ExportArguments["4,3033"] ="55,3132,1" -- Gun Ammunition Counter Adjustment >> AXIS :: Axis_A_33
Helios_F14.ExportArguments["4,3034"] ="40,3223,1" -- HUD Pitch Ladder Brightness >> AXIS :: Axis_A_34
Helios_F14.ExportArguments["4,3035"] ="40,3229,1" -- HUD Trim" >> AXIS :: Axis_A_35
Helios_F14.ExportArguments["4,3036"] ="42,3230,1" -- VSDI Screen Trim >> AXIS :: Axis_A_36
Helios_F14.ExportArguments["4,3037"] ="42,3231,1" -- VDI Screen Contrast >> AXIS :: Axis_A_37
Helios_F14.ExportArguments["4,3038"] ="42,3232,1" -- VSDI Screen Brightness >> AXIS :: Axis_A_38
Helios_F14.ExportArguments["4,3039"] ="40,3233,1" -- HUD Brightness >> AXIS :: Axis_A_39
Helios_F14.ExportArguments["4,3040"] ="26,3042,1" -- Clock Wind >> AXIS :: Axis_A_40
Helios_F14.ExportArguments["4,3041"] ="26,3697,1" -- Clock Wind >> AXIS :: Axis_A_41
Helios_F14.ExportArguments["4,3042"] ="43,3124,1" -- TID Brightness >> AXIS :: Axis_A_42
Helios_F14.ExportArguments["4,3043"] ="43,3125,1" -- TID Contrast >> AXIS :: Axis_A_43
Helios_F14.ExportArguments["4,3044"] ="39,3473,1" -- IR gain N-F >> AXIS :: Axis_A_44
Helios_F14.ExportArguments["4,3045"] ="39,3474,1" -- IR volume N-F >> AXIS :: Axis_A_45
Helios_F14.ExportArguments["4,3046"] ="39,3475,1" -- IR threshold N-F >> AXIS :: Axis_A_46
Helios_F14.ExportArguments["4,3047"] ="39,3476,1" -- Brightness >> AXIS :: Axis_A_47
Helios_F14.ExportArguments["4,3048"] ="39,3477,1" -- Pulse video >> AXIS :: Axis_A_48
Helios_F14.ExportArguments["4,3049"] ="39,3478,1" -- Erase >> AXIS :: Axis_A_49
Helios_F14.ExportArguments["4,3050"] ="39,3479,1" -- Pulse gain >> AXIS :: Axis_A_50
Helios_F14.ExportArguments["4,3051"] ="39,3480,1" -- ACM threshold N-F >> AXIS :: Axis_A_51
Helios_F14.ExportArguments["4,3052"] ="39,3481,1" -- JAM/JET N-F >> AXIS :: Axis_A_52
Helios_F14.ExportArguments["4,3053"] ="39,3482,1" -- PD threshold clutter >> AXIS :: Axis_A_53
Helios_F14.ExportArguments["4,3054"] ="39,3483,1" -- PD threshold clear N-F >> AXIS :: Axis_A_54
Helios_F14.ExportArguments["4,3055"] ="39,3446,1" -- Radar elevation center >> AXIS :: Axis_A_55
Helios_F14.ExportArguments["4,3056"] ="39,3447,1" -- Radar azimuth center >> AXIS :: Axis_A_56
Helios_F14.ExportArguments["4,3057"] ="37,3609,1" -- Record reset N-F >> AXIS :: Axis_A_57
Helios_F14.ExportArguments["4,3058"] ="38,3676,1" -- LANTIRN Power >> AXIS :: Axis_A_58
Helios_F14.ExportArguments["4,3060"] ="11,3635,1" -- Temperature >> AXIS :: Axis_A_60
Helios_F14.ExportArguments["4,3061"] ="25,3212,1" -- AoA Indexer Light Intensity >> AXIS :: Axis_A_61
Helios_F14.ExportArguments["4,3062"] ="11,3178,1" -- ACM Panel Light Intensity >> AXIS :: Axis_A_62
Helios_F14.ExportArguments["4,3063"] ="11,3179,1" -- Instrument Light Intensity >> AXIS :: Axis_A_63
Helios_F14.ExportArguments["4,3064"] ="11,3180,1" -- Console Light Intensity >> AXIS :: Axis_A_64
Helios_F14.ExportArguments["4,3065"] ="11,3181,1" -- Formation Light Intensity >> AXIS :: Axis_A_65
Helios_F14.ExportArguments["4,3066"] ="11,3602,1" -- Instrument Light Intensity >> AXIS :: Axis_A_66
Helios_F14.ExportArguments["4,3067"] ="11,3603,1" -- Console Light Intensity >> AXIS :: Axis_A_67
Helios_F14.ExportArguments["4,3068"] ="47,3326,1" -- TACAN Mode >> AXIS :: Axis_A_68
Helios_F14.ExportArguments["4,3069"] ="47,3330,1" -- TACAN Channel Wheel (Tens) >> AXIS :: Axis_A_69
Helios_F14.ExportArguments["4,3070"] ="47,3332,1" -- TACAN Channel Lever (Ones) >> AXIS :: Axis_A_70
Helios_F14.ExportArguments["4,3071"] ="47,3338,1" -- TACAN Mode >> AXIS :: Axis_A_71
Helios_F14.ExportArguments["4,3072"] ="47,3342,1" -- TACAN Channel Wheel (Tens) >> AXIS :: Axis_A_72
Helios_F14.ExportArguments["4,3073"] ="47,3344,1" -- TACAN Channel Lever (Ones) >> AXIS :: Axis_A_73
Helios_F14.ExportArguments["4,3074"] ="2,3382,1" -- ICS Amplifier Selector >> AXIS :: Axis_A_74
Helios_F14.ExportArguments["4,3075"] ="2,3389,1" -- ICS Amplifier Selector >> AXIS :: Axis_A_75
Helios_F14.ExportArguments["4,3076"] ="3,3375,1" -- UHF ARC-159 Freq Mode >> AXIS :: Axis_A_76
Helios_F14.ExportArguments["4,3077"] ="3,3371,1" -- UHF ARC-159 Function >> AXIS :: Axis_A_77
Helios_F14.ExportArguments["4,3078"] ="4,3417,1" -- VHF/UHF ARC-182 Freq Mode >> AXIS :: Axis_A_78
Helios_F14.ExportArguments["4,3079"] ="4,3413,1" -- VHF/UHF ARC-182 MODE >> AXIS :: Axis_A_79
Helios_F14.ExportArguments["4,3080"] ="2,3423,1" -- KY-28 Power Mode >> AXIS :: Axis_A_80
Helios_F14.ExportArguments["4,3081"] ="2,3425,1" -- KY-28 Radio Selector >> AXIS :: Axis_A_81
Helios_F14.ExportArguments["4,3082"] ="53,3252,1" -- DECM ALQ-100 Power/Mode >> AXIS :: Axis_A_82
Helios_F14.ExportArguments["4,3083"] ="54,3257,1" -- AN/ALR-67 Display Type >> AXIS :: Axis_A_83
Helios_F14.ExportArguments["4,3084"] ="50,3106,1" -- Navigation Mode >> AXIS :: Axis_A_84
Helios_F14.ExportArguments["4,3085"] ="46,3109,1" -- Destination Mode >> AXIS :: Axis_A_85
Helios_F14.ExportArguments["4,3086"] ="43,3112,1" -- TID Mode >> AXIS :: Axis_A_86
Helios_F14.ExportArguments["4,3087"] ="43,3113,1" -- TID Range >> AXIS :: Axis_A_87
Helios_F14.ExportArguments["4,3088"] ="39,3442,1" -- Radar elevation scan >> AXIS :: Axis_A_88
Helios_F14.ExportArguments["4,3089"] ="39,3443,1" -- Radar azimuth scan >> AXIS :: Axis_A_89
Helios_F14.ExportArguments["4,3090"] ="37,3605,1" -- Record mode N-F >> AXIS :: Axis_A_90
Helios_F14.ExportArguments["4,3091"] ="55,3146,1" -- Weapon type wheel >> AXIS :: Axis_A_91
Helios_F14.ExportArguments["4,3092"] ="55,3151,1" -- Attack mode >> AXIS :: Axis_A_92
Helios_F14.ExportArguments["4,3093"] ="55,3152,1" -- Elec fuse >> AXIS :: Axis_A_93
Helios_F14.ExportArguments["4,3094"] ="55,3153,1" -- Missile speed gate >> AXIS :: Axis_A_94
Helios_F14.ExportArguments["4,3095"] ="23,3530,1" -- CAP category >> AXIS :: Axis_A_95
Helios_F14.ExportArguments["4,3096"] ="52,3680,1" -- Beacon mode >> AXIS :: Axis_A_96
Helios_F14.ExportArguments["4,3097"] ="64,3621,1" -- IFF code N-F >> AXIS :: Axis_A_97
Helios_F14.ExportArguments["4,3098"] ="64,3622,1" -- IFF master N-F >> AXIS :: Axis_A_98
Helios_F14.ExportArguments["4,3099"] ="3,3373,1" -- UHF ARC-159 Preset Channel Selector >> AXIS :: Axis_A_99
Helios_F14.ExportArguments["4,3101"] ="12,3006,1" -- Hydraulic Hand Pump >> AXIS :: Axis_B_101
Helios_F14.ExportArguments["4,3102"] ="16,3029,1" -- Emergency Wing Sweep Handle Cover >> AXIS :: Axis_B_102
Helios_F14.ExportArguments["4,3103"] ="17,3013,1" -- Parking Brake Handle >> AXIS :: Axis_B_103
Helios_F14.ExportArguments["4,3104"] ="20,3061,1" -- Fuel Shutoff - Right >> AXIS :: Axis_B_104
Helios_F14.ExportArguments["4,3105"] ="20,3062,1" -- Fuel Shutoff - Left >> AXIS :: Axis_B_105
Helios_F14.ExportArguments["4,3106"] ="11,3184,1" -- Canopy Jettison >> AXIS :: Axis_B_106
Helios_F14.ExportArguments["4,3107"] ="11,3184,1" -- Canopy Jettison >> AXIS :: Axis_B_107
Helios_F14.ExportArguments["4,3108"] ="11,3185,1" -- Ejection CMD Lever >> AXIS :: Axis_B_108
Helios_F14.ExportArguments["4,3109"] ="11,3186,1" -- Ejection Seat Safety >> AXIS :: Axis_B_109
Helios_F14.ExportArguments["4,3110"] ="11,3187,1" -- Ejection Seat Safety >> AXIS :: Axis_B_110
Helios_F14.ExportArguments["4,3111"] ="11,3566,1" -- Storage >> AXIS :: Axis_B_111
Helios_F14.ExportArguments["4,3112"] ="40,3228,1" -- HUD filter >> AXIS :: Axis_B_112
Helios_F14.ExportArguments["4,3113"] ="55,3135,1" -- Master Arm Cover >> AXIS :: Axis_B_113
Helios_F14.ExportArguments["4,3114"] ="55,3133,1" -- ACM Cover >> AXIS :: Axis_B_114
Helios_F14.ExportArguments["4,3115"] ="55,3655,1" -- Jettison aux guard >> AXIS :: Axis_B_115
Helios_F14.ExportArguments["4,3116"] ="16,3031,1" -- mergency Wing Sweep Handle LEV >> AXIS :: Axis_B_116
Helios_F14.ExportArguments["4,3117"] ="29,3484,1" -- Radar Altimeter Control Knob LEV >> AXIS :: Axis_B_117
Helios_F14.ExportArguments["4,3118"] ="27,3491,1" -- Airspeed Indicator Bug Knob LEV >> AXIS :: Axis_B_118
Helios_F14.ExportArguments["4,3119"] ="51,3433,1" -- Compass HDG Slave Knob/nPush rotate >> AXIS :: Axis_B_119
Helios_F14.ExportArguments["4,3120"] ="30,3546,1" -- Standby ADI Knob LEV >> AXIS :: Axis_B_120
Helios_F14.ExportArguments["4,3121"] ="30,3548,1" -- RIO Standby ADI Knob LEV >> AXIS :: Axis_B_121
Helios_F14.ExportArguments["4,3122"] ="5,3281,1" -- AN/ALE-37 L10 Load Type >> AXIS :: Axis_B_122
Helios_F14.ExportArguments["4,3123"] ="5,3283,1" -- AN/ALE-37 L20 Load Type >> AXIS :: Axis_B_123
Helios_F14.ExportArguments["4,3124"] ="5,3285,1" -- AN/ALE-37 R10 Load Type >> AXIS :: Axis_B_124
Helios_F14.ExportArguments["4,3125"] ="5,3287,1" -- AN/ALE-37 R20 Load Type >> AXIS :: Axis_B_125
Helios_F14.ExportArguments["4,3126"] ="5,3298,1" -- AN/ALE-37 Chaff Burst Quantity >> AXIS :: Axis_B_126
Helios_F14.ExportArguments["4,3127"] ="5,3300,1" -- AN/ALE-37 Chaff Burst Interval >> AXIS :: Axis_B_127
Helios_F14.ExportArguments["4,3128"] ="5,3302,1" -- AN/ALE-37 Chaff Salvo Quantity >> AXIS :: Axis_B_128
Helios_F14.ExportArguments["4,3129"] ="5,3304,1" -- AN/ALE-37 Chaff Salvo Interval >> AXIS :: Axis_B_129
Helios_F14.ExportArguments["4,3130"] ="5,3306,1" -- AN/ALE-37 Flare Quantity >> AXIS :: Axis_B_130
Helios_F14.ExportArguments["4,3131"] ="5,3308,1" -- AN/ALE-37 Flare Interval >> AXIS :: Axis_B_131
Helios_F14.ExportArguments["4,3132"] ="5,3295,1" -- AN/ALE-37 Jammer Quantity >> AXIS :: Axis_B_132
Helios_F14.ExportArguments["4,3133"] ="48,3322,1" -- AN/ARA-63 Channel Knob >> AXIS :: Axis_B_133
Helios_F14.ExportArguments["4,3134"] ="4,3415,1" -- VHF/UHF ARC-182 Preset Channel Selector >> AXIS :: Axis_B_134
Helios_F14.ExportArguments["4,3135"] ="64,3625,1" -- IFF M3 code 1s N-F >> AXIS :: Axis_B_135
Helios_F14.ExportArguments["4,3136"] ="64,3626,1" -- IFF M3 code 10s N-F >> AXIS :: Axis_B_136
Helios_F14.ExportArguments["4,3137"] ="64,3627,1" -- IFF M3 code 100s N-F >> AXIS :: Axis_B_137
Helios_F14.ExportArguments["4,3138"] ="64,3628,1" -- IFF M3 code 1000s N-F >> AXIS :: Axis_B_138
Helios_F14.ExportArguments["4,3139"] ="64,3629,1" -- IFF M1 code 1s N-F >> AXIS :: Axis_B_139
Helios_F14.ExportArguments["4,3140"] ="64,3630,1" -- IFF M1 code 10s N-F >> AXIS :: Axis_B_140
Helios_F14.ExportArguments["4,3141"] ="5,3289,1" -- AN/ALE-37 Jammer Interval Units >> AXIS :: Axis_B_141
Helios_F14.ExportArguments["4,3142"] ="5,3291,1" -- AN/ALE-37 Jammer Interval Tens >> AXIS :: Axis_B_142
Helios_F14.ExportArguments["4,3143"] ="5,3293,1" -- AN/ALE-37 Jammer Interval Hundreds >> AXIS :: Axis_B_143
Helios_F14.ExportArguments["4,3144"] ="55,3148,1" -- Weapon Interval x10ms >> AXIS :: Axis_B_144
Helios_F14.ExportArguments["4,3145"] ="55,3147,1" -- Weapon Interval x100ms >> AXIS :: Axis_B_145
Helios_F14.ExportArguments["4,3146"] ="55,3149,1" -- Weapon Quantity 10s >> AXIS :: Axis_B_146
Helios_F14.ExportArguments["4,3147"] ="55,3150,1" -- Weapon Quantity 1s >> AXIS :: Axis_B_147
Helios_F14.ExportArguments["4,3148"] ="52,3586,1" -- Datalink freq 10MHz >> AXIS :: Axis_B_148
Helios_F14.ExportArguments["4,3149"] ="52,3587,1" -- Datalink freq 1MHz >> AXIS :: Axis_B_149
Helios_F14.ExportArguments["4,3150"] ="52,3588,1" -- Datalink freq 100kHz >> AXIS :: Axis_B_150
Helios_F14.ExportArguments["4,3151"] ="52,3593,1" -- Datalink address high >> AXIS :: Axis_B_151
Helios_F14.ExportArguments["4,3152"] ="52,3594,1" -- Datalink address low >> AXIS :: Axis_B_152
Helios_F14.ExportArguments["4,3153"] ="10,3076,1" -- Master Test Selector rotate >> AXIS :: Axis_B_153 


	
---------------------------- end of F14 export table
----------------------------------------------------------

