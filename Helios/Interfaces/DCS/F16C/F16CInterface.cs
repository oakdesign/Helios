//  Copyright 2014 Craig Courtney
//    
//  Helios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Helios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

namespace GadrocsWorkshop.Helios.Interfaces.DCS.F16C
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using GadrocsWorkshop.Helios.Interfaces.DCS.F16C.Functions;
    using GadrocsWorkshop.Helios.Interfaces.DCS.F16C;
    using GadrocsWorkshop.Helios.Interfaces.DCS.Common;
    using GadrocsWorkshop.Helios.UDPInterface;
    using Microsoft.Win32;
    using System;

    [HeliosInterface("Helios.F16C", "DCS F-16C", typeof(F16CInterfaceEditor), typeof(UniqueHeliosInterfaceFactory))]
    public class F16CInterface : BaseUDPInterface
    {
        private string _dcsPath;

        private bool _phantomFix;
        private int _phantomLeft;
        private int _phantomTop;

        private long _nextCheck = 0;

        #region Devices
        //  From devices.lua - DCS seem to want this to remain constant which is great 
        private const string FM_PROXY = "1";
        private const string CONTROL_INTERFACE = "2";
        private const string ELEC_INTERFACE = "3";
        private const string FUEL_INTERFACE = "4";
        private const string HYDRO_INTERFACE = "5";
        private const string ENGINE_INTERFACE = "6";
        private const string GEAR_INTERFACE = "7";
        private const string OXYGEN_INTERFACE = "8";
        private const string HEARING_SENS = "9";
        private const string CPT_MECH = "10";
        private const string EXTLIGHTS_SYSTEM = "11";
        private const string CPTLIGHTS_SYSTEM = "12";
        private const string ECS_INTERFACE = "13";
        private const string INS = "14";
        private const string RALT = "15";
        private const string HOTAS = "16";
        private const string UFC = "17";
        private const string MUX = "18";
        private const string MMC = "19";
        private const string CADC = "20";
        private const string FLCC = "21";
        private const string SMS = "22";
        private const string HUD = "23";
        private const string MFD_LEFT = "24";
        private const string MFD_RIGHT = "25";
        private const string DED = "26";
        private const string PFLD = "27";
        private const string EHSI = "28";
        private const string NVG = "29";
        private const string HMCS = "30";
        private const string FCR = "31";
        private const string CMDS = "32";
        private const string RWR = "33";
        private const string IFF = "34";
        private const string IFF_CONTROL_PANEL = "35";
        private const string UHF_RADIO = "36";
        private const string UHF_CONTROL_PANEL = "37";
        private const string VHF_RADIO = "38";
        private const string INTERCOM = "39";
        private const string MIDS_RT = "40";
        private const string MIDS = "41";
        private const string KY58 = "42";
        private const string ILS = "43";
        private const string AOA_INDICATOR = "44";
        private const string AAU34 = "45";
        private const string AMI = "46";
        private const string SAI = "47";
        private const string VVI = "48";
        private const string STANDBY_COMPASS = "49";
        private const string ADI = "50";
        private const string CLOCK = "51";
        private const string MACROS = "52";
        private const string AIHelper = "53";
        private const string KNEEBOARD = "54";
        private const string ARCADE = "55";
        private const string TACAN_CTRL_PANEL = "56";
        private const string SIDEWINDER_INTERFACE = "57";
        private const string TGP_INTERFACE = "58";
        private const string HMD = "59";
        #endregion

        public F16CInterface()
            : base("DCS F-16C")
        {
            DCSConfigurator config = new DCSConfigurator("DCS F-16C", DCSPath);
            config.ExportConfigPath = "Scripts";
            config.ExportFunctionsPath = "pack://application:,,,/Helios;component/Interfaces/DCS/F16C/ExportFunctions.lua";
            Port = config.Port;
            _phantomFix = config.PhantomFix;
            _phantomLeft = config.PhantomFixLeft;
            _phantomTop = config.PhantomFixTop;

            #region  Indicators
            #region  Caution Light Panel
            AddFunction(new FlagValue(this, "630", "Caution Lights", "FLCS Fault", ""));             //    630, CautionLights.FLCS_FAULT)
            AddFunction(new FlagValue(this, "631", "Caution Lights", "Engine Fault", ""));               //    631, CautionLights.ENGINE_FAULT)
            AddFunction(new FlagValue(this, "632", "Caution Lights", "Avionics Fault", ""));             //    632, CautionLights.AVIONICS_FAULT)
            AddFunction(new FlagValue(this, "633", "Caution Lights", "Seat Not Armed", ""));             //    633, CautionLights.SEAT_NOT_ARMED)
            AddFunction(new FlagValue(this, "634", "Caution Lights", "Elec Sys", ""));               //    634, CautionLights.ELEC_SYS)
            AddFunction(new FlagValue(this, "635", "Caution Lights", "Sec", ""));                //    635, CautionLights.SEC)
            AddFunction(new FlagValue(this, "636", "Caution Lights", "Equip Hot", ""));              //    636, CautionLights.EQUIP_HOT)
            AddFunction(new FlagValue(this, "637", "Caution Lights", "NWS Fail", ""));               //    637, CautionLights.NWS_FAIL)
            AddFunction(new FlagValue(this, "638", "Caution Lights", "Probe Heat", ""));             //    638, CautionLights.PROBE_HEAT)
            AddFunction(new FlagValue(this, "639", "Caution Lights", "Fuel Oil Hot", ""));               //    639, CautionLights.FUEL_OIL_HOT)
            AddFunction(new FlagValue(this, "640", "Caution Lights", "Radar Alt", ""));              //    640, CautionLights.RADAR_ALT)
            AddFunction(new FlagValue(this, "641", "Caution Lights", "Anti Skid", ""));              //    641, CautionLights.ANTI_SKID)
            AddFunction(new FlagValue(this, "642", "Caution Lights", "CADC", ""));               //    642, CautionLights.CADC)
            AddFunction(new FlagValue(this, "643", "Caution Lights", "Inlet Icing", ""));                //    643, CautionLights.INLET_ICING)
            AddFunction(new FlagValue(this, "644", "Caution Lights", "IFF", ""));                //    644, CautionLights.IFF)
            AddFunction(new FlagValue(this, "645", "Caution Lights", "Hook", ""));               //    645, CautionLights.HOOK)
            AddFunction(new FlagValue(this, "646", "Caution Lights", "Stores Config", ""));              //    646, CautionLights.STORES_CONFIG)
            AddFunction(new FlagValue(this, "647", "Caution Lights", "Overheat", ""));               //    647, CautionLights.OVERHEAT)
            AddFunction(new FlagValue(this, "648", "Caution Lights", "Nuclear", ""));                //    648, CautionLights.NUCLEAR)
            AddFunction(new FlagValue(this, "649", "Caution Lights", "OBOGS", ""));              //    649, CautionLights.OBOGS)
            AddFunction(new FlagValue(this, "650", "Caution Lights", "ATF Not Engaged", ""));                //    650, CautionLights.ATF_NOT_ENGAGED)
            AddFunction(new FlagValue(this, "651", "Caution Lights", "EEC", ""));                //    651, CautionLights.EEC)
            AddFunction(new FlagValue(this, "652", "Caution Lights", "Lights Max", ""));             //    652, CautionLights.LIGHTS_MAX)
            AddFunction(new FlagValue(this, "653", "Caution Lights", "Cabin Press", ""));                //    653, CautionLights.CABIN_PRESS)
            AddFunction(new FlagValue(this, "654", "Caution Lights", "Fwd Fuel Low", ""));               //    654, CautionLights.FWD_FUEL_LOW)
            AddFunction(new FlagValue(this, "655", "Caution Lights", "BUC", ""));                //    655, CautionLights.BUC)
            AddFunction(new FlagValue(this, "656", "Caution Lights", "Lights Max 1", ""));             //    656, CautionLights.LIGHTS_MAX)
            AddFunction(new FlagValue(this, "657", "Caution Lights", "Lights Max 2", ""));             //    657, CautionLights.LIGHTS_MAX)
            AddFunction(new FlagValue(this, "658", "Caution Lights", "Aft Fuel Low", ""));               //    658, CautionLights.AFT_FUEL_LOW)
            AddFunction(new FlagValue(this, "659", "Caution Lights", "Lights Max 3", ""));             //    659, CautionLights.LIGHTS_MAX)
            AddFunction(new FlagValue(this, "660", "Caution Lights", "Lights Max 4", ""));             //    660, CautionLights.LIGHTS_MAX)
            AddFunction(new FlagValue(this, "661", "Caution Lights", "Lights Max 5", ""));             //    661, CautionLights.LIGHTS_MAX)
            #endregion
            #region  Edge of glareshield
            AddFunction(new FlagValue(this, "117", "Caution Lights", "Master Caution", ""));             //    117, CautionLights.MASTER_CAUTION)
            AddFunction(new FlagValue(this, "121", "Caution Lights", "TF Fail", ""));                //    121, CautionLights.TF_FAIL)
            AddFunction(new FlagValue(this, "126", "Caution Lights", "Eng Fire", ""));               //    126, CautionLights.ENG_FIRE)
            AddFunction(new FlagValue(this, "127", "Caution Lights", "Engine", ""));             //    127, CautionLights.ENGINE)
            AddFunction(new FlagValue(this, "129", "Caution Lights", "Hyd Oil Press", ""));              //    129, CautionLights.HYD_OIL_PRESS)
            AddFunction(new FlagValue(this, "130", "Caution Lights", "FLCS", ""));               //    130, CautionLights.FLCS)
            AddFunction(new FlagValue(this, "131", "Caution Lights", "Dbu On", ""));             //    131, CautionLights.DBU_ON)
            AddFunction(new FlagValue(this, "133", "Caution Lights", "TO Ldg Config", ""));              //    133, CautionLights.TO_LDG_CONFIG)
            AddFunction(new FlagValue(this, "134", "Caution Lights", "Canopy", ""));             //    134, CautionLights.CANOPY)
            AddFunction(new FlagValue(this, "135", "Caution Lights", "Oxy Low", ""));                //    135, CautionLights.OXY_LOW)
            #endregion
            #region  AOA Indexer
            AddFunction(new FlagValue(this, "110", "Caution Lights", "AoA Red", ""));                //    110, CautionLights.AOA_RED)
            AddFunction(new FlagValue(this, "111", "Caution Lights", "AoA Green", ""));              //    111, CautionLights.AOA_GREEN)
            AddFunction(new FlagValue(this, "112", "Caution Lights", "AoA Yellow", ""));             //    112, CautionLights.AOA_YELLOW)
            #endregion
            #region  LG Control Panel
            AddFunction(new FlagValue(this, "350", "Caution Lights", "Gear Nose", ""));              //    350, CautionLights.GEAR_NOSE)
            AddFunction(new FlagValue(this, "351", "Caution Lights", "Gear Left", ""));              //    351, CautionLights.GEAR_LEFT)
            AddFunction(new FlagValue(this, "352", "Caution Lights", "Gear Right", ""));             //    352, CautionLights.GEAR_RIGHT)
            AddFunction(new FlagValue(this, "369", "Caution Lights", "Gear Warning", ""));               //    369, CautionLights.GEAR_WARNING)
            #endregion
            #region  AR Status/NWS Indicator
            AddFunction(new FlagValue(this, "113", "Caution Lights", "Rdy", ""));                //    113, CautionLights.RDY)
            AddFunction(new FlagValue(this, "114", "Caution Lights", "AR NWS", ""));             //    114, CautionLights.AR_NWS)
            AddFunction(new FlagValue(this, "115", "Caution Lights", "Disc", ""));               //    115, CautionLights.DISC)
            #endregion
            #region 
            AddFunction(new FlagValue(this, "157", "Caution Lights", "Marker Beacon", ""));              //    157, CautionLights.MARKER_BEACON)
            #endregion
            #region  Eng Control Panel
            AddFunction(new FlagValue(this, "446", "Caution Lights", "JFS Run", ""));                //    446, CautionLights.JFS_RUN)
            #endregion
            #region  EPU Control Panel
            AddFunction(new FlagValue(this, "524", "Caution Lights", "Hydrazn", ""));                //    524, CautionLights.HYDRAZN)
            AddFunction(new FlagValue(this, "523", "Caution Lights", "Air", ""));                //    523, CautionLights.AIR)
            AddFunction(new FlagValue(this, "526", "Caution Lights", "EPU", ""));                //    526, CautionLights.EPU)
            #endregion
            #region  Elec Control Panel
            AddFunction(new FlagValue(this, "513", "Caution Lights", "FLCS PMG", ""));               //    513, CautionLights.FLCS_PMG)
            AddFunction(new FlagValue(this, "512", "Caution Lights", "Main Gen", ""));               //    512, CautionLights.MAIN_GEN)
            AddFunction(new FlagValue(this, "515", "Caution Lights", "Stby Gen", ""));               //    515, CautionLights.STBY_GEN)
            AddFunction(new FlagValue(this, "517", "Caution Lights", "EPU Gen", ""));                //    517, CautionLights.EPU_GEN)
            AddFunction(new FlagValue(this, "516", "Caution Lights", "EPU PMG", ""));                //    516, CautionLights.EPU_PMG)
            AddFunction(new FlagValue(this, "519", "Caution Lights", "TO FLCS", ""));                //    519, CautionLights.TO_FLCS)
            AddFunction(new FlagValue(this, "518", "Caution Lights", "FLCS Rly", ""));               //    518, CautionLights.FLCS_RLY)
            AddFunction(new FlagValue(this, "521", "Caution Lights", "ACFT Batt Fail", ""));             //    521, CautionLights.ACFT_BATT_FAIL)
            #endregion
            #region  Advance Mode Switch
            AddFunction(new FlagValue(this, "106", "Caution Lights", "Active", ""));             //    106, CautionLights.ACTIVE)
            AddFunction(new FlagValue(this, "107", "Caution Lights", "Stby", ""));               //    107, CautionLights.STBY)
            #endregion
            #region  FLCP
            AddFunction(new FlagValue(this, "570", "Caution Lights", "FL Run", ""));             //    570, CautionLights.FL_RUN)
            AddFunction(new FlagValue(this, "571", "Caution Lights", "FL Fail", ""));                //    571, CautionLights.FL_FAIL)
            #endregion
            #region  Test Switch Panel
            AddFunction(new FlagValue(this, "581", "Caution Lights", "FLCS Pwr A", ""));             //    581, CautionLights.FLCS_PWR_A)
            AddFunction(new FlagValue(this, "582", "Caution Lights", "FLCS Pwr B", ""));             //    582, CautionLights.FLCS_PWR_B)
            AddFunction(new FlagValue(this, "583", "Caution Lights", "FLCS Pwr C", ""));             //    583, CautionLights.FLCS_PWR_C)
            AddFunction(new FlagValue(this, "584", "Caution Lights", "FLCS Pwr D", ""));             //    584, CautionLights.FLCS_PWR_D)
            AddFunction(new FlagValue(this, "396", "RWR Lights", "Search", ""));             //    396, RWRLights.SEARCH)
            AddFunction(new FlagValue(this, "398", "RWR Lights", "Activity", ""));               //    398, RWRLights.ACTIVITY)
            AddFunction(new FlagValue(this, "423", "RWR Lights", "Act Power", ""));              //    423, RWRLights.ACT_POWER)
            AddFunction(new FlagValue(this, "400", "RWR Lights", "Alt Low", ""));                //    400, RWRLights.ALT_LOW)
            AddFunction(new FlagValue(this, "424", "RWR Lights", "Alt", ""));                //    424, RWRLights.ALT)
            AddFunction(new FlagValue(this, "402", "RWR Lights", "Power", ""));              //    402, RWRLights.POWER)
            AddFunction(new FlagValue(this, "142", "RWR Lights", "Handoff Up", ""));             //    142, RWRLights.HANDOFF_UP)
            AddFunction(new FlagValue(this, "136", "RWR Lights", "Handoff H", ""));              //    136, RWRLights.HANDOFF_H)
            AddFunction(new FlagValue(this, "144", "RWR Lights", "Msl Launch", ""));             //    144, RWRLights.MSL_LAUNCH)
            AddFunction(new FlagValue(this, "146", "RWR Lights", "Mode Pri", ""));               //    146, RWRLights.MODE_PRI)
            AddFunction(new FlagValue(this, "137", "RWR Lights", "Mode Open", ""));              //    137, RWRLights.MODE_OPEN)
            #endregion
            #region rwr_Ship_U			= create_rwr_lights(148, RWRLights.SHIP_U)
            AddFunction(new FlagValue(this, "148", "RWR Lights", "Ship Unknown", ""));               //    148, RWRLights.SHIP_UNKNOWN)
            #endregion
            #region rwr_Sys_On			= create_rwr_lights(150, RWRLights.SYSTEST_ON)
            AddFunction(new FlagValue(this, "150", "RWR Lights", "Systest", ""));                //    150, RWRLights.SYSTEST)
            AddFunction(new FlagValue(this, "152", "RWR Lights", "Tgtsep Up", ""));              //    152, RWRLights.TGTSEP_UP)
            AddFunction(new FlagValue(this, "138", "RWR Lights", "Tgtsep Down", ""));                //    138, RWRLights.TGTSEP_DOWN)
            #endregion
            #region  Brightness 792
            AddFunction(new FlagValue(this, "792", "Controllers", "Brtrwrlights", ""));             //    792, Controllers.brtRwrLights)
            AddFunction(new FlagValue(this, "370", "Cmds Lights", "No Go", ""));             //    370, CmdsLights.NO_GO)
            AddFunction(new FlagValue(this, "372", "Cmds Lights", "Go", ""));                //    372, CmdsLights.GO)
            AddFunction(new FlagValue(this, "376", "Cmds Lights", "Disp", ""));              //    376, CmdsLights.DISP)
            AddFunction(new FlagValue(this, "379", "Cmds Lights", "Rdy", ""));               //    379, CmdsLights.RDY)
            AddFunction(new FlagValue(this, "788", "Internal Lights", "Consoles Lt", ""));               //    788, InternalLights.Consoles_lt)
            AddFunction(new FlagValue(this, "787", "Internal Lights", "Instpnl Lt", ""));                //    787, InternalLights.InstPnl_lt)
            AddFunction(new FlagValue(this, "790", "Internal Lights", "Consolesflood Lt", ""));              //    790, InternalLights.ConsolesFlood_lt)
            AddFunction(new FlagValue(this, "791", "Internal Lights", "Instpnlflood Lt", ""));               //    791, InternalLights.InstPnlFlood_lt)
            AddFunction(new FlagValue(this, "793", "Controllers", "Brightnesswci", ""));                //    793, Controllers.BrightnessWCI)
            #endregion
            #endregion

            #region Control Interface
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "566", "CONTROL INTERFACE","DIGITAL BACKUP Switch, OFF/BACKUP",%%));    		    //     default_2_position_tumb(_("DIGITAL BACKUP Switch, OFF/BACKUP"),devices.CONTROL_INTERFACE, control_commands.DigitalBackup,566)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "567", "CONTROL INTERFACE","ALT FLAPS Switch, NORM/EXTEND",%%));    		    //     default_2_position_tumb(_("ALT FLAPS Switch, NORM/EXTEND"),devices.CONTROL_INTERFACE, control_commands.AltFlaps,567)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "574", "CONTROL INTERFACE","BIT Switch, OFF/BIT",%%));    		    //     springloaded_2_pos_tumb(_("BIT Switch, OFF/BIT"),devices.CONTROL_INTERFACE, control_commands.BitSw,574)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "573", "CONTROL INTERFACE","FLCS RESET Switch, OFF/RESET",%%));    		    //     springloaded_2_pos_tumb_small(_("FLCS RESET Switch, OFF/RESET"),devices.CONTROL_INTERFACE, control_commands.FLCSReset,573)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "572", "CONTROL INTERFACE","LE FLAPS Switch, AUTO/LOCK",%%));    		    //     default_2_position_tumb(_("LE FLAPS Switch, AUTO/LOCK"),devices.CONTROL_INTERFACE, control_commands.LeFlaps,572)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "564", "CONTROL INTERFACE","TRIM/AP DISC Switch, DISC/NORM",%%));    		    //     default_2_position_tumb(_("TRIM/AP DISC Switch, DISC/NORM"),devices.CONTROL_INTERFACE, control_commands.TrimApDisc,564)
            // 	AddFunction( axis(this, CONTROL_INTERFACE, "", " NOT_RELATIV", "CONTROL INTERFACE","ROLL TRIM Wheel",%%));    		    //     default_axis_limited(_("ROLL TRIM Wheel"),devices.CONTROL_INTERFACE, control_commands.RollTrim,560, 0.0, 0.1, NOT_UPDATABLE, NOT_RELATIV
            // 	AddFunction( axis(this, CONTROL_INTERFACE, "", " NOT_RELA", "CONTROL INTERFACE","PITCH TRIM Wheel",%%));    		    //     default_axis_limited(_("PITCH TRIM Wheel"),devices.CONTROL_INTERFACE, control_commands.PitchTrim,562, 0.0, 0.1, NOT_UPDATABLE, NOT_RELA
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "425", "CONTROL INTERFACE","MANUAL PITCH Override Switch, OVRD/NORM",%%));    		    //     springloaded_2_pos_tumb_small(_("MANUAL PITCH Override Switch, OVRD/NORM"),devices.CONTROL_INTERFACE, control_commands.ManualPitchOverride,425)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "358", "CONTROL INTERFACE","STORES CONFIG Switch, CAT III/CAT I",%%));    		    //     default_2_position_tumb_small(_("STORES CONFIG Switch, CAT III/CAT I"),devices.CONTROL_INTERFACE, control_commands.StoresConfig,358)
            // 	AddFunction( 3pos(this, CONTROL_INTERFACE, "", " control_comma", "CONTROL INTERFACE","Autopilot PITCH Switch, ATT HOLD/ A/P OFF/ ALT HOLD",%%));    		    //     springloaded_3_pos_tumb(_("Autopilot PITCH Switch, ATT HOLD/ A/P OFF/ ALT HOLD"),devices.CONTROL_INTERFACE, control_commands.ApPitchAtt, control_comma
            // 	AddFunction( 3position(this, CONTROL_INTERFACE, "", "108", "CONTROL INTERFACE","Autopilot ROLL Switch, STRG SEL/ATT HOLD/HDG SEL",%%));    		    //     default_3_position_tumb_small(_("Autopilot ROLL Switch, STRG SEL/ATT HOLD/HDG SEL"),devices.CONTROL_INTERFACE, control_commands.ApRoll,108)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "97", "CONTROL INTERFACE","ADV MODE Switch",%%));    		    //     default_2_position_tumb(_("ADV MODE Switch"),devices.CONTROL_INTERFACE, control_commands.AdvMode,97)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CONTROL_INTERFACE, "", "568", "CONTROL INTERFACE","MANUAL TF FLYUP Switch, ENABLE/DISABLE",%%));    		    //     default_2_position_tumb(_("MANUAL TF FLYUP Switch, ENABLE/DISABLE"),devices.CONTROL_INTERFACE, control_commands.ManualTfFlyup,568)
            #endregion
            #region External Lights
            // 	AddFunction( Switch.CreateToggleSwitch(this, EXTLIGHTS_SYSTEM, "", "532", "EXTLIGHTS SYSTEM","FLASH STEADY Switch, FLASH/STEADY",%%));    		    //     default_2_position_tumb_small(_("FLASH STEADY Switch, FLASH/STEADY"),devices.EXTLIGHTS_SYSTEM, extlights_commands.PosFlash,532)
            // 	AddFunction( 3position(this, EXTLIGHTS_SYSTEM, "", "533", "EXTLIGHTS SYSTEM","WING/TAIL Switch, BRT/OFF/DIM",%%));    		    //     default_3_position_tumb_small(_("WING/TAIL Switch, BRT/OFF/DIM"),devices.EXTLIGHTS_SYSTEM, extlights_commands.PosWingTail,533)
            // 	AddFunction( 3position(this, EXTLIGHTS_SYSTEM, "", "534", "EXTLIGHTS SYSTEM","FUSELAGE Switch, BRT/OFF/DIM",%%));    		    //     default_3_position_tumb_small(_("FUSELAGE Switch, BRT/OFF/DIM"),devices.EXTLIGHTS_SYSTEM, extlights_commands.PosFus,534)
            // 	AddFunction( axis(this, EXTLIGHTS_SYSTEM, "", "535", "EXTLIGHTS SYSTEM","FORM Knob",%%));    		    //     default_axis_limited(_("FORM Knob"),devices.EXTLIGHTS_SYSTEM, extlights_commands.FormKn,535)
            // 	AddFunction( switch(this, EXTLIGHTS_SYSTEM, "", "0", "EXTLIGHTS SYSTEM","MASTER Switch, OFF/ALL/A-C/FORM/NORM",%%));    		    //     multiposition_switch(_("MASTER Switch, OFF/ALL/A-C/FORM/NORM"),devices.EXTLIGHTS_SYSTEM, extlights_commands.Master,536, 5, 0.1, NOT_INVERSED, 0
            // 	AddFunction( axis(this, EXTLIGHTS_SYSTEM, "", "537", "EXTLIGHTS SYSTEM","AERIAL REFUELING Knob",%%));    		    //     default_axis_limited(_("AERIAL REFUELING Knob"),devices.EXTLIGHTS_SYSTEM, extlights_commands.AerialRefuel,537)
            // 	AddFunction( 3position(this, EXTLIGHTS_SYSTEM, "", "360", "EXTLIGHTS SYSTEM","LANDING TAXI LIGHTS Switch, LANDING/OFF/TAXI",%%));    		    //     default_3_position_tumb_small(_("LANDING TAXI LIGHTS Switch, LANDING/OFF/TAXI"),devices.EXTLIGHTS_SYSTEM, extlights_commands.LandingTaxi,360)
            #endregion
            #region Interior Lights
            // 	AddFunction( new PushButton(this, CPTLIGHTS_SYSTEM, "", "116", "CPTLIGHTS SYSTEM","Master Caution Button - Push to reset",%%));    		    //     default_button(_("Master Caution Button - Push to reset"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.MasterCaution,116)
            // 	AddFunction( new PushButton(this, CPTLIGHTS_SYSTEM, "", "577", "CPTLIGHTS SYSTEM","MAL & IND LTS Test Button - Push to test",%%));    		    //     default_button(_("MAL & IND LTS Test Button - Push to test"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.MalIndLtsTest,577)
            // 	AddFunction( axis(this, CPTLIGHTS_SYSTEM, "", " NOT_RELA", "CPTLIGHTS SYSTEM","PRIMARY CONSOLES BRT Knob",%%));    		    //     default_axis_limited(_("PRIMARY CONSOLES BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.Consoles,685, 0, 0.1, NOT_UPDATABLE, NOT_RELA
            // 	AddFunction( axis(this, CPTLIGHTS_SYSTEM, "", " NOT_RELAT", "CPTLIGHTS SYSTEM","PRIMARY INST PNL BRT Knob",%%));    		    //     default_axis_limited(_("PRIMARY INST PNL BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.IntsPnl,686, 0, 0.1, NOT_UPDATABLE, NOT_RELAT
            // 	AddFunction( axis(this, CPTLIGHTS_SYSTEM, "", " NOT_UPDATA", "CPTLIGHTS SYSTEM","PRIMARY DATA ENTRY DISPLAY BRT Knob",%%));    		    //     default_axis_limited(_("PRIMARY DATA ENTRY DISPLAY BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.DataEntryDisplay,687, 0, 0.1, NOT_UPDATA
            // 	AddFunction( axis(this, CPTLIGHTS_SYSTEM, "", "688", "CPTLIGHTS SYSTEM","FLOOD CONSOLES BRT Knob",%%));    		    //     default_axis_limited(_("FLOOD CONSOLES BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.ConsolesFlood,688)
            // 	AddFunction( axis(this, CPTLIGHTS_SYSTEM, "", " NOT_REL", "CPTLIGHTS SYSTEM","FLOOD INST PNL BRT Knob",%%));    		    //     default_axis_limited(_("FLOOD INST PNL BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.InstPnlFlood,690, 0, 0.1, NOT_UPDATABLE, NOT_REL
            // 	AddFunction( 3pos(this, CPTLIGHTS_SYSTEM, "", " cptlights_commands.", "CPTLIGHTS SYSTEM","MAL & IND LTS Switch, BRT/Center/DIM",%%));    		    //     springloaded_3_pos_tumb_small(_("MAL & IND LTS Switch, BRT/Center/DIM"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.MalIndLtsDim, cptlights_commands.
            #endregion
            #region Electric System
            // 	AddFunction( 3position(this, ELEC_INTERFACE, "", " fal", "ELEC INTERFACE","MAIN PWR Switch, MAIN PWR/BATT/OFF",%%));    		    //     default_3_position_tumb(_("MAIN PWR Switch, MAIN PWR/BATT/OFF"),devices.ELEC_INTERFACE, elec_commands.MainPwrSw,510, false, anim_speed_default, fal
            // 	AddFunction( new PushButton(this, ELEC_INTERFACE, "", "511", "ELEC INTERFACE","ELEC CAUTION RESET Button - Push to reset",%%));    		    //     default_button(_("ELEC CAUTION RESET Button - Push to reset"),devices.ELEC_INTERFACE, elec_commands.CautionResetBtn,511)
            // 	AddFunction( Switch.CreateToggleSwitch(this, ELEC_INTERFACE, "", "579", "ELEC INTERFACE","EPU/GEN Test Switch, EPU/GEN /OFF",%%));    		    //     springloaded_2_pos_tumb_small(_("EPU/GEN Test Switch, EPU/GEN /OFF"),devices.ELEC_INTERFACE, elec_commands.EPU_GEN_TestSw,579)
            // 	AddFunction( 3position(this, ELEC_INTERFACE, "", "578", "ELEC INTERFACE","PROBE HEAT Switch, PROBE HEAT/OFF/HEAT",%%));    		    //     default_3_position_tumb_small(_("PROBE HEAT Switch, PROBE HEAT/OFF/HEAT"),devices.ELEC_INTERFACE, elec_commands.ProbeHeatSw,578)
            // 	AddFunction( new PushButton(this, ELEC_INTERFACE, "", " elec_commands.Fl", "ELEC INTERFACE","FLCS PWR TEST Switch, MAINT/NORM/TEST(momentarily)",%%));    		    //     default_tumb_button(_("FLCS PWR TEST Switch, MAINT/NORM/TEST(momentarily)"),devices.ELEC_INTERFACE, elec_commands.FLCSPwrTestSwMAINT, elec_commands.Fl
            #endregion
            #region Fuel System
            // 	AddFunction( Switch.CreateToggleSwitch(this, FUEL_INTERFACE, "", "559", "FUEL INTERFACE","FUEL MASTER Switch, MASTER/OFF",%%));    		    //     default_2_position_tumb_small(_("FUEL MASTER Switch, MASTER/OFF"),devices.FUEL_INTERFACE, fuel_commands.FuelMasterSw,559)
            // 	AddFunction( redcover(this, FUEL_INTERFACE, "", "558", "FUEL INTERFACE","FUEL MASTER Switch Cover, OPEN/CLOSE",%%));    		    //     default_red_cover(_("FUEL MASTER Switch Cover, OPEN/CLOSE"),devices.FUEL_INTERFACE, fuel_commands.FuelMasterSwCvr,558)
            // 	AddFunction( Switch.CreateToggleSwitch(this, FUEL_INTERFACE, "", "557", "FUEL INTERFACE","TANK INERTING Switch, TANK INERTING /OFF",%%));    		    //     default_2_position_tumb(_("TANK INERTING Switch, TANK INERTING /OFF"),devices.FUEL_INTERFACE, fuel_commands.TankInertingSw,557)
            // 	AddFunction( switch(this, FUEL_INTERFACE, "", " NOT_INVERSE", "FUEL INTERFACE","ENGINE FEED Knob, OFF/NORM/AFT/FWD",%%));    		    //     multiposition_switch(_("ENGINE FEED Knob, OFF/NORM/AFT/FWD"),devices.FUEL_INTERFACE, fuel_commands.EngineFeedSw,556, 4, 0.1, NOT_INVERSE
            // 	AddFunction( Switch.CreateToggleSwitch(this, FUEL_INTERFACE, "", "555", "FUEL INTERFACE","AIR REFUEL Switch, OPEN/CLOSE",%%));    		    //     default_2_position_tumb(_("AIR REFUEL Switch, OPEN/CLOSE"),devices.FUEL_INTERFACE, fuel_commands.AirRefuelSw,555)
            // 	AddFunction( Switch.CreateToggleSwitch(this, FUEL_INTERFACE, "", "159", "FUEL INTERFACE","External Fuel Transfer Switch, NORM/ WING FIRST",%%));    		    //     default_2_position_tumb(_("External Fuel Transfer Switch, NORM/ WING FIRST"),devices.FUEL_INTERFACE, fuel_commands.ExtFuelTransferSw,159)
            #endregion
            #region Gear System
            // 	AddFunction( Switch.CreateToggleSwitch(this, GEAR_INTERFACE, "", "362", "GEAR INTERFACE","LG Handle, UP/DN",%%));    		    //     default_2_position_tumb(_("LG Handle, UP/DN"),devices.GEAR_INTERFACE, gear_commands.LGHandle,362)
            // 	AddFunction( new PushButton(this, GEAR_INTERFACE, "", "361", "GEAR INTERFACE","DN LOCK REL Button - Push to reset",%%));    		    //     default_button(_("DN LOCK REL Button - Push to reset"),devices.GEAR_INTERFACE, gear_commands.DownLockRelBtn,361)
            // 	AddFunction( Switch.CreateToggleSwitch(this, GEAR_INTERFACE, "", "354", "GEAR INTERFACE","HOOK Switch, UP/DN",%%));    		    //     default_2_position_tumb(_("HOOK Switch, UP/DN"),devices.GEAR_INTERFACE, gear_commands.HookSw,354)
            // 	AddFunction( new PushButton(this, GEAR_INTERFACE, "", "359", "GEAR INTERFACE","HORN SILENCER Button - Push to reset",%%));    		    //     default_button(_("HORN SILENCER Button - Push to reset"),devices.GEAR_INTERFACE, gear_commands.HornSilencerBtn,359)
            // 	AddFunction( Switch.CreateToggleSwitch(this, GEAR_INTERFACE, "", "356", "GEAR INTERFACE","BRAKES Channel Switch, CHAN 1/CHAN 2",%%));    		    //     default_2_position_tumb_small(_("BRAKES Channel Switch, CHAN 1/CHAN 2"),devices.GEAR_INTERFACE, gear_commands.BrakesChannelSw,356)
            // 	AddFunction( new PushButton(this, GEAR_INTERFACE, "", "357", "GEAR INTERFACE","ANTI-SKID Switch, PARKING BRAKE/ANTI-SKID/OFF",%%));    		    //     default_tumb_button(_("ANTI-SKID Switch, PARKING BRAKE/ANTI-SKID/OFF"),devices.GEAR_INTERFACE, gear_commands.AntiSkidSw,gear_commands.ParkingSw,357)
            #endregion
            #region ECS
            // 	AddFunction( axis(this, ECS_INTERFACE, "", "0.3}", "ECS INTERFACE","TEMP Knob",%%));    		    //     default_axis_limited(_("TEMP Knob"),devices.ECS_INTERFACE, ecs_commands.TempKnob, 692, 0.0, 0.1, false, false, {-0.3,0.3})
            // 	AddFunction( switch(this, ECS_INTERFACE, "", " anim_", "ECS INTERFACE","AIR SOURCE Knob, OFF/NORM/DUMP/RAM",%%));    		    //     multiposition_switch(_("AIR SOURCE Knob, OFF/NORM/DUMP/RAM"),devices.ECS_INTERFACE, ecs_commands.AirSourceKnob, 693, 4, 0.1, NOT_INVERSED, 0.0, anim_
            // 	AddFunction( axis(this, ECS_INTERFACE, "", "1}", "ECS INTERFACE","DEFOG Lever",%%));    		    //     default_axis_limited(_("DEFOG Lever"),devices.ECS_INTERFACE, ecs_commands.DefogLever, 602, 0.0, 0.1, true, false, {0,1})
            #endregion
            #region EPU
            // 	AddFunction( redcover(this, ENGINE_INTERFACE, "", "527", "ENGINE INTERFACE","EPU Switch Cover for ON, OPEN/CLOSE",%%));    		    //     default_red_cover(_("EPU Switch Cover for ON, OPEN/CLOSE"),devices.ENGINE_INTERFACE, engine_commands.EpuSwCvrOn,527)
            // 	AddFunction( redcover(this, ENGINE_INTERFACE, "", "529", "ENGINE INTERFACE","EPU Switch Cover for OFF, OPEN/CLOSE",%%));    		    //     default_red_cover(_("EPU Switch Cover for OFF, OPEN/CLOSE"),devices.ENGINE_INTERFACE, engine_commands.EpuSwCvrOff,529)
            // 	AddFunction( 3position(this, ENGINE_INTERFACE, "", "528", "ENGINE INTERFACE","EPU Switch, ON/NORM/OFF",%%));    		    //     default_3_position_tumb_small(_("EPU Switch, ON/NORM/OFF"),devices.ENGINE_INTERFACE, engine_commands.EpuSw,528)
            #endregion
            #region engine
            // 	AddFunction( 3position(this, ENGINE_INTERFACE, "", "710", "ENGINE INTERFACE","Engine ANTI ICE Switch, ON/AUTO/OFF",%%));    		    //     default_3_position_tumb(_("Engine ANTI ICE Switch, ON/AUTO/OFF"),devices.ENGINE_INTERFACE, engine_commands.EngAntiIceSw,710)
            // 	AddFunction( 3pos(this, ENGINE_INTERFACE, "", " engine_commands.JfsSwStar", "ENGINE INTERFACE","JFS Switch, START 1/OFF/START 2",%%));    		    //     springloaded_3_pos_tumb(_("JFS Switch, START 1/OFF/START 2"),devices.ENGINE_INTERFACE, engine_commands.JfsSwStart2, engine_commands.JfsSwStar
            // 	AddFunction( redcover(this, ENGINE_INTERFACE, "", "448", "ENGINE INTERFACE","ENG CONT Switch Cover, OPEN/CLOSE",%%));    		    //     default_red_cover(_("ENG CONT Switch Cover, OPEN/CLOSE"),devices.ENGINE_INTERFACE, engine_commands.EngContSwCvr,448)
            // 	AddFunction( Switch.CreateToggleSwitch(this, ENGINE_INTERFACE, "", "449", "ENGINE INTERFACE","ENG CONT Switch, PRI/SEC",%%));    		    //     default_2_position_tumb_small(_("ENG CONT Switch, PRI/SEC"),devices.ENGINE_INTERFACE, engine_commands.EngContSw,449)
            // 	AddFunction( Switch.CreateToggleSwitch(this, ENGINE_INTERFACE, "", "451", "ENGINE INTERFACE","MAX POWER Switch (is inoperative), MAX POWER/OFF",%%));    		    //     default_2_position_tumb(_("MAX POWER Switch (is inoperative), MAX POWER/OFF"),devices.ENGINE_INTERFACE, engine_commands.MaxPowerSw,451)
            // 	AddFunction( 3pos(this, ENGINE_INTERFACE, "", " engine_commands", "ENGINE INTERFACE","AB RESET Switch, AB RESET/NORM/ENG DATA",%%));    		    //     springloaded_3_pos_tumb(_("AB RESET Switch, AB RESET/NORM/ENG DATA"),devices.ENGINE_INTERFACE, engine_commands.ABResetSwEngData, engine_commands
            // 	AddFunction( new PushButton(this, ENGINE_INTERFACE, "", "575", "ENGINE INTERFACE","FIRE & OHEAT DETECT Test Button - Push to test",%%));    		    //     default_button(_("FIRE & OHEAT DETECT Test Button - Push to test"),devices.ENGINE_INTERFACE, engine_commands.FireOheatTestBtn,575)
            #endregion
            #region Oxygen System
            // 	AddFunction( 3position(this, OXYGEN_INTERFACE, "", " anim_speed_default", "OXYGEN INTERFACE","Supply Lever, PBG/ON/OFF",%%));    		    //     default_3_position_tumb_small(_("Supply Lever, PBG/ON/OFF"),devices.OXYGEN_INTERFACE, oxygen_commands.SupplyLever,728, false, anim_speed_default
            // 	AddFunction( Switch.CreateToggleSwitch(this, OXYGEN_INTERFACE, "", "727", "OXYGEN INTERFACE","Diluter Lever, 100 percent/NORM",%%));    		    //     default_2_position_tumb_small(_("Diluter Lever, 100 percent/NORM"),devices.OXYGEN_INTERFACE, oxygen_commands.DiluterLever,727)
            // 	AddFunction( 3position(this, OXYGEN_INTERFACE, "", "726", "OXYGEN INTERFACE","Emergency Lever, EMERGENCY/NORMAL/TEST MASK",%%));    		    //     default_3_position_tumb_small(_("Emergency Lever, EMERGENCY/NORMAL/TEST MASK"),devices.OXYGEN_INTERFACE, oxygen_commands.EmergencyLever,726)
            #endregion
            #region Sensor Power Control Panel
            // 	AddFunction( Switch.CreateToggleSwitch(this, SMS, "", "670", "SMS","LEFT HDPT Switch, ON/OFF",%%));    		    //     default_2_position_tumb(_("LEFT HDPT Switch, ON/OFF"),devices.SMS, sms_commands.LeftHDPT, 670)
            // 	AddFunction( Switch.CreateToggleSwitch(this, SMS, "", "671", "SMS","RIGHT HDPT Switch, ON/OFF",%%));    		    //     default_2_position_tumb(_("RIGHT HDPT Switch, ON/OFF"),devices.SMS, sms_commands.RightHDPT, 671)
            // 	AddFunction( Switch.CreateToggleSwitch(this, FCR, "", "672", "FCR","FCR Switch, FCR/OFF",%%));    		    //     default_2_position_tumb(_("FCR Switch, FCR/OFF"),devices.FCR, fcr_commands.PwrSw, 672)
            // 	AddFunction( 3position(this, RALT, "", "673", "RALT","RDR ALT Switch, RDR ALT/STBY/OFF",%%));    		    //     default_3_position_tumb(_("RDR ALT Switch, RDR ALT/STBY/OFF"),devices.RALT, ralt_commands.PwrSw, 673)
            #endregion
            #region Avionic Power Panel
            // 	AddFunction( Switch.CreateToggleSwitch(this, MMC, "", "715", "MMC","MMC Switch, MMC/OFF",%%));    		    //     default_2_position_tumb(_("MMC Switch, MMC/OFF"),devices.MMC, mmc_commands.MmcPwr,715)
            // 	AddFunction( Switch.CreateToggleSwitch(this, SMS, "", "716", "SMS","ST STA Switch, ST STA/OFF",%%));    		    //     default_2_position_tumb(_("ST STA Switch, ST STA/OFF"),devices.SMS, sms_commands.StStaSw,716)
            // 	AddFunction( Switch.CreateToggleSwitch(this, MMC, "", "717", "MFD","Switch, MFD/OFF",%%));    		    //     default_2_position_tumb(_("MFD Switch, MFD/OFF"),devices.MMC, mmc_commands.MFD,717)
            // 	AddFunction( Switch.CreateToggleSwitch(this, UFC, "", "718", "UFC","UFC Switch, UFC/OFF",%%));    		    //     default_2_position_tumb(_("UFC Switch, UFC/OFF"),devices.UFC, ufc_commands.UFC_Sw,718)
            // 	AddFunction( switch(this, MIDS, "", " NO", "MIDS","MIDS LVT Knob, ZERO/OFF/ON",%%));    		    //     multiposition_switch(_("MIDS LVT Knob, ZERO/OFF/ON"),devices.MIDS, mids_commands.PwrSw, 723, 3, 0.1, NOT_INVERSED, 0.0, anim_speed_default * 0.1, NO
            // 	AddFunction( switch(this, INS, "", " anim_", "INS","INS Knob, OFF/STOR HDG/NORM/NAV/CAL/INFLT ALIGN/ATT",%%));    		    //     multiposition_switch(_("INS Knob, OFF/STOR HDG/NORM/NAV/CAL/INFLT ALIGN/ATT"),devices.INS, ins_commands.ModeKnob, 719, 7, 0.1, NOT_INVERSED, 0.0, anim_
            // 	AddFunction( Switch.CreateToggleSwitch(this, ELEC_INTERFACE, "", "722", "ELEC INTERFACE","MAP Switch, MAP/OFF",%%));    		    //     default_2_position_tumb(_("MAP Switch, MAP/OFF"),devices.ELEC_INTERFACE, 3101,722)
            // 	AddFunction( Switch.CreateToggleSwitch(this, ELEC_INTERFACE, "", "720", "ELEC INTERFACE","GPS Switch, GPS/OFF",%%));    		    //     default_2_position_tumb(_("GPS Switch, GPS/OFF"),devices.ELEC_INTERFACE, 3102,720)
            // 	AddFunction( Switch.CreateToggleSwitch(this, ELEC_INTERFACE, "", "721", "ELEC INTERFACE","DL Switch, DL/OFF",%%));    		    //     default_2_position_tumb(_("DL Switch, DL/OFF"),devices.ELEC_INTERFACE, 3103,721)
            #endregion
            #region Modular Mission Computer (MMC)
            // 	AddFunction( 3position(this, MMC, "", "105", "MMC","MASTER ARM Switch, MASTER ARM/OFF/SIMULATE",%%));    		    //     default_3_position_tumb(_("MASTER ARM Switch, MASTER ARM/OFF/SIMULATE"),devices.MMC, mmc_commands.MasterArmSw,105)
            // 	AddFunction( new PushButton(this, MMC, "", "353", "MMC","EMER STORES JETTISON Button - Push to jettison",%%));    		    //     default_button(_("EMER STORES JETTISON Button - Push to jettison"),devices.MMC, mmc_commands.EmerStoresJett,353)
            // 	AddFunction( Switch.CreateToggleSwitch(this, MMC, "", "355", "MMC","GND JETT ENABLE Switch, ENABLE/OFF",%%));    		    //     default_2_position_tumb(_("GND JETT ENABLE Switch, ENABLE/OFF"),devices.MMC, mmc_commands.GroundJett,355)
            // 	AddFunction( new PushButton(this, MMC, "", "104", "MMC","ALT REL Button - Push to release",%%));    		    //     default_button(_("ALT REL Button - Push to release"),devices.MMC, mmc_commands.AltRel,104)
            // 	AddFunction( Switch.CreateToggleSwitch(this, SMS, "", "103", "SMS","LASER ARM Switch, ARM/OFF",%%));    		    //     default_2_position_tumb(_("LASER ARM Switch, ARM/OFF"),devices.SMS, sms_commands.LaserSw, 103)
            #endregion
            #region Integrated Control Panel (ICP) of Upfront Controls (UFC)
            // 	AddFunction( new PushButton(this, UFC, "", "171", "ICP","Priority Function Button, 1(T-ILS)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 1(T-ILS)"),devices.UFC, ufc_commands.DIG1_T_ILS,171)
            // 	AddFunction( new PushButton(this, UFC, "", "172", "ICP","Priority Function Button, 2/N(ALOW)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 2/N(ALOW)"),devices.UFC, ufc_commands.DIG2_ALOW,172)
            // 	AddFunction( new PushButton(this, UFC, "", "173", "ICP","Priority Function Button, 3",%%));    		    //     short_way_button(_("ICP Priority Function Button, 3"),devices.UFC, ufc_commands.DIG3,173)
            // 	AddFunction( new PushButton(this, UFC, "", "175", "ICP","Priority Function Button, 4/W(STPT)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 4/W(STPT)"),devices.UFC, ufc_commands.DIG4_STPT,175)
            // 	AddFunction( new PushButton(this, UFC, "", "176", "ICP","Priority Function Button, 5(CRUS)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 5(CRUS)"),devices.UFC, ufc_commands.DIG5_CRUS,176)
            // 	AddFunction( new PushButton(this, UFC, "", "177", "ICP","Priority Function Button, 6/E(TIME)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 6/E(TIME)"),devices.UFC, ufc_commands.DIG6_TIME,177)
            // 	AddFunction( new PushButton(this, UFC, "", "179", "ICP","Priority Function Button, 7(MARK)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 7(MARK)"),devices.UFC, ufc_commands.DIG7_MARK,179)
            // 	AddFunction( new PushButton(this, UFC, "", "180", "ICP","Priority Function Button, 8/S(FIX)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 8/S(FIX)"),devices.UFC, ufc_commands.DIG8_FIX,180)
            // 	AddFunction( new PushButton(this, UFC, "", "181", "ICP","Priority Function Button, 9(A-CAL)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 9(A-CAL)"),devices.UFC, ufc_commands.DIG9_A_CAL,181)
            // 	AddFunction( new PushButton(this, UFC, "", "182", "ICP","Priority Function Button, 0(M-SEL)",%%));    		    //     short_way_button(_("ICP Priority Function Button, 0(M-SEL)"),devices.UFC, ufc_commands.DIG0_M_SEL,182)
            // 	AddFunction( new PushButton(this, UFC, "", "165", "ICP","COM Override Button, COM1(UHF)",%%));    		    //     short_way_button(_("ICP COM Override Button, COM1(UHF)"),devices.UFC, ufc_commands.COM1,165)
            // 	AddFunction( new PushButton(this, UFC, "", "166", "ICP","COM Override Button, COM2(VHF)",%%));    		    //     short_way_button(_("ICP COM Override Button, COM2(VHF)"),devices.UFC, ufc_commands.COM2,166)
            // 	AddFunction( new PushButton(this, UFC, "", "167", "ICP","IFF Override Button, IFF",%%));    		    //     short_way_button(_("ICP IFF Override Button, IFF"),devices.UFC, ufc_commands.IFF,167)
            // 	AddFunction( new PushButton(this, UFC, "", "168", "ICP","LIST Override Button, LIST",%%));    		    //     short_way_button(_("ICP LIST Override Button, LIST"),devices.UFC, ufc_commands.LIST,168)
            // 	AddFunction( new PushButton(this, UFC, "", "169", "ICP","Master Mode Button, A-A",%%));    		    //     short_way_button(_("ICP Master Mode Button, A-A"),devices.UFC, ufc_commands.AA,169)
            // 	AddFunction( new PushButton(this, UFC, "", "170", "ICP","Master Mode Button, A-G",%%));    		    //     short_way_button(_("ICP Master Mode Button, A-G"),devices.UFC, ufc_commands.AG,170)
            // 	AddFunction( new PushButton(this, UFC, "", "174", "ICP","Recall Button, RCL",%%));    		    //     short_way_button(_("ICP Recall Button, RCL"),devices.UFC, ufc_commands.RCL,174)
            // 	AddFunction( new PushButton(this, UFC, "", "178", "ICP","Enter Button, ENTR",%%));    		    //     short_way_button(_("ICP Enter Button, ENTR"),devices.UFC, ufc_commands.ENTR,178)
            // 	AddFunction( axis(this, UFC, "", "192", "ICP","Reticle Depression Control Knob",%%));    		    //     default_axis_limited(_("ICP Reticle Depression Control Knob"),devices.UFC, ufc_commands.RET_DEPR_Knob,192)
            // 	AddFunction( axis(this, UFC, "", "193", "ICP","Raster Contrast Knob",%%));    		    //     default_axis_limited(_("ICP Raster Contrast Knob"),devices.UFC, ufc_commands.CONT_Knob,193)
            // 	AddFunction( axis(this, UFC, "", "191", "ICP","Raster Intensity Knob",%%));    		    //     default_axis_limited(_("ICP Raster Intensity Knob"),devices.UFC, ufc_commands.BRT_Knob,191)
            // 	AddFunction( axis(this, UFC, "", "190", "ICP","HUD","Symbology Intensity Knob",%%));    		    //     default_axis_limited(_("ICP HUD Symbology Intensity Knob"),devices.UFC, ufc_commands.SYM_Knob,190)
            // 	AddFunction( new PushButton(this, UFC, "", "187", "ICP","FLIR Polarity Button, Wx",%%));    		    //     short_way_button(_("ICP FLIR Polarity Button, Wx"),devices.UFC, ufc_commands.Wx,187)
            // 	AddFunction( 3position(this, UFC, "", "189", "ICP","FLIR GAIN/LEVEL Switch, GAIN/LVL/AUTO",%%));    		    //     default_3_position_tumb_small(_("ICP FLIR GAIN/LEVEL Switch, GAIN/LVL/AUTO"),devices.UFC, ufc_commands.FLIR_GAIN_Sw,189)
            // 	AddFunction( Rockerswitchpositive(this, UFC, "", "183", "ICP","DED Increment/Decrement Switch, Up",%%));    		    //     Rocker_switch_positive(_("ICP DED Increment/Decrement Switch, Up"),devices.UFC, ufc_commands.DED_INC,183)
            // 	AddFunction( Rockerswitchnegative(this, UFC, "", "183", "ICP","DED Increment/Decrement Switch, Down",%%));    		    //     Rocker_switch_negative(_("ICP DED Increment/Decrement Switch, Down"),devices.UFC, ufc_commands.DED_DEC,183)
            // 	AddFunction( Rockerswitchpositive(this, UFC, "", "188", "ICP","FLIR Increment/Decrement Switch, Up",%%));    		    //     Rocker_switch_positive(_("ICP FLIR Increment/Decrement Switch, Up"),devices.UFC, ufc_commands.FLIR_INC,188)
            // 	AddFunction( Rockerswitchnegative(this, UFC, "", "188", "ICP","FLIR Increment/Decrement Switch, Down",%%));    		    //     Rocker_switch_negative(_("ICP FLIR Increment/Decrement Switch, Down"),devices.UFC, ufc_commands.FLIR_DEC,188)
            // 	AddFunction( Switch.CreateToggleSwitch(this, UFC, "", "184", "ICP","Data Control Switch, RTN",%%));    		    //     springloaded_2_pos_tumb_small(_("ICP Data Control Switch, RTN"),devices.UFC, ufc_commands.DCS_RTN,184)
            // 	AddFunction( {-1(this, , "", " -1}", "",,%%));    		    //     {-1, -1}
            // 	AddFunction( {{-1(this, , "", "0}}", "",,%%));    		    //     {{-1,0},{-1,0}}
            // 	AddFunction( Switch.CreateToggleSwitch(this, UFC, "", "184", "ICP","Data Control Switch, SEQ",%%));    		    //     springloaded_2_pos_tumb_small(_("ICP Data Control Switch, SEQ"),devices.UFC, ufc_commands.DCS_SEQ,184)
            // 	AddFunction( Switch.CreateToggleSwitch(this, UFC, "", "185", "ICP","Data Control Switch, UP",%%));    		    //     springloaded_2_pos_tumb_small(_("ICP Data Control Switch, UP"),devices.UFC, ufc_commands.DCS_UP,185)
            // 	AddFunction( Switch.CreateToggleSwitch(this, UFC, "", "185", "ICP","Data Control Switch, DN",%%));    		    //     springloaded_2_pos_tumb_small(_("ICP Data Control Switch, DN"),devices.UFC, ufc_commands.DCS_DOWN,185)
            // 	AddFunction( {-1(this, , "", " -1}", "",,%%));    		    //     {-1, -1}
            // 	AddFunction( {{-1(this, , "", "0}}", "",,%%));    		    //     {{-1,0},{-1,0}}
            // 	AddFunction( new PushButton(this, UFC, "", "122", "UFC","F-ACK Button",%%));    		    //     short_way_button(_("F-ACK Button"),devices.UFC, ufc_commands.F_ACK,122)
            // 	AddFunction( new PushButton(this, UFC, "", "125", "UFC","IFF IDENT Button",%%));    		    //     short_way_button(_("IFF IDENT Button"),devices.UFC, ufc_commands.IFF_IDENT,125)
            // 	AddFunction( 3position(this, UFC, "", "100", "UFC","RF Switch, SILENT/QUIET/NORM",%%));    		    //     default_3_position_tumb(_("RF Switch, SILENT/QUIET/NORM"),devices.UFC, ufc_commands.RF_Sw,100)
            #endregion
            #region HUD Remote Control Panel
            // 	AddFunction( 3position(this, MMC, "", "675", "HUD","Scales Switch, VV/VAH / VAH / OFF",%%));    		    //     default_3_position_tumb(_("HUD Scales Switch, VV/VAH / VAH / OFF"),devices.MMC, mmc_commands.VvVah,675)
            // 	AddFunction( 3position(this, MMC, "", "676", "HUD","Flightpath Marker Switch, ATT/FPM / FPM / OFF",%%));    		    //     default_3_position_tumb(_("HUD Flightpath Marker Switch, ATT/FPM / FPM / OFF"),devices.MMC, mmc_commands.AttFpm,676)
            // 	AddFunction( 3position(this, MMC, "", "677", "HUD","DED/PFLD Data Switch, DED / PFL / OFF",%%));    		    //     default_3_position_tumb_small(_("HUD DED/PFLD Data Switch, DED / PFL / OFF"),devices.MMC, mmc_commands.DedData,677)
            // 	AddFunction( 3position(this, MMC, "", "678", "HUD","Depressible Reticle Switch, STBY / PRI / OFF",%%));    		    //     default_3_position_tumb(_("HUD Depressible Reticle Switch, STBY / PRI / OFF"),devices.MMC, mmc_commands.DeprRet,678)
            // 	AddFunction( 3position(this, MMC, "", "679", "HUD","Velocity Switch, CAS / TAS / GND SPD",%%));    		    //     default_3_position_tumb_small(_("HUD Velocity Switch, CAS / TAS / GND SPD"),devices.MMC, mmc_commands.Spd,679)
            // 	AddFunction( 3position(this, MMC, "", "680", "HUD","Altitude Switch, RADAR / BARO / AUTO",%%));    		    //     default_3_position_tumb_small(_("HUD Altitude Switch, RADAR / BARO / AUTO"),devices.MMC, mmc_commands.Alt,680)
            // 	AddFunction( 3position(this, MMC, "", "681", "HUD","Brightness Control Switch, DAY / AUTO BRT / NIGHT",%%));    		    //     default_3_position_tumb_small(_("HUD Brightness Control Switch, DAY / AUTO BRT / NIGHT"),devices.MMC, mmc_commands.Brt,681)
            // 	AddFunction( 3position(this, MMC, "", "682", "HUD","TEST Switch, STEP / ON / OFF",%%));    		    //     default_3_position_tumb_small(_("HUD TEST Switch, STEP / ON / OFF"),devices.MMC, mmc_commands.Test,682)
            #endregion
            #region Audio Control Panels
            // 	AddFunction( switch(this, INTERCOM, "", " anim_sp", "INTERCOM","COMM 1 (UHF) Mode Knob",%%));    		    //     multiposition_switch(_("COMM 1 (UHF) Mode Knob"),devices.INTERCOM, intercom_commands.COM1_ModeKnob,434, 3, 0.5, NOT_INVERSED, 0.0, anim_sp
            // 	AddFunction( switch(this, INTERCOM, "", " anim_sp", "INTERCOM","COMM 2 (VHF) Mode Knob",%%));    		    //     multiposition_switch(_("COMM 2 (VHF) Mode Knob"),devices.INTERCOM, intercom_commands.COM2_ModeKnob,435, 3, 0.5, NOT_INVERSED, 0.0, anim_sp
            // 	AddFunction( axis(this, INTERCOM, "", "430", "INTERCOM","COMM 1 Power Knob",%%));    		    //     default_axis_limited(_("COMM 1 Power Knob"),devices.INTERCOM, intercom_commands.COM1_PowerKnob,430)
            // 	AddFunction( axis(this, INTERCOM, "", "431", "INTERCOM","COMM 2 Power Knob",%%));    		    //     default_axis_limited(_("COMM 2 Power Knob"),devices.INTERCOM, intercom_commands.COM2_PowerKnob,431)
            // 	AddFunction( axis(this, INTERCOM, "", "432", "INTERCOM","SECURE VOICE Knob",%%));    		    //     default_axis_limited(_("SECURE VOICE Knob"),devices.INTERCOM, intercom_commands.SecureVoiceKnob,432)
            // 	AddFunction( axis(this, INTERCOM, "", "433", "INTERCOM","MSL Tone Knob",%%));    		    //     default_axis_limited(_("MSL Tone Knob"),devices.INTERCOM, intercom_commands.MSL_ToneKnob,433)
            // 	AddFunction( axis(this, INTERCOM, "", "436", "INTERCOM","TF Tone Knob",%%));    		    //     default_axis_limited(_("TF Tone Knob"),devices.INTERCOM, intercom_commands.TF_ToneKnob,436)
            // 	AddFunction( axis(this, INTERCOM, "", "437", "INTERCOM","THREAT Tone Knob",%%));    		    //     default_axis_limited(_("THREAT Tone Knob"),devices.INTERCOM, intercom_commands.THREAT_ToneKnob,437)
            // 	AddFunction( axis(this, INTERCOM, "", "440", "INTERCOM","INTERCOM Knob",%%));    		    //     default_axis_limited(_("INTERCOM Knob"),devices.INTERCOM, intercom_commands.INTERCOM_Knob,440)
            // 	AddFunction( axis(this, INTERCOM, "", "441", "INTERCOM","TACAN Knob",%%));    		    //     default_axis_limited(_("TACAN Knob"),devices.INTERCOM, intercom_commands.TACAN_Knob,441)
            // 	AddFunction( axis(this, INTERCOM, "", "442", "INTERCOM","ILS Power Knob",%%));    		    //     default_axis_limited(_("ILS Power Knob"),devices.INTERCOM, intercom_commands.ILS_PowerKnob,442)
            // 	AddFunction( 3position(this, INTERCOM, "", "443", "INTERCOM","HOT MIC CIPHER Switch, HOT MIC / OFF / CIPHER",%%));    		    //     default_3_position_tumb_small(_("HOT MIC CIPHER Switch, HOT MIC / OFF / CIPHER"),devices.INTERCOM, intercom_commands.HotMicCipherSw,443)
            // 	AddFunction( Switch.CreateToggleSwitch(this, INTERCOM, "", "696", "INTERCOM","Voice Message Inhibit Switch, VOICE MESSAGE/INHIBIT",%%));    		    //     default_2_position_tumb_small(_("Voice Message Inhibit Switch, VOICE MESSAGE/INHIBIT"),devices.INTERCOM, intercom_commands.VMS_InhibitSw,696)
            // 	AddFunction( 3position(this, INTERCOM, "", "711", "INTERCOM","IFF ANT SEL Switch, LOWER/NORM/UPPER",%%));    		    //     default_3_position_tumb_small(_("IFF ANT SEL Switch, LOWER/NORM/UPPER"),devices.INTERCOM, intercom_commands.IFF_AntSelSw,711)
            // 	AddFunction( 3position(this, INTERCOM, "", "712", "INTERCOM","UHF ANT SEL Switch, LOWER/NORM/UPPER",%%));    		    //     default_3_position_tumb_small(_("UHF ANT SEL Switch, LOWER/NORM/UPPER"),devices.INTERCOM, intercom_commands.UHF_AntSelSw,712)
            #endregion
            #region UHF Backup Control Panel
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " anim_spe", "UHF CONTROL PANEL","UHF CHAN Knob",%%));    		    //     multiposition_switch(_("UHF CHAN Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.ChannelKnob,410, 20, 0.05, NOT_INVERSED, 0.0, anim_spe
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " NOT_INVERS", "UHF CONTROL PANEL","UHF Manual Frequency Knob 100 MHz",%%));    		    //     multiposition_switch(_("UHF Manual Frequency Knob 100 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector100Mhz,411, 3, 0.1, NOT_INVERS
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " NOT_INVERSED", "UHF CONTROL PANEL","UHF Manual Frequency Knob 10 MHz",%%));    		    //     multiposition_switch(_("UHF Manual Frequency Knob 10 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector10Mhz,412, 10, 0.1, NOT_INVERSED
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", "0", "UHF CONTROL PANEL","UHF Manual Frequency Knob 1 MHz",%%));    		    //     multiposition_switch(_("UHF Manual Frequency Knob 1 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector1Mhz,413, 10, 0.1, NOT_INVERSED, 0
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " NOT_INVERS", "UHF CONTROL PANEL","UHF Manual Frequency Knob 0.1 MHz",%%));    		    //     multiposition_switch(_("UHF Manual Frequency Knob 0.1 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector01Mhz,414, 10, 0.1, NOT_INVERS
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " NOT_INV", "UHF CONTROL PANEL","UHF Manual Frequency Knob 0.025 MHz",%%));    		    //     multiposition_switch(_("UHF Manual Frequency Knob 0.025 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector0025Mhz,415, 4, 0.25, NOT_INV
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " anim_speed", "UHF CONTROL PANEL","UHF Function Knob",%%));    		    //     multiposition_switch(_("UHF Function Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.FunctionKnob,417, 4, 0.1, NOT_INVERSED, 0.0, anim_speed
            // 	AddFunction( switch(this, UHF_CONTROL_PANEL, "", " anim_speed_de", "UHF CONTROL PANEL","UHF Mode Knob",%%));    		    //     multiposition_switch(_("UHF Mode Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqModeKnob,416, 3, 0.1, NOT_INVERSED, 0.0, anim_speed_de
            // 	AddFunction( new PushButton(this, UHF_CONTROL_PANEL, "", "418", "UHF CONTROL PANEL","UHF Tone Button",%%));    		    //     default_button(_("UHF Tone Button"),devices.UHF_CONTROL_PANEL, uhf_commands.TToneSw,418)
            // 	AddFunction( Switch.CreateToggleSwitch(this, UHF_CONTROL_PANEL, "", "419", "UHF CONTROL PANEL","UHF SQUELCH Switch",%%));    		    //     default_2_position_tumb_small(_("UHF SQUELCH Switch"),devices.UHF_CONTROL_PANEL, uhf_commands.SquelchSw,419)
            // 	AddFunction( axis(this, UHF_CONTROL_PANEL, "", "420", "UHF CONTROL PANEL","UHF VOL Knob",%%));    		    //     default_axis_limited(_("UHF VOL Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.VolumeKnob,420)
            // 	AddFunction( new PushButton(this, UHF_CONTROL_PANEL, "", "421", "UHF CONTROL PANEL","UHF TEST DISPLAY Button",%%));    		    //     default_button(_("UHF TEST DISPLAY Button"),devices.UHF_CONTROL_PANEL, uhf_commands.TestDisplayBtn,421)
            // 	AddFunction( new PushButton(this, UHF_CONTROL_PANEL, "", "422", "UHF CONTROL PANEL","UHF STATUS Button",%%));    		    //     default_button(_("UHF STATUS Button"),devices.UHF_CONTROL_PANEL, uhf_commands.StatusBtn,422)
            // 	AddFunction( Switch.CreateToggleSwitch(this, UHF_CONTROL_PANEL, "", " anim_speed_default * 0.5", "UHF CONTROL PANEL","Access Door, OPEN/CLOSE",%%));    		    //     default_2_position_tumb(_("Access Door, OPEN/CLOSE"),devices.UHF_CONTROL_PANEL, uhf_commands.AccessDoor,734, anim_speed_default * 0.5)
            #endregion
            #region IFF Control Panel
            // 	AddFunction( switch(this, IFF_CONTROL_PANEL, "", " anim_speed_defa", "IFF CONTROL PANEL","C & I Knob, UFC/BACKUP",%%));    		    //     multiposition_switch(_("C & I Knob, UFC/BACKUP"),devices.IFF_CONTROL_PANEL, iff_commands.CNI_Knob,542, 2, 1, NOT_INVERSED, 0.0, anim_speed_defa
            // 	AddFunction( switch(this, IFF_CONTROL_PANEL, "", "0", "IFF CONTROL PANEL","IFF MASTER Knob, OFF/STBY/LOW/NORM/EMER",%%));    		    //     multiposition_switch(_("IFF MASTER Knob, OFF/STBY/LOW/NORM/EMER"),devices.IFF_CONTROL_PANEL, iff_commands.MasterKnob,540, 5, 0.1, NOT_INVERSED, 0.0
            // 	AddFunction( 3position(this, IFF_CONTROL_PANEL, "", "541", "IFF CONTROL PANEL","IFF M-4 CODE Switch, HOLD/ A/B /ZERO",%%));    		    //     default_3_position_tumb(_("IFF M-4 CODE Switch, HOLD/ A/B /ZERO"),devices.IFF_CONTROL_PANEL, iff_commands.M4CodeSw,541)
            // 	AddFunction( 3position(this, IFF_CONTROL_PANEL, "", "543", "IFF CONTROL PANEL","IFF MODE 4 REPLY Switch, OUT/A/B",%%));    		    //     default_3_position_tumb(_("IFF MODE 4 REPLY Switch, OUT/A/B"),devices.IFF_CONTROL_PANEL, iff_commands.M4ReplySw,543)
            // 	AddFunction( Switch.CreateToggleSwitch(this, IFF_CONTROL_PANEL, "", "544", "IFF CONTROL PANEL","IFF MODE 4 MONITOR Switch, OUT/AUDIO",%%));    		    //     default_2_position_tumb_small(_("IFF MODE 4 MONITOR Switch, OUT/AUDIO"),devices.IFF_CONTROL_PANEL, iff_commands.M4MonitorSw,544)
            // 	AddFunction( 3position(this, IFF_CONTROL_PANEL, "", "553", "IFF CONTROL PANEL","IFF ENABLE Switch, M1/M3 /OFF/ M3/MS",%%));    		    //     default_3_position_tumb_small(_("IFF ENABLE Switch, M1/M3 /OFF/ M3/MS"),devices.IFF_CONTROL_PANEL, iff_commands.EnableSw,553)
            // 	AddFunction( 3pos(this, IFF_CONTROL_PANEL, "", " iff_commands.M1M3Selector1", "IFF CONTROL PANEL","IFF MODE 1 Selector Lever, DIGIT 1",%%));    		    //     springloaded_3_pos_tumb(_("IFF MODE 1 Selector Lever, DIGIT 1"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector1_Dec, iff_commands.M1M3Selector1
            // 	AddFunction( 3pos(this, IFF_CONTROL_PANEL, "", " iff_commands.M1M3Selector2", "IFF CONTROL PANEL","IFF MODE 1 Selector Lever, DIGIT 2",%%));    		    //     springloaded_3_pos_tumb(_("IFF MODE 1 Selector Lever, DIGIT 2"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector2_Dec, iff_commands.M1M3Selector2
            // 	AddFunction( 3pos(this, IFF_CONTROL_PANEL, "", " iff_commands.M1M3Selector3", "IFF CONTROL PANEL","IFF MODE 3 Selector Lever, DIGIT 1",%%));    		    //     springloaded_3_pos_tumb(_("IFF MODE 3 Selector Lever, DIGIT 1"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector3_Dec, iff_commands.M1M3Selector3
            // 	AddFunction( 3pos(this, IFF_CONTROL_PANEL, "", " iff_commands.M1M3Selector4", "IFF CONTROL PANEL","IFF MODE 3 Selector Lever, DIGIT 2",%%));    		    //     springloaded_3_pos_tumb(_("IFF MODE 3 Selector Lever, DIGIT 2"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector4_Dec, iff_commands.M1M3Selector4
            #endregion
            #region KY-58
            // 	AddFunction( switch(this, KY58, "", " anim_speed_default", "KY58","KY-58 MODE Knob, P/C/LD/RV",%%));    		    //     multiposition_switch(_("KY-58 MODE Knob, P/C/LD/RV"),devices.KY58, ky58_commands.KY58_ModeSw,705, 4, 0.1, NOT_INVERSED, 0.0, anim_speed_default
            // 	AddFunction( axis(this, KY58, "", "1}", "KY58","KY-58 VOLUME Knob",%%));    		    //     default_axis_limited(_("KY-58 VOLUME Knob"),devices.KY58, ky58_commands.KY58_Volume,708, 0.0, 0.1, false, false, {0,1})
            // 	AddFunction( switch(this, KY58, "", " anim_spe", "KY58","KY-58 FILL Knob, Z 1-5/1/2/3/4/5/6/Z ALL",%%));    		    //     multiposition_switch(_("KY-58 FILL Knob, Z 1-5/1/2/3/4/5/6/Z ALL"),devices.KY58, ky58_commands.KY58_FillSw,706, 8, 0.1, NOT_INVERSED, 0.0, anim_spe
            // 	AddFunction( switch(this, KY58, "", " anim_speed_defaul", "KY58","KY-58 Power Knob, OFF/ON/TD",%%));    		    //     multiposition_switch(_("KY-58 Power Knob, OFF/ON/TD"),devices.KY58, ky58_commands.KY58_PowerSw,707, 3, 0.5, NOT_INVERSED, 0.0, anim_speed_defaul
            // 	AddFunction( 3position(this, INTERCOM, "", "701", "INTERCOM","PLAIN Cipher Switch, CRAD 1/PLAIN/CRAD 2",%%));    		    //     default_3_position_tumb_small(_("PLAIN Cipher Switch, CRAD 1/PLAIN/CRAD 2"),devices.INTERCOM, intercom_commands.PlainCipherSw,701)
            // 	AddFunction( redcover(this, INTERCOM, "", "694", "INTERCOM","ZEROIZE Switch Cover, OPEN/CLOSE",%%));    		    //     default_red_cover(_("ZEROIZE Switch Cover, OPEN/CLOSE"),devices.INTERCOM, intercom_commands.ZeroizeSwCvr,694)
            // 	AddFunction( 3position(this, INTERCOM, "", "695", "INTERCOM","ZEROIZE Switch, OFP/OFF/DATA",%%));    		    //     default_3_position_tumb_small(_("ZEROIZE Switch, OFP/OFF/DATA"),devices.INTERCOM, intercom_commands.ZeroizeSw,695)
            #endregion
            #region HMCS
            // 	AddFunction( axis(this, HMCS, "", "392", "HMCS","HMCS SYMBOLOGY INT Knob",%%));    		    //     default_axis_limited(_("HMCS SYMBOLOGY INT Knob"),devices.HMCS, hmcs_commands.IntKnob,392)
            #endregion
            #region RWR
            // 	AddFunction( axis(this, RWR, "", " {", "RWR","RWR Intensity Knob - Rotate to adjust brightness",%%));    		    //     default_axis_limited(_("RWR Intensity Knob - Rotate to adjust brightness"),devices.RWR, rwr_commands.IntKnob,140, 0, 0.1, NOT_UPDATABLE, NOT_RELATIVE, {
            // 	AddFunction( new PushButton(this, RWR, "", "141", "RWR Indicator Control","HANDOFF Button",%%));    		    //     short_way_button(_("RWR Indicator Control HANDOFF Button"),devices.RWR, rwr_commands.Handoff,141)
            // 	AddFunction( new PushButton(this, RWR, "", "143", "RWR Indicator Control","LAUNCH Button",%%));    		    //     short_way_button(_("RWR Indicator Control LAUNCH Button"),devices.RWR, rwr_commands.Launch,143)
            // 	AddFunction( new PushButton(this, RWR, "", "145", "RWR Indicator Control","MODE Button",%%));    		    //     short_way_button(_("RWR Indicator Control MODE Button"),devices.RWR, rwr_commands.Mode,145)
            // 	AddFunction( new PushButton(this, RWR, "", "147", "RWR Indicator Control","UNKNOWN SHIP Button",%%));    		    //     short_way_button(_("RWR Indicator Control UNKNOWN SHIP Button"),devices.RWR, rwr_commands.UnknownShip,147)
            // 	AddFunction( new PushButton(this, RWR, "", "149", "RWR Indicator Control","SYS TEST Button",%%));    		    //     short_way_button(_("RWR Indicator Control SYS TEST Button"),devices.RWR, rwr_commands.SysTest,149)
            // 	AddFunction( new PushButton(this, RWR, "", "151", "RWR Indicator Control","T Button",%%));    		    //     short_way_button(_("RWR Indicator Control T Button"),devices.RWR, rwr_commands.TgtSep,151)
            // 	AddFunction( axis(this, RWR, "", "404", "RWR Indicator Control","DIM Knob - Rotate to adjust brightness",%%));    		    //     default_axis_limited(_("RWR Indicator Control DIM Knob - Rotate to adjust brightness"),devices.RWR, rwr_commands.BrtKnob,404)
            // 	AddFunction( new PushButton(this, RWR, "", "395", "RWR Indicator Control","SEARCH Button",%%));    		    //     short_way_button(_("RWR Indicator Control SEARCH Button"),devices.RWR, rwr_commands.Search,395)
            // 	AddFunction( new PushButton(this, RWR, "", "397", "RWR Indicator Control","ACT/PWR Button",%%));    		    //     short_way_button(_("RWR Indicator Control ACT/PWR Button"),devices.RWR, rwr_commands.ActPwr,397)
            // 	AddFunction( new PushButton(this, RWR, "", "399", "RWR Indicator Control","ALTITUDE Button",%%));    		    //     short_way_button(_("RWR Indicator Control ALTITUDE Button"),devices.RWR, rwr_commands.Altitude,399)
            // 	AddFunction( Switch.CreateToggleSwitch(this, RWR, "", "401", "RWR Indicator Control","POWER Button",%%));    		    //     default_2_position_tumb(_("RWR Indicator Control POWER Button"),devices.RWR, rwr_commands.Power,401)
            #endregion
            #region CMDS
            // 	AddFunction( new PushButton(this, CMDS, "", "604", "CMDS","CHAFF/FLARE Dispense Button - Push to dispense",%%));    		    //     default_button(_("CHAFF/FLARE Dispense Button - Push to dispense"),devices.CMDS, cmds_commands.DispBtn,604)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "375", "CMDS","RWR Source Switch, ON/OFF",%%));    		    //     default_2_position_tumb_small(_("RWR Source Switch, ON/OFF"),devices.CMDS, cmds_commands.RwrSrc,375)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "374", "CMDS","JMR Source Switch, ON/OFF",%%));    		    //     default_2_position_tumb_small(_("JMR Source Switch, ON/OFF"),devices.CMDS, cmds_commands.JmrSrc,374)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "373", "CMDS","MWS Source Switch, ON/OFF (no function)",%%));    		    //     default_2_position_tumb_small(_("MWS Source Switch, ON/OFF (no function)"),devices.CMDS, cmds_commands.MwsSrc,373)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "371", "CMDS","Jettison Switch, JETT/OFF",%%));    		    //     default_2_position_tumb(_("Jettison Switch, JETT/OFF"),devices.CMDS, cmds_commands.Jett,371)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "365", "CMDS","O1 Expendable Category Switch, ON/OFF",%%));    		    //     default_2_position_tumb_small(_("O1 Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.O1Exp,365)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "366", "CMDS","O2 Expendable Category Switch, ON/OFF",%%));    		    //     default_2_position_tumb_small(_("O2 Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.O2Exp,366)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "367", "CMDS","CH Expendable Category Switch, ON/OFF",%%));    		    //     default_2_position_tumb_small(_("CH Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.ChExp,367)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CMDS, "", "368", "CMDS","FL Expendable Category Switch, ON/OFF",%%));    		    //     default_2_position_tumb_small(_("FL Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.FlExp,368)
            // 	AddFunction( switch(this, CMDS, "", " NOT_CY", "CMDS","PROGRAM Knob, BIT/1/2/3/4",%%));    		    //     multiposition_switch(_("PROGRAM Knob, BIT/1/2/3/4"),devices.CMDS, cmds_commands.Prgm,377, 5, 0.1, NOT_INVERSED, 0.0, anim_speed_default, NOT_CY
            // 	AddFunction( switch(this, CMDS, "", " anim_speed_defaul", "CMDS","MODE Knob, OFF/STBY/MAN/SEMI/AUTO/BYP",%%));    		    //     multiposition_switch(_("MODE Knob, OFF/STBY/MAN/SEMI/AUTO/BYP"),devices.CMDS, cmds_commands.Mode,378, 6, 0.1, NOT_INVERSED, 0.0, anim_speed_defaul
            #endregion
            #region MFD Left
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "300", "Left MFD","OSB 1",%%));    		    //     mfd_button(_("Left MFD OSB 1"),devices.MFD_LEFT, mfd_commands.OSB_1,300)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "301", "Left MFD","OSB 2",%%));    		    //     mfd_button(_("Left MFD OSB 2"),devices.MFD_LEFT, mfd_commands.OSB_2,301)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "302", "Left MFD","OSB 3",%%));    		    //     mfd_button(_("Left MFD OSB 3"),devices.MFD_LEFT, mfd_commands.OSB_3,302)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "303", "Left MFD","OSB 4",%%));    		    //     mfd_button(_("Left MFD OSB 4"),devices.MFD_LEFT, mfd_commands.OSB_4,303)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "304", "Left MFD","OSB 5",%%));    		    //     mfd_button(_("Left MFD OSB 5"),devices.MFD_LEFT, mfd_commands.OSB_5,304)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "305", "Left MFD","OSB 6",%%));    		    //     mfd_button(_("Left MFD OSB 6"),devices.MFD_LEFT, mfd_commands.OSB_6,305)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "306", "Left MFD","OSB 7",%%));    		    //     mfd_button(_("Left MFD OSB 7"),devices.MFD_LEFT, mfd_commands.OSB_7,306)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "307", "Left MFD","OSB 8",%%));    		    //     mfd_button(_("Left MFD OSB 8"),devices.MFD_LEFT, mfd_commands.OSB_8,307)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "308", "Left MFD","OSB 9",%%));    		    //     mfd_button(_("Left MFD OSB 9"),devices.MFD_LEFT, mfd_commands.OSB_9,308)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "309", "Left MFD","OSB 10",%%));    		    //     mfd_button(_("Left MFD OSB 10"),devices.MFD_LEFT, mfd_commands.OSB_10,309)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "310", "Left MFD","OSB 11",%%));    		    //     mfd_button(_("Left MFD OSB 11"),devices.MFD_LEFT, mfd_commands.OSB_11,310)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "311", "Left MFD","OSB 12",%%));    		    //     mfd_button(_("Left MFD OSB 12"),devices.MFD_LEFT, mfd_commands.OSB_12,311)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "312", "Left MFD","OSB 13",%%));    		    //     mfd_button(_("Left MFD OSB 13"),devices.MFD_LEFT, mfd_commands.OSB_13,312)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "313", "Left MFD","OSB 14",%%));    		    //     mfd_button(_("Left MFD OSB 14"),devices.MFD_LEFT, mfd_commands.OSB_14,313)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "314", "Left MFD","OSB 15",%%));    		    //     mfd_button(_("Left MFD OSB 15"),devices.MFD_LEFT, mfd_commands.OSB_15,314)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "315", "Left MFD","OSB 16",%%));    		    //     mfd_button(_("Left MFD OSB 16"),devices.MFD_LEFT, mfd_commands.OSB_16,315)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "316", "Left MFD","OSB 17",%%));    		    //     mfd_button(_("Left MFD OSB 17"),devices.MFD_LEFT, mfd_commands.OSB_17,316)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "317", "Left MFD","OSB 18",%%));    		    //     mfd_button(_("Left MFD OSB 18"),devices.MFD_LEFT, mfd_commands.OSB_18,317)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "318", "Left MFD","OSB 19",%%));    		    //     mfd_button(_("Left MFD OSB 19"),devices.MFD_LEFT, mfd_commands.OSB_19,318)
            // 	AddFunction( new PushButton(this, MFD_LEFT, "", "319", "Left MFD","OSB 20",%%));    		    //     mfd_button(_("Left MFD OSB 20"),devices.MFD_LEFT, mfd_commands.OSB_20,319)
            // 	AddFunction( Rockerswitchpositive(this, MFD_LEFT, "", " 320", "Left MFD","GAIN Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Left MFD GAIN Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.GAIN_Rocker_UP, 320)
            // 	AddFunction( Rockerswitchnegative(this, MFD_LEFT, "", " 320", "Left MFD","GAIN Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Left MFD GAIN Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.GAIN_Rocker_DOWN, 320)
            // 	AddFunction( Rockerswitchpositive(this, MFD_LEFT, "", " 321", "Left MFD","SYM Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Left MFD SYM Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.SYM_Rocker_UP, 321)
            // 	AddFunction( Rockerswitchnegative(this, MFD_LEFT, "", " 321", "Left MFD","SYM Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Left MFD SYM Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.SYM_Rocker_DOWN, 321)
            // 	AddFunction( Rockerswitchpositive(this, MFD_LEFT, "", " 322", "Left MFD","CON Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Left MFD CON Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.CON_Rocker_UP, 322)
            // 	AddFunction( Rockerswitchnegative(this, MFD_LEFT, "", " 322", "Left MFD","CON Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Left MFD CON Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.CON_Rocker_DOWN, 322)
            // 	AddFunction( Rockerswitchpositive(this, MFD_LEFT, "", " 323", "Left MFD","BRT Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Left MFD BRT Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.BRT_Rocker_UP, 323)
            // 	AddFunction( Rockerswitchnegative(this, MFD_LEFT, "", " 323", "Left MFD","BRT Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Left MFD BRT Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.BRT_Rocker_DOWN, 323)
            #endregion
            #region MFD Right
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "326", "Right MFD","OSB 1",%%));    		    //     mfd_button(_("Right MFD OSB 1"),devices.MFD_RIGHT, mfd_commands.OSB_1,326)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "327", "Right MFD","OSB 2",%%));    		    //     mfd_button(_("Right MFD OSB 2"),devices.MFD_RIGHT, mfd_commands.OSB_2,327)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "328", "Right MFD","OSB 3",%%));    		    //     mfd_button(_("Right MFD OSB 3"),devices.MFD_RIGHT, mfd_commands.OSB_3,328)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "329", "Right MFD","OSB 4",%%));    		    //     mfd_button(_("Right MFD OSB 4"),devices.MFD_RIGHT, mfd_commands.OSB_4,329)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "330", "Right MFD","OSB 5",%%));    		    //     mfd_button(_("Right MFD OSB 5"),devices.MFD_RIGHT, mfd_commands.OSB_5,330)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "331", "Right MFD","OSB 6",%%));    		    //     mfd_button(_("Right MFD OSB 6"),devices.MFD_RIGHT, mfd_commands.OSB_6,331)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "332", "Right MFD","OSB 7",%%));    		    //     mfd_button(_("Right MFD OSB 7"),devices.MFD_RIGHT, mfd_commands.OSB_7,332)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "333", "Right MFD","OSB 8",%%));    		    //     mfd_button(_("Right MFD OSB 8"),devices.MFD_RIGHT, mfd_commands.OSB_8,333)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "334", "Right MFD","OSB 9",%%));    		    //     mfd_button(_("Right MFD OSB 9"),devices.MFD_RIGHT, mfd_commands.OSB_9,334)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "335", "Right MFD","OSB 10",%%));    		    //     mfd_button(_("Right MFD OSB 10"),devices.MFD_RIGHT, mfd_commands.OSB_10,335)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "336", "Right MFD","OSB 11",%%));    		    //     mfd_button(_("Right MFD OSB 11"),devices.MFD_RIGHT, mfd_commands.OSB_11,336)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "337", "Right MFD","OSB 12",%%));    		    //     mfd_button(_("Right MFD OSB 12"),devices.MFD_RIGHT, mfd_commands.OSB_12,337)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "338", "Right MFD","OSB 13",%%));    		    //     mfd_button(_("Right MFD OSB 13"),devices.MFD_RIGHT, mfd_commands.OSB_13,338)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "339", "Right MFD","OSB 14",%%));    		    //     mfd_button(_("Right MFD OSB 14"),devices.MFD_RIGHT, mfd_commands.OSB_14,339)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "340", "Right MFD","OSB 15",%%));    		    //     mfd_button(_("Right MFD OSB 15"),devices.MFD_RIGHT, mfd_commands.OSB_15,340)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "341", "Right MFD","OSB 16",%%));    		    //     mfd_button(_("Right MFD OSB 16"),devices.MFD_RIGHT, mfd_commands.OSB_16,341)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "342", "Right MFD","OSB 17",%%));    		    //     mfd_button(_("Right MFD OSB 17"),devices.MFD_RIGHT, mfd_commands.OSB_17,342)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "343", "Right MFD","OSB 18",%%));    		    //     mfd_button(_("Right MFD OSB 18"),devices.MFD_RIGHT, mfd_commands.OSB_18,343)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "344", "Right MFD","OSB 19",%%));    		    //     mfd_button(_("Right MFD OSB 19"),devices.MFD_RIGHT, mfd_commands.OSB_19,344)
            // 	AddFunction( new PushButton(this, MFD_RIGHT, "", "345", "Right MFD","OSB 20",%%));    		    //     mfd_button(_("Right MFD OSB 20"),devices.MFD_RIGHT, mfd_commands.OSB_20,345)
            // 	AddFunction( Rockerswitchpositive(this, MFD_RIGHT, "", " 346", "Right MFD","GAIN Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Right MFD GAIN Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.GAIN_Rocker_UP, 346)
            // 	AddFunction( Rockerswitchnegative(this, MFD_RIGHT, "", " 346", "Right MFD","GAIN Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Right MFD GAIN Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.GAIN_Rocker_DOWN, 346)
            // 	AddFunction( Rockerswitchpositive(this, MFD_RIGHT, "", " 347", "Right MFD","SYM Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Right MFD SYM Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.SYM_Rocker_UP, 347)
            // 	AddFunction( Rockerswitchnegative(this, MFD_RIGHT, "", " 347", "Right MFD","SYM Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Right MFD SYM Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.SYM_Rocker_DOWN, 347)
            // 	AddFunction( Rockerswitchpositive(this, MFD_RIGHT, "", " 348", "Right MFD","CON Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Right MFD CON Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.CON_Rocker_UP, 348)
            // 	AddFunction( Rockerswitchnegative(this, MFD_RIGHT, "", " 348", "Right MFD","CON Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Right MFD CON Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.CON_Rocker_DOWN, 348)
            // 	AddFunction( Rockerswitchpositive(this, MFD_RIGHT, "", " 349", "Right MFD","BRT Rocker Switch, Up/Increase",%%));    		    //     Rocker_switch_positive(_("Right MFD BRT Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.BRT_Rocker_UP, 349)
            // 	AddFunction( Rockerswitchnegative(this, MFD_RIGHT, "", " 349", "Right MFD","BRT Rocker Switch, Down/Decrease",%%));    		    //     Rocker_switch_negative(_("Right MFD BRT Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.BRT_Rocker_DOWN, 349)
            #endregion
            #region Instruments
            #endregion
            #region Airspeed/Mach Indicator
            // 	AddFunction( axis(this, MI, "", " true", "MI","SET INDEX Knob",%%));    		    //     default_axis(_("SET INDEX Knob"), devices.AMI, ami_commands.SettingKnob, 71, 0, 0.05, true, true, true)
            #endregion
            #region Altimeter
            // 	AddFunction( axis(this, AAU34, "", " true", "AAU34","Barometric Setting Knob",%%));    		    //     default_axis(_("Barometric Setting Knob"),devices.AAU34, alt_commands.ZERO, 62, 0, 0.1, true, true, true)
            // 	AddFunction( 3pos(this, AAU34, "", "60", "AAU34","Mode Lever, ELEC/OFF/PNEU",%%));    		    //     springloaded_3_pos_tumb(_("Mode Lever, ELEC/OFF/PNEU"),devices.AAU34, alt_commands.ELEC, alt_commands.PNEU, 60)
            #endregion
            #region SAI
            #endregion
            #region ADI
            // 	AddFunction( axis(this, ADI, "", "22", "ADI","Pitch Trim Knob",%%));    		    //     default_axis_limited(_("Pitch Trim Knob"),devices.ADI, device_commands.Button_1, 22)
            #endregion
            #region EHSI
            // 	AddFunction( new PushButtonknob(this, EHSI, "", "44", "EHSI","CRS Set / Brightness Control Knob",%%));    		    //     default_button_knob(_("CRS Set / Brightness Control Knob"),devices.EHSI, ehsi_commands.RightKnobBtn, ehsi_commands.RightKnob, 43, 44)
            // 	AddFunction( new PushButtonknob(this, EHSI, "", "45", "EHSI","HDG Set Knob",%%));    		    //     default_button_knob(_("HDG Set Knob"),devices.EHSI, ehsi_commands.LeftKnobBtn, ehsi_commands.LeftKnob, 42, 45)
            // 	AddFunction( new PushButton(this, EHSI, "", "46", "EHSI","Mode (M) Button",%%));    		    //     default_button(_("Mode (M) Button"),devices.EHSI, ehsi_commands.ModeBtn, 46)
            #endregion
            #region Clock
            // 	AddFunction( new PushButton(this, LOCK, "", "628", "LOCK","Clock Elapsed Time Knob",%%));    		    //     default_button(_("Clock Elapsed Time Knob"), devices.CLOCK, clock_commands.CLOCK_right_lev_down, 628)
            #endregion
            #region Cockpit Mechanics
            // 	AddFunction( Switch.CreateToggleSwitch(this, CPT_MECH, "", "600", "CPT MECH","Canopy Handle, UP/DOWN",%%));    		    //     default_2_position_tumb(_("Canopy Handle, UP/DOWN"),devices.CPT_MECH, cpt_commands.CanopyHandle, 600)
            // 	AddFunction( 3pos(this, CPT_MECH, "", "786", "CPT MECH","SEAT ADJ Switch, UP/OFF/DOWN",%%));    		    //     springloaded_3_pos_tumb_small(_("SEAT ADJ Switch, UP/OFF/DOWN"),devices.CPT_MECH, cpt_commands.SeatAdjSwitchDown, cpt_commands.SeatAdjSwitchUp, 786)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CPT_MECH, "", "601", "CPT MECH","CANOPY JETTISON T-Handle, PULL/STOW",%%));    		    //     default_2_position_tumb(_("CANOPY JETTISON T-Handle, PULL/STOW"),devices.CPT_MECH, cpt_commands.CanopyTHandle, 601)
            // 	AddFunction( Switch.CreateToggleSwitch(this, CPT_MECH, "", "785", "CPT MECH","Ejection Safety Lever, ARMED/LOCKED",%%));    		    //     default_2_position_tumb(_("Ejection Safety Lever, ARMED/LOCKED"),devices.CPT_MECH, cpt_commands.EjectionSafetyLever, 785)
            // 	AddFunction( new PushButton(this, CPT_MECH, "", "60", "CPT MECH","Canopy Switch, OPEN/HOLD/CLOSE(momentarily)",%%));    		    //     default_button_tumb(_("Canopy Switch, OPEN/HOLD/CLOSE(momentarily)"),devices.CPT_MECH, cpt_commands.CanopySwitchClose, cpt_commands.CanopySwitchOpen, 60
            #endregion


            #region  Left MFD
            AddFunction(new Switch(this, MFD_LEFT, "320", new SwitchPosition[] { new SwitchPosition("0.0", "OFF", "3001"), new SwitchPosition("0.5", "NIGHT", "3001"), new SwitchPosition("1.0", "DAY", "3001") }, "Left MFD", "Left MFD Brightness Selector Knob", "%0.1f"));    // elements["pnt_51"]      = default_3_position_tumb(_("Left MFD Brightness Selector Knob, OFF/NIGHT/DAY"),    devices.MFD_LEFT, MFD_commands.MFD_off_night_day, 51, false, anim_speed_default, false, 0.1, {0, 0.2})
            AddFunction(new Axis(this, MFD_LEFT, "3002", "52", 0.15d, 0d, 1d, "Left MFD", "Left MFD Brightness Control Knob"));    // elements["pnt_52"]      = default_axis_limited(_("Left MFD Brightness Control Knob"),                       devices.MFD_LEFT, MFD_commands.MFD_brightness, 52, 0.0, 0.1, false, false, {0, 1})
            AddFunction(new Axis(this, MFD_LEFT, "3003", "53", 0.15d, 0d, 1d, "Left MFD", "Left MFD Contrast Control Knob"));    // elements["pnt_53"]      = default_axis_limited(_("Left MFD Contrast Control Knob"),                         devices.MFD_LEFT, MFD_commands.MFD_contrast, 53, 0.0, 0.1, false, false, {0, 1})
            AddFunction(new PushButton(this, MFD_LEFT, "3011", "300", "Left MFD", "OSB 01", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3012", "301", "Left MFD", "OSB 02", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3013", "302", "Left MFD", "OSB 03", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3014", "303", "Left MFD", "OSB 04", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3015", "304", "Left MFD", "OSB 05", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3016", "305", "Left MFD", "OSB 06", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3017", "306", "Left MFD", "OSB 07", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3018", "307", "Left MFD", "OSB 08", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3019", "308", "Left MFD", "OSB 09", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3020", "309", "Left MFD", "OSB 10", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3021", "310", "Left MFD", "OSB 11", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3022", "311", "Left MFD", "OSB 12", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3023", "312", "Left MFD", "OSB 13", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3024", "313", "Left MFD", "OSB 14", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3025", "314", "Left MFD", "OSB 15", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3026", "315", "Left MFD", "OSB 16", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3027", "316", "Left MFD", "OSB 17", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3028", "317", "Left MFD", "OSB 18", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3029", "318", "Left MFD", "OSB 19", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_LEFT, "3030", "319", "Left MFD", "OSB 20", "1", "0", "%1d"));
            #endregion
            #region  Right MFD
            AddFunction(new Switch(this, MFD_RIGHT, "346", new SwitchPosition[] { new SwitchPosition("0.0", "OFF", "3001"), new SwitchPosition("0.5", "NIGHT", "3001"), new SwitchPosition("1.0", "DAY", "3001") }, "Right MFD", "Right MFD Brightness Selector Knob", "%0.1f"));    // elements["pnt_76"]      = default_3_position_tumb(_("Right MFD Brightness Selector Knob, OFF/NIGHT/DAY"),   devices.MFD_RIGHT, MFD_commands.MFD_off_night_day, 76, false, anim_speed_default, false, 0.1, {0, 0.2})
            AddFunction(new Axis(this, MFD_RIGHT, "3002", "77", 0.15d, 0d, 1d, "Right MFD", "Right MFD Brightness Control Knob"));    // elements["pnt_77"]      = default_axis_limited(_("Right MFD Brightness Control Knob"),                      devices.MFD_RIGHT, MFD_commands.MFD_brightness, 77, 0.0, 0.1, false, false, {0, 1})
            AddFunction(new Axis(this, MFD_RIGHT, "3003", "78", 0.15d, 0d, 1d, "Right MFD", "Right MFD Contrast Control Knob"));    // elements["pnt_78"]      = default_axis_limited(_("Right MFD Contrast Control Knob"),                        devices.MFD_RIGHT, MFD_commands.MFD_contrast, 78, 0.0, 0.1, false, false, {0, 1})
            AddFunction(new PushButton(this, MFD_RIGHT, "3011", "326", "Right MFD", "OSB 01", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3012", "327", "Right MFD", "OSB 02", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3013", "328", "Right MFD", "OSB 03", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3014", "329", "Right MFD", "OSB 04", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3015", "330", "Right MFD", "OSB 05", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3016", "331", "Right MFD", "OSB 06", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3017", "332", "Right MFD", "OSB 07", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3018", "333", "Right MFD", "OSB 08", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3019", "334", "Right MFD", "OSB 09", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3020", "335", "Right MFD", "OSB 10", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3021", "336", "Right MFD", "OSB 11", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3022", "337", "Right MFD", "OSB 12", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3023", "338", "Right MFD", "OSB 13", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3024", "339", "Right MFD", "OSB 14", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3025", "340", "Right MFD", "OSB 15", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3026", "341", "Right MFD", "OSB 16", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3027", "342", "Right MFD", "OSB 17", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3028", "343", "Right MFD", "OSB 18", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3029", "344", "Right MFD", "OSB 19", "1", "0", "%1d"));
            AddFunction(new PushButton(this, MFD_RIGHT, "3030", "345", "Right MFD", "OSB 20", "1", "0", "%1d"));
            #endregion

            #region Instrument parsed values

            #endregion
        }

        private string DCSPath
        {
            get
            {
                if (_dcsPath == null)
                {
                    RegistryKey pathKey = Registry.CurrentUser.OpenSubKey(@"Software\Eagle Dynamics\DCS World");
                    if (pathKey != null)
                    {
                        _dcsPath = (string)pathKey.GetValue("Path");
                        pathKey.Close();
                        ConfigManager.LogManager.LogDebug("DCS F-16C Interface Editor - Found DCS Path (Path=\"" + _dcsPath + "\")");
                    }
                    else
                    {
                        _dcsPath = "";
                    }
                }
                return _dcsPath;
            }
        }

        protected override void OnProfileChanged(HeliosProfile oldProfile)
        {
            base.OnProfileChanged(oldProfile);

            if (oldProfile != null)
            {
                oldProfile.ProfileTick -= Profile_Tick;
            }

            if (Profile != null)
            {
                Profile.ProfileTick += Profile_Tick;
            }
        }

        void Profile_Tick(object sender, EventArgs e)
        {
            if (_phantomFix && System.Environment.TickCount - _nextCheck >= 0)
            {
                System.Diagnostics.Process[] dcs = System.Diagnostics.Process.GetProcessesByName("DCS");
                if (dcs.Length == 1)
                {
                    IntPtr hWnd = dcs[0].MainWindowHandle;
                    NativeMethods.Rect dcsRect;
                    NativeMethods.GetWindowRect(hWnd, out dcsRect);

                    if (dcsRect.Width > 640 && (dcsRect.Left != _phantomLeft || dcsRect.Top != _phantomTop))
                    {
                        NativeMethods.MoveWindow(hWnd, _phantomLeft, _phantomTop, dcsRect.Width, dcsRect.Height, true);
                    }
                }
                _nextCheck = System.Environment.TickCount + 5000;
            }
        }
    }
}
