Helios_Huey = {}

Helios_Huey.Name = "UH-1H"
Helios_Huey.FlamingCliffsAircraft = false

Helios_Huey.ExportArguments = {}

function Helios_Huey.ProcessInput(data)
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
		lConvDevice = Helios_Huey.ExportArguments[sIndex]
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
			end
		end
	end
end

function Helios_Huey.HighImportance(MainPanel)
	-- prepare frecuencies data
	local ARN_83_Band = MainPanel:get_argument_value(38)
	if ARN_83_Band == 0 then
		ADF_ARN83_Frequency = Helios_Util.ValueConvert(MainPanel:get_argument_value(45),{400, 420, 450, 850},{0.0, 0.053, 0.11, 0.550})
		ADF_band_selector=2
    end
	
    if ARN_83_Band < 0 then
		ADF_ARN83_Frequency = Helios_Util.ValueConvert(MainPanel:get_argument_value(45),{190, 200, 400},{0.0, 0.048, 0.550})
		ADF_band_selector=1
    end
	
    if ARN_83_Band > 0 then
		ADF_ARN83_Frequency = Helios_Util.ValueConvert(MainPanel:get_argument_value(45),{850, 900, 1800},{0.0, 0.053, 0.550})
		ADF_band_selector=3
    end

	local UHF_ARC51_Freq1 = Helios_Util.ValueConvert(MainPanel:get_argument_value(10),{2.0, 3.0},{0.0, 1.0})
    local UHF_ARC51_Freq2 = MainPanel:get_argument_value(11)*10 
    local UHF_ARC51_Freq3 = MainPanel:get_argument_value(12)*10 
    local UHF_ARC51_Freq4 = MainPanel:get_argument_value(13)*10 
    local UHF_ARC51_Freq5 = MainPanel:get_argument_value(14)*10 
   					
    local NAV_ARN82_Freq1 = MainPanel:get_argument_value(46)*10
    local NAV_ARN82_Freq2 = MainPanel:get_argument_value(47)*10
    local NAV_ARN82_Freq3 = MainPanel:get_argument_value(48)*10
    local NAV_ARN82_Freq4 = MainPanel:get_argument_value(49)*10
    local NAV_ARN82_Freq5 = MainPanel:get_argument_value(50)*10
 
	local VHF_ARC134_Freq1 = MainPanel:get_argument_value(1)*10 
    local VHF_ARC134_Freq2 = MainPanel:get_argument_value(2)*10 
    local VHF_ARC134_Freq3 = MainPanel:get_argument_value(3)
    local VHF_ARC134_Freq4 = MainPanel:get_argument_value(4)
	
	local FM_mask_1 =false
	local FM_mask_2 =false

	local FMknob1 =  MainPanel:get_argument_value(31)
	local FMknob2 =  MainPanel:get_argument_value(32)
	
	if FMknob1 > 0.55 and  FMknob2 >0.55 then
		FM_mask_1 =0
	else
		FM_mask_1=1
	end

	if FMknob1 > 0.65 and  FMknob2 >0.45 then
		FM_mask_2 =0
	else
		FM_mask_2=1
	end
	
	Helios_Udp.Send("7059", string.format("%0.1f", MainPanel:get_argument_value(31) ) ) -- Frequency Tens MHz Selector 
	Helios_Udp.Send("7057", string.format("%0.1f", MainPanel:get_argument_value(32) ) ) -- Frequency Ones MHz Selector 

	local instruments_table =
	{	
		[1] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(151),{-0.7, 0.7},{-1.0, 1.0}),   -- VerticalBar 										
		[2] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(152),{-0.7, 0.7},{-1.0, 1.0}),   -- HorisontalBar 									
		[3] =	MainPanel:get_argument_value(31),            -- Frequency Tens MHz Selector 									
		[4] =	MainPanel:get_argument_value(32),            -- Frequency Ones MHz Selector 										
		[5] =	Helios_Util.ValueConvert(MainPanel:get_argument_value(156),{0.0, math.pi * 2.0},{0.0, 1.0}),   -- RotCourseCard 									
		[6] =	ADF_ARN83_Frequency,                           -- ADF_ARN83_Frequency 								
		[7] =	MainPanel:get_argument_value(40),              -- ARN83_SignalLevel 	0 to 1  							
		[8] =	MainPanel:get_argument_value(159),             -- GMC_CoursePointer1 0 to 1  								
		[9] =	MainPanel:get_argument_value(160),             -- GMC_CoursePointer2 0 to 1  								
		[10] = 	MainPanel:get_argument_value(162),             -- GMC_HeadingMarker 	0 to 1  							
		[11] = 	MainPanel:get_argument_value(165),             -- GMC_Heading 	0 to 1  									
		[12] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(166),{-1.0, 1.0},{0.0, 1.0}),    -- GMC_Annunciator 									
		[13] = 	MainPanel:get_argument_value(167),             -- GMC_PowerFail 	0 to 1  							
		[14] = 	MainPanel:get_argument_value(266),   -- RMI_CoursePointer1 								
		[15] = 	MainPanel:get_argument_value(267),   -- RMI_CoursePointer2 								
		[16] = 	MainPanel:get_argument_value(269),   -- RMI_Heading 										
		[17] = 	MainPanel:get_argument_value(168),   -- Pointer 	0 to 1  										
		[18] = 	MainPanel:get_argument_value(169),       -- Alt1AAU_10000_footCount 0 to 1  							
		[19] = 	MainPanel:get_argument_value(170),       -- Alt1AAU_1000_footCount 0 to 1  							
		[20] = 	MainPanel:get_argument_value(171),       -- Alt1AAU_100_footCount 	0 to 1  						
		[21] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(174),{0, 1.0},{0.0, 0.3}),   -- AAU_32_Drum_Counter1 							
		[22] = 	MainPanel:get_argument_value(175),       -- AAU_32_Drum_Counter2 	0 to 1  						
		[23] = 	MainPanel:get_argument_value(176),       -- AAU_32_Drum_Counter3 	0 to 1  						
		[24] = 	MainPanel:get_argument_value(177),          -- CodeOff_flag 	0 to 1  								
		[25] =  ADF_band_selector,                           -- ADF_band_selector 					
		[26] = 	MainPanel:get_argument_value(178),          -- Alt_10000_AAU_7A 	0 to 1  							
		[27] = 	MainPanel:get_argument_value(179),          -- Alt_1000_AAU_7A 	0 to 1  								
		[28] = 	MainPanel:get_argument_value(180),          -- Alt_100_AAU_7A 	0 to 1  								
		[29] = 	MainPanel:get_argument_value(182),          -- Press_AAU_7A 		0 to 1  							
		[30] = 	MainPanel:get_argument_value(181),	       -- Pressure_Adjustment_pilot 						
		[31] = 	MainPanel:get_argument_value(113),          -- EngOilPress 										
		[32] = 	MainPanel:get_argument_value(114),          -- EngOilTemp 										
		[33] = 	MainPanel:get_argument_value(115),          -- TransmOilPress 									
		[34] = 	MainPanel:get_argument_value(116),          -- TransmOilTemp 									
		[35] = 	MainPanel:get_argument_value(117),          -- AIRSPEED_Nose 	0 to 1							
		[36] = 	MainPanel:get_argument_value(118),          -- AIRSPEED_Roof 	0 to 1							
		[37] = 	MainPanel:get_argument_value(121),          -- ExhaustTemp 		0 to 1							
		[38] = 	MainPanel:get_argument_value(122),          -- EngineTach		0 to 1							
		[39] = 	MainPanel:get_argument_value(123),          -- RotorTach 		0 to 1							
		[40] = 	MainPanel:get_argument_value(119),          -- GasProducerTach 	0 to 1							
		[41] = 	MainPanel:get_argument_value(120),          -- GasProducerTach_U 0 to 1							
		[42] = 	MainPanel:get_argument_value(124),          -- TorquePress	 									
		[43] = 	MainPanel:get_argument_value(149), 		   -- VoltageDC 		 0 to 1         								
		[44] = 	MainPanel:get_argument_value(150), 		   -- VoltageAC 		 0 to 1         								
		[45] = 	MainPanel:get_argument_value(436), 		   -- LoadmeterMainGen 	 0 to 1         							
		[46] = 	MainPanel:get_argument_value(125), 		   -- LoadmeterSTBYGen 	 0 to 1         							
		[47] = 	MainPanel:get_argument_value(126), 		   -- FuelPress 		                								
		[48] = 	MainPanel:get_argument_value(239), 		   -- FuelQuantity 		                							
		[49] = 	MainPanel:get_argument_value(127), 		   -- CLOCK_hours 		 0 to 1         								
		[50] = 	MainPanel:get_argument_value(128), 		   -- CLOCK_minutes 	 0 to 1         								
		[51] = 	MainPanel:get_argument_value(129), 		   -- CLOCK_seconds 	 0 to 1         								
		[52] = 	MainPanel:get_argument_value(132),		   -- TurnPtr 			-1 to 1         								
		[53] = 	MainPanel:get_argument_value(133), 		   -- SideSlip 			 -1 to 1        							
		[54] = 	MainPanel:get_argument_value(134), 		   -- VertVelocPilot 	 -1 to 1        								
		[55] = 	MainPanel:get_argument_value(251), 		   -- VertVelocCopilot	 -1 to 1        								
		[56] = 	MainPanel:get_argument_value(142), 		   -- Attitude_Roll 	 -1 to 1        								
		[57] = 	MainPanel:get_argument_value(143), 		   -- Attitude_Pitch 	 -1 to 1        								
		[58] = 	MainPanel:get_argument_value(148), 		   -- Attitude_Off_flag  0 to 1 INVERTIDO								
		[59] = 	MainPanel:get_argument_value(145),          -- Attitude_Indicator_Pitch_Trim_Knob_pilot 		
		[60] = 	MainPanel:get_argument_value(144),          -- Attitude_Indicator_Roll_Trim_Knob_pilot 			
		[61] = 	MainPanel:get_argument_value(135),   	   -- Attitude_Roll_left 	-1 to 1							
		[62] = 	MainPanel:get_argument_value(136), 		   -- Attitude_Pitch_left 	-1 to 1 							
		[63] = 	MainPanel:get_argument_value(141),    	   -- Attitude_Off_flag_left 	0 to 1 INVERTIDO						
		[64] = 	Helios_Util.ValueConvert(MainPanel:get_argument_value(138),{0.0, 1.0},{-1.0, 1.0}),   -- Attitude_PitchShift 								
		[65] =	MainPanel:get_argument_value(163),           -- Heading_Set_Knob 			
		[66] =	MainPanel:get_argument_value(161),			-- Compass_Synchronizing 		
		[67] =	MainPanel:get_argument_value(155),           -- Course_select_knob 			
		[68] = 	MainPanel:get_argument_value(268),  			-- RMI Pointer						
		[69] =  MainPanel:get_argument_value(463),       -- CHAFF_Digit_2 	0 to 1 								
		[70] = 	(UHF_ARC51_Freq1*100) + (UHF_ARC51_Freq2*10) + (UHF_ARC51_Freq3) + (UHF_ARC51_Freq4/10) + (UHF_ARC51_Freq5/100),  -- UHF_ARC51_FREQ 									
		[71] =	math.floor((MainPanel:get_argument_value(16)*20)+ 0.4),   -- preset_channel_selector 	20 pos 0.05												
		[72] = 	100 + (VHF_ARC134_Freq1*10) + (VHF_ARC134_Freq2) + (VHF_ARC134_Freq3) + (VHF_ARC134_Freq4/10),                    -- VHF_ARC134_FREQ 									
		[73] = 	(NAV_ARN82_Freq1*100) + (NAV_ARN82_Freq2*10) + (NAV_ARN82_Freq3) + (NAV_ARN82_Freq4/10) + (NAV_ARN82_Freq5/100),  -- NAV_ARN82_FREQ 									
		[74] = 	MainPanel:get_argument_value(443), 	        -- RALT_Needle 		0 to 0.98 								
		[75] = 	MainPanel:get_argument_value(444), 	        -- RALT_LO_Index 	0 to 0.744								
		[76] = 	MainPanel:get_argument_value(466), 	        -- RALT_HI_Index	0 to 0.744								
		[77] = 	MainPanel:get_argument_value(468), 	        -- RALT_Digit_1 	0 to 1    								
		[78] = 	MainPanel:get_argument_value(469), 	        -- RALT_Digit_2		0 to 1    								
		[79] = 	MainPanel:get_argument_value(470), 	        -- RALT_Digit_3		0 to 1    								
		[80] = 	MainPanel:get_argument_value(471), 	        -- RALT_Digit_4		0 to 1    								
		[81] = 	MainPanel:get_argument_value(131),           -- clock winding buttton 									
		[82] = 	MainPanel:get_argument_value(460),       -- FLARE_Digit_1 	0 to 1 								
		[83] = 	MainPanel:get_argument_value(461),       -- FLARE_Digit_2 	0 to 1 								
		[84] = 	MainPanel:get_argument_value(462),       -- CHAFF_Digit_1 	0 to 1 
		[85] = 	MainPanel:get_argument_value(437)       -- RamTemp 	0 to 1 			
	}		

	-- exporting UH-1H instruments data
	for a=1, #instruments_table do
		Helios_Udp.Send(tostring(a), string.format("%0.3f",  instruments_table[a] ) )
	end

	local lamps_table =
	{	
		[1] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(56)),      -- Marker_Beacon_Lamp
		[2] = FM_mask_1,     -- masks for FM knobs
		[3] = FM_mask_2,     -- masks for FM knobs
		[4] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(467)),     -- lamp_RALT_Off_Flag
		[5] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(447)),     -- RALT_LO_Lamp
		[6] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(465)),     -- RALT_HI_Lamp
		[7] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(91)),		-- lamp_ENGINE_OIL_PRESS
		[8] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(92)),      -- lamp_ENGINE_ICING    
		[9] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(93)),      -- lamp_ENGINE_ICE_JET  
		[10] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(94)),     -- lamp_ENGINE_CHIP_DET 
		[11] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(95)),     -- lamp_LEFT_FUEL_BOOST 
		[12] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(96)),     -- lamp_RIGHT_FUEL_BOOST
		[13] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(97)),     -- lamp_ENG_FUEL_PUMP   
		[14] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(98)),     -- lamp_20_MINUTE       
		[15] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(99)),     -- lamp_FUEL_FILTER     
		[16] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(100)),    -- lamp_GOV_EMERG       
		[17] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(101)),    -- lamp_AUX_FUEL_LOW    
		[18] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(102)),    -- lamp_XMSN_OIL_PRESS  
		[19] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(103)),    -- lamp_XMSN_OIL_HOT    
		[20] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(104)),    -- lamp_HYD_PRESSURE    
		[21] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(105)),    -- lamp_ENGINE_INLET_AIR
		[22] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(106)),    -- lamp_INST_INVERTER   
		[23] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(107)),    -- lamp_DC_GENERATOR    
		[24] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(108)),    -- lamp_EXTERNAL_POWER  
		[25] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(109)),    -- lamp_CHIP_DETECTOR   
		[26] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(110)),    -- lamp_IFF             
		[27] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(254)),    -- lamp_ARMED           
		[28] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(255)),    -- lamp_SAFE            
		[29] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(275)),    -- lamp_FIRE            
		[30] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(276)),    -- lamp_LOW_RPM         
		[31] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(277)),    -- lamp_MASTER          
		[32] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(76)),     -- lamp_IFF_REPLY
		[33] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(77)),     -- lamp_IFF_TEST 
		[34] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(458)),    -- lamp_XM130_ARMED
		[35] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(157)),    -- lamp_VerticalOFF
		[36] = Helios_Util.Convert_Lamp (MainPanel:get_argument_value(158))    -- lamp_HorisontalOFF	
	} 
	
	-- flag values in index 1001
	for a=1, #lamps_table do
		Helios_Udp.Send(tostring(a + 1000), string.format("%1d",  lamps_table[a] ) )
	end
	
	Helios_Udp.Flush()
end

function Helios_Huey.LowImportance(MainPanel)
	Helios_Udp.Send(130, string.format("%1d", (MainPanel:get_argument_value(68)*3.03)+0.1 )) --MODE1-WHEEL1  68  4 pos 0.33
	Helios_Udp.Send(131, string.format("%1d", (MainPanel:get_argument_value(69)*9.09)+0.1 )) --MODE1-WHEEL2  69  8 pos 0.11
	Helios_Udp.Send(132, string.format("%1d", (MainPanel:get_argument_value(70)*9.09)+0.1 )) --MODE3A-WHEEL1  70  8 pos 0.11
	Helios_Udp.Send(133, string.format("%1d", (MainPanel:get_argument_value(71)*9.09)+0.1 )) --MODE3A-WHEEL2  71  8 pos 0.11
	Helios_Udp.Send(134, string.format("%1d", (MainPanel:get_argument_value(72)*9.09)+0.1 )) --MODE3A-WHEEL3  72  8 pos 0.11
	Helios_Udp.Send(135, string.format("%1d", (MainPanel:get_argument_value(73)*9.09)+0.1 )) --MODE3A-WHEEL4  73  8 pos 0.11

-- BUTTONS
	Helios_Udp.Send("2001", string.format("%.1f", MainPanel:get_argument_value(240) ) ) -- Test Fuel Gauge Button - Push to Test >> PUSH_BUTTONS :: PB_1
	Helios_Udp.Send("2002", string.format("%.1f", MainPanel:get_argument_value(131) ) ) -- Winding/Adjustment Clock btn >> PUSH_BUTTONS :: PB_2
	Helios_Udp.Send("2003", string.format("%.1f", MainPanel:get_argument_value(278) ) ) -- Fire Detector Test Button - Push to test >> PUSH_BUTTONS :: PB_3
	Helios_Udp.Send("2004", string.format("%.1f", MainPanel:get_argument_value(140) ) ) -- Cage Copilot Attitude Indicator - Pull to cage >> PUSH_BUTTONS :: PB_4
	Helios_Udp.Send("2005", string.format("%.1f", MainPanel:get_argument_value(6) ) ) -- Comm Test Button - Push to test >> PUSH_BUTTONS :: PB_5
	Helios_Udp.Send("2006", string.format("%.1f", MainPanel:get_argument_value(258) ) ) -- Rocket Reset Button - Push to reset >> PUSH_BUTTONS :: PB_6
	Helios_Udp.Send("2007", string.format("%.1f", MainPanel:get_argument_value(260) ) ) -- Jettison Switch >> PUSH_BUTTONS :: PB_7
	Helios_Udp.Send("2008", string.format("%.1f", MainPanel:get_argument_value(189) ) ) -- Force Trim Button >> PUSH_BUTTONS :: PB_8
	Helios_Udp.Send("2009", string.format("%.1f", MainPanel:get_argument_value(193) ) ) -- Force Trim Button >> PUSH_BUTTONS :: PB_9
	Helios_Udp.Send("2010", string.format("%.1f", MainPanel:get_argument_value(195) ) ) -- Cargo Release Pilot >> PUSH_BUTTONS :: PB_10
	Helios_Udp.Send("2011", string.format("%.1f", MainPanel:get_argument_value(198) ) ) -- Cargo Release CoPilot >> PUSH_BUTTONS :: PB_11
	Helios_Udp.Send("2012", string.format("%.1f", MainPanel:get_argument_value(464) ) ) -- Flare Dispense Button - Push to dispense >> PUSH_BUTTONS :: PB_12
	Helios_Udp.Send("2013", string.format("%.1f", MainPanel:get_argument_value(457) ) ) -- Armed Lamp Test Button - Push to test >> PUSH_BUTTONS :: PB_13
	Helios_Udp.Send("2014", string.format("%.1f", MainPanel:get_argument_value(453) ) ) -- Flare counter Reset. press reset >> PUSH_BUTTONS :: PB_14
	Helios_Udp.Send("2015", string.format("%.1f", MainPanel:get_argument_value(455) ) ) -- Chaff counter Reset. press reset >> PUSH_BUTTONS :: PB_15
	Helios_Udp.Send("2016", string.format("%.1f", MainPanel:get_argument_value(446) ) ) -- Test / Hight Set. Left mouse click to Test >> PUSH_BUTTONS :: PB_16
	--Helios_Udp.Send("2017", string.format("%.1f", MainPanel:get_argument_value(419) ) ) -- Open Doors >> PUSH_BUTTONS :: PB_17
	--Helios_Udp.Send("2018", string.format("%.1f", MainPanel:get_argument_value(421) ) ) -- Open Doors >> PUSH_BUTTONS :: PB_18
	--Helios_Udp.Send("2019", string.format("%.1f", MainPanel:get_argument_value(42) ) ) -- Loop Left Low Speed >> PUSH_BUTTONS :: PB_19
	--Helios_Udp.Send("2020", string.format("%.1f", MainPanel:get_argument_value(42) ) ) -- Loop Right Low Speed >> PUSH_BUTTONS :: PB_20
	Helios_Udp.Send("2021", string.format("%.1f", MainPanel:get_argument_value(74) ) ) -- Reply Button >> PUSH_BUTTONS :: PB_21
	Helios_Udp.Send("2022", string.format("%.1f", MainPanel:get_argument_value(75) ) ) -- Test Button >> PUSH_BUTTONS :: PB_22

--switches 2 pos
	Helios_Udp.Send("3001", string.format("%1d", MainPanel:get_argument_value(219) ) ) -- Battery Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_1
	Helios_Udp.Send("3002", string.format("%1d", MainPanel:get_argument_value(220) ) ) -- Starter/Stdby GEN Switch >> TOGLEE_SWITCH :: TSwitch_2
	Helios_Udp.Send("3003", string.format("%1d", MainPanel:get_argument_value(221) ) ) -- Non-Essential Bus Switch, NORMAL/MANUAL >> TOGLEE_SWITCH :: TSwitch_3
	Helios_Udp.Send("3004", string.format("%1d", MainPanel:get_argument_value(285) ) ) -- CB IFF APX 1 (N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_4
	Helios_Udp.Send("3005", string.format("%1d", MainPanel:get_argument_value(287) ) ) -- CB IFF APX 2 (N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_5
	Helios_Udp.Send("3006", string.format("%1d", MainPanel:get_argument_value(289) ) ) -- CB Prox. warn.(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_6
	Helios_Udp.Send("3007", string.format("%1d", MainPanel:get_argument_value(291) ) ) -- CB Marker beacon, ON/OFF >> TOGLEE_SWITCH :: TSwitch_7
	Helios_Udp.Send("3008", string.format("%1d", MainPanel:get_argument_value(293) ) ) -- CB VHF Nav. (ARN-82), ON/OFF >> TOGLEE_SWITCH :: TSwitch_8
	Helios_Udp.Send("3009", string.format("%1d", MainPanel:get_argument_value(295) ) ) -- CB LF Nav. (ARN-83), ON/OFF >> TOGLEE_SWITCH :: TSwitch_9
	Helios_Udp.Send("3010", string.format("%1d", MainPanel:get_argument_value(297) ) ) -- CB Intercom CPLT(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_10
	Helios_Udp.Send("3011", string.format("%1d", MainPanel:get_argument_value(299) ) ) -- CB Intercom PLT, ON/OFF >> TOGLEE_SWITCH :: TSwitch_11
	Helios_Udp.Send("3012", string.format("%1d", MainPanel:get_argument_value(349) ) ) -- CB ARC-102 HF Static INVTR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_12
	Helios_Udp.Send("3013", string.format("%1d", MainPanel:get_argument_value(351) ) ) -- CB HF ANT COUPLR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_13
	Helios_Udp.Send("3014", string.format("%1d", MainPanel:get_argument_value(353) ) ) -- CB HF ARC-102(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_14
	Helios_Udp.Send("3015", string.format("%1d", MainPanel:get_argument_value(355) ) ) -- CB FM Radio, ON/OFF >> TOGLEE_SWITCH :: TSwitch_15
	Helios_Udp.Send("3016", string.format("%1d", MainPanel:get_argument_value(357) ) ) -- CB UHF Radio, ON/OFF >> TOGLEE_SWITCH :: TSwitch_16
	Helios_Udp.Send("3017", string.format("%1d", MainPanel:get_argument_value(359) ) ) -- CB FM 2 Radio(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_17
	Helios_Udp.Send("3018", string.format("%1d", MainPanel:get_argument_value(361) ) ) -- CB VHF AM Radio, ON/OFF >> TOGLEE_SWITCH :: TSwitch_18
	Helios_Udp.Send("3019", string.format("%1d", MainPanel:get_argument_value(321) ) ) -- CB Pitot tube(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_19
	Helios_Udp.Send("3020", string.format("%1d", MainPanel:get_argument_value(345) ) ) -- CB Rescue hoist CTL(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_20
	Helios_Udp.Send("3021", string.format("%1d", MainPanel:get_argument_value(347) ) ) -- CB Rescue hoist cable cutter N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_21
	Helios_Udp.Send("3022", string.format("%1d", MainPanel:get_argument_value(301) ) ) -- CB Wind wiper CPLT, ON/OFF >> TOGLEE_SWITCH :: TSwitch_22
	Helios_Udp.Send("3023", string.format("%1d", MainPanel:get_argument_value(303) ) ) -- CB Wind wiper PLT, ON/OFF >> TOGLEE_SWITCH :: TSwitch_23
	Helios_Udp.Send("3024", string.format("%1d", MainPanel:get_argument_value(305) ) ) -- CB KY-28 voice security(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_24
	Helios_Udp.Send("3025", string.format("%1d", MainPanel:get_argument_value(403) ) ) -- CB Starter Relay(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_25
	Helios_Udp.Send("3026", string.format("%1d", MainPanel:get_argument_value(307) ) ) -- CB Search light power(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_26
	Helios_Udp.Send("3027", string.format("%1d", MainPanel:get_argument_value(309) ) ) -- CB Landing light power(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_27
	Helios_Udp.Send("3028", string.format("%1d", MainPanel:get_argument_value(311) ) ) -- CB Landing & Search light control(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_28
	Helios_Udp.Send("3029", string.format("%1d", MainPanel:get_argument_value(313) ) ) -- CB Anticollision light(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_29
	Helios_Udp.Send("3030", string.format("%1d", MainPanel:get_argument_value(363) ) ) -- CB Fuselage lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_30
	Helios_Udp.Send("3031", string.format("%1d", MainPanel:get_argument_value(365) ) ) -- CB Navigation lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_31
	Helios_Udp.Send("3032", string.format("%1d", MainPanel:get_argument_value(367) ) ) -- CB Dome lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_32
	Helios_Udp.Send("3033", string.format("%1d", MainPanel:get_argument_value(369) ) ) -- CB Cockpit lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_33
	Helios_Udp.Send("3034", string.format("%1d", MainPanel:get_argument_value(371) ) ) -- CB Caution lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_34
	Helios_Udp.Send("3035", string.format("%1d", MainPanel:get_argument_value(373) ) ) -- CB Console lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_35
	Helios_Udp.Send("3036", string.format("%1d", MainPanel:get_argument_value(375) ) ) -- CB INST Panel lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_36
	Helios_Udp.Send("3037", string.format("%1d", MainPanel:get_argument_value(377) ) ) -- CB INST SEC lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_37
	Helios_Udp.Send("3038", string.format("%1d", MainPanel:get_argument_value(323) ) ) -- CB Cabin heater (Outlet valve)(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_38
	Helios_Udp.Send("3039", string.format("%1d", MainPanel:get_argument_value(325) ) ) -- CB Cabin heater (Air valve)(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_39
	Helios_Udp.Send("3040", string.format("%1d", MainPanel:get_argument_value(343) ) ) -- CB Rescue hoist PWR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_40
	Helios_Udp.Send("3041", string.format("%1d", MainPanel:get_argument_value(327) ) ) -- CB RPM Warning system(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_41
	Helios_Udp.Send("3042", string.format("%1d", MainPanel:get_argument_value(329) ) ) -- CB Engine anti-ice(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_42
	Helios_Udp.Send("3043", string.format("%1d", MainPanel:get_argument_value(331) ) ) -- CB Fire detector(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_43
	Helios_Udp.Send("3044", string.format("%1d", MainPanel:get_argument_value(333) ) ) -- CB LH fuel boost pump(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_44
	Helios_Udp.Send("3045", string.format("%1d", MainPanel:get_argument_value(335) ) ) -- CB Turn & Slip indicator, ON/OFF >> TOGLEE_SWITCH :: TSwitch_45
	Helios_Udp.Send("3046", string.format("%1d", MainPanel:get_argument_value(337) ) ) -- CB TEMP indicator(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_46
	Helios_Udp.Send("3047", string.format("%1d", MainPanel:get_argument_value(339) ) ) -- CB HYD Control(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_47
	Helios_Udp.Send("3048", string.format("%1d", MainPanel:get_argument_value(341) ) ) -- CB FORCE Trim(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_48
	Helios_Udp.Send("3049", string.format("%1d", MainPanel:get_argument_value(379) ) ) -- CB Cargo hook release(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_49
	Helios_Udp.Send("3050", string.format("%1d", MainPanel:get_argument_value(381) ) ) -- CB EXT Stores jettison(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_50
	Helios_Udp.Send("3051", string.format("%1d", MainPanel:get_argument_value(383) ) ) -- CB Spare inverter PWR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_51
	Helios_Udp.Send("3052", string.format("%1d", MainPanel:get_argument_value(385) ) ) -- CB Inverter CTRL (N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_52
	Helios_Udp.Send("3053", string.format("%1d", MainPanel:get_argument_value(387) ) ) -- CB Main inverter PWR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_53
	Helios_Udp.Send("3054", string.format("%1d", MainPanel:get_argument_value(389) ) ) -- CB Generator & Bus Reset(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_54
	Helios_Udp.Send("3055", string.format("%1d", MainPanel:get_argument_value(391) ) ) -- CB STBY Generator Field(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_55
	Helios_Udp.Send("3056", string.format("%1d", MainPanel:get_argument_value(393) ) ) -- CB Governor Control(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_56
	Helios_Udp.Send("3057", string.format("%1d", MainPanel:get_argument_value(395) ) ) -- CB IDLE Stop release(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_57
	Helios_Udp.Send("3058", string.format("%1d", MainPanel:get_argument_value(397) ) ) -- CB RH fuel boost pump(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_58
	Helios_Udp.Send("3059", string.format("%1d", MainPanel:get_argument_value(399) ) ) -- CB Fuel TRANS(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_59
	Helios_Udp.Send("3060", string.format("%1d", MainPanel:get_argument_value(401) ) ) -- CB Fuel valves(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_60
	Helios_Udp.Send("3061", string.format("%1d", MainPanel:get_argument_value(315) ) ) -- CB Heated blanket 1(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_61
	Helios_Udp.Send("3062", string.format("%1d", MainPanel:get_argument_value(317) ) ) -- CB Heated blanket 2(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_62
	Helios_Udp.Send("3063", string.format("%1d", MainPanel:get_argument_value(319) ) ) -- CB Voltmeter Non Ess Bus(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_63
	Helios_Udp.Send("3064", string.format("%1d", MainPanel:get_argument_value(405) ) ) -- CB Ignition system(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_64
	Helios_Udp.Send("3065", string.format("%1d", MainPanel:get_argument_value(423) ) ) -- CB Pilot ATTD1(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_65
	Helios_Udp.Send("3066", string.format("%1d", MainPanel:get_argument_value(424) ) ) -- CB Pilot ATTD2(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_66
	Helios_Udp.Send("3067", string.format("%1d", MainPanel:get_argument_value(425) ) ) -- CB Copilot ATTD1(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_67
	Helios_Udp.Send("3068", string.format("%1d", MainPanel:get_argument_value(426) ) ) -- CB Copilot ATTD2(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_68
	Helios_Udp.Send("3069", string.format("%1d", MainPanel:get_argument_value(427) ) ) -- CB Gyro Cmps(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_69
	Helios_Udp.Send("3070", string.format("%1d", MainPanel:get_argument_value(428) ) ) -- CB Fuel Quantity(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_70
	Helios_Udp.Send("3071", string.format("%1d", MainPanel:get_argument_value(429) ) ) -- CB 28V Trans(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_71
	Helios_Udp.Send("3072", string.format("%1d", MainPanel:get_argument_value(430) ) ) -- CB Fail Relay(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_72
	Helios_Udp.Send("3073", string.format("%1d", MainPanel:get_argument_value(431) ) ) -- CB Pressure Fuel(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_73
	Helios_Udp.Send("3074", string.format("%1d", MainPanel:get_argument_value(432) ) ) -- CB Pressure Torque(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_74
	Helios_Udp.Send("3075", string.format("%1d", MainPanel:get_argument_value(433) ) ) -- CB Pressure XMSN(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_75
	Helios_Udp.Send("3076", string.format("%1d", MainPanel:get_argument_value(434) ) ) -- CB Pressure Eng(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_76
	Helios_Udp.Send("3077", string.format("%1d", MainPanel:get_argument_value(435) ) ) -- CB Course Ind(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_77
	Helios_Udp.Send("3078", string.format("%1d", MainPanel:get_argument_value(238) ) ) -- Pitot Heater Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_78
	Helios_Udp.Send("3079", string.format("%1d", MainPanel:get_argument_value(217) ) ) -- Main generator switch cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_79
	Helios_Udp.Send("3080", string.format("%1d", MainPanel:get_argument_value(81) ) ) -- Main Fuel Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_80
	Helios_Udp.Send("3081", string.format("%1d", MainPanel:get_argument_value(67) ) ) -- IFF On/Out Switch >> TOGLEE_SWITCH :: TSwitch_81
	Helios_Udp.Send("3082", string.format("%1d", MainPanel:get_argument_value(206) ) ) -- Throttle Stop Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_82
	Helios_Udp.Send("3083", string.format("%1d", MainPanel:get_argument_value(84) ) ) -- De-Ice Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_83
	Helios_Udp.Send("3084", string.format("%1d", MainPanel:get_argument_value(80) ) ) -- Low RPM Warning Switch, AUDIO/OFF >> TOGLEE_SWITCH :: TSwitch_84
	Helios_Udp.Send("3085", string.format("%1d", MainPanel:get_argument_value(85) ) ) -- Governor Switch, EMER/AUTO >> TOGLEE_SWITCH :: TSwitch_85
	Helios_Udp.Send("3086", string.format("%1d", MainPanel:get_argument_value(90) ) ) -- Hydraulic Control Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_86
	Helios_Udp.Send("3087", string.format("%1d", MainPanel:get_argument_value(89) ) ) -- Force Trim Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_87
	Helios_Udp.Send("3088", string.format("%1d", MainPanel:get_argument_value(23) ) ) -- VHF FM Radio Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_88
	Helios_Udp.Send("3089", string.format("%1d", MainPanel:get_argument_value(24) ) ) -- UHF Radio Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_89
	Helios_Udp.Send("3090", string.format("%1d", MainPanel:get_argument_value(25) ) ) -- VHF AM Radio Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_90
	Helios_Udp.Send("3091", string.format("%1d", MainPanel:get_argument_value(26) ) ) -- Receiver 4 N/F Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_91
	Helios_Udp.Send("3092", string.format("%1d", MainPanel:get_argument_value(27) ) ) -- INT Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_92
	Helios_Udp.Send("3093", string.format("%1d", MainPanel:get_argument_value(28) ) ) -- Receiver NAV Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_93
	Helios_Udp.Send("3094", string.format("%1d", MainPanel:get_argument_value(22) ) ) -- Squelch Disable Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_94
	Helios_Udp.Send("3095", string.format("%1d", MainPanel:get_argument_value(55) ) ) -- Marker Beacon Sensing Switch, HIGH/LOW >> TOGLEE_SWITCH :: TSwitch_95
	Helios_Udp.Send("3096", string.format("%1d", MainPanel:get_argument_value(41) ) ) -- BFO Switch (N/F), BFO/OFF >> TOGLEE_SWITCH :: TSwitch_96
	--Helios_Udp.Send("3097", string.format("%1d", MainPanel:get_argument_value(43) ) ) -- Gain control / Mode. Right mouse click to cycle mode >> TOGLEE_SWITCH :: TSwitch_97
	--Helios_Udp.Send("3098", string.format("%1d", MainPanel:get_argument_value(38) ) ) -- Tune control / Band selection. Right mouse click to select a band >> TOGLEE_SWITCH :: TSwitch_98
	Helios_Udp.Send("3099", string.format("%1d", MainPanel:get_argument_value(224) ) ) -- Position Lights Switch, DIM/BRIGHT >> TOGLEE_SWITCH :: TSwitch_99
	Helios_Udp.Send("3100", string.format("%1d", MainPanel:get_argument_value(225) ) ) -- Anti-Collision Lights Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_100
	Helios_Udp.Send("3101", string.format("%1d", MainPanel:get_argument_value(202) ) ) -- Landing Light Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_101
	Helios_Udp.Send("3102", string.format("%1d", MainPanel:get_argument_value(164) ) ) -- ADF/VOR Control Switch >> TOGLEE_SWITCH :: TSwitch_102
	Helios_Udp.Send("3103", string.format("%1d", MainPanel:get_argument_value(241) ) ) -- Gyro Mode Switch, DG/Slave >> TOGLEE_SWITCH :: TSwitch_103
	--Helios_Udp.Send("3104", string.format("%1d", MainPanel:get_argument_value(0) ) ) -- Pilot Sight, Armed/Safe >> TOGLEE_SWITCH :: TSwitch_104
	--Helios_Udp.Send("3105", string.format("%1d", MainPanel:get_argument_value(439) ) ) -- Pilot Sight Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_105
	Helios_Udp.Send("3106", string.format("%1d", MainPanel:get_argument_value(228) ) ) -- Cargo Safety >> TOGLEE_SWITCH :: TSwitch_106
	Helios_Udp.Send("3107", string.format("%1d", MainPanel:get_argument_value(450) ) ) -- Ripple Fire Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_107
	Helios_Udp.Send("3108", string.format("%1d", MainPanel:get_argument_value(451) ) ) -- Ripple Fire Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_108
	Helios_Udp.Send("3109", string.format("%1d", MainPanel:get_argument_value(456) ) ) -- ARM Switch, SAFE/ARM >> TOGLEE_SWITCH :: TSwitch_109
	Helios_Udp.Send("3110", string.format("%1d", MainPanel:get_argument_value(459) ) ) -- Chaff Mode Switch, MAN/PGRM >> TOGLEE_SWITCH :: TSwitch_110
	Helios_Udp.Send("3111", string.format("%1d", MainPanel:get_argument_value(449) ) ) -- Radar Altimeter Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_111
		
-- TREE WAY SWITCHES	
	Helios_Udp.Send("5001", string.format("%1d", MainPanel:get_argument_value(215) ) ) -- Inverter Switch, MAIN/OFF/SPARE >> TREE_WAY_SWITCH :: 3WSwitch_A_1
	Helios_Udp.Send("5002", string.format("%1d", MainPanel:get_argument_value(60) ) ) -- Audio/light Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_2
	Helios_Udp.Send("5003", string.format("%1d", MainPanel:get_argument_value(223) ) ) -- Position Lights Switch, STEADY/OFF/FLASH >> TREE_WAY_SWITCH :: 3WSwitch_A_3
	Helios_Udp.Send("5004", string.format("%1d", MainPanel:get_argument_value(201) ) ) -- Search Light Switch, ON/OFF/STOW >> TREE_WAY_SWITCH :: 3WSwitch_A_4
	Helios_Udp.Send("5005", string.format("%1d", MainPanel:get_argument_value(205) ) ) -- Landing Light Control Switch, EXT/OFF/RETR >> TREE_WAY_SWITCH :: 3WSwitch_A_5
	Helios_Udp.Send("5006", string.format("%1d", MainPanel:get_argument_value(226) ) ) -- Dome Light Switch, WHITE/OFF/GREEN >> TREE_WAY_SWITCH :: 3WSwitch_A_6
	Helios_Udp.Send("5007", string.format("%1d", MainPanel:get_argument_value(252) ) ) -- Armament Switch, ARMED/SAFE/OFF >> TREE_WAY_SWITCH :: 3WSwitch_A_7
	Helios_Udp.Send("5008", string.format("%1d", MainPanel:get_argument_value(253) ) ) -- Gun Selector Switch, LEFT/ALL/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_8
	Helios_Udp.Send("5009", string.format("%1d", MainPanel:get_argument_value(256) ) ) -- Armament Selector Switch, 7.62/2.75/40 >> TREE_WAY_SWITCH :: 3WSwitch_A_9
	Helios_Udp.Send("5010", string.format("%1d", MainPanel:get_argument_value(259) ) ) -- Jettison Switch Cover, OPEN/CLOSE >> TREE_WAY_SWITCH :: 3WSwitch_A_10
	--Helios_Udp.Send("5011", string.format("%1d", MainPanel:get_argument_value(408) ) ) -- Sighting Station Lamp Switch, BACKUP/OFF/MAIN >> TREE_WAY_SWITCH :: 3WSwitch_A_11
	Helios_Udp.Send("5012", string.format("%1d", MainPanel:get_argument_value(227) ) ) -- Wiper Selector Switch, PILOT/BOTH/COPILOT >> TREE_WAY_SWITCH :: 3WSwitch_A_12
	Helios_Udp.Send("5013", string.format("%1d", MainPanel:get_argument_value(111) ) ) -- Reset/Test switch >> TREE_WAY_SWITCH :: 3WSwitch_A_13
	Helios_Udp.Send("5014", string.format("%1d", MainPanel:get_argument_value(112) ) ) -- Bright/Dim switch >> TREE_WAY_SWITCH :: 3WSwitch_A_14
	Helios_Udp.Send("5015", string.format("%1d", MainPanel:get_argument_value(86) ) ) -- Chip Detector Switch, LMB - Tail Rotor / RMB - XMSN >> TREE_WAY_SWITCH :: 3WSwitch_A_15
	Helios_Udp.Send("5016", string.format("%1d", MainPanel:get_argument_value(203) ) ) -- Governor RPM Switch, Decrease/Increase >> TREE_WAY_SWITCH :: 3WSwitch_A_16
	Helios_Udp.Send("5017", string.format("%1d", MainPanel:get_argument_value(216) ) ) -- Main generator Switch (Left button - ON/OFF. Right button RESET) >> TREE_WAY_SWITCH :: 3WSwitch_A_17
	Helios_Udp.Send("5018", string.format("%1d", MainPanel:get_argument_value(61) ) ) -- Test M-1 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_18
	Helios_Udp.Send("5019", string.format("%1d", MainPanel:get_argument_value(62) ) ) -- Test M-2 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_19
	Helios_Udp.Send("5020", string.format("%1d", MainPanel:get_argument_value(63) ) ) -- Test M-3A Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_20
	Helios_Udp.Send("5021", string.format("%1d", MainPanel:get_argument_value(64) ) ) -- Test M-C Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_21
	Helios_Udp.Send("5022", string.format("%1d", MainPanel:get_argument_value(65) ) ) -- RAD Switch, TEST/MON >> TREE_WAY_SWITCH :: 3WSwitch_A_22
	Helios_Udp.Send("5023", string.format("%1d", MainPanel:get_argument_value(66) ) ) -- Ident/Mic Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_23	
	Helios_Udp.Send("5025", string.format("%1d", MainPanel:get_argument_value(38) ) )-- Tune control / Band selection. Right mouse click to select a band >> TREE_WAY_SWITCH :: 3WSwitch_A_25 				

-- AXIS		
	--Helios_Udp.Send("6001", string.format("%.2f", MainPanel:get_argument_value(146) ) ) -- Attitude Indicator Pitch Trim Knob copilot>> AXIS :: Axis_A_1
	--Helios_Udp.Send("6002", string.format("%.2f", MainPanel:get_argument_value(145) ) ) -- Attitude Indicator Pitch Trim Knob >> AXIS :: Axis_A_2
	--Helios_Udp.Send("6003", string.format("%.2f", MainPanel:get_argument_value(144) ) ) -- Attitude Indicator Roll Trim Knob >> AXIS :: Axis_A_3
	--Helios_Udp.Send("6004", string.format("%.2f", MainPanel:get_argument_value(172) ) ) -- Pressure Adjustment Knob >> AXIS :: Axis_A_4
	--Helios_Udp.Send("6005", string.format("%.2f", MainPanel:get_argument_value(181) ) ) -- Pressure Adjustment Knob >> AXIS :: Axis_A_5
	Helios_Udp.Send("6006", string.format("%.2f", MainPanel:get_argument_value(21) ) ) -- UHF Volume Knob >> AXIS :: Axis_A_6
	--Helios_Udp.Send("6007", string.format("%.2f", MainPanel:get_argument_value(163) ) ) -- Heading Set Knob >> AXIS :: Axis_A_7
	Helios_Udp.Send("6101", string.format("%.2f", MainPanel:get_argument_value(161) ) ) -- Compass Synchronizing Knob >> AXIS :: Axis_B_101
	--Helios_Udp.Send("6008", string.format("%.2f", MainPanel:get_argument_value(155) ) ) -- Course Select Knob >> AXIS :: Axis_A_8
	--Helios_Udp.Send("6009", string.format("%.2f", MainPanel:get_argument_value(281) ) ) -- Sighting Station Intensity Knob >> AXIS :: Axis_A_9
	--Helios_Udp.Send("6010", string.format("%.2f", MainPanel:get_argument_value(440) ) ) -- Pilot Sighting Station Intensity Knob >> AXIS :: Axis_A_10
	--Helios_Udp.Send("6011", string.format("%.2f", MainPanel:get_argument_value(445) ) ) -- Low Altitude Setting Knob >> AXIS :: Axis_A_11
	Helios_Udp.Send("6012", string.format("%.2f", MainPanel:get_argument_value(29) ) ) -- Intercom Volume Knob >> AXIS :: Axis_A_12
	Helios_Udp.Send("6013", string.format("%.2f", MainPanel:get_argument_value(18) ) ) -- 10 MHz Selector >> AXIS :: Axis_A_13
	Helios_Udp.Send("6014", string.format("%.2f", MainPanel:get_argument_value(19) ) ) -- 1 MHz Selector >> AXIS :: Axis_A_14
	Helios_Udp.Send("6015", string.format("%.2f", MainPanel:get_argument_value(20) ) ) -- 50 kHz Selector >> AXIS :: Axis_A_15
	Helios_Udp.Send("6016", string.format("%.2f", MainPanel:get_argument_value(37) ) ) -- Volume Knob >> AXIS :: Axis_A_16
	Helios_Udp.Send("6017", string.format("%.2f", MainPanel:get_argument_value(57) ) ) -- Marker Beacon Knob, ON/OFF/Volume >> AXIS :: Axis_A_17
	Helios_Udp.Send("6018", string.format("%.2f", MainPanel:get_argument_value(230) ) ) -- Overhead Console Panel Lights Brightness Rheostat >> AXIS :: Axis_A_18
	Helios_Udp.Send("6019", string.format("%.2f", MainPanel:get_argument_value(231) ) ) -- Pedestal Lights Brightness Rheostat >> AXIS :: Axis_A_19
	Helios_Udp.Send("6020", string.format("%.2f", MainPanel:get_argument_value(232) ) ) -- Secondary Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_20
	Helios_Udp.Send("6021", string.format("%.2f", MainPanel:get_argument_value(233) ) ) -- Engine Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_21
	Helios_Udp.Send("6022", string.format("%.2f", MainPanel:get_argument_value(234) ) ) -- Copilot Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_22
	Helios_Udp.Send("6023", string.format("%.2f", MainPanel:get_argument_value(235) ) ) -- Pilot Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_23	
	Helios_Udp.Send("6024", string.format("%.2f", MainPanel:get_argument_value(44) ) ) -- Gain control / Mode. Rotate mouse wheel to adjust gain >> AXIS :: Axis_A_24
	Helios_Udp.Send("6025", string.format("%.2f", MainPanel:get_argument_value(452) ) ) -- Flare counter Reset. Rotate mouse wheel to set Number >> AXIS :: Axis_A_25
	Helios_Udp.Send("6026", string.format("%.2f", MainPanel:get_argument_value(454) ) ) -- Chaff counter Reset. Rotate mouse wheel to set Number >> AXIS :: Axis_A_26
	--Helios_Udp.Send("6027", string.format("%.2f", MainPanel:get_argument_value(448) ) ) -- Test / Hight Set. Rotate mouse wheel to set Hight >> AXIS :: Axis_A_27
	Helios_Udp.Send("6028", string.format("%.2f", MainPanel:get_argument_value(9) ) ) -- VHF_ARC_134 Volume >> AXIS :: Axis_A_28 
	Helios_Udp.Send("6029", string.format("%.2f", MainPanel:get_argument_value(53) ) ) -- NAV Frequency kHz / Volume VOLUME     -KHz>> AXIS :: Axis_A_29 
	Helios_Udp.Send("6102", string.format("%.2f", MainPanel:get_argument_value(132) ) ) -- Winding/Adjustment Clock lev >> AXIS :: Axis_B_102
	Helios_Udp.Send("6103", string.format("%.2f", MainPanel:get_argument_value(39) ) ) -- Tune control / Band selection. Rotate mouse wheel to adjust tune >> AXIS :: Axis_B_103
	Helios_Udp.Send("6104", string.format("%.2f", MainPanel:get_argument_value(16) ) ) -- Preset Channel Selector >> AXIS :: Axis_B_104
	Helios_Udp.Send("6030", string.format("%.2f", MainPanel:get_argument_value(8) ) ) -- VHF_ARC_134 Khz >> AXIS :: Axis_A_30
	Helios_Udp.Send("6031", string.format("%.2f", MainPanel:get_argument_value(7) ) ) -- VHF_ARC_134 Mhz >> AXIS :: Axis_A_31
	Helios_Udp.Send("6032", string.format("%.2f", MainPanel:get_argument_value(5) ) ) -- VHF_ARC_134 POWER >> AXIS :: Axis_A_32
	Helios_Udp.Send("6033", string.format("%.2f", MainPanel:get_argument_value(54) ) ) -- NAV Frequency kHz / Volume VOLUME   - VOLUME>> AXIS :: Axis_A_33 
	Helios_Udp.Send("6034", string.format("%.2f", MainPanel:get_argument_value(51) ) ) -- NAV CON  POWER >> AXIS :: Axis_A_34	
	Helios_Udp.Send("6035", string.format("%.2f", MainPanel:get_argument_value(52) ) ) -- NAV Frequency MHz / Volume VOLUME   - Mhz>> AXIS :: Axis_A_35
	Helios_Udp.Send("6036", string.format("%.2f", MainPanel:get_argument_value(250)+1 ) ) -- Throttle>> AXIS :: Axis_A_36

-- MULTIPOSITIONS	
	Helios_Udp.Send("7001", string.format("%0.1f", MainPanel:get_argument_value(218) ) ) -- DC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_1
	Helios_Udp.Send("7002", string.format("%0.1f", MainPanel:get_argument_value(214) ) ) -- AC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_2
	Helios_Udp.Send("7003", string.format("%0.1f", MainPanel:get_argument_value(59) ) ) -- Master Knob, OFF/STBY/LOW/NORM/EMER >> MULTI_POS_SWITCH :: Multi6PosSwitch_3
	--Helios_Udp.Send("7004", string.format("%0.1f", MainPanel:get_argument_value(68) ) ) -- MODE1-WHEEL1 >> MULTI_POS_SWITCH :: Multi6PosSwitch_4
	--Helios_Udp.Send("7051", string.format("%0.1f", MainPanel:get_argument_value(69) ) ) -- MODE1-WHEEL2 >> MULTI_POS_SWITCH :: Multi11PosSwitch_51
	--Helios_Udp.Send("7052", string.format("%0.1f", MainPanel:get_argument_value(70) ) ) -- MODE3A-WHEEL1 >> MULTI_POS_SWITCH :: Multi11PosSwitch_52
	--Helios_Udp.Send("7053", string.format("%0.1f", MainPanel:get_argument_value(71) ) ) -- MODE3A-WHEEL2 >> MULTI_POS_SWITCH :: Multi11PosSwitch_53
	--Helios_Udp.Send("7054", string.format("%0.1f", MainPanel:get_argument_value(72) ) ) -- MODE3A-WHEEL3 >> MULTI_POS_SWITCH :: Multi11PosSwitch_54
	--Helios_Udp.Send("7055", string.format("%0.1f", MainPanel:get_argument_value(73) ) ) -- MODE3A-WHEEL4 >> MULTI_POS_SWITCH :: Multi11PosSwitch_55
	Helios_Udp.Send("7005", string.format("%0.1f", MainPanel:get_argument_value(30) ) ) -- Intercom Mode (PVT,INT,VHF FM,UHF,VHF AM,Not used) >> MULTI_POS_SWITCH :: Multi6PosSwitch_5
	Helios_Udp.Send("5201", string.format("%0.1f", MainPanel:get_argument_value(194) ) ) -- Radio/ICS Switch >> TREE_WAY_SWITCH :: 3WSwitch_C_201
	Helios_Udp.Send("7006", string.format("%0.1f", MainPanel:get_argument_value(15) ) ) -- Frequency Mode Dial >> MULTI_POS_SWITCH :: Multi6PosSwitch_6
	Helios_Udp.Send("7007", string.format("%0.1f", MainPanel:get_argument_value(17) ) ) -- Function Dial >> MULTI_POS_SWITCH :: Multi6PosSwitch_7
	Helios_Udp.Send("7008", string.format("%0.1f", MainPanel:get_argument_value(222) ) ) -- Navigation Lights Switch, OFF/1/2/3/4/BRT >> MULTI_POS_SWITCH :: Multi6PosSwitch_8
	Helios_Udp.Send("7009", string.format("%0.1f", MainPanel:get_argument_value(236) ) ) -- Bleed Air Switch, OFF/1/2/3/4 >> MULTI_POS_SWITCH :: Multi6PosSwitch_9
	Helios_Udp.Send("7056", string.format("%0.1f", MainPanel:get_argument_value(257) ) ) -- Rocket Pair Selector Switch >> MULTI_POS_SWITCH :: Multi11PosSwitch_56
	Helios_Udp.Send("7059", string.format("%0.1f", MainPanel:get_argument_value(31) ) ) -- Frequency Tens MHz Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_59
	Helios_Udp.Send("7057", string.format("%0.1f", MainPanel:get_argument_value(32) ) ) -- Frequency Ones MHz Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_57
	Helios_Udp.Send("7058", string.format("%0.1f", MainPanel:get_argument_value(33) ) ) -- Frequency Decimals MHz Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_58
	Helios_Udp.Send("7011", string.format("%0.1f", MainPanel:get_argument_value(34) ) ) -- Frequency Hundredths MHz Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_11
	Helios_Udp.Send("7012", string.format("%0.1f", MainPanel:get_argument_value(35) ) ) -- Mode Switch, OFF/TR/RETRAN(N/F)/HOME(N/F) >> MULTI_POS_SWITCH :: Multi6PosSwitch_12
	Helios_Udp.Send("7013", string.format("%0.1f", MainPanel:get_argument_value(36) ) ) -- Squelch Mode Switch, DIS/CARR/TONE >> MULTI_POS_SWITCH :: Multi6PosSwitch_13
	Helios_Udp.Send("7014", string.format("%0.1f", MainPanel:get_argument_value(229) ) ) -- Wipers Speed Switch, PARK/OFF/LOW/MED/HIGH >> MULTI_POS_SWITCH :: Multi6PosSwitch_14 
	Helios_Udp.Send("7015", string.format("%0.1f", MainPanel:get_argument_value(43) ) ) -- Gain control / Mode. Right mouse click to cycle mode >> MULTI_POS_SWITCH :: Multi6PosSwitch_15 
	Helios_Udp.Send("7016", string.format("%0.1f", MainPanel:get_argument_value(42) ) ) --ADF Loop Antenna speed 42 5 pos 0.1	 >> MULTI_POS_SWITCH :: Multi6PosSwitch_16 
	Helios_Udp.Send("7017", string.format("%0.1f", MainPanel:get_argument_value(58) ) ) -- Code Knob, ZERO/B/A/HOLD >> MULTI_POS_SWITCH :: Multi6PosSwitch_17

	Helios_Udp.Flush()
end

-- Format: device,button number, multiplier
-- arguments with multiplier >100 are special conversion cases, and are computed in different way

--                      Extended       	UH1H

-- buttons
Helios_Huey.ExportArguments["1,3001"] ="2,3002,1" -- Test Fuel Gauge Button - Push to Test >> PUSH_BUTTONS :: PB_1
Helios_Huey.ExportArguments["1,3002"] ="30,3001,1" -- Winding/Adjustment Clock btn >> PUSH_BUTTONS :: PB_2
Helios_Huey.ExportArguments["1,3003"] ="3,3023,1" -- Fire Detector Test Button - Push to test >> PUSH_BUTTONS :: PB_3
Helios_Huey.ExportArguments["1,3004"] ="6,3001,1" -- Cage Copilot Attitude Indicator - Pull to cage >> PUSH_BUTTONS :: PB_4
Helios_Huey.ExportArguments["1,3005"] ="20,3002,1" -- Comm Test Button - Push to test >> PUSH_BUTTONS :: PB_5
Helios_Huey.ExportArguments["1,3006"] ="9,3012,1" -- Rocket Reset Button - Push to reset >> PUSH_BUTTONS :: PB_6
Helios_Huey.ExportArguments["1,3007"] ="9,3014,1" -- Jettison Switch >> PUSH_BUTTONS :: PB_7
Helios_Huey.ExportArguments["1,3008"] ="42,3001,1" -- Force Trim Button >> PUSH_BUTTONS :: PB_8
Helios_Huey.ExportArguments["1,3009"] ="42,3002,1" -- Force Trim Button >> PUSH_BUTTONS :: PB_9
Helios_Huey.ExportArguments["1,3010"] ="52,3001,1" -- Cargo Release Pilot >> PUSH_BUTTONS :: PB_10
Helios_Huey.ExportArguments["1,3011"] ="52,3002,1" -- Cargo Release CoPilot >> PUSH_BUTTONS :: PB_11
Helios_Huey.ExportArguments["1,3012"] ="50,3006,1" -- Flare Dispense Button - Push to dispense >> PUSH_BUTTONS :: PB_12
Helios_Huey.ExportArguments["1,3013"] ="50,3010,1" -- Armed Lamp Test Button - Push to test >> PUSH_BUTTONS :: PB_13
Helios_Huey.ExportArguments["1,3014"] ="50,3003,1" -- Flare counter Reset. press reset >> PUSH_BUTTONS :: PB_14
Helios_Huey.ExportArguments["1,3015"] ="50,3007,1" -- Chaff counter Reset. press reset >> PUSH_BUTTONS :: PB_15
Helios_Huey.ExportArguments["1,3016"] ="13,3001,1" -- Test / Hight Set. Left mouse click to Test >> PUSH_BUTTONS :: PB_16
Helios_Huey.ExportArguments["1,3017"] ="12,3005,1" -- Open Doors >> PUSH_BUTTONS :: PB_17
Helios_Huey.ExportArguments["1,3018"] ="12,3006,1" -- Open Doors >> PUSH_BUTTONS :: PB_18
Helios_Huey.ExportArguments["1,3019"] ="27,3005,1" -- Loop Left Low Speed >> PUSH_BUTTONS :: PB_19
Helios_Huey.ExportArguments["1,3020"] ="27,3005,1" -- Loop Right Low Speed >> PUSH_BUTTONS :: PB_20
Helios_Huey.ExportArguments["1,3021"] ="17,3017,1" -- Reply Button >> PUSH_BUTTONS :: PB_21
Helios_Huey.ExportArguments["1,3022"] ="17,3018,1" -- Test Button >> PUSH_BUTTONS :: PB_22
Helios_Huey.ExportArguments["1,3023"] ="0,511,108" -- Search light left >> PUSH_BUTTONS :: PB_23
Helios_Huey.ExportArguments["1,3024"] ="0,512,108" -- Search light right >> PUSH_BUTTONS :: PB_24
Helios_Huey.ExportArguments["1,3025"] ="0,513,108" -- Search light up >> PUSH_BUTTONS :: PB_25
Helios_Huey.ExportArguments["1,3026"] ="0,514,108" -- Search light down >> PUSH_BUTTONS :: PB_26
Helios_Huey.ExportArguments["1,3027"] ="0,515,108" -- Search light stop >> PUSH_BUTTONS :: PB_27
--toggle_switches:
Helios_Huey.ExportArguments["2,3001"] ="1,3001,1" -- Battery Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_1
Helios_Huey.ExportArguments["2,3002"] ="1,3003,1" -- Starter/Stdby GEN Switch >> TOGLEE_SWITCH :: TSwitch_2
Helios_Huey.ExportArguments["2,3003"] ="1,3005,1" -- Non-Essential Bus Switch, NORMAL/MANUAL >> TOGLEE_SWITCH :: TSwitch_3
Helios_Huey.ExportArguments["2,3004"] ="1,3021,1" -- CB IFF APX 1 (N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_4
Helios_Huey.ExportArguments["2,3005"] ="1,3022,1" -- CB IFF APX 2 (N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_5
Helios_Huey.ExportArguments["2,3006"] ="1,3023,1" -- CB Prox. warn.(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_6
Helios_Huey.ExportArguments["2,3007"] ="1,3024,1" -- CB Marker beacon, ON/OFF >> TOGLEE_SWITCH :: TSwitch_7
Helios_Huey.ExportArguments["2,3008"] ="1,3025,1" -- CB VHF Nav. (ARN-82), ON/OFF >> TOGLEE_SWITCH :: TSwitch_8
Helios_Huey.ExportArguments["2,3009"] ="1,3026,1" -- CB LF Nav. (ARN-83), ON/OFF >> TOGLEE_SWITCH :: TSwitch_9
Helios_Huey.ExportArguments["2,3010"] ="1,3027,1" -- CB Intercom CPLT(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_10
Helios_Huey.ExportArguments["2,3011"] ="1,3028,1" -- CB Intercom PLT, ON/OFF >> TOGLEE_SWITCH :: TSwitch_11
Helios_Huey.ExportArguments["2,3012"] ="1,3029,1" -- CB ARC-102 HF Static INVTR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_12
Helios_Huey.ExportArguments["2,3013"] ="1,3030,1" -- CB HF ANT COUPLR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_13
Helios_Huey.ExportArguments["2,3014"] ="1,3031,1" -- CB HF ARC-102(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_14
Helios_Huey.ExportArguments["2,3015"] ="1,3032,1" -- CB FM Radio, ON/OFF >> TOGLEE_SWITCH :: TSwitch_15
Helios_Huey.ExportArguments["2,3016"] ="1,3033,1" -- CB UHF Radio, ON/OFF >> TOGLEE_SWITCH :: TSwitch_16
Helios_Huey.ExportArguments["2,3017"] ="1,3034,1" -- CB FM 2 Radio(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_17
Helios_Huey.ExportArguments["2,3018"] ="1,3035,1" -- CB VHF AM Radio, ON/OFF >> TOGLEE_SWITCH :: TSwitch_18
Helios_Huey.ExportArguments["2,3019"] ="1,3037,1" -- CB Pitot tube(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_19
Helios_Huey.ExportArguments["2,3020"] ="1,3039,1" -- CB Rescue hoist CTL(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_20
Helios_Huey.ExportArguments["2,3021"] ="1,3040,1" -- CB Rescue hoist cable cutter N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_21
Helios_Huey.ExportArguments["2,3022"] ="1,3041,1" -- CB Wind wiper CPLT, ON/OFF >> TOGLEE_SWITCH :: TSwitch_22
Helios_Huey.ExportArguments["2,3023"] ="1,3042,1" -- CB Wind wiper PLT, ON/OFF >> TOGLEE_SWITCH :: TSwitch_23
Helios_Huey.ExportArguments["2,3024"] ="1,3043,1" -- CB KY-28 voice security(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_24
Helios_Huey.ExportArguments["2,3025"] ="1,3044,1" -- CB Starter Relay(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_25
Helios_Huey.ExportArguments["2,3026"] ="1,3045,1" -- CB Search light power(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_26
Helios_Huey.ExportArguments["2,3027"] ="1,3046,1" -- CB Landing light power(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_27
Helios_Huey.ExportArguments["2,3028"] ="1,3047,1" -- CB Landing & Search light control(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_28
Helios_Huey.ExportArguments["2,3029"] ="1,3048,1" -- CB Anticollision light(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_29
Helios_Huey.ExportArguments["2,3030"] ="1,3049,1" -- CB Fuselage lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_30
Helios_Huey.ExportArguments["2,3031"] ="1,3050,1" -- CB Navigation lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_31
Helios_Huey.ExportArguments["2,3032"] ="1,3051,1" -- CB Dome lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_32
Helios_Huey.ExportArguments["2,3033"] ="1,3052,1" -- CB Cockpit lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_33
Helios_Huey.ExportArguments["2,3034"] ="1,3053,1" -- CB Caution lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_34
Helios_Huey.ExportArguments["2,3035"] ="1,3054,1" -- CB Console lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_35
Helios_Huey.ExportArguments["2,3036"] ="1,3055,1" -- CB INST Panel lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_36
Helios_Huey.ExportArguments["2,3037"] ="1,3056,1" -- CB INST SEC lights(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_37
Helios_Huey.ExportArguments["2,3038"] ="1,3057,1" -- CB Cabin heater (Outlet valve)(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_38
Helios_Huey.ExportArguments["2,3039"] ="1,3058,1" -- CB Cabin heater (Air valve)(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_39
Helios_Huey.ExportArguments["2,3040"] ="1,3059,1" -- CB Rescue hoist PWR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_40
Helios_Huey.ExportArguments["2,3041"] ="1,3060,1" -- CB RPM Warning system(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_41
Helios_Huey.ExportArguments["2,3042"] ="1,3061,1" -- CB Engine anti-ice(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_42
Helios_Huey.ExportArguments["2,3043"] ="1,3062,1" -- CB Fire detector(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_43
Helios_Huey.ExportArguments["2,3044"] ="1,3063,1" -- CB LH fuel boost pump(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_44
Helios_Huey.ExportArguments["2,3045"] ="1,3064,1" -- CB Turn & Slip indicator, ON/OFF >> TOGLEE_SWITCH :: TSwitch_45
Helios_Huey.ExportArguments["2,3046"] ="1,3065,1" -- CB TEMP indicator(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_46
Helios_Huey.ExportArguments["2,3047"] ="1,3066,1" -- CB HYD Control(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_47
Helios_Huey.ExportArguments["2,3048"] ="1,3068,1" -- CB FORCE Trim(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_48
Helios_Huey.ExportArguments["2,3049"] ="1,3069,1" -- CB Cargo hook release(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_49
Helios_Huey.ExportArguments["2,3050"] ="1,3070,1" -- CB EXT Stores jettison(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_50
Helios_Huey.ExportArguments["2,3051"] ="1,3071,1" -- CB Spare inverter PWR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_51
Helios_Huey.ExportArguments["2,3052"] ="1,3072,1" -- CB Inverter CTRL (N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_52
Helios_Huey.ExportArguments["2,3053"] ="1,3073,1" -- CB Main inverter PWR(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_53
Helios_Huey.ExportArguments["2,3054"] ="1,3074,1" -- CB Generator & Bus Reset(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_54
Helios_Huey.ExportArguments["2,3055"] ="1,3075,1" -- CB STBY Generator Field(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_55
Helios_Huey.ExportArguments["2,3056"] ="1,3076,1" -- CB Governor Control(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_56
Helios_Huey.ExportArguments["2,3057"] ="1,3077,1" -- CB IDLE Stop release(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_57
Helios_Huey.ExportArguments["2,3058"] ="1,3078,1" -- CB RH fuel boost pump(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_58
Helios_Huey.ExportArguments["2,3059"] ="1,3079,1" -- CB Fuel TRANS(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_59
Helios_Huey.ExportArguments["2,3060"] ="1,3080,1" -- CB Fuel valves(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_60
Helios_Huey.ExportArguments["2,3061"] ="1,3081,1" -- CB Heated blanket 1(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_61
Helios_Huey.ExportArguments["2,3062"] ="1,3082,1" -- CB Heated blanket 2(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_62
Helios_Huey.ExportArguments["2,3063"] ="1,3083,1" -- CB Voltmeter Non Ess Bus(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_63
Helios_Huey.ExportArguments["2,3064"] ="1,3085,1" -- CB Ignition system(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_64
Helios_Huey.ExportArguments["2,3065"] ="1,3086,1" -- CB Pilot ATTD1(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_65
Helios_Huey.ExportArguments["2,3066"] ="1,3087,1" -- CB Pilot ATTD2(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_66
Helios_Huey.ExportArguments["2,3067"] ="1,3088,1" -- CB Copilot ATTD1(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_67
Helios_Huey.ExportArguments["2,3068"] ="1,3089,1" -- CB Copilot ATTD2(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_68
Helios_Huey.ExportArguments["2,3069"] ="1,3090,1" -- CB Gyro Cmps(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_69
Helios_Huey.ExportArguments["2,3070"] ="1,3091,1" -- CB Fuel Quantity(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_70
Helios_Huey.ExportArguments["2,3071"] ="1,3092,1" -- CB 28V Trans(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_71
Helios_Huey.ExportArguments["2,3072"] ="1,3093,1" -- CB Fail Relay(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_72
Helios_Huey.ExportArguments["2,3073"] ="1,3094,1" -- CB Pressure Fuel(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_73
Helios_Huey.ExportArguments["2,3074"] ="1,3095,1" -- CB Pressure Torque(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_74
Helios_Huey.ExportArguments["2,3075"] ="1,3096,1" -- CB Pressure XMSN(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_75
Helios_Huey.ExportArguments["2,3076"] ="1,3097,1" -- CB Pressure Eng(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_76
Helios_Huey.ExportArguments["2,3077"] ="1,3098,1" -- CB Course Ind(N/F), ON/OFF >> TOGLEE_SWITCH :: TSwitch_77
Helios_Huey.ExportArguments["2,3078"] ="1,3016,1" -- Pitot Heater Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_78
Helios_Huey.ExportArguments["2,3079"] ="1,3019,1" -- Main generator switch cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_79
Helios_Huey.ExportArguments["2,3080"] ="2,3001,1" -- Main Fuel Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_80
Helios_Huey.ExportArguments["2,3081"] ="17,3016,1" -- IFF On/Out Switch >> TOGLEE_SWITCH :: TSwitch_81
Helios_Huey.ExportArguments["2,3082"] ="3,3027,1" -- Throttle Stop Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_82
Helios_Huey.ExportArguments["2,3083"] ="3,3002,1" -- De-Ice Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_83
Helios_Huey.ExportArguments["2,3084"] ="3,3021,1" -- Low RPM Warning Switch, AUDIO/OFF >> TOGLEE_SWITCH :: TSwitch_84
Helios_Huey.ExportArguments["2,3085"] ="3,3014,1" -- Governor Switch, EMER/AUTO >> TOGLEE_SWITCH :: TSwitch_85
Helios_Huey.ExportArguments["2,3086"] ="4,3003,1" -- Hydraulic Control Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_86
Helios_Huey.ExportArguments["2,3087"] ="4,3004,1" -- Force Trim Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_87
Helios_Huey.ExportArguments["2,3088"] ="21,3001,1" -- VHF FM Radio Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_88
Helios_Huey.ExportArguments["2,3089"] ="21,3002,1" -- UHF Radio Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_89
Helios_Huey.ExportArguments["2,3090"] ="21,3003,1" -- VHF AM Radio Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_90
Helios_Huey.ExportArguments["2,3091"] ="21,3004,1" -- Receiver 4 N/F Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_91
Helios_Huey.ExportArguments["2,3092"] ="21,3005,1" -- INT Receiver Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_92
Helios_Huey.ExportArguments["2,3093"] ="21,3006,1" -- Receiver NAV Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_93
Helios_Huey.ExportArguments["2,3094"] ="22,3007,1" -- Squelch Disable Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_94
Helios_Huey.ExportArguments["2,3095"] ="26,3002,1" -- Marker Beacon Sensing Switch, HIGH/LOW >> TOGLEE_SWITCH :: TSwitch_95
Helios_Huey.ExportArguments["2,3096"] ="27,3006,1" -- BFO Switch (N/F), BFO/OFF >> TOGLEE_SWITCH :: TSwitch_96
--Helios_Huey.ExportArguments["2,3097"] ="27,3001,1" -- Gain control / Mode. Right mouse click to cycle mode >> TOGLEE_SWITCH :: TSwitch_97
Helios_Huey.ExportArguments["2,3099"] ="7,3003,1" -- Position Lights Switch, DIM/BRIGHT >> TOGLEE_SWITCH :: TSwitch_99
Helios_Huey.ExportArguments["2,3100"] ="7,3004,1" -- Anti-Collision Lights Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_100
Helios_Huey.ExportArguments["2,3101"] ="7,3005,1" -- Landing Light Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_101
Helios_Huey.ExportArguments["2,3102"] ="10,3004,1" -- ADF/VOR Control Switch >> TOGLEE_SWITCH :: TSwitch_102
Helios_Huey.ExportArguments["2,3103"] ="10,3002,1" -- Gyro Mode Switch, DG/Slave >> TOGLEE_SWITCH :: TSwitch_103
Helios_Huey.ExportArguments["2,3104"] ="49,3005,1" -- Pilot Sight, Armed/Safe >> TOGLEE_SWITCH :: TSwitch_104
Helios_Huey.ExportArguments["2,3105"] ="49,3006,1" -- Pilot Sight Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_105
Helios_Huey.ExportArguments["2,3106"] ="52,3003,1" -- Cargo Safety >> TOGLEE_SWITCH :: TSwitch_106
Helios_Huey.ExportArguments["2,3107"] ="50,3001,1" -- Ripple Fire Cover, OPEN/CLOSE >> TOGLEE_SWITCH :: TSwitch_107
Helios_Huey.ExportArguments["2,3108"] ="50,3002,1" -- Ripple Fire Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_108
Helios_Huey.ExportArguments["2,3109"] ="50,3005,1" -- ARM Switch, SAFE/ARM >> TOGLEE_SWITCH :: TSwitch_109
Helios_Huey.ExportArguments["2,3110"] ="50,3009,1" -- Chaff Mode Switch, MAN/PGRM >> TOGLEE_SWITCH :: TSwitch_110
Helios_Huey.ExportArguments["2,3111"] ="13,3007,1" -- Radar Altimeter Power Switch, ON/OFF >> TOGLEE_SWITCH :: TSwitch_111
-- tree way switches
Helios_Huey.ExportArguments["3,3001"] ="1,3008,1" -- Inverter Switch, MAIN/OFF/SPARE >> TREE_WAY_SWITCH :: 3WSwitch_A_1
Helios_Huey.ExportArguments["3,3002"] ="17,3009,1" -- Audio/light Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_2
Helios_Huey.ExportArguments["3,3003"] ="7,3002,1" -- Position Lights Switch, STEADY/OFF/FLASH >> TREE_WAY_SWITCH :: 3WSwitch_A_3
Helios_Huey.ExportArguments["3,3004"] ="7,3006,1" -- Search Light Switch, ON/OFF/STOW >> TREE_WAY_SWITCH :: 3WSwitch_A_4
Helios_Huey.ExportArguments["3,3005"] ="7,3007,1" -- Landing Light Control Switch, EXT/OFF/RETR >> TREE_WAY_SWITCH :: 3WSwitch_A_5
Helios_Huey.ExportArguments["3,3006"] ="7,3021,1" -- Dome Light Switch, WHITE/OFF/GREEN >> TREE_WAY_SWITCH :: 3WSwitch_A_6
Helios_Huey.ExportArguments["3,3007"] ="9,3008,1" -- Armament Switch, ARMED/SAFE/OFF >> TREE_WAY_SWITCH :: 3WSwitch_A_7
Helios_Huey.ExportArguments["3,3008"] ="9,3009,1" -- Gun Selector Switch, LEFT/ALL/RIGHT >> TREE_WAY_SWITCH :: 3WSwitch_A_8
Helios_Huey.ExportArguments["3,3009"] ="9,3010,1" -- Armament Selector Switch, 7.62/2.75/40 >> TREE_WAY_SWITCH :: 3WSwitch_A_9
Helios_Huey.ExportArguments["3,3010"] ="9,3013,1" -- Jettison Switch Cover, OPEN/CLOSE >> TREE_WAY_SWITCH :: 3WSwitch_A_10
Helios_Huey.ExportArguments["3,3011"] ="32,3003,1" -- Sighting Station Lamp Switch, BACKUP/OFF/MAIN >> TREE_WAY_SWITCH :: 3WSwitch_A_11
Helios_Huey.ExportArguments["3,3012"] ="12,3002,1" -- Wiper Selector Switch, PILOT/BOTH/COPILOT >> TREE_WAY_SWITCH :: 3WSwitch_A_12
Helios_Huey.ExportArguments["3,3013"] ="15,3001,1" -- Reset/Test switch >> TREE_WAY_SWITCH :: 3WSwitch_A_13
Helios_Huey.ExportArguments["3,3014"] ="15,3002,1" -- Bright/Dim switch >> TREE_WAY_SWITCH :: 3WSwitch_A_14
Helios_Huey.ExportArguments["3,3015"] ="3,3013,1" -- Chip Detector Switch, LMB - Tail Rotor / RMB - XMSN >> TREE_WAY_SWITCH :: 3WSwitch_A_15
Helios_Huey.ExportArguments["3,3016"] ="3,3015,1" -- Governor RPM Switch, Decrease/Increase >> TREE_WAY_SWITCH :: 3WSwitch_A_16
Helios_Huey.ExportArguments["3,3017"] ="1,3002,1" -- Main generator Switch (Left button - ON/OFF. Right button RESET) >> TREE_WAY_SWITCH :: 3WSwitch_A_17
Helios_Huey.ExportArguments["3,3018"] ="17,3010,1" -- Test M-1 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_18
Helios_Huey.ExportArguments["3,3019"] ="17,3011,1" -- Test M-2 Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_19
Helios_Huey.ExportArguments["3,3020"] ="17,3012,1" -- Test M-3A Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_20
Helios_Huey.ExportArguments["3,3021"] ="17,3013,1" -- Test M-C Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_21
Helios_Huey.ExportArguments["3,3022"] ="17,3014,1" -- RAD Switch, TEST/MON >> TREE_WAY_SWITCH :: 3WSwitch_A_22
Helios_Huey.ExportArguments["3,3023"] ="17,3015,1" -- Ident/Mic Switch >> TREE_WAY_SWITCH :: 3WSwitch_A_23
Helios_Huey.ExportArguments["3,3024"] ="12,3001,1" -- Wipers Speed Switch, PARK/OFF/LOW/MED/HIGH  >> TREE_WAY_SWITCH :: 3WSwitch_A_24
Helios_Huey.ExportArguments["3,3025"] ="27,3002,1" -- Tune control / Band selection. Right mouse click to select a band >> TREE_WAY_SWITCH :: 3WSwitch_A_25 
Helios_Huey.ExportArguments["3,3201"] ="21,3009,1" -- Radio/ICS Switch >> TREE_WAY_SWITCH :: 3WSwitch_C_201
-- axis:
Helios_Huey.ExportArguments["4,3001"] ="6,3002,1" -- Attitude Indicator Pitch Trim Knob copilot>> AXIS :: Axis_A_1
Helios_Huey.ExportArguments["4,3002"] ="5,3001,1" -- Attitude Indicator Pitch Trim Knob >> AXIS :: Axis_A_2
Helios_Huey.ExportArguments["4,3003"] ="5,3002,1" -- Attitude Indicator Roll Trim Knob >> AXIS :: Axis_A_3
Helios_Huey.ExportArguments["4,3004"] ="19,3001,1" -- Pressure Adjustment Knob >> AXIS :: Axis_A_4
Helios_Huey.ExportArguments["4,3005"] ="18,3001,1" -- Pressure Adjustment Knob >> AXIS :: Axis_A_5
Helios_Huey.ExportArguments["4,3006"] ="22,3008,1" -- UHF Volume Knob >> AXIS :: Axis_A_6
Helios_Huey.ExportArguments["4,3007"] ="10,3003,1" -- Heading Set Knob >> AXIS :: Axis_A_7
Helios_Huey.ExportArguments["4,3008"] ="29,3001,1" -- Course Select Knob >> AXIS :: Axis_A_8
Helios_Huey.ExportArguments["4,3009"] ="32,3001,1" -- Sighting Station Intensity Knob >> AXIS :: Axis_A_9
Helios_Huey.ExportArguments["4,3010"] ="49,3001,1" -- Pilot Sighting Station Intensity Knob >> AXIS :: Axis_A_10
Helios_Huey.ExportArguments["4,3011"] ="13,3002,1" -- Low Altitude Setting Knob >> AXIS :: Axis_A_11
Helios_Huey.ExportArguments["4,3012"] ="21,3007,1" -- Intercom Volume Knob >> AXIS :: Axis_A_12
--Helios_Huey.ExportArguments["4,3013"] ="22,3002,1" -- 10 MHz Selector >> AXIS :: Axis_A_13
--Helios_Huey.ExportArguments["4,3014"] ="22,3003,1" -- 1 MHz Selector >> AXIS :: Axis_A_14
--Helios_Huey.ExportArguments["4,3015"] ="22,3004,1" -- 50 kHz Selector >> AXIS :: Axis_A_15
Helios_Huey.ExportArguments["4,3016"] ="23,3006,1" -- Volume Knob VHF COM >> AXIS :: Axis_A_16
Helios_Huey.ExportArguments["4,3017"] ="26,3001,1" -- Marker Beacon Knob, ON/OFF/Volume >> AXIS :: Axis_A_17
Helios_Huey.ExportArguments["4,3018"] ="7,3015,1" -- Overhead Console Panel Lights Brightness Rheostat >> AXIS :: Axis_A_18
Helios_Huey.ExportArguments["4,3019"] ="7,3016,1" -- Pedestal Lights Brightness Rheostat >> AXIS :: Axis_A_19
Helios_Huey.ExportArguments["4,3020"] ="7,3017,1" -- Secondary Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_20
Helios_Huey.ExportArguments["4,3021"] ="7,3018,1" -- Engine Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_21
Helios_Huey.ExportArguments["4,3022"] ="7,3019,1" -- Copilot Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_22
Helios_Huey.ExportArguments["4,3023"] ="7,3020,1" -- Pilot Instrument Lights Brightness Rheostat >> AXIS :: Axis_A_23
Helios_Huey.ExportArguments["4,3024"] ="27,3004,1" -- Gain control / Mode. Rotate mouse wheel to adjust gain >> AXIS :: Axis_A_24
--Helios_Huey.ExportArguments["4,3025"] ="50,3004,1" -- Flare counter Reset. Rotate mouse wheel to set Number >> AXIS :: Axis_A_25
--Helios_Huey.ExportArguments["4,3026"] ="50,3008,1" -- Chaff counter Reset. Rotate mouse wheel to set Number >> AXIS :: Axis_A_26
Helios_Huey.ExportArguments["4,3027"] ="13,3003,1" -- Test / Hight Set. Rotate mouse wheel to set Hight >> AXIS :: Axis_A_27
Helios_Huey.ExportArguments["4,3028"] ="20,3003,1" -- VHF_ARC_134 Volume >> AXIS :: Axis_A_28 
Helios_Huey.ExportArguments["4,3029"] ="25,3002,1" -- Frequency kHz / Volume VOLUME    --NAV CON Khz>> AXIS :: Axis_A_29   
Helios_Huey.ExportArguments["4,3101"] ="10,3005,1" -- Compass Synchronizing Knob >> AXIS :: Axis_B_101
Helios_Huey.ExportArguments["4,3102"] ="30,3002,1" -- Winding/Adjustment Clock lev >> AXIS :: Axis_B_102
Helios_Huey.ExportArguments["4,3103"] ="27,3003,1" -- Tune control / Band selection. Rotate mouse wheel to adjust tune >> AXIS :: Axis_B_103
Helios_Huey.ExportArguments["4,3104"] ="22,3001,1" -- Preset Channel Selector >> AXIS :: Axis_B_104
Helios_Huey.ExportArguments["4,3032"] ="20,3001,1" -- VHF_ARC_134 POWER >> AXIS :: Axis_A_32
Helios_Huey.ExportArguments["4,3033"] ="25,3004,1" -- NAV Frequency kHz / Volume VOLUME   - NAV CON VOLUME>> AXIS :: Axis_A_33 
Helios_Huey.ExportArguments["4,3034"] ="25,3003,1" -- NAV CON  POWER >> AXIS :: Axis_A_34	
Helios_Huey.ExportArguments["4,3036"] ="3,3024,107" -- THROTLE >> AXIS :: Axis_A_36
-- multiposition:
Helios_Huey.ExportArguments["5,3001"] ="1,3004,1" -- DC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_1
Helios_Huey.ExportArguments["5,3002"] ="1,3007,1" -- AC Voltmeter Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_2
Helios_Huey.ExportArguments["5,3003"] ="17,3008,1" -- Master Knob, OFF/STBY/LOW/NORM/EMER >> MULTI_POS_SWITCH :: Multi6PosSwitch_3
Helios_Huey.ExportArguments["5,3004"] ="17,3001,3.3" -- MODE1-WHEEL1 >> MULTI_POS_SWITCH :: Multi6PosSwitch_4
Helios_Huey.ExportArguments["5,3005"] ="21,3008,1" -- Intercom Mode (PVT,INT,VHF FM,UHF,VHF AM,Not used) >> MULTI_POS_SWITCH :: Multi6PosSwitch_5
Helios_Huey.ExportArguments["5,3006"] ="22,3005,1" -- Frequency Mode Dial >> MULTI_POS_SWITCH :: Multi6PosSwitch_6
Helios_Huey.ExportArguments["5,3007"] ="22,3006,1" -- Function Dial >> MULTI_POS_SWITCH :: Multi6PosSwitch_7
Helios_Huey.ExportArguments["5,3008"] ="7,3001,1" -- Navigation Lights Switch, OFF/1/2/3/4/BRT >> MULTI_POS_SWITCH :: Multi6PosSwitch_8
Helios_Huey.ExportArguments["5,3009"] ="47,3001,1" -- Bleed Air Switch, OFF/1/2/3/4 >> MULTI_POS_SWITCH :: Multi6PosSwitch_9
--Helios_Huey.ExportArguments["5,3010"] ="23,3001,1" -- Frequency Tens MHz Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_10
Helios_Huey.ExportArguments["5,3011"] ="23,3004,1" -- Frequency Hundredths MHz Selector >> MULTI_POS_SWITCH :: Multi6PosSwitch_11
Helios_Huey.ExportArguments["5,3012"] ="23,3007,1" -- Mode Switch, OFF/TR/RETRAN(N/F)/HOME(N/F) >> MULTI_POS_SWITCH :: Multi6PosSwitch_12
Helios_Huey.ExportArguments["5,3013"] ="23,3005,1" -- Squelch Mode Switch, DIS/CARR/TONE >> MULTI_POS_SWITCH :: Multi6PosSwitch_13
Helios_Huey.ExportArguments["5,3014"] ="12,3001,1" -- Wipers Speed Switch, PARK/OFF/LOW/MED/HIGH >> MULTI_POS_SWITCH :: Multi6PosSwitch_14 
Helios_Huey.ExportArguments["5,3015"] ="27,3001,1" -- Gain control / Mode. Right mouse click to cycle mode >> MULTI_POS_SWITCH :: Multi6PosSwitch_15
Helios_Huey.ExportArguments["5,3016"] ="27,3005,1" -- ADF loop >> MULTI_POS_SWITCH :: Multi6PosSwitch_16
Helios_Huey.ExportArguments["5,3017"] ="17,3007,1" -- Code Knob, ZERO/B/A/HOLD >> MULTI_POS_SWITCH :: Multi6PosSwitch_17
Helios_Huey.ExportArguments["5,3051"] ="17,3002,1.1" -- MODE1-WHEEL2 >> MULTI_POS_SWITCH :: Multi11PosSwitch_51
Helios_Huey.ExportArguments["5,3052"] ="17,3003,1.1" -- MODE3A-WHEEL1 >> MULTI_POS_SWITCH :: Multi11PosSwitch_52
Helios_Huey.ExportArguments["5,3053"] ="17,3004,1.1" -- MODE3A-WHEEL2 >> MULTI_POS_SWITCH :: Multi11PosSwitch_53
Helios_Huey.ExportArguments["5,3054"] ="17,3005,1.1" -- MODE3A-WHEEL3 >> MULTI_POS_SWITCH :: Multi11PosSwitch_54
Helios_Huey.ExportArguments["5,3055"] ="17,3006,1.1" -- MODE3A-WHEEL4 >> MULTI_POS_SWITCH :: Multi11PosSwitch_55
Helios_Huey.ExportArguments["5,3056"] ="9,3011,1" -- Rocket Pair Selector Switch >> MULTI_POS_SWITCH :: Multi11PosSwitch_56
Helios_Huey.ExportArguments["5,3057"] ="23,3002,1" -- Frequency Ones MHz Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_57
Helios_Huey.ExportArguments["5,3058"] ="23,3003,1" -- Frequency Decimals MHz Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_58
Helios_Huey.ExportArguments["5,3059"] ="23,3001,1" -- Frequency Tens MHz Selector >> MULTI_POS_SWITCH :: Multi11PosSwitch_59
-- rockers
Helios_Huey.ExportArguments["10,3001"] ="27,3003,-0.01" -- Tune control / Band selection. Rotate mouse wheel to adjust tune >> Rocker_C_101
Helios_Huey.ExportArguments["10,3002"] ="27,3003,0.01" -- Tune control / Band selection. Rotate mouse wheel to adjust tune >>  Rocker_C_101
Helios_Huey.ExportArguments["10,3003"] ="20,3005,-0.01" -- VHF_ARC_134 Khz >> Rocker_C_102
Helios_Huey.ExportArguments["10,3004"] ="20,3005,0.01" -- VHF_ARC_134 Khz >>  Rocker_C_102
Helios_Huey.ExportArguments["10,3005"] ="20,3004,-0.01" -- VHF_ARC_134 Mhz >> Rocker_C_103
Helios_Huey.ExportArguments["10,3006"] ="20,3004,0.01" -- VHF_ARC_134 Mhz >>  Rocker_C_103
Helios_Huey.ExportArguments["10,3007"] ="25,3002,-0.01" -- NAV CON Khz >> Rocker_C_104
Helios_Huey.ExportArguments["10,3008"] ="25,3002,0.01" -- NAV CON Khz >>  Rocker_C_104
Helios_Huey.ExportArguments["10,3009"] ="25,3001,-0.01" -- NAV CON Mhz >> Rocker_C_105
Helios_Huey.ExportArguments["10,3010"] ="25,3001,0.01" -- NAV CON Mhz >>  Rocker_C_105
Helios_Huey.ExportArguments["10,3011"] ="13,3002,-0.02" -- Low Altitude Setting Knob >> Rocker_C_106
Helios_Huey.ExportArguments["10,3012"] ="13,3002,0.02" -- Low Altitude Setting Knob >>  Rocker_C_106
Helios_Huey.ExportArguments["10,3013"] ="13,3003,-0.02" -- Test / Hight Set >> Rocker_C_107
Helios_Huey.ExportArguments["10,3014"] ="13,3003,0.02" -- Test / Hight Set >>  Rocker_C_107
Helios_Huey.ExportArguments["10,3015"] ="29,3001,-0.02" -- Course Select Knobb >> Rocker_C_108
Helios_Huey.ExportArguments["10,3016"] ="29,3001,0.02" -- Course Select Knob >>  Rocker_C_108
Helios_Huey.ExportArguments["10,3017"] ="10,3003,-0.02" -- Heading Set Knob  >> Rocker_C_109
Helios_Huey.ExportArguments["10,3018"] ="10,3003,0.02" -- Heading Set Knob  >>  Rocker_C_109
Helios_Huey.ExportArguments["10,3019"] ="10,3005,-0.02" -- Compass Synchronizing Knob >> Rocker_C_110
Helios_Huey.ExportArguments["10,3020"] ="10,3005,0.02" -- Compass Synchronizing Knob >>  Rocker_C_110
Helios_Huey.ExportArguments["10,3021"] ="18,3001,-0.02" -- Pressure Adjustment Knob >> Rocker_C_111
Helios_Huey.ExportArguments["10,3022"] ="18,3001,0.02" -- Pressure Adjustment Knob >>  Rocker_C_111
Helios_Huey.ExportArguments["10,3023"] ="5,3001,-0.02" -- Attitude Indicator Pitch Trim Knob >> Rocker_C_112
Helios_Huey.ExportArguments["10,3024"] ="5,3001,0.02" -- Attitude Indicator Pitch Trim Knob >>  Rocker_C_112
Helios_Huey.ExportArguments["10,3025"] ="19,3001,-0.2" -- Pressure Adjustment Knob      copilot>> Rocker_C_113
Helios_Huey.ExportArguments["10,3026"] ="19,3001,0.2" -- Pressure Adjustment Knob       copilot>>  Rocker_C_113
Helios_Huey.ExportArguments["10,3027"] ="6,3002,-0.02" -- Attitude Indicator Pitch Trim Knob copilot >> Rocker_C_114
Helios_Huey.ExportArguments["10,3028"] ="6,3002,0.02" -- Attitude Indicator Pitch Trim Knob copilot >>  Rocker_C_114
Helios_Huey.ExportArguments["10,3029"] ="5,3002,-0.02" -- Attitude Indicator Roll Trim Knob >> Rocker_C_115
Helios_Huey.ExportArguments["10,3030"] ="5,3002,0.02" -- Attitude Indicator Roll Trim Knob >>  Rocker_C_115
Helios_Huey.ExportArguments["10,3031"] ="30,3002,-0.02" -- adjustement clock >> Rocker_C_116
Helios_Huey.ExportArguments["10,3032"] ="30,3002,0.02" -- adjustement clock >>  Rocker_C_116
Helios_Huey.ExportArguments["10,3033"] ="50,3004,-0.02" -- Flare counter Reset. Rotate mouse wheel to set Number >> Rocker_C_117
Helios_Huey.ExportArguments["10,3034"] ="50,3004,0.02" -- Flare counter Reset. Rotate mouse wheel to set Number >>  Rocker_C_117
Helios_Huey.ExportArguments["10,3035"] ="50,3008,-0.02" -- Chaff counter Reset. Rotate mouse wheel to set Number >> Rocker_C_118
Helios_Huey.ExportArguments["10,3036"] ="50,3008,0.02" -- Chaff counter Reset. Rotate mouse wheel to set Number >>  Rocker_C_118
Helios_Huey.ExportArguments["10,3037"] ="22,3002,-0.02" -- 10 MHz Selector >> Rocker_C_119
Helios_Huey.ExportArguments["10,3038"] ="22,3002,0.02" -- 10 MHz Selector >>  Rocker_C_119
Helios_Huey.ExportArguments["10,3039"] ="22,3003,-0.02" -- 1 MHz Selector >> Rocker_C_120
Helios_Huey.ExportArguments["10,3040"] ="22,3003,0.02" -- 1 MHz Selector >>  Rocker_C_120
Helios_Huey.ExportArguments["10,3041"] ="22,3004,-0.02" -- 50 kHz Selector >> Rocker_C_121
Helios_Huey.ExportArguments["10,3042"] ="22,3004,0.02" -- 50 kHz Selector >>  Rocker_C_121
