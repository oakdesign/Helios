Helios_SA342 = {}

Helios_SA342.Name = "SA342"
Helios_SA342.FlamingCliffsAircraft = false

Helios_SA342.ExportArguments = {}

function Helios_SA342.ProcessInput(data)
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
		lConvDevice = Helios_SA342.ExportArguments[sIndex] 	
		lArgument = Helios_Util.Split(string.sub(lConvDevice,1),",")
		min_clamp = 0
		
		if lArgument[3]=="300" then   -- several axis exported in the same rotator encoder, because i dont have enought axis outputs in the KA50 interface
			local valor_actual = GetDevice(0)
			local absoluto= math.abs(lCommandArgs[3])
			local variacion= (lCommandArgs[3]/absoluto)/10
				
			if absoluto==0.1 then
				valor_axis= valor_actual:get_argument_value(182) + variacion
				lArgument = {27,3003,1} -- A342 PH bright
			end
			if absoluto==0.15 then
				valor_axis= valor_actual:get_argument_value(386) + variacion
				lArgument = {31,3004,1} -- SA342 UHF PAGE
			end
			if absoluto==0.2 then
				valor_axis= valor_actual:get_argument_value(330) + variacion
				lArgument = {23,3001,1} -- NADIR bright
			end
			if absoluto==0.25 then
				valor_axis= valor_actual:get_argument_value(122) + variacion
				lArgument = {24,3005,1} -- SA342 RWR brt
			end
			if absoluto==0.3 then
				valor_axis= valor_actual:get_argument_value(121) + variacion
				lArgument = {24,3004,1} -- SA342 RWR Audio
			end
			if absoluto==0.35 then
				valor_axis= valor_actual:get_argument_value(30) + variacion
				lArgument = {15,3010,1} -- Anti-collision bright
			end
			if absoluto==0.4 then
				valor_axis= valor_actual:get_argument_value(21) + variacion
				lArgument = {14,3002,1} -- SA342 Console Lighting   PUP
			end
			if absoluto==0.45 then
				valor_axis= valor_actual:get_argument_value(22) + variacion
				lArgument = {14,3001,1} -- SA342 Main Dashboard Lighting  POB
			end
			if absoluto==0.5 then
				valor_axis= valor_actual:get_argument_value(357) + variacion
				lArgument = {26,3009,1} -- A342 WP1 Brt
			end
			if absoluto==0.55 then
				valor_axis= valor_actual:get_argument_value(230) + variacion
				lArgument = {15,3012,1} -- formation lights bright
			end
			if absoluto==0.6 then
				valor_axis= valor_actual:get_argument_value(145) + variacion
				lArgument = {14,3003,1} -- UV light bright
			end
			if absoluto==0.65 then
				valor_axis =  variacion
				lArgument = {9,3001,1} -- HA rot
				min_clamp = -1
			end
			if absoluto==0.7 then
				valor_axis =  variacion
				lArgument = {9,3003,1} -- stanby HA rot
				min_clamp = -1
			end
			if absoluto==0.75 then
				valor_axis =  variacion
				lArgument = {19,3001,1} -- QFE adjust rot
				min_clamp = -1
			end
			if absoluto==0.8 then
				valor_axis =  variacion
				lArgument = {20,3001,1} -- CLOCK exterior ring (podria ser el btn 4 en vez del 1)
				min_clamp = -1
			end
			if absoluto==0.85 then
				valor_axis = variacion
				lArgument = {18,3001,1} -- Ralt safe bug rot
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
			
			lDevice:performClickableAction(lArgument[2],lCommandArgs[3]*lArgument[3])
		end
	end
end

function Helios_SA342.HighImportance(mainPanelDevice)
	--- Altitude
	Helios_Udp.Send("87", string.format("%.4f", mainPanelDevice:get_argument_value(87) ))		-- Baro_Altimeter_thousands (0-1) > Barometric Altimeter
	Helios_Udp.Send("89", string.format("%.4f", mainPanelDevice:get_argument_value(573) ))		-- Baro_Altimeter_hundred (0-1) > Commanded Altitude
	Helios_Udp.Send("471", string.format("%.4f", mainPanelDevice:get_argument_value(94) ))		-- Radar_Altimeter  > Common Pressure
	Helios_Udp.Send("472", string.format("%.4f", mainPanelDevice:get_argument_value(93) ))		-- DangerRALT_index  > Main Pressure
	--- Velocity
	Helios_Udp.Send("24", string.format("%.4f", mainPanelDevice:get_argument_value(24) ))		-- Variometre > vertical velocity
	Helios_Udp.Send("51", string.format("%.4f", mainPanelDevice:get_argument_value(51) ))		-- IAS > Indicated Airspeed
	-- Engine Management
	Helios_Udp.Send("53", string.format("%.4f", mainPanelDevice:get_argument_value(16) ))		-- Torque > Rotor Pitch
	Helios_Udp.Send("133", string.format("%.4f", mainPanelDevice:get_argument_value(151) ))	-- TempThm > Left Engine EGT
	Helios_Udp.Send("134", string.format("%.4f", mainPanelDevice:get_argument_value(15) ))		-- TQuatre > Right Engine EGT
	Helios_Udp.Send("135", string.format("%.4f", mainPanelDevice:get_argument_value(135) ))	-- Turbine_RPM > Left Engine RPM
	Helios_Udp.Send("136", string.format("%.4f", mainPanelDevice:get_argument_value(52) ))		-- Rotor_RPM > Right Engine RPM
	Helios_Udp.Send("111", string.format("%.4f", mainPanelDevice:get_argument_value(55) ))		-- Torque_Bug > ADI air speed deviation
	-- HA
	local HA_rot_var= (mainPanelDevice:get_argument_value(115)*0.06)-0.03
	local Adjusted_HA = (-2 * mainPanelDevice:get_argument_value(27))- HA_rot_var
	Helios_Udp.Send("101", string.format("%.4f", Adjusted_HA ))								-- HA_Pitch plus HA rot  > ADI pitch
	Helios_Udp.Send("100", string.format("%.4f", mainPanelDevice:get_argument_value(28) ))		-- HA_Roll > ADI roll
	Helios_Udp.Send("108", string.format("%.4f", mainPanelDevice:get_argument_value(20) ))		-- HA_bille > ADI side slip
	Helios_Udp.Send("107", string.format("%.4f", mainPanelDevice:get_argument_value(118) ))	-- HA_barre_Verticale > ADI bank deviation
	Helios_Udp.Send("106", string.format("%.4f", mainPanelDevice:get_argument_value(119) ))	-- HA_barre_Horizontale > ADI pitch deviation
	Helios_Udp.Send("109", string.format("%.4f", mainPanelDevice:get_argument_value(19) ))		-- HA_flag_HS > ADI malfunction flag
	-- Stby HA
	local STB_HA_rot_var= (mainPanelDevice:get_argument_value(215)*0.06)-0.03
	local Adjusted_STB_HA = (-2 * mainPanelDevice:get_argument_value(213))- STB_HA_rot_var
	Helios_Udp.Send("143", string.format("%.4f", Adjusted_STB_HA ))							-- Stdby_HA_Pitch plus Stb_HA rot > Backup ADI pitch
	Helios_Udp.Send("142", string.format("%.4f", mainPanelDevice:get_argument_value(214) ))	-- Stdby_HA_Roll > Backup ADI roll
	Helios_Udp.Send("145", string.format("%.4f", mainPanelDevice:get_argument_value(211) ))	-- Stdby_HA_flag > Backup ADI warning flag
	-- HSI
	local valFixed = 1 - mainPanelDevice:get_argument_value(113)
	Helios_Udp.Send("112", string.format("%.4f", valFixed ))									-- ADF_Fond > HSI Heading
	Helios_Udp.Send("118", string.format("%.4f", mainPanelDevice:get_argument_value(102) ))	-- ADF_AiguilleLarge > HSI Commaned Course
	Helios_Udp.Send("124", string.format("%.4f", mainPanelDevice:get_argument_value(103) ))	-- ADF_Aiguille_fine > HSI Commanded Heading
	Helios_Udp.Send("372", string.format("%.4f", mainPanelDevice:get_argument_value(110) ))	-- ADF_100 >  R-828 VHF-1 Radio Volume
	Helios_Udp.Send("574", string.format("%.4f", mainPanelDevice:get_argument_value(111) ))	-- ADF_10 > R-800 VHF-2 Radio 2nd Rotary Window
	Helios_Udp.Send("575", string.format("%.4f", mainPanelDevice:get_argument_value(112) ))	-- ADF_1 > R-800 VHF-2 Radio rd Rotary Window
	--Gyro
	Helios_Udp.Send("144", string.format("%.4f", mainPanelDevice:get_argument_value(200) ))	-- Gyro needle > Backup ADI side slip
	--Clock
	Helios_Udp.Send("70", string.format("%.4f", mainPanelDevice:get_argument_value(42) ))		-- CLOCK_SECOND > Current Time Seconds
	Helios_Udp.Send("406", string.format("%.4f", mainPanelDevice:get_argument_value(210) ))	-- CLOCK_exterior corone > Shkval Brightness
	-- PA
	Helios_Udp.Send("103", string.format("%.4f", mainPanelDevice:get_argument_value(37) ))		-- SA342 PA T > adi lateral dev
	Helios_Udp.Send("526", string.format("%.4f", mainPanelDevice:get_argument_value(38) ))		-- SA342 PA R > adi alt dev
	Helios_Udp.Send("127", string.format("%.4f", mainPanelDevice:get_argument_value(39) ))		-- SA342 PA L > hsi long dev
	-- main alarms lamps
	Helios_Udp.Send("64", string.format("%.4f", mainPanelDevice:get_argument_value(303) ))		-- SA342 Voyant_ALARME > Mechanical Nose Gear Down Indicator
	Helios_Udp.Send("61", string.format("%.4f", mainPanelDevice:get_argument_value(17) ))		-- SA342 Voyant_Torque > Mechanical Right Gear Up Indicator	
end

function Helios_SA342.LowImportance(mainPanelDevice)
	-- SA342  >  KA50
	--Instruments Flags
	Helios_Udp.Send("190", string.format("%.4f", mainPanelDevice:get_argument_value(29) ))		-- SA342 HA loc >
	Helios_Udp.Send("207", string.format("%.4f", mainPanelDevice:get_argument_value(18) ))		-- SA342 HA GS >
	Helios_Udp.Send("183", string.format("%.4f", mainPanelDevice:get_argument_value(108) ))	-- SA342 HSI px >
	Helios_Udp.Send("182", string.format("%.4f", mainPanelDevice:get_argument_value(109) ))	-- SA342 HSI but >
	Helios_Udp.Send("191", string.format("%.4f", mainPanelDevice:get_argument_value(107) ))	-- SA342 HSI cap >
	Helios_Udp.Send("208", string.format("%.4f", mainPanelDevice:get_argument_value(208) ))	-- SA342 Gyro flags >
	--- Clock
	Helios_Udp.Send("68", string.format("%.4f", mainPanelDevice:get_argument_value(41) ))		-- SA342 CLOCK_HOUR > Current Time Hours
	Helios_Udp.Send("69", string.format("%.4f", mainPanelDevice:get_argument_value(43) ))		-- SA342 CLOCK_MINUTE > Current Time Minutes
	Helios_Udp.Send("73", string.format("%.4f", mainPanelDevice:get_argument_value(44) ))		-- SA342 CLOCK_MINI > Stop Watch Minutes
	-- Qcomb
	Helios_Udp.Send("137", string.format("%.4f", mainPanelDevice:get_argument_value(137) ))	-- SA342 QComb > Rear Tank Fuel Quantity
	-- voltmetre
	Helios_Udp.Send("52", string.format("%.4f", mainPanelDevice:get_argument_value(14) ))		-- SA342 Voltmetre > Rotor RPM
	-- torque
	Helios_Udp.Send("55", string.format("%1d", mainPanelDevice:get_argument_value(58) ))		-- SA342 torque test button >  laser ranger reset
	-- alarms panel
	Helios_Udp.Send("59", string.format("%.4f", mainPanelDevice:get_argument_value(1) ))		-- SA342 TA_PITOT > Mechanical Left Gear Up Indicator
	Helios_Udp.Send("47", string.format("%.4f", mainPanelDevice:get_argument_value(2) ))		-- SA342 TA_HMOT > Caution Under Fire Indicator
	Helios_Udp.Send("48", string.format("%.4f", mainPanelDevice:get_argument_value(3) ))		-- SA342 TA_HBTP > Caution Lower Gear Indicator
	Helios_Udp.Send("78", string.format("%.4f", mainPanelDevice:get_argument_value(4) ))		-- SA342 TA_HRAL > Caution Left Engine Max RPM Indicator
	Helios_Udp.Send("79", string.format("%.4f", mainPanelDevice:get_argument_value(5) ))		-- SA342 TA_GENE > Caution Right Engine Max RPM Indicator
	Helios_Udp.Send("80", string.format("%.4f", mainPanelDevice:get_argument_value(6) ))		-- SA342 TA_ALTER > Caution Ny Max	
	Helios_Udp.Send("81", string.format("%.4f", mainPanelDevice:get_argument_value(7) ))		-- SA342 TA_BAT > Caution Left Engine Vibration Indicator	
	Helios_Udp.Send("82", string.format("%.4f", mainPanelDevice:get_argument_value(8) ))		-- SA342 TA_PA > Caution Right Engine Vibration Indicator	
	Helios_Udp.Send("83", string.format("%.4f", mainPanelDevice:get_argument_value(9) ))		-- SA342 TA_NAV > Caution IAS Max Indicator	
	Helios_Udp.Send("84", string.format("%.4f", mainPanelDevice:get_argument_value(10) ))		-- SA342 TA_COMB > Caution Main Transmission Warning Indicator	
	Helios_Udp.Send("85", string.format("%.4f", mainPanelDevice:get_argument_value(11) ))		-- SA342 TA_BPHY > Caution Fire Indicator	
	Helios_Udp.Send("86", string.format("%.4f", mainPanelDevice:get_argument_value(12) ))		-- SA342 TA_LIM > Caution IFF Failure Indicator
	Helios_Udp.Send("63", string.format("%.4f", mainPanelDevice:get_argument_value(13) ))		-- SA342 TA_FILT > Mechanical Nose Gear Up Indicator		
	-- other alarms
	Helios_Udp.Send("62", string.format("%.4f", mainPanelDevice:get_argument_value(97) ))		-- SA342 RAlt_Alarm > Mechanical Right Gear Down Indicator
	Helios_Udp.Send("170", string.format("%.4f", mainPanelDevice:get_argument_value(300) ))	-- SA342 Voyant_DEM > Left Warning Panel R-Alt Hold Indicator
	Helios_Udp.Send("175", string.format("%.4f", mainPanelDevice:get_argument_value(301) ))	-- SA342 Voyant_RLT > Left Warning Panel Auto Hover
	Helios_Udp.Send("172", string.format("%.4f", mainPanelDevice:get_argument_value(302) ))	-- SA342 Voyant_BLOC > Left Warning Panel Auto Descent
	Helios_Udp.Send("165", string.format("%.4f", mainPanelDevice:get_argument_value(320) ))	-- SA342 Voyant_SUPP > Left Warning Panel ENR Nav On
	Helios_Udp.Send("171", string.format("%.4f", mainPanelDevice:get_argument_value(321) ))	-- SA342 Voyant_CONV > Left Warning Panel ENR Course
	Helios_Udp.Send("176", string.format("%.4f", mainPanelDevice:get_argument_value(322) ))	-- SA342 Voyant_FILTAS > Left Warning Panel Next WP"
	Helios_Udp.Send("166", string.format("%.4f", mainPanelDevice:get_argument_value(201) ))	-- SA342 Voyant_TEST > Left Warning Panel ENR End
	Helios_Udp.Send("164", string.format("%.4f", mainPanelDevice:get_argument_value(202) ))	-- SA342 Voyant_TRIM > Left Warning Panel AC-POS Cal. Data
	Helios_Udp.Send("178", string.format("%.4f", mainPanelDevice:get_argument_value(203) ))	-- SA342 Voyant_BPP > Left Warning Panel Weap. Arm
	Helios_Udp.Send("173", string.format("%.4f", mainPanelDevice:get_argument_value(127) ))	-- SA342 Voyant_BPP > Left Warning Panel cannon"
	-- PH panel
	Helios_Udp.Send("392", string.format("%.4f", mainPanelDevice:get_argument_value(183) ))	-- SA342 PH_Bon_Light > "PUI-800", "Station 1 Present Lamp"
	Helios_Udp.Send("393", string.format("%.4f", mainPanelDevice:get_argument_value(184) ))	-- SA342 PH_Mauvais_Light > "PUI-800", "Station 2 Present Lamp"
	Helios_Udp.Send("394", string.format("%.4f", mainPanelDevice:get_argument_value(185) ))	-- SA342 PH_Alim_Light > "PUI-800", "Station 3 Present Lamp"
	Helios_Udp.Send("177", string.format("%.4f", mainPanelDevice:get_argument_value(189) ))	-- SA342 PH_TestI_Light > canon <> lamp
	Helios_Udp.Send("395", string.format("%.4f", mainPanelDevice:get_argument_value(190) ))	-- SA342 PH_Jour_Light > "PUI-800", "Station 4 Present Lamp"
	Helios_Udp.Send("211", string.format("%.4f", mainPanelDevice:get_argument_value(192) ))	-- SA342 PH_TestII_Light > Xfeed valve open lamp
	Helios_Udp.Send("388", string.format("%.4f", mainPanelDevice:get_argument_value(193) ))	-- SA342 PH_Nuit_Light > "PUI-800", "Station 1 Ready Lamp"
	Helios_Udp.Send("389", string.format("%.4f", mainPanelDevice:get_argument_value(186) ))	-- SA342 PH_Pret_Light > "PUI-800", "Station 2 Ready Lamp
	Helios_Udp.Send("390", string.format("%.4f", mainPanelDevice:get_argument_value(187) ))	-- SA342 PH_Autor_Light > "PUI-800", "Station 3 Ready Lamp"
	Helios_Udp.Send("391", string.format("%.4f", mainPanelDevice:get_argument_value(188) ))	-- SA342 PH_Defaut_Light > "PUI-800", "Station 4 Ready Lamp"
	Helios_Udp.Send("187", string.format("%.4f", mainPanelDevice:get_argument_value(191) ))	-- SA342 PH_ilum light > turbo gear lamp
	Helios_Udp.Send("517", string.format("%.4f", mainPanelDevice:get_argument_value(178) ))	-- SA342 PH_Gisement into "ABRIS", "Brightness"
	-- Nadir
	Helios_Udp.Send("312", string.format("%.1f", mainPanelDevice:get_argument_value(351)/5 ))		-- SA342 NADIR 0 > PVI 0
	Helios_Udp.Send("303", string.format("%.1f", mainPanelDevice:get_argument_value(338)/5 ))		-- SA342 NADIR 1
	Helios_Udp.Send("304", string.format("%.1f", mainPanelDevice:get_argument_value(339)/5 ))		-- SA342 NADIR 2
	Helios_Udp.Send("305", string.format("%.1f", mainPanelDevice:get_argument_value(340)/5 ))		-- SA342 NADIR 3
	Helios_Udp.Send("306", string.format("%.1f", mainPanelDevice:get_argument_value(342)/5 ))		-- SA342 NADIR 4
	Helios_Udp.Send("307", string.format("%.1f", mainPanelDevice:get_argument_value(343)/5 ))		-- SA342 NADIR 5
	Helios_Udp.Send("308", string.format("%.1f", mainPanelDevice:get_argument_value(344)/5 ))		-- SA342 NADIR 6
	Helios_Udp.Send("309", string.format("%.1f", mainPanelDevice:get_argument_value(346)/5 ))		-- SA342 NADIR 7
	Helios_Udp.Send("310", string.format("%.1f", mainPanelDevice:get_argument_value(347)/5 ))		-- SA342 NADIR 8
	Helios_Udp.Send("311", string.format("%.1f", mainPanelDevice:get_argument_value(348)/5 ))		-- SA342 NADIR 9
	Helios_Udp.Send("315", string.format("%.1f", mainPanelDevice:get_argument_value(333)/5 ))		-- SA342 NADIR_ENT
	Helios_Udp.Send("519", string.format("%.1f", mainPanelDevice:get_argument_value(334)/5 ))		-- SA342 NADIR_DES
	Helios_Udp.Send("316", string.format("%.1f", mainPanelDevice:get_argument_value(335)/5 ))		-- SA342 NADIR_AUX
	Helios_Udp.Send("520", string.format("%.1f", mainPanelDevice:get_argument_value(336)/5 ))		-- SA342 NADIR_IC
	Helios_Udp.Send("317", string.format("%.1f", mainPanelDevice:get_argument_value(337)/5 ))		-- SA342 NADIR_DOWN
	Helios_Udp.Send("521", string.format("%.1f", mainPanelDevice:get_argument_value(341)/5 ))		-- SA342 NADIR_POL
	Helios_Udp.Send("318", string.format("%.1f", mainPanelDevice:get_argument_value(345)/5 ))		-- SA342 NADIR_GEO
	Helios_Udp.Send("313", string.format("%.1f", mainPanelDevice:get_argument_value(349)/5 ))		-- SA342 NADIR_POS
	Helios_Udp.Send("314", string.format("%.1f", mainPanelDevice:get_argument_value(350)/5 ))		-- SA342 NADIR_GEL
	Helios_Udp.Send("522", string.format("%.1f", mainPanelDevice:get_argument_value(352)/5 ))		-- SA342 NADIR_EFF
	Helios_Udp.Send("324", string.format("%.1f", mainPanelDevice:get_argument_value(331)/2 ))		-- SA342 NADIR Mode
	Helios_Udp.Send("357", string.format("%.1f", mainPanelDevice:get_argument_value(332)/2 ))		-- SA342 NADIR Parameter
	Helios_Udp.Send("531", string.format("%.4f", mainPanelDevice:get_argument_value(330) ))		-- SA342 NADIR Light Intensity >  flight time seconds
	--RWR
	Helios_Udp.Send("319", string.format("%.1f", mainPanelDevice:get_argument_value(149)/5 ))		-- SA342 RWR marquer
	Helios_Udp.Send("320", string.format("%.1f", mainPanelDevice:get_argument_value(150)/5 ))		-- SA342 RWR page
	Helios_Udp.Send("9", string.format("%1d", mainPanelDevice:get_argument_value(148) ))			-- SA342 RWR ON-OFF-PTR
	Helios_Udp.Send("98", string.format("%.4f", mainPanelDevice:get_argument_value(122) ))	    	-- SA342 rwr brt rot  >  Accelerometer max g
	Helios_Udp.Send("99", string.format("%.4f", mainPanelDevice:get_argument_value(121) ))			-- SA342 rwr audio rot  >  Accelerometer min g
	--Main panel
	Helios_Udp.Send("329", string.format("%.1f", mainPanelDevice:get_argument_value(218)/3.3 ))	-- SA342 Source ArtVisVhfDop
	Helios_Udp.Send("262", string.format("%1d", mainPanelDevice:get_argument_value(264) ))			-- SA342 Battery	2 > guarda del dc power
	Helios_Udp.Send("263", string.format("%1d", mainPanelDevice:get_argument_value(265) ))			-- SA342 Alternator	2
	Helios_Udp.Send("543", string.format("%1d", mainPanelDevice:get_argument_value(268) ))			-- SA342 Generator	2
	Helios_Udp.Send("544", string.format("%1d", mainPanelDevice:get_argument_value(170) ))			-- SA342 Pitot	2
	Helios_Udp.Send("264", string.format("%1d", mainPanelDevice:get_argument_value(271) ))			-- SA342 Fuel Pump	2
	Helios_Udp.Send("265", string.format("%1d", mainPanelDevice:get_argument_value(267) ))			-- SA342 Additionnal Fuel Tank	2
	Helios_Udp.Send("408", string.format("%.1f", (mainPanelDevice:get_argument_value(56) +1)/10 ))	-- SA342 Starter Start/Stop/Air	3  >  laser convert -1 0 1 to 0 0.1 0.2
	Helios_Udp.Send("267", string.format("%1d", mainPanelDevice:get_argument_value(57) ))			-- SA342 Test
	Helios_Udp.Send("400", string.format("%.1f", (mainPanelDevice:get_argument_value(48) +1)/10 ))	-- SA342 Copilot Wiper	3
	Helios_Udp.Send("36", string.format("%.1f", (mainPanelDevice:get_argument_value(49) +1)/10 ))	-- SA342 Pilot Wiper	3  
	Helios_Udp.Send("268", string.format("%1d", mainPanelDevice:get_argument_value(61) ))			-- SA342 space				2
	Helios_Udp.Send("321", string.format("%.1f", mainPanelDevice:get_argument_value(62)/5 ))		-- SA342 Voltmeter Test
	Helios_Udp.Send("271", string.format("%1d", mainPanelDevice:get_argument_value(59) ))			-- SA342 HYD Test
	Helios_Udp.Send("272", string.format("%1d", mainPanelDevice:get_argument_value(66) ))			-- SA342 Alter Rearm
	Helios_Udp.Send("273", string.format("%1d", mainPanelDevice:get_argument_value(67) ))			-- SA342 Gene Rearm
	Helios_Udp.Send("274", string.format("%1d", mainPanelDevice:get_argument_value(63) ))			-- SA342 Convoy Tank On/Off	2
	Helios_Udp.Send("275", string.format("%1d", mainPanelDevice:get_argument_value(64) ))			-- SA342 Sand Filter On/Off	2
	Helios_Udp.Send("354", string.format("%.1d", mainPanelDevice:get_argument_value(269) ))		-- SA342 armt 2
	Helios_Udp.Send("269", string.format("%1d", mainPanelDevice:get_argument_value(382) ))			-- SA342 Panels Lighting On/Off		2
	Helios_Udp.Send("276", string.format("%1d", mainPanelDevice:get_argument_value(60) ))			-- SA342 Trim On/Off		2
	Helios_Udp.Send("277", string.format("%1d", mainPanelDevice:get_argument_value(65) ))			-- SA342 Magnetic Brake On/Off		2
	--Lights
	Helios_Udp.Send("415", string.format("%.1f", (mainPanelDevice:get_argument_value(146) +1)/10 ))-- SA342 Navigation Lights CLI / OFF / FIX	3
	Helios_Udp.Send("270", string.format("%.1f", (mainPanelDevice:get_argument_value(228) +1)/10 ))-- SA342 Anticollision Light NOR / OFF / ATT	3 
	Helios_Udp.Send("592", string.format("%.4f", mainPanelDevice:get_argument_value(22) ))			-- SA342 Main Dashboard Lighting >  Engine Power Indicator Power Indicator Mode
	Helios_Udp.Send("2003", string.format("%.4f", mainPanelDevice:get_argument_value(21) ))		-- SA342 Console Lighting >  PUI-800 Cannon Rounds
	Helios_Udp.Send("2001", string.format("%.4f", mainPanelDevice:get_argument_value(145) ))		-- SA342 UV Lighting >  PUI-800Selected Station Type	
	Helios_Udp.Send("72", string.format("%.4f", mainPanelDevice:get_argument_value(30) ))			-- SA342 AntiCollision Light Intensity >  flight time hours
	Helios_Udp.Send("138", string.format("%.4f", mainPanelDevice:get_argument_value(230) ))		-- SA342 formation lights brt >  Fuel System Forward Tank Fuel Quantity
	Helios_Udp.Send("356", string.format("%1d", mainPanelDevice:get_argument_value(229) ))			-- SA342  inter_Feux_Formation >
	--TV
	Helios_Udp.Send("278", string.format("%1d", mainPanelDevice:get_argument_value(124) ))			-- SA342 TV On/Off		2
	Helios_Udp.Send("8", string.format("%.4f", mainPanelDevice:get_argument_value(123)/2 ))		-- SA342 TV Brightness		2
	Helios_Udp.Send("407", string.format("%.4f", mainPanelDevice:get_argument_value(125)/2 ))		-- SA342 TV Contrast		2
	--Gyro
	Helios_Udp.Send("280", string.format("%1d", mainPanelDevice:get_argument_value(198) ))			-- SA342 Gyro Test Switch On/Off    2
	Helios_Udp.Send("281", string.format("%1d", mainPanelDevice:get_argument_value(197) ))			-- SA342 Gyro Test Cover On/Off		2
	Helios_Udp.Send("154", string.format("%.1f", (mainPanelDevice:get_argument_value(199) +1)/2 ))	-- SA342 Left/Center/Right	3 
	Helios_Udp.Send("147", string.format("%.1f", mainPanelDevice:get_argument_value(153)/2.5 ))	-- SA342 CM/A/GM/D/GD   multipos	
	--PE
	Helios_Udp.Send("396", string.format("%1d", mainPanelDevice:get_argument_value(367) ))			-- SA342 PE system M/A		2
	Helios_Udp.Send("403", string.format("%1d", mainPanelDevice:get_argument_value(362) ))			-- SA342 PE centering		2
	Helios_Udp.Send("399", string.format("%1d", mainPanelDevice:get_argument_value(364) ))			-- SA342 PE VDO VTH		2
	Helios_Udp.Send("462", string.format("%.1f", mainPanelDevice:get_argument_value(370)/2.5  ))	-- SA342 PE mode		2 ( convert steps 0.25 to steps 0.1
	Helios_Udp.Send("335", string.format("%.1f", mainPanelDevice:get_argument_value(366) ))		-- SA342 PE CTH		3 pos 
	Helios_Udp.Send("336", string.format("%0.1f", (mainPanelDevice:get_argument_value(365) +1)/2 ))-- SA342 PE CTH		3 pos 
	--PH
	Helios_Udp.Send("431", string.format("%.1f", mainPanelDevice:get_argument_value(180)/2.5 ))	-- SA342 PH cle
	Helios_Udp.Send("371", string.format("%.1f", mainPanelDevice:get_argument_value(181)/1.25 ))	-- SA342 PH station selection
	--Weapons
	Helios_Udp.Send("548", string.format("%1d", mainPanelDevice:get_argument_value(373) ))			-- SA342 weapon cover left		2
	Helios_Udp.Send("547", string.format("%1d", mainPanelDevice:get_argument_value(372) ))			-- SA342 weapon left		2
	Helios_Udp.Send("283", string.format("%1d", mainPanelDevice:get_argument_value(375) ))			-- SA342 weapon cover right		2
	Helios_Udp.Send("282", string.format("%1d", mainPanelDevice:get_argument_value(374) ))			-- SA342 weapon right		2
	Helios_Udp.Send("398", string.format("%1d", mainPanelDevice:get_argument_value(376) ))			-- SA342 weapon riple single		2
	Helios_Udp.Send("204", string.format("%.4f", mainPanelDevice:get_argument_value(377) ))		-- SA342 weapon left lamp > AGB Oil Press
	Helios_Udp.Send("213", string.format("%.4f", mainPanelDevice:get_argument_value(378) ))		-- SA342 weapon right lamp >	SL Hook Open	
	Helios_Udp.Send("229", string.format("%.1f", (mainPanelDevice:get_argument_value(354)+1)/10))  -- SA342 weapons power	3
	Helios_Udp.Send("532", string.format("%.4f", mainPanelDevice:get_argument_value(357) ))		-- SA342 wp1 display brt >  Clock Stop Watch Seconds
	--FD flare dispenser
	Helios_Udp.Send("167", string.format("%.4f", mainPanelDevice:get_argument_value(223) ))		-- SA342 FD g1 lamp > right alarm panel
	Helios_Udp.Send("180", string.format("%.4f", mainPanelDevice:get_argument_value(224) ))		-- SA342 FD g2 lamp > right alarm panel
	Helios_Udp.Send("179", string.format("%.4f", mainPanelDevice:get_argument_value(225) ))		-- SA342 FD d1 lamp > right alarm panel
	Helios_Udp.Send("188", string.format("%.4f", mainPanelDevice:get_argument_value(226) ))		-- SA342 FD d2 lamp > right alarm panel
	Helios_Udp.Send("189", string.format("%.4f", mainPanelDevice:get_argument_value(227) ))		-- SA342 FD leu lamp > right alarm panel
	Helios_Udp.Send("206", string.format("%.4f", mainPanelDevice:get_argument_value(231) ))		-- SA342 FD left lamp > right alarm panel
	Helios_Udp.Send("212", string.format("%.4f", mainPanelDevice:get_argument_value(232) ))		-- SA342 FD right lamp > right alarm panel
	Helios_Udp.Send("205", string.format("%.4f", mainPanelDevice:get_argument_value(233) ))		-- SA342 FD power lamp > right alarm panel
	Helios_Udp.Send("230", string.format("%.1d", mainPanelDevice:get_argument_value(221) ))		-- SA342 FD seq switch 2 > AGB Oil Press
	Helios_Udp.Send("248", string.format("%.1f", (mainPanelDevice:get_argument_value(220)+1)/10))  -- SA342 FD G+D	3 >
	Helios_Udp.Send("295", string.format("%.1f", (mainPanelDevice:get_argument_value(222)+1)/10))  -- SA342 FD LE VE AR 3 >
	--PA Autopilot
	Helios_Udp.Send("65", string.format("%.1d", mainPanelDevice:get_argument_value(31) ))		-- SA342 PA on off > CPT MECH gear
	Helios_Udp.Send("539", string.format("%.1d", mainPanelDevice:get_argument_value(32) ))		-- SA342 PA pitch on 2 > CPT MECH pitot static
	Helios_Udp.Send("151", string.format("%.1d", mainPanelDevice:get_argument_value(33) ))		-- SA342 PA roll on 2 > CPT MECH pitot ram
	Helios_Udp.Send("153", string.format("%.1d", mainPanelDevice:get_argument_value(34) ))		-- SA342 PA yaw on 2 > engine rotor de icing
	Helios_Udp.Send("328", string.format("%.1f", (mainPanelDevice:get_argument_value(35)+1)/10)) -- SA342 PA mode 3 > datalink self id
	--UHF 
	Helios_Udp.Send("301", string.format("%.1f", mainPanelDevice:get_argument_value(383)/1.67 ))	-- SA342 UHF left rot
	Helios_Udp.Send("512", string.format("%.1d", mainPanelDevice:get_argument_value(384) ))	-- SA342 UHF drw
	Helios_Udp.Send("513", string.format("%.1d", mainPanelDevice:get_argument_value(385) ))	-- SA342 UHF vld
	Helios_Udp.Send("514", string.format("%.1d", mainPanelDevice:get_argument_value(387) ))	-- SA342 UHF conf
	Helios_Udp.Send("515", string.format("%.1d", mainPanelDevice:get_argument_value(388) ))	-- SA342 UHF 1
	Helios_Udp.Send("516", string.format("%.1d", mainPanelDevice:get_argument_value(389) ))	-- SA342 UHF 2
	Helios_Udp.Send("523", string.format("%.1d", mainPanelDevice:get_argument_value(390) ))	-- SA342 UHF 3
	Helios_Udp.Send("156", string.format("%.1d", mainPanelDevice:get_argument_value(391) ))	-- SA342 UHF 4
	Helios_Udp.Send("38", string.format("%.1d", mainPanelDevice:get_argument_value(392) ))		-- SA342 UHF 5
	Helios_Udp.Send("39", string.format("%.1d", mainPanelDevice:get_argument_value(393) ))		-- SA342 UHF 6
	Helios_Udp.Send("41", string.format("%.1d", mainPanelDevice:get_argument_value(394) ))		-- SA342 UHF 7
	Helios_Udp.Send("43", string.format("%.1d", mainPanelDevice:get_argument_value(395) ))		-- SA342 UHF 8
	Helios_Udp.Send("42", string.format("%.1d", mainPanelDevice:get_argument_value(396) ))		-- SA342 UHF 9
	Helios_Udp.Send("40", string.format("%.1d", mainPanelDevice:get_argument_value(397) ))		-- SA342 UHF 0
	--FM radio
	Helios_Udp.Send("484", string.format("%.1f", mainPanelDevice:get_argument_value(272)/2.5 ))	-- SA342 FM mode selector
	Helios_Udp.Send("483", string.format("%.1f", mainPanelDevice:get_argument_value(273)/1.43 ))	-- SA342 FM channels selector
	--AM radio
	Helios_Udp.Send("252", string.format("%.4f", mainPanelDevice:get_argument_value(133) ))	-- SA342 AM 1 digit > 
	Helios_Udp.Send("253", string.format("%.4f", mainPanelDevice:get_argument_value(134) ))	-- SA342 AM 2 digit > 
	Helios_Udp.Send("254", string.format("%.4f", mainPanelDevice:get_argument_value(136) ))	-- SA342 AM 3 digit > 
	Helios_Udp.Send("255", string.format("%.4f", mainPanelDevice:get_argument_value(138) ))	-- SA342 AM 1 dec digit > 
	Helios_Udp.Send("256", string.format("%.4f", mainPanelDevice:get_argument_value(139) ))	-- SA342 AM 2 dec digit >
	Helios_Udp.Send("181", string.format("%.4f", mainPanelDevice:get_argument_value(141) ))	-- SA342 AM on lamp > 
	Helios_Udp.Send("583", string.format("%.1d", mainPanelDevice:get_argument_value(130) ))	-- SA342 AM 25/50 > 	
	Helios_Udp.Send("428", string.format("%0.2f", mainPanelDevice:get_argument_value(128)/3 ))	-- SA342 selector A M SQ TEST
	--ADF
	Helios_Udp.Send("56", string.format("%1d", mainPanelDevice:get_argument_value(166) ))		-- SA342 ADF select		2
	Helios_Udp.Send("57", string.format("%1d", mainPanelDevice:get_argument_value(167) ))		-- SA342 ADF tune	2
	Helios_Udp.Send("473", string.format("%.4f", mainPanelDevice:get_argument_value(158) ))	-- SA342 ADF1 1 digit > 
	Helios_Udp.Send("474", string.format("%.4f", mainPanelDevice:get_argument_value(159) ))	-- SA342 ADF1 2 digit > 
	Helios_Udp.Send("475", string.format("%.4f", mainPanelDevice:get_argument_value(160) ))	-- SA342 ADF1 3 digit > 
	Helios_Udp.Send("476", string.format("%.4f", mainPanelDevice:get_argument_value(161) ))	-- SA342 ADF1 dec digit > 	
	Helios_Udp.Send("257", string.format("%.4f", mainPanelDevice:get_argument_value(162) ))	-- SA342 ADF2 1 digit > 
	Helios_Udp.Send("235", string.format("%.2f", mainPanelDevice:get_argument_value(163) ))	-- SA342 ADF2 2 digit > 
	Helios_Udp.Send("234", string.format("%.2f", mainPanelDevice:get_argument_value(164) ))	-- SA342 ADF2 3 digit > 
	Helios_Udp.Send("6", string.format("%.4f", mainPanelDevice:get_argument_value(165) ))		-- SA342 ADF2 dec digit > 
	Helios_Udp.Send("405", string.format("%.4f", mainPanelDevice:get_argument_value(179) ))	-- SA342 ADF gain rot >  hms bright
	--Radio alt
	Helios_Udp.Send("386", string.format("%1d", mainPanelDevice:get_argument_value(91) ))		-- Ralt on /off
	Helios_Udp.Send("119", string.format("%.4f", mainPanelDevice:get_argument_value(99) ))		-- Ralt on off flag > HSI Heading Warning Flag
	Helios_Udp.Send("114", string.format("%.4f", mainPanelDevice:get_argument_value(98) ))		-- Ralt test flag > HSI Course Warning Flag
	Helios_Udp.Send("113", string.format("%1d", mainPanelDevice:get_argument_value(100) ))		-- Ralt test > HSI button test
	--QFE
	local qfe_mil= math.floor((mainPanelDevice:get_argument_value(95)+0.05)*10)*1000
	local qfe_cent= math.floor((mainPanelDevice:get_argument_value(92)+0.05)*10)*100
	local qfe_dec= math.floor((mainPanelDevice:get_argument_value(90)+0.05)*10)*10
	local qfe_unit= math.floor((mainPanelDevice:get_argument_value(88)+0.05)*10)
	local qfe= qfe_mil+qfe_cent+qfe_dec+qfe_unit
	Helios_Udp.Send("2002", string.format("%.4f", qfe ))										-- SA342 QFE > PUI-800 Selected Station Count
	--Intercom Pilot
	Helios_Udp.Send("338", string.format("%.4f", mainPanelDevice:get_argument_value(68) ))		-- SA342 IC1 VHF >  ZMS-3 Magnetic Variation
	Helios_Udp.Send("340", string.format("%.4f", mainPanelDevice:get_argument_value(69) ))		-- SA342 IC1 UHF >  PShK-7 Latitude Entry
	Helios_Udp.Send("327", string.format("%.4f", mainPanelDevice:get_argument_value(70) ))		-- SA342 IC1 FM1 >  PVI-800 Control Panel Brightness
	-- HA nad Stby HA
	Helios_Udp.Send("128", string.format("%.4f", mainPanelDevice:get_argument_value(115) ))	-- SA342 HA rot >  HSI Lateral deviation
	Helios_Udp.Send("97", string.format("%.4f", mainPanelDevice:get_argument_value(215) ))		-- SA342 Stby HA rot  >  Accelerometer Current gs
	--Collective
	Helios_Udp.Send("382", string.format("%.1f", (mainPanelDevice:get_argument_value(105)+1)/2))  -- SA342 Landing Light Off/Vario/On > Landing Light On/Off/Retract
	Helios_Udp.Send("383", string.format("%1d", mainPanelDevice:get_argument_value(194) ))    -- SA342 flare dispenser guard > Landing Light Primary/Backup Select
	Helios_Udp.Send("402", string.format("%1d", mainPanelDevice:get_argument_value(116) ))    -- SA342 flare dispenser guard > Landing Light Primary/Backup Select
	Helios_Udp.Send("397", string.format("%1d", mainPanelDevice:get_argument_value(216) ))    -- SA342 flare dispenser guard > Landing Light Primary/Backup Select
end


-- Format: device,button number, multiplier
-- arguments with multiplier 100, 101,102 or 300 are special conversion cases, and are computed in different way

--NADIR
Helios_SA342.ExportArguments["20,3001"] = "23,3009,5"	-- NADIR_0 > PVI 0
Helios_SA342.ExportArguments["20,3002"] = "23,3010,5"	-- NADIR_1
Helios_SA342.ExportArguments["20,3003"] = "23,3011,5"	-- NADIR_2
Helios_SA342.ExportArguments["20,3004"] = "23,3012,5"	-- NADIR_3
Helios_SA342.ExportArguments["20,3005"] = "23,3013,5"	-- NADIR_4
Helios_SA342.ExportArguments["20,3006"] = "23,3014,5"	-- NADIR_5
Helios_SA342.ExportArguments["20,3007"] = "23,3015,5"	-- NADIR_6
Helios_SA342.ExportArguments["20,3008"] = "23,3016,5"	-- NADIR_7
Helios_SA342.ExportArguments["20,3009"] = "23,3017,5"	-- NADIR_8
Helios_SA342.ExportArguments["20,3010"] = "23,3018,5"	-- NADIR_9
Helios_SA342.ExportArguments["20,3011"] = "23,3004,5"	-- NADIR_ENT
Helios_SA342.ExportArguments["20,3012"] = "23,3005,5"	-- NADIR_DES
Helios_SA342.ExportArguments["20,3013"] = "23,3006,5"	-- NADIR_AUX
Helios_SA342.ExportArguments["20,3014"] = "23,3007,5"	-- NADIR_IC
Helios_SA342.ExportArguments["20,3015"] = "23,3008,5"	-- NADIR_DOWN
Helios_SA342.ExportArguments["20,3016"] = "23,3019,5"	-- NADIR_POL
Helios_SA342.ExportArguments["20,3017"] = "23,3020,5"	-- NADIR_GEO
Helios_SA342.ExportArguments["20,3018"] = "23,3021,5"	-- NADIR_POS
Helios_SA342.ExportArguments["20,3019"] = "23,3022,5"	-- NADIR_GEL
Helios_SA342.ExportArguments["20,3020"] = "23,3023,5"	-- NADIR_EFF
Helios_SA342.ExportArguments["20,3026"] = "23,3002,2"	-- NADIR mode
Helios_SA342.ExportArguments["46,3002"] = "23,3003,2"	-- NADIR parameter
--RWR
Helios_SA342.ExportArguments["20,3021"] = "24,3002,5"	-- rwr marquer
Helios_SA342.ExportArguments["20,3022"] = "24,3003,5"	-- rwr page
Helios_SA342.ExportArguments["7,3002"] = "24,3001,1"	-- rwr on/off/croc   >   HUD night/day/standby
--Main panel
Helios_SA342.ExportArguments["25,3015"] = "9,3007,3.3"	-- SA342 Source ArtVisVhfDop  >  datalink data mode
Helios_SA342.ExportArguments["20,3023"] = "2,3004,5"	-- SA342 Voltmeter Test        
Helios_SA342.ExportArguments["2,3001"] = "2,3001,1"		-- SA342 Battery	2 > dc power
Helios_SA342.ExportArguments["2,3002"] = "2,3002,1"		-- SA342 Alternator	2  > guarda dc power
Helios_SA342.ExportArguments["2,3003"] = "2,3003,1"		-- SA342 Generator	2 > batt 2
Helios_SA342.ExportArguments["2,3023"] = "2,3004,5"		-- SA342 Voltmeter Test b
Helios_SA342.ExportArguments["2,3004"] = "2,3005,1"		-- SA342 Pitot	2  > guarda batt 2
Helios_SA342.ExportArguments["2,3005"] = "2,3006,1"		-- SA342 Fuel Pump	2  > batt 1
Helios_SA342.ExportArguments["2,3006"] = "2,3007,1"		-- SA342 Additionnal Fuel Tank	2 > guarda batt 1
Helios_SA342.ExportArguments["12,3007"] = "2,3008,100"	-- SA342 Starter Start/Stop/Air	3  > weapons laser code
Helios_SA342.ExportArguments["2,3007"] = "2,3009,5"		-- SA342 Test b  >  ac gnd power
Helios_SA342.ExportArguments["12,3004"] = "2,3010,100"	-- SA342 Copilot Wiper	3 >  Weapon Burst Length
Helios_SA342.ExportArguments["22,3001"] = "2,3011,100"	-- SA342 Pilot Wiper	3 > UV_26 Release Select Switch
Helios_SA342.ExportArguments["2,3008"] = "2,3012,1"		-- SA342 space			2  >  ac left generator
Helios_SA342.ExportArguments["3,3001"] = "2,3013,5"		-- SA342 HYD Test b  >  "Fuel System", "Forward Fuel Tank Pumps"
Helios_SA342.ExportArguments["3,3002"] = "2,3014,5"		-- SA342 Alter Rearm b  >  "Fuel System", "Rear Fuel Tank Pumps"
Helios_SA342.ExportArguments["3,3003"] = "2,3015,5"		-- SA342 Gene Rearm b  >  "Fuel System", "Inner External Fuel Tank Pumps"
Helios_SA342.ExportArguments["3,3004"] = "2,3016,1"		-- SA342 Convoy Tank On/Off	2 > "Outer External Fuel Tank Pumps"
Helios_SA342.ExportArguments["3,3005"] = "2,3017,1"		-- SA342 Sand Filter On/Off	2 > "Fuel Meter power"
Helios_SA342.ExportArguments["2,3009"] = "15,3008,1"	-- SA342 Panels Lighting On/Off	2 > "AC Right Generator"
Helios_SA342.ExportArguments["3,3006"] = "7,3006,1"		-- SA342 Trim On/Off	2 > "Left Engine Fuel Shutoff Valve"
Helios_SA342.ExportArguments["3,3007"] = "7,3007,1"		-- SA342 Magnetic Brake On/Off	2 > "GUARD Left Engine Fuel Shutoff Valve"
Helios_SA342.ExportArguments["46,3005"] = "26,3001,1"	-- SA342 master arm	2 > ark22 ndb mode
--LIGHTS
Helios_SA342.ExportArguments["4,3012"] = "15,3001,100"	-- SA342 nav lights	3 >  engines start mode
Helios_SA342.ExportArguments["2,3010"] = "15,3002,100"	-- SA342 anticol lights	3 > dc ac inverter
Helios_SA342.ExportArguments["46,3004"] = "15,3011,1"	-- form light on off >  ark22 adf mode
--TV
Helios_SA342.ExportArguments["3,3008"] = "13,3001,1"	-- SA342 TV On/Off	2 > "Right Engine Fuel Shutoff Valve"
Helios_SA342.ExportArguments["7,3001"] = "13,3003,2"	-- SA342 TV brightness axis > hud brightness
Helios_SA342.ExportArguments["8,3003"] = "13,3002,2"	-- SA342 TV Contrast axis > Shkval contrast
--GYRO
Helios_SA342.ExportArguments["3,3010"] = "7,3015,1"		-- SA342 Gyro Test Switch On/Off 2 > APU Fuel Shutoff Valve
Helios_SA342.ExportArguments["3,3011"] = "7,3014,1"		-- SA342 Gyro Test Cover On/Off  2 > APU Fuel Shutoff Valve guard
Helios_SA342.ExportArguments["4,3014"] = "7,3016,101"	-- SA342 Left/Center/Right	  3 > Enginges De-icing / dust-protection system
Helios_SA342.ExportArguments["34,3007"] = "7,3017,2.5"	-- SA342 CM/A/GM/D/GD   multipos   > Windshield Wiper Switch	
--PE
Helios_SA342.ExportArguments["12,3022"] = "16,3006,1"	-- SA342 PE system M/A	 2 > weapons armed
Helios_SA342.ExportArguments["12,3005"] = "16,3001,1"	-- SA342 PE centering	 2 > weapons auto manual
Helios_SA342.ExportArguments["12,3006"] = "16,3002,1"	-- SA342 PE VDO/VTH	 2 > weapons HE/PA 
Helios_SA342.ExportArguments["6,3005"] = "16,3007,2.5"	-- SA342 PE mode	 2 > eject syst circuit selector 
Helios_SA342.ExportArguments["33,3006"] = "16,3005,1"	-- SA342 PE CTH	 3 > baro/radar alt
Helios_SA342.ExportArguments["45,3003"] = "16,3003,1"	-- SA342 PE zoom -	  3 > autopik track/heading
Helios_SA342.ExportArguments["33,3007"] = "16,3004,101"	-- SA342 PE zoom +	  3 > autopik track/heading
--PH
Helios_SA342.ExportArguments["12,3014"] = "27,3001,2.5"	-- SA342 PH cle  >  Targeting Control Mode - Weapons System Mode 431
Helios_SA342.ExportArguments["49,3001"] = "27,3002,1.25"-- SA342 PH station selection  >  r828 channel
--WP2
Helios_SA342.ExportArguments["12,3019"] = "26,3011,1"	-- SA342 weapon cover left		2 > weapons power cover
Helios_SA342.ExportArguments["12,3018"] = "26,3010,1"	-- SA342 weapon left		2	> weapons power
Helios_SA342.ExportArguments["3,3013"] = "26,3013,1"	-- SA342 weapon cover right		2 > crossfeed valve cover
Helios_SA342.ExportArguments["3,3012"] = "26,3012,1"	-- SA342 weapon right		2 > crossfeed valve
Helios_SA342.ExportArguments["12,3020"] = "26,3014,1"	-- SA342 weapon riple single	2 > weapons rate fire low hi
Helios_SA342.ExportArguments["28,3001"] = "26,3004,100"	-- SA342 weapons power	3 >  nav interface heading source
--FD
Helios_SA342.ExportArguments["56,3004"] = "25,3002,1"	-- SA342 FD seq switch 2 > stby adi power
Helios_SA342.ExportArguments["40,3005"] = "25,3001,100"	-- SA342 FD G+D	3 > fire ext work off test
Helios_SA342.ExportArguments["4,3017"] = "25,3003,100"	-- SA342 FD LE VE AR 3 > engine pwr turb test
--AUTOPILOT
Helios_SA342.ExportArguments["34,3001"] = "7,3001,1"	-- SA342 PA on off > CPT MECH gear
Helios_SA342.ExportArguments["34,3009"] = "7,3002,1"	-- SA342 PA pitch on 2 > CPT MECH pitot static
Helios_SA342.ExportArguments["34,3010"] = "7,3003,1"	-- SA342 PA roll on 2 > CPT MECH pitot ram
Helios_SA342.ExportArguments["4,3013"] = "7,3004,1"		-- SA342 PA yaw on 2 > engine rotor de icing
Helios_SA342.ExportArguments["25,3014"] = "7,3005,100"	-- SA342 PA mode 3 > datalink self id
--UHF
Helios_SA342.ExportArguments["8,3006"] = "31,3001,1.67"	-- SA342 UHF left rot >SHKVAL scan rate
Helios_SA342.ExportArguments["9,3001"] = "31,3002,1"	-- SA342 UHF drw > ABRIS button 1
Helios_SA342.ExportArguments["9,3002"] = "31,3003,1"	-- SA342 UHF vld > ABRIS button 2
Helios_SA342.ExportArguments["9,3003"] = "31,3005,1"	-- SA342 UHF conf > ABRIS button 3
Helios_SA342.ExportArguments["9,3004"] = "31,3006,1"	-- SA342 UHF 1 > ABRIS button 4
Helios_SA342.ExportArguments["9,3005"] = "31,3007,1"	-- SA342 UHF 2 > ABRIS button 5
Helios_SA342.ExportArguments["9,3007"] = "31,3008,1"	-- SA342 UHF 3 > ABRIS button 6
Helios_SA342.ExportArguments["34,3011"] = "31,3009,1"	-- SA342 UHF 4 > CPT MECH Pitot heat system test
Helios_SA342.ExportArguments["22,3004"] = "31,3010,1"	-- SA342 UHF 5 > UV26 Num of sequences
Helios_SA342.ExportArguments["22,3005"] = "31,3011,1"	-- SA342 UHF 6 > UV26 Num in sequence
Helios_SA342.ExportArguments["22,3006"] = "31,3012,1"	-- SA342 UHF 7 > UV26 Dispence interval
Helios_SA342.ExportArguments["22,3007"] = "31,3013,1"	-- SA342 UHF 8 > UV26 Start dispense
Helios_SA342.ExportArguments["22,3008"] = "31,3014,1"	-- SA342 UHF 9 > UV26 Reset to default program
Helios_SA342.ExportArguments["22,3009"] = "31,3015,1"	-- SA342 UHF 0 > UV26 Stop dispense
--FM
Helios_SA342.ExportArguments["12,3023"] = "28,3001,2.5"	--  SA342 selector > weapons ballistic seletor
Helios_SA342.ExportArguments["37,3001"] = "28,3002,1.43"--  SA342 channels > ppk atgm temp
--AM
Helios_SA342.ExportArguments["36,3002"] = "5,3003,1"	-- SA342 AM 25-50 > laser warning sys power
Helios_SA342.ExportArguments["50,3002"] = "5,3001,3"	-- SA342 AM radio A-M-SQ-TEST > spu9 source
Helios_SA342.ExportArguments["30,3001"] = "5,3004,1"	-- SA342 left freq rotary > hsi commanded course
Helios_SA342.ExportArguments["30,3002"] = "5,3002,1"	-- SA342 right freq rotary > hsi commanded heading
--ADF
Helios_SA342.ExportArguments["11,3003"] = "21,3001,1"	-- SA342 ADF select > laser-ranger
Helios_SA342.ExportArguments["11,3002"] = "21,3002,1"	-- SA342 ADF tune > laser-ranger guard
Helios_SA342.ExportArguments["8,3002"] = "21,3003,1"	-- SA342 ADF on/ant/adf/test  >  abris bright
Helios_SA342.ExportArguments["31,3001"] = "21,3007,1"	-- ADF 1 decimal rot >  adi zero pitch
Helios_SA342.ExportArguments["38,3001"] = "21,3006,1"	-- ADF 1 decenas rot >  radar altimeter
Helios_SA342.ExportArguments["56,3003"] = "21,3005,1"	-- ADF 1 centenas rot >  stby adi cage
Helios_SA342.ExportArguments["9,3006"] = "21,3010,1"	-- ADF 2 decimal rot >  abris cursor
Helios_SA342.ExportArguments["48,3007"] = "21,3009,1"	-- ADF 2 decenas rot >  r800 1 ot
Helios_SA342.ExportArguments["48,3008"] = "21,3008,1"	-- ADF 2 centenas rot >  r800 2 rot
Helios_SA342.ExportArguments["23,3001"] = "21,3004,1"	-- ADF gain rot >  hms bright
--instruments buttons
Helios_SA342.ExportArguments["11,3004"] = "17,3001,1"	-- torque test >  laser ranger reset
Helios_SA342.ExportArguments["48,3009"] = "17,3002,1"	-- torque safe % bug >  r800 3 rot
Helios_SA342.ExportArguments["13,3002"] = "18,3002,102"	-- RALT On / Off >  VMS Emergency Mode Switch
Helios_SA342.ExportArguments["30,3003"] = "18,3003,1"	-- Ralt test > HSI button test
Helios_SA342.ExportArguments["12,3003"] = "9,3002,1"	-- HA pull > PUI-800 External Stores Jettison
Helios_SA342.ExportArguments["12,3021"] = "9,3004,1"	-- stby HA pull > PUI-800 Emergency ATGM launch
--Clock
Helios_SA342.ExportArguments["4,3022"] = "20,3002,1"	-- SA342 Clock start stop > Engine Running EGT Test Button
Helios_SA342.ExportArguments["31,3003"] = "20,3003,1"	-- SA342 Clock Reset > ADI test
--Intercom
Helios_SA342.ExportArguments["59,3001"] = "4,3001,1"	-- IC1 VHF >  ZMS-3 Magnetic Variation
Helios_SA342.ExportArguments["58,3001"] = "4,3003,1"	-- IC1 UHF >  PShK-7 Latitude Entry
Helios_SA342.ExportArguments["20,3029"] = "4,3002,1"	-- IC1 FM1 >  PVI-800 Control Panel Brightness
--Collective
Helios_SA342.ExportArguments["44,3002"] = "25,3004,1"	-- SA342 flare dispenser guard > Landing Light Primary/Backup Select
Helios_SA342.ExportArguments["13,3004"] = "25,3005,1"	-- SA342 flare dispenser fire > Landing Light Primary/Backup Select
Helios_SA342.ExportArguments["44,3001"] = "15,3003,101"	--  SA342 Landing Light Off/Vario/On	3 > Landing Light", "On/Off/Retract
Helios_SA342.ExportArguments["13,3001"] = "15,3004,1"	--  SA342 Landing Light Extend	2 > VMS Cease Message
Helios_SA342.ExportArguments["13,3003"] = "15,3006,-1"	--  SA342 Landing Light Retract	2 > VMS Repeat Message
--Special case
Helios_SA342.ExportArguments["48,3010"] = "24,3005,300" -- Special case, several encoders and axis in the same KA50 encoder
