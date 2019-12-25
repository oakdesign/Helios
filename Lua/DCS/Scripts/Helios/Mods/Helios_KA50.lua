Helios_KA50 = {}

Helios_KA50.Name = "Ka-50"
Helios_KA50.FlamingCliffsAircraft = false

Helios_KA50.ExportArguments = {}

Helios_KA50.StationTypes = 
{
	["9A4172"] = "NC", 
	["S-8KOM"] = "HP", 
	["S-13"] = "HP", 
	["UPK-23-250"] = "NN", 
	["AO-2.5RT"] = "A6", 
	["PTAB-2.5KO"] = "A6",
	["FAB-250"] = "A6", 
	["FAB-500"] = "A6" 
}

Helios_KA50.Trigger = 0

function Helios_KA50.LowImportance(mainPanelDevice)
	local lWeaponSystem = GetDevice(12)
	local lEKRAN = GetDevice(10)
	local l828Radio = GetDevice(49)
	local lCannonAmmoCount = " "
	local lStationNumbers = lWeaponSystem:get_selected_weapon_stations()
	local lStationCount = " "
	local lStationType = " "	
	local lTargetingPower = mainPanelDevice:get_argument_value(433)
	local lTrigger = mainPanelDevice:get_argument_value(615)

	if lTrigger == 0 then
		Helios_KA50.Trigger = 1
	end
	if lTrigger == -1 then
		Helios_KA50.Trigger = 0
	end

	if lTargetingPower == 1 then
		lCannonAmmoCount = string.format("%02d",string.match(lWeaponSystem:get_selected_gun_ammo_count() / 10,"(%d+)"))
	
		if #lStationNumbers ~= 0 and Helios_KA50.Trigger == 0 then
			lStationCount = 0
			for i=1,#lStationNumbers do
				lStationCount = lStationCount + lWeaponSystem:get_weapon_count_on_station(lStationNumbers[i])
			end
			
			lStationCount = string.format("%02d", lStationCount);
			
			lStationType = Helios_KA50.StationTypes[lWeaponSystem:get_weapon_type_on_station(lStationNumbers[1])]
			if lStationType == nil then
				lStationType = " "
			end
		end
	end

	local lEkranText = lEKRAN:get_actual_text_frame()
	local lEkranSendString = string.sub(lEkranText,1,8).."\n"..string.sub(lEkranText,12,19).."\n"..string.sub(lEkranText,23,30).."\n"..string.sub(lEkranText,34,41) 
	
	Helios_Udp.Send("2001",lStationType)
	Helios_Udp.Send("2002",lStationCount)
	Helios_Udp.Send("2003",lCannonAmmoCount)
	Helios_Udp.Send("2004",lEkranSendString)
	Helios_Udp.Send("2017", string.format("%7.3f", l828Radio:get_frequency()/1000000))
	
	-- getting the UV26 data
    local li = Helios_Util.GetListIndicator(7)  -- 7 for UV26
	if li then
		Helios_Udp.Send("2005", string.format("%s",Helios_KA50.Check(li.txt_digits)))
		else
		Helios_Udp.Send("2005", string.format("%s","   "))
	end

   -- getting the EKRAN data
    local li = Helios_Util.GetListIndicator(4)  -- 4 for EKRAN
	if li then
        Helios_Udp.Send("2006", string.format("%s",Helios_KA50.Check(li.txt_queue)))
        Helios_Udp.Send("2007", string.format("%s",Helios_KA50.Check(li.txt_failure)))
		Helios_Udp.Send("2008", string.format("%s",Helios_KA50.Check(li.txt_memory)))
		else
		Helios_Udp.Send("2006", string.format("%s"," "))
        Helios_Udp.Send("2007", string.format("%s"," "))
		Helios_Udp.Send("2008", string.format("%s"," "))
	end

	-- getting the PVI display data
    local li = Helios_Util.GetListIndicator(5)  -- 75 for PVI
	if li then
		Helios_Udp.Send("2009", string.format("%s",Helios_KA50.Check(li.txt_VIT)))
		Helios_Udp.Send("2010", string.format("%s",Helios_KA50.Check(li.txt_VIT_apostrophe1)))
        Helios_Udp.Send("2011", string.format("%s",Helios_KA50.Check(li.txt_VIT_apostrophe2)))
		Helios_Udp.Send("2012", string.format("%s",Helios_KA50.Check(li.txt_OIT_PPM)))
		Helios_Udp.Send("2013", string.format("%s",Helios_KA50.Check(li.txt_NIT)))
		Helios_Udp.Send("2014", string.format("%s",Helios_KA50.Check(li.txt_NIT_apostrophe1)))
		Helios_Udp.Send("2015", string.format("%s",Helios_KA50.Check(li.txt_NIT_apostrophe2)))
		Helios_Udp.Send("2016", string.format("%s",Helios_KA50.Check(li.txt_OIT_NOT)))
		else
		Helios_Udp.Send("2009", string.format("%s"," "))
		Helios_Udp.Send("2010", string.format("%s"," "))
        Helios_Udp.Send("2011", string.format("%s"," "))
		Helios_Udp.Send("2012", string.format("%s"," "))
		Helios_Udp.Send("2013", string.format("%s"," "))
		Helios_Udp.Send("2014", string.format("%s"," "))
		Helios_Udp.Send("2015", string.format("%s"," "))
		Helios_Udp.Send("2016", string.format("%s"," "))
	end
	
	Helios_Udp.Flush()
end

function Helios_KA50.Check(indicator)
	if indicator == nil then
		return " "
	else
		return indicator
	end
end

Helios_KA50.HighImportanceArguments = 
{
	[44]="%0.1f", 
	[46]="%0.1f", 
	[47]="%0.1f", 
	[48]="%0.1f", 
	[78]="%0.1f", 
	[79]="%0.1f", 
	[80]="%0.1f", 
	[81]="%0.1f", 
	[82]="%0.1f", 
	[83]="%0.1f", 
	[84]="%0.1f", 
	[85]="%0.1f", 
	[86]="%0.1f", 
	[24]="%.4f", 
	[100]="%.4f", 
	[101]="%.4f", 
	[102]="%0.1f", 
	[109]="%0.1f", 
	[107]="%.4f", 
	[106]="%.4f", 
	[111]="%.4f", 
	[103]="%.4f", 
	[526]="%.4f", 
	[108]="%.4f", 
	[87]="%.4f", 
	[88]="%0.2f", 
	[89]="%.4f", 
	[112]="%.4f", 
	[118]="%.4f", 
	[124]="%.4f", 
	[115]="%.4f", 
	[119]="%0.1f", 
	[114]="%0.1f", 
	[125]="%0.1f", 
	[117]="%0.4f", 
	[527]="%0.4f", 
	[528]="%0.4f", 
	[127]="%.4f", 
	[128]="%.4f", 
	[116]="%0.1f", 
	[121]="%0.1f", 
	[53]="%.4f", 
	[52]="%.4f", 
	[94]="%.4f", 
	[93]="%.4f", 
	[95]="%0.1f", 
	[92]="%0.1f", 
	[51]="%.4f", 
	[97]="%0.2f", 
	[98]="%0.2f", 
	[99]="%0.2f", 
	[68]="%.4f", 
	[69]="%.4f", 
	[70]="%.4f", 
	[75]="%0.1f", 
	[72]="%.4f", 
	[531]="%.4f", 
	[73]="%.4f", 
	[532]="%.4f", 
	[142]="%.4f", 
	[143]="%.4f", 
	[144]="%.4f", 
	[145]="%0.1f", 
	[133]="%.4f", 
	[134]="%.4f", 
	[135]="%.4f", 
	[136]="%.4f", 
	[138]="%.4f", 
	[137]="%.4f", 
	[139]="%0.1f", 
	[140]="%0.1f", 
	[392]="%0.1f", 
	[393]="%0.1f", 
	[394]="%0.1f", 
	[395]="%0.1f", 
	[388]="%0.1f", 
	[389]="%0.1f", 
	[390]="%0.1f", 
	[391]="%0.1f", 
	[63]="%0.1f", 
	[64]="%0.1f", 
	[61]="%0.1f", 
	[62]="%0.1f", 
	[59]="%0.1f", 
	[60]="%0.1f", 
	[170]="%0.1f", 
	[175]="%0.1f", 
	[172]="%0.1f", 
	[165]="%0.1f", 
	[171]="%0.1f", 
	[176]="%0.1f", 
	[166]="%0.1f", 
	[164]="%0.1f", 
	[178]="%0.1f", 
	[173]="%0.1f", 
	[177]="%0.1f", 
	[211]="%0.1f", 
	[187]="%0.1f", 
	[204]="%0.1f", 
	[213]="%0.1f", 
	[11]="%.4f", 
	[12]="%.4f", 
	[14]="%.4f", 
	[167]="%0.1f", 
	[180]="%0.1f", 
	[179]="%0.1f", 
	[188]="%0.1f", 
	[189]="%0.1f", 
	[206]="%0.1f", 
	[212]="%0.1f", 
	[205]="%0.1f", 
	[181]="%0.1f", 
	[190]="%0.1f", 
	[207]="%0.1f", 
	[183]="%0.1f", 
	[182]="%0.1f", 
	[191]="%0.1f", 
	[208]="%0.1f", 
	[184]="%0.1f", 
	[200]="%0.1f", 
	[209]="%0.1f", 
	[185]="%0.1f", 
	[202]="%0.1f", 
	[201]="%0.1f", 
	[210]="%0.1f", 
	[186]="%0.1f", 
	[203]="%0.1f", 
	[159]="%0.1f", 
	[150]="%0.1f", 
	[161]="%0.1f", 
	[15]="%0.1f", 
	[16]="%0.1f", 
	[17]="%0.1f", 
	[18]="%0.1f", 
	[19]="%0.1f", 
	[20]="%0.1f", 
	[21]="%0.1f", 
	[22]="%0.1f", 
	[23]="%0.1f", 
	[50]="%0.1f", 
	[25]="%0.1f", 
	[28]="%0.1f", 
	[26]="%0.1f", 
	[27]="%0.1f", 
	[31]="%0.1f", 
	[32]="%0.1f", 
	[33]="%0.1f", 
	[34]="%0.1f", 
	[582]="%0.1f", 
	[541]="%0.1f", 
	[542]="%0.1f", 
	[315]="%0.1f", 
	[519]="%0.1f", 
	[316]="%0.1f", 
	[520]="%0.1f", 
	[317]="%0.1f", 
	[521]="%0.1f", 
	[318]="%0.1f", 
	[313]="%0.1f", 
	[314]="%0.1f", 
	[522]="%0.1f", 
	[319]="%0.1f", 
	[320]="%0.1f", 
	[321]="%0.1f", 
	[322]="%0.1f", 
	[323]="%0.1f", 
	[330]="%0.1f", 
	[332]="%0.1f", 
	[331]="%0.1f", 
	[333]="%0.1f", 
	[334]="%0.1f", 
	[375]="%0.1f", 
	[419]="%0.1f", 
	[577]="%.3f", 
	[574]="%.2f", 
	[575]="%.2f", 
	[576]="%.2f", 
	[437]="%0.1f", 
	[438]="%0.1f", 
	[439]="%0.1f", 
	[440]="%0.1f", 
	[441]="%0.1f", 
	[163]="%0.1f", 
	[162]="%0.1f", 
	[168]="%0.1f", 
	[169]="%0.1f", 
	[174]="%0.1f", 
	[6]="%.4f", 
	[586]="%0.1f", 
	[261]="%0.1f", 
	[461]="%0.1f", 
	[237]="%0.1f", 
	[239]="%0.1f", 
	[568]="%0.1f", 
	[241]="%0.1f", 
	[243]="%0.1f", 
	[244]="%0.1f", 
	[245]="%0.1f", 
	[592]="%.4f", 
	[234]="%0.2f", 
	[235]="%0.2f", 
	[252]="%.4f", 
	[253]="%.4f", 
	[254]="%.4f", 
	[255]="%.4f", 
	[256]="%.4f", 
	[257]="%.4f", 
	[469]="%0.1f", 
	[470]="%0.1f", 
	[471]="%.4f", 
	[472]="%.4f", 
	[473]="%.4f", 
	[474]="%.4f", 
	[475]="%.4f", 
	[476]="%.4f", 
	[342]="%0.1f", 
	[339]="%0.4f", 
	[594]="%0.4f", 
	[337]="%0.4f", 
	[596]="%0.4f"
}

Helios_KA50.LowImportanceArguments = 
{
	[110]="%.1f", 
	[113]="%.1f", 
	[54]="%1d", 
	[56]="%1d", 
	[57]="%1d", 
	[55]="%.1f", 
	[96]="%.1f", 
	[572]="%.1f", 
	[45]="%.1f", 
	[230]="%1d", 
	[131]="%.1f", 
	[132]="%.1f", 
	[616]="%.1f", 
	[512]="%.1f", 
	[513]="%.1f", 
	[514]="%.1f", 
	[515]="%.1f", 
	[516]="%.1f", 
	[523]="%.1f", 
	[517]="%.3f", 
	[130]="%0.1f", 
	[8]="%.3f", 
	[9]="%1d", 
	[7]="%.1f", 
	[510]="%0.1f", 
	[387]="%1d", 
	[402]="%.1f", 
	[396]="%1d", 
	[403]="%1d", 
	[399]="%1d", 
	[400]="%0.1f", 
	[398]="%1d", 
	[397]="%.1f", 
	[404]="%1d", 
	[406]="%.3f", 
	[407]="%.3f", 
	[405]="%.3f", 
	[408]="%0.1f", 
	[409]="%1d", 
	[382]="%0.1f", 
	[383]="%1d", 
	[381]="%0.2f", 
	[384]="%.1f", 
	[385]="%.1f", 
	[386]="%0.1f", 
	[442]="%.1f", 
	[65]="%1d", 
	[66]="%1d", 
	[67]="%1d", 
	[146]="%0.1f", 
	[147]="%0.1f", 
	[539]="%1d", 
	[151]="%1d", 
	[153]="%1d", 
	[154]="%0.1f", 
	[156]="%.1f", 
	[35]="%.1f", 
	[583]="%1d", 
	[584]="%.1f", 
	[36]="%0.1f", 
	[37]="%0.1f", 
	[38]="%.1f", 
	[39]="%.1f", 
	[41]="%.1f", 
	[43]="%.1f", 
	[42]="%.1f", 
	[40]="%.1f", 
	[496]="%1d", 
	[497]="%1d", 
	[498]="%1d", 
	[499]="%1d", 
	[312]="%0.1f", 
	[303]="%0.1f", 
	[304]="%0.1f", 
	[305]="%0.1f", 
	[306]="%0.1f", 
	[307]="%0.1f", 
	[308]="%0.1f", 
	[309]="%0.1f", 
	[310]="%0.1f", 
	[311]="%0.1f", 
	[324]="%0.1f", 
	[325]="%1d", 
	[326]="%1d", 
	[327]="%.3f", 
	[328]="%0.1f", 
	[329]="%0.1f", 
	[335]="%0.1f", 
	[336]="%0.1f", 
	[355]="%.1f", 
	[354]="%1d", 
	[353]="%.3f", 
	[356]="%1d", 
	[357]="%0.1f", 
	[371]="%0.1f", 
	[372]="%.3f", 
	[373]="%.1f", 
	[374]="%1d", 
	[376]="%.1f", 
	[377]="%.1f", 
	[378]="%.1f", 
	[379]="%.1f", 
	[380]="%1d", 
	[418]="%.1f", 
	[417]="%1d", 
	[421]="%1d", 
	[422]="%1d", 
	[420]="%1d", 
	[423]="%1d", 
	[432]="%1d", 
	[431]="%0.1f", 
	[436]="%1d", 
	[433]="%1d", 
	[435]="%1d", 
	[434]="%1d", 
	[412]="%.1f", 
	[413]="%.1f", 
	[414]="%.1f", 
	[415]="%0.1f", 
	[416]="%0.1f", 
	[428]="%0.2f", 
	[554]="%1d", 
	[555]="%1d", 
	[556]="%1d", 
	[301]="%0.1f", 
	[224]="%.1f", 
	[262]="%1d", 
	[263]="%1d", 
	[543]="%1d", 
	[544]="%1d", 
	[264]="%1d", 
	[265]="%1d", 
	[267]="%1d", 
	[268]="%1d", 
	[269]="%1d", 
	[270]="%0.1f", 
	[271]="%1d", 
	[272]="%1d", 
	[273]="%1d", 
	[274]="%1d", 
	[275]="%1d", 
	[276]="%1d", 
	[277]="%1d", 
	[278]="%1d", 
	[279]="%1d", 
	[280]="%1d", 
	[281]="%1d", 
	[282]="%1d", 
	[283]="%1d", 
	[284]="%1d", 
	[285]="%1d", 
	[286]="%1d", 
	[287]="%1d", 
	[288]="%1d", 
	[289]="%1d", 
	[547]="%1d", 
	[548]="%1d", 
	[214]="%1d", 
	[215]="%1d", 
	[216]="%1d", 
	[217]="%1d", 
	[462]="%0.1f", 
	[460]="%.1f", 
	[220]="%1d", 
	[221]="%1d", 
	[218]="%1d", 
	[219]="%1d", 
	[222]="%1d", 
	[229]="%0.1f", 
	[228]="%1d", 
	[296]="%1d", 
	[297]="%0.1f", 
	[290]="%1d", 
	[291]="%1d", 
	[292]="%1d", 
	[293]="%1d", 
	[294]="%1d", 
	[569]="%1d", 
	[295]="%0.1f", 
	[570]="%0.1f", 
	[457]="%.1f", 
	[458]="%.1f", 
	[459]="%.1f", 
	[300]="%1d", 
	[299]="%1d", 
	[298]="%1d", 
	[236]="%.1f", 
	[238]="%.1f", 
	[240]="%.1f", 
	[242]="%.1f", 
	[248]="%0.1f", 
	[249]="%0.1f", 
	[250]="%1d", 
	[246]="%1d", 
	[247]="%1d", 
	[258]="%0.1f", 
	[259]="%1d", 
	[483]="%0.1f", 
	[484]="%0.1f", 
	[485]="%1d", 
	[486]="%1d", 
	[489]="%.1f", 
	[490]="%1d", 
	[491]="%1d", 
	[492]="%1d", 
	[487]="%1d", 
	[488]="%1d", 
	[452]="%1d", 
	[453]="%1d", 
	[340]="%.3f", 
	[341]="%1d", 
	[338]="%.3f",
	[450]="%1d", 	-- added by capt zeen to ka50 interface
	[90]="%0.2f",	-- added by capt zeen to ka50 interface
	[451]="%0.2f",	-- added by capt zeen to ka50 interface
	[507]="%0.2f",	-- added by capt zeen to ka50 interface
	[593]="%0.2f",	-- added by capt zeen to ka50 interface
	[508]="%0.2f", 	-- added by capt zeen to ka50 interface
	[587]="%0.2f", 	-- added by capt zeen to ka50 interface
	[599]="%0.2f", 	-- added by capt zeen to ka50 interface
	[613]="%0.2f", 	-- added by capt zeen to ka50 interface
	[1001]="%.1f" 	-- added by capt zeen to ka50 interface
}
