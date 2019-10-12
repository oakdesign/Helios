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
            AlternateName = "F-16C";           
            DCSConfigurator config = new DCSConfigurator("DCS F-16C", DCSPath);
            config.ExportConfigPath = "Config\\Export";
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
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.DigitalBackup, "566", "1.0", "OFF", "0.0", "BACKUP", "Control Interface", "DIGITAL BACKUP Switch, OFF/BACKUP", "0.1f"));// default_2_position_tumb(_("DIGITAL BACKUP Switch, OFF/BACKUP"),devices.CONTROL_INTERFACE, control_commands.DigitalBackup,566)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.AltFlaps, "567", "1.0", "NORM", "0.0", "EXTEND", "Control Interface", "ALT Flaps Switch, NORM/Extend", "0.1f"));// default_2_position_tumb(_("ALT FLAPS Switch, NORM/EXTEND"),devices.CONTROL_INTERFACE, control_commands.AltFlaps,567)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.BitSw, "574", "1.0", "OFF", "0.0", "BIT", "Control Interface", "BIT Switch, OFF/BIT", "0.1f"));// springloaded_2_pos_tumb(_("BIT Switch, OFF/BIT"),devices.CONTROL_INTERFACE, control_commands.BitSw,574)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.FlcsReset, "573", "1.0", "OFF", "0.0", "RESET", "Control Interface", "FLCS RESET Switch, OFF/RESET", "0.1f"));// springloaded_2_pos_tumb_small(_("FLCS RESET Switch, OFF/RESET"),devices.CONTROL_INTERFACE, control_commands.FlcsReset,573)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.LeFlaps, "572", "1.0", "AUTO", "0.0", "LOCK", "Control Interface", "LE Flaps Switch, AUTO/LOCK", "0.1f"));// default_2_position_tumb(_("LE FLAPS Switch, AUTO/LOCK"),devices.CONTROL_INTERFACE, control_commands.LeFlaps,572)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.TrimApDisc, "564", "1.0", "DISC", "0.0", "NORM", "Control Interface", "TRIM/AP DISC Switch, DISC/NORM", "0.1f"));// default_2_position_tumb(_("TRIM/AP DISC Switch, DISC/NORM"),devices.CONTROL_INTERFACE, control_commands.TrimApDisc,564)
            AddFunction(new Axis(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.RollTrim, "NOT_RELATIV", 0.01d, 0.0d, 1.0d, "Control Interface", "ROLL TRIM Wheel"));// default_axis_limited(_("ROLL TRIM Wheel"),devices.CONTROL_INTERFACE, control_commands.RollTrim,560, 0.0, 0.1, NOT_UPDATABLE, NOT_RELATIV
            AddFunction(new Axis(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.PitchTrim, "NOT_RELA", 0.01d, 0.0d, 1.0d, "Control Interface", "PITCH TRIM Wheel"));// default_axis_limited(_("PITCH TRIM Wheel"),devices.CONTROL_INTERFACE, control_commands.PitchTrim,562, 0.0, 0.1, NOT_UPDATABLE, NOT_RELA
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.ManualPitchOverride, "425", "1.0", "OVRD", "0.0", "NORM", "Control Interface", "MANUAL PITCH Override Switch, OVRD/NORM", "0.1f"));// springloaded_2_pos_tumb_small(_("MANUAL PITCH Override Switch, OVRD/NORM"),devices.CONTROL_INTERFACE, control_commands.ManualPitchOverride,425)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.StoresConfig, "358", "1.0", "CAT III", "0.0", "CAT I", "Control Interface", "STORES CONFIG Switch, CAT III/CAT I", "0.1f"));// default_2_position_tumb_small(_("STORES CONFIG Switch, CAT III/CAT I"),devices.CONTROL_INTERFACE, control_commands.StoresConfig,358)
            AddFunction(new Switch(this, (int)devices.CONTROL_INTERFACE, "control_comma", new SwitchPosition[] { new SwitchPosition("1", "ATT HOLD", (int)control_commands.ApPitchAtt), new SwitchPosition("0.5", "A", (int)control_commands.ApPitchAtt), new SwitchPosition("0", "P OFF", (int)control_commands.ApPitchAtt) }, "Control Interface", "Autopilot PITCH Switch, ATT HOLD/ A/P OFF/ ALT HOLD", "0.1f"));// springloaded_3_pos_tumb(_("Autopilot PITCH Switch, ATT HOLD/ A/P OFF/ ALT HOLD"),devices.CONTROL_INTERFACE, control_commands.ApPitchAtt, control_comma
            AddFunction(new Switch(this, (int)devices.CONTROL_INTERFACE, "108", new SwitchPosition[] { new SwitchPosition("1", "STRG SEL", (int)control_commands.ApRoll), new SwitchPosition("0.5", "ATT HOLD", (int)control_commands.ApRoll), new SwitchPosition("0", "HDG SEL", (int)control_commands.ApRoll) }, "Control Interface", "Autopilot ROLL Switch, STRG SEL/ATT HOLD/HDG SEL", "0.1f"));// default_3_position_tumb_small(_("Autopilot ROLL Switch, STRG SEL/ATT HOLD/HDG SEL"),devices.CONTROL_INTERFACE, control_commands.ApRoll,108)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.AdvMode, "97", "1.0", "", "0.0", "", "Control Interface", "ADV MODE Switch", "0.1f"));// default_2_position_tumb(_("ADV MODE Switch"),devices.CONTROL_INTERFACE, control_commands.AdvMode,97)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CONTROL_INTERFACE, (int)control_commands.ManualTfFlyup, "568", "1.0", "ENABLE", "0.0", "DISABLE", "Control Interface", "MANUAL TF FLYUP Switch, ENABLE/DISABLE", "0.1f"));// default_2_position_tumb(_("MANUAL TF FLYUP Switch, ENABLE/DISABLE"),devices.CONTROL_INTERFACE, control_commands.ManualTfFlyup,568)
            #endregion
            #region External Lights
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.EXTLIGHTS_SYSTEM, (int)extlights_commands.PosFlash, "532", "1.0", "FLASH", "0.0", "STEADY", "External Lights System", "FLASH STEADY Switch, FLASH/STEADY", "0.1f"));// default_2_position_tumb_small(_("FLASH STEADY Switch, FLASH/STEADY"),devices.EXTLIGHTS_SYSTEM, extlights_commands.PosFlash,532)
            AddFunction(new Switch(this, (int)devices.EXTLIGHTS_SYSTEM, "533", new SwitchPosition[] { new SwitchPosition("1", "BRT", (int)extlights_commands.PosWingTail), new SwitchPosition("0.5", "OFF", (int)extlights_commands.PosWingTail), new SwitchPosition("0", "DIM", (int)extlights_commands.PosWingTail) }, "External Lights System", "WING/TAIL Switch, BRT/OFF/DIM", "0.1f"));// default_3_position_tumb_small(_("WING/TAIL Switch, BRT/OFF/DIM"),devices.EXTLIGHTS_SYSTEM, extlights_commands.PosWingTail,533)
            AddFunction(new Switch(this, (int)devices.EXTLIGHTS_SYSTEM, "534", new SwitchPosition[] { new SwitchPosition("1", "BRT", (int)extlights_commands.PosFus), new SwitchPosition("0.5", "OFF", (int)extlights_commands.PosFus), new SwitchPosition("0", "DIM", (int)extlights_commands.PosFus) }, "External Lights System", "FUSELAGE Switch, BRT/OFF/DIM", "0.1f"));// default_3_position_tumb_small(_("FUSELAGE Switch, BRT/OFF/DIM"),devices.EXTLIGHTS_SYSTEM, extlights_commands.PosFus,534)
            AddFunction(new Axis(this, (int)devices.EXTLIGHTS_SYSTEM, (int)extlights_commands.FormKn, "535", 0.01d, 0.0d, 1.0d, "External Lights System", "FORM Knob"));// default_axis_limited(_("FORM Knob"),devices.EXTLIGHTS_SYSTEM, extlights_commands.FormKn,535)
            AddFunction(new Switch(this, (int)devices.EXTLIGHTS_SYSTEM, "0", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)extlights_commands.Master), new SwitchPosition("0.25", "ALL", (int)extlights_commands.Master), new SwitchPosition("0.5", "A-C", (int)extlights_commands.Master), new SwitchPosition("0.75", "FORM", (int)extlights_commands.Master), new SwitchPosition("1", "NORM", (int)extlights_commands.Master) }, "External Lights System", "MASTER Switch, OFF/ALL/A-C/FORM/NORM", "0.1f"));// multiposition_switch(_("MASTER Switch, OFF/ALL/A-C/FORM/NORM"),devices.EXTLIGHTS_SYSTEM, extlights_commands.Master,536, 5, 0.1, NOT_INVERSED, 0
            AddFunction(new Axis(this, (int)devices.EXTLIGHTS_SYSTEM, (int)extlights_commands.AerialRefuel, "537", 0.01d, 0.0d, 1.0d, "External Lights System", "AERIAL Refueling Knob"));// default_axis_limited(_("AERIAL REFUELING Knob"),devices.EXTLIGHTS_SYSTEM, extlights_commands.AerialRefuel,537)
            AddFunction(new Switch(this, (int)devices.EXTLIGHTS_SYSTEM, "360", new SwitchPosition[] { new SwitchPosition("1", "LANDING", (int)extlights_commands.LandingTaxi), new SwitchPosition("0.5", "OFF", (int)extlights_commands.LandingTaxi), new SwitchPosition("0", "TAXI", (int)extlights_commands.LandingTaxi) }, "External Lights System", "LANDING TAXI  Lights Switch, LANDING/OFF/TAXI", "0.1f"));// default_3_position_tumb_small(_("LANDING TAXI LIGHTS Switch, LANDING/OFF/TAXI"),devices.EXTLIGHTS_SYSTEM, extlights_commands.LandingTaxi,360)
            #endregion
            #region Interior Lights
            AddFunction(new PushButton(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.MasterCaution, "116", "Cockpit Lights System", "Master Caution Button - Push to reset"));// default_button(_("Master Caution Button - Push to reset"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.MasterCaution,116)
            AddFunction(new PushButton(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.MalIndLtsTest, "577", "Cockpit Lights System", "MAL & IND LTS Test Button - Push to test"));// default_button(_("MAL & IND LTS Test Button - Push to test"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.MalIndLtsTest,577)
            AddFunction(new Axis(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.Consoles, "NOT_RELA", 0.01d, 0.0d, 1.0d, "Cockpit Lights System", "PRIMARY CONSOLES BRT Knob"));// default_axis_limited(_("PRIMARY CONSOLES BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.Consoles,685, 0, 0.1, NOT_UPDATABLE, NOT_RELA
            AddFunction(new Axis(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.IntsPnl, "NOT_RELAT", 0.01d, 0.0d, 1.0d, "Cockpit Lights System", "PRIMARY INST PNL BRT Knob"));// default_axis_limited(_("PRIMARY INST PNL BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.IntsPnl,686, 0, 0.1, NOT_UPDATABLE, NOT_RELAT
            AddFunction(new Axis(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.DataEntryDisplay, "NOT_UPDATA", 0.01d, 0.0d, 1.0d, "Cockpit Lights System", "PRIMARY DATA ENTRY DISPLAY BRT Knob"));// default_axis_limited(_("PRIMARY DATA ENTRY DISPLAY BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.DataEntryDisplay,687, 0, 0.1, NOT_UPDATA
            AddFunction(new Axis(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.ConsolesFlood, "688", 0.01d, 0.0d, 1.0d, "Cockpit Lights System", "Flood CONSOLES BRT Knob"));// default_axis_limited(_("FLOOD CONSOLES BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.ConsolesFlood,688)
            AddFunction(new Axis(this, (int)devices.CPTLIGHTS_SYSTEM, (int)cptlights_commands.InstPnlFlood, "NOT_REL", 0.01d, 0.0d, 1.0d, "Cockpit Lights System", "Flood INST PNL BRT Knob"));// default_axis_limited(_("FLOOD INST PNL BRT Knob"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.InstPnlFlood,690, 0, 0.1, NOT_UPDATABLE, NOT_REL
            AddFunction(new Switch(this, (int)devices.CPTLIGHTS_SYSTEM, "cptlights_commands.", new SwitchPosition[] { new SwitchPosition("1", "BRT", (int)cptlights_commands.MalIndLtsDim), new SwitchPosition("0.5", "Center", (int)cptlights_commands.MalIndLtsDim), new SwitchPosition("0", "DIM", (int)cptlights_commands.MalIndLtsDim) }, "Cockpit Lights System", "MAL & IND LTS Switch, BRT/Center/DIM", "0.1f"));// springloaded_3_pos_tumb_small(_("MAL & IND LTS Switch, BRT/Center/DIM"),devices.CPTLIGHTS_SYSTEM, cptlights_commands.MalIndLtsDim, cptlights_commands.
            #endregion
            #region Electric System
            AddFunction(new Switch(this, (int)devices.ELEC_INTERFACE, "fal", new SwitchPosition[] { new SwitchPosition("1", "MAIN PWR", (int)elec_commands.MainPwrSw), new SwitchPosition("0.5", "BATT", (int)elec_commands.MainPwrSw), new SwitchPosition("0", "OFF", (int)elec_commands.MainPwrSw) }, "Elec Interface", "MAIN PWR Switch, MAIN PWR/BATT/OFF", "0.1f"));// default_3_position_tumb(_("MAIN PWR Switch, MAIN PWR/BATT/OFF"),devices.ELEC_INTERFACE, elec_commands.MainPwrSw,510, false, anim_speed_default, fal
            AddFunction(new PushButton(this, (int)devices.ELEC_INTERFACE, (int)elec_commands.CautionResetBtn, "511", "Elec Interface", "Elec CAUTION RESET Button - Push to reset"));// default_button(_("ELEC CAUTION RESET Button - Push to reset"),devices.ELEC_INTERFACE, elec_commands.CautionResetBtn,511)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.ELEC_INTERFACE, (int)elec_commands.EPU_GEN_TestSw, "579", "1.0", "EPU", "0.0", "GEN", "Elec Interface", "EPU/GEN Test Switch, EPU/GEN /OFF", "0.1f"));// springloaded_2_pos_tumb_small(_("EPU/GEN Test Switch, EPU/GEN /OFF"),devices.ELEC_INTERFACE, elec_commands.EPU_GEN_TestSw,579)
            AddFunction(new Switch(this, (int)devices.ELEC_INTERFACE, "578", new SwitchPosition[] { new SwitchPosition("1", "PROBE HEAT", (int)elec_commands.ProbeHeatSw), new SwitchPosition("0.5", "OFF", (int)elec_commands.ProbeHeatSw), new SwitchPosition("0", "HEAT", (int)elec_commands.ProbeHeatSw) }, "Elec Interface", "PROBE HEAT Switch, PROBE HEAT/OFF/HEAT", "0.1f"));// default_3_position_tumb_small(_("PROBE HEAT Switch, PROBE HEAT/OFF/HEAT"),devices.ELEC_INTERFACE, elec_commands.ProbeHeatSw,578)
            AddFunction(new PushButton(this, (int)devices.ELEC_INTERFACE, (int)elec_commands.FlcsPwrTestSwMAINT, "elec_commands.Fl", "Elec Interface", "FLCS PWR TEST Switch, MAInternal/NORM/TEST(momentarily)"));// default_tumb_button(_("FLCS PWR TEST Switch, MAINT/NORM/TEST(momentarily)"),devices.ELEC_INTERFACE, elec_commands.FlcsPwrTestSwMAINT, elec_commands.Fl
            #endregion
            #region Fuel System
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.FUEL_INTERFACE, (int)fuel_commands.FuelMasterSw, "559", "1.0", "MASTER", "0.0", "OFF", "Fuel Interface", "Fuel MASTER Switch, MASTER/OFF", "0.1f"));// default_2_position_tumb_small(_("FUEL MASTER Switch, MASTER/OFF"),devices.FUEL_INTERFACE, fuel_commands.FuelMasterSw,559)
                                                                                                                                                                                                                         //AddFunction((this, (int)devices.FUEL_INTERFACE, (int)fuel_commands.FuelMasterSwCvr, "558", "Fuel Interface", "Fuel MASTER Switch Cover, OPEN/CLOSE"));// default_red_cover(_("FUEL MASTER Switch Cover, OPEN/CLOSE"),devices.FUEL_INTERFACE, fuel_commands.FuelMasterSwCvr,558)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.FUEL_INTERFACE, (int)fuel_commands.TankInertingSw, "557", "1.0", "TANK INERTING", "0.0", "OFF", "Fuel Interface", "TANK INERTING Switch, TANK INERTING /OFF", "0.1f"));// default_2_position_tumb(_("TANK INERTING Switch, TANK INERTING /OFF"),devices.FUEL_INTERFACE, fuel_commands.TankInertingSw,557)
            AddFunction(new Switch(this, (int)devices.FUEL_INTERFACE, "NOT_INVERSE", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)fuel_commands.EngineFeedSw), new SwitchPosition("0.333333333333333", "NORM", (int)fuel_commands.EngineFeedSw), new SwitchPosition("0.666666666666667", "AFT", (int)fuel_commands.EngineFeedSw), new SwitchPosition("1", "FWD", (int)fuel_commands.EngineFeedSw) }, "Fuel Interface", "Engine FEED Knob, OFF/NORM/AFT/FWD", "0.1f"));// multiposition_switch(_("ENGINE FEED Knob, OFF/NORM/AFT/FWD"),devices.FUEL_INTERFACE, fuel_commands.EngineFeedSw,556, 4, 0.1, NOT_INVERSE
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.FUEL_INTERFACE, (int)fuel_commands.AirRefuelSw, "555", "1.0", "OPEN", "0.0", "CLOSE", "Fuel Interface", "AIR REFuel Switch, OPEN/CLOSE", "0.1f"));// default_2_position_tumb(_("AIR REFUEL Switch, OPEN/CLOSE"),devices.FUEL_INTERFACE, fuel_commands.AirRefuelSw,555)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.FUEL_INTERFACE, (int)fuel_commands.ExtFuelTransferSw, "159", "1.0", "NORM", "0.0", "WING FIRST", "Fuel Interface", "External Fuel Transfer Switch, NORM/ WING FIRST", "0.1f"));// default_2_position_tumb(_("External Fuel Transfer Switch, NORM/ WING FIRST"),devices.FUEL_INTERFACE, fuel_commands.ExtFuelTransferSw,159)
            #endregion
            #region Gear System
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.GEAR_INTERFACE, (int)gear_commands.LGHandle, "362", "1.0", "UP", "0.0", "DN", "Gear Interface", "LG Handle, UP/DN", "0.1f"));// default_2_position_tumb(_("LG Handle, UP/DN"),devices.GEAR_INTERFACE, gear_commands.LGHandle,362)
            AddFunction(new PushButton(this, (int)devices.GEAR_INTERFACE, (int)gear_commands.DownLockRelBtn, "361", "Gear Interface", "DN LOCK REL Button - Push to reset"));// default_button(_("DN LOCK REL Button - Push to reset"),devices.GEAR_INTERFACE, gear_commands.DownLockRelBtn,361)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.GEAR_INTERFACE, (int)gear_commands.HookSw, "354", "1.0", "UP", "0.0", "DN", "Gear Interface", "HOOK Switch, UP/DN", "0.1f"));// default_2_position_tumb(_("HOOK Switch, UP/DN"),devices.GEAR_INTERFACE, gear_commands.HookSw,354)
            AddFunction(new PushButton(this, (int)devices.GEAR_INTERFACE, (int)gear_commands.HornSilencerBtn, "359", "Gear Interface", "HORN SILENCER Button - Push to reset"));// default_button(_("HORN SILENCER Button - Push to reset"),devices.GEAR_INTERFACE, gear_commands.HornSilencerBtn,359)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.GEAR_INTERFACE, (int)gear_commands.BrakesChannelSw, "356", "1.0", "CHAN 1", "0.0", "CHAN 2", "Gear Interface", "BrakeS Channel Switch, CHAN 1/CHAN 2", "0.1f"));// default_2_position_tumb_small(_("BRAKES Channel Switch, CHAN 1/CHAN 2"),devices.GEAR_INTERFACE, gear_commands.BrakesChannelSw,356)
            AddFunction(new PushButton(this, (int)devices.GEAR_INTERFACE, (int)gear_commands.AntiSkidSw, "357", "Gear Interface", "ANTI-SKID Switch, Parking Brake/ANTI-SKID/OFF"));// default_tumb_button(_("ANTI-SKID Switch, PARKING BRAKE/ANTI-SKID/OFF"),devices.GEAR_INTERFACE, gear_commands.AntiSkidSw,gear_commands.ParkingSw,357)
            #endregion
            #region ECS
            AddFunction(new Axis(this, (int)devices.ECS_INTERFACE, (int)ecs_commands.TempKnob, "0.3}", 0.01d, 0.0d, 1.0d, "ECS Interface", "TEMP Knob"));// default_axis_limited(_("TEMP Knob"),devices.ECS_INTERFACE, ecs_commands.TempKnob, 692, 0.0, 0.1, false, false, {-0.3,0.3})
            AddFunction(new Switch(this, (int)devices.ECS_INTERFACE, "anim_", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)ecs_commands.AirSourceKnob), new SwitchPosition("0.333333333333333", "NORM", (int)ecs_commands.AirSourceKnob), new SwitchPosition("0.666666666666667", "DUMP", (int)ecs_commands.AirSourceKnob), new SwitchPosition("1", "RAM", (int)ecs_commands.AirSourceKnob) }, "ECS Interface", "AIR SOURCE Knob, OFF/NORM/DUMP/RAM", "0.1f"));// multiposition_switch(_("AIR SOURCE Knob, OFF/NORM/DUMP/RAM"),devices.ECS_INTERFACE, ecs_commands.AirSourceKnob, 693, 4, 0.1, NOT_INVERSED, 0.0, anim_
            AddFunction(new Axis(this, (int)devices.ECS_INTERFACE, (int)ecs_commands.DefogLever, "1}", 0.01d, 0.0d, 1.0d, "ECS Interface", "DEFOG Lever"));// default_axis_limited(_("DEFOG Lever"),devices.ECS_INTERFACE, ecs_commands.DefogLever, 602, 0.0, 0.1, true, false, {0,1})
            #endregion
            #region EPU
            //AddFunction((this, (int)devices.ENGINE_INTERFACE, (int)engine_commands.EpuSwCvrOn, "527", "Engine Interface", "EPU Switch Cover for ON, OPEN/CLOSE"));// default_red_cover(_("EPU Switch Cover for ON, OPEN/CLOSE"),devices.ENGINE_INTERFACE, engine_commands.EpuSwCvrOn,527)
            //AddFunction((this, (int)devices.ENGINE_INTERFACE, (int)engine_commands.EpuSwCvrOff, "529", "Engine Interface", "EPU Switch Cover for OFF, OPEN/CLOSE"));// default_red_cover(_("EPU Switch Cover for OFF, OPEN/CLOSE"),devices.ENGINE_INTERFACE, engine_commands.EpuSwCvrOff,529)
            AddFunction(new Switch(this, (int)devices.ENGINE_INTERFACE, "528", new SwitchPosition[] { new SwitchPosition("1", "ON", (int)engine_commands.EpuSw), new SwitchPosition("0.5", "NORM", (int)engine_commands.EpuSw), new SwitchPosition("0", "OFF", (int)engine_commands.EpuSw) }, "Engine Interface", "EPU Switch, ON/NORM/OFF", "0.1f"));// default_3_position_tumb_small(_("EPU Switch, ON/NORM/OFF"),devices.ENGINE_INTERFACE, engine_commands.EpuSw,528)
            #endregion
            #region engine
            AddFunction(new Switch(this, (int)devices.ENGINE_INTERFACE, "710", new SwitchPosition[] { new SwitchPosition("1", "ON", (int)engine_commands.EngAntiIceSw), new SwitchPosition("0.5", "AUTO", (int)engine_commands.EngAntiIceSw), new SwitchPosition("0", "OFF", (int)engine_commands.EngAntiIceSw) }, "Engine Interface", "Engine ANTI ICE Switch, ON/AUTO/OFF", "0.1f"));// default_3_position_tumb(_("Engine ANTI ICE Switch, ON/AUTO/OFF"),devices.ENGINE_INTERFACE, engine_commands.EngAntiIceSw,710)
            AddFunction(new Switch(this, (int)devices.ENGINE_INTERFACE, "engine_commands.JfsSwStar", new SwitchPosition[] { new SwitchPosition("1", "START 1", (int)engine_commands.JfsSwStart2), new SwitchPosition("0.5", "OFF", (int)engine_commands.JfsSwStart2), new SwitchPosition("0", "START 2", (int)engine_commands.JfsSwStart2) }, "Engine Interface", "JFS Switch, START 1/OFF/START 2", "0.1f"));// springloaded_3_pos_tumb(_("JFS Switch, START 1/OFF/START 2"),devices.ENGINE_INTERFACE, engine_commands.JfsSwStart2, engine_commands.JfsSwStar
                                                                                                                                                                                                                                                                                                                                                                                                              //AddFunction((this, (int)devices.ENGINE_INTERFACE, (int)engine_commands.EngContSwCvr, "448", "Engine Interface", "ENG CONT Switch Cover, OPEN/CLOSE"));// default_red_cover(_("ENG CONT Switch Cover, OPEN/CLOSE"),devices.ENGINE_INTERFACE, engine_commands.EngContSwCvr,448)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.ENGINE_INTERFACE, (int)engine_commands.EngContSw, "449", "1.0", "PRI", "0.0", "SEC", "Engine Interface", "ENG CONT Switch, PRI/SEC", "0.1f"));// default_2_position_tumb_small(_("ENG CONT Switch, PRI/SEC"),devices.ENGINE_INTERFACE, engine_commands.EngContSw,449)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.ENGINE_INTERFACE, (int)engine_commands.MaxPowerSw, "451", "1.0", "MAX POWER", "0.0", "OFF", "Engine Interface", "MAX POWER Switch (is inoperative), MAX POWER/OFF", "0.1f"));// default_2_position_tumb(_("MAX POWER Switch (is inoperative), MAX POWER/OFF"),devices.ENGINE_INTERFACE, engine_commands.MaxPowerSw,451)
            AddFunction(new Switch(this, (int)devices.ENGINE_INTERFACE, "engine_commands", new SwitchPosition[] { new SwitchPosition("1", "AB RESET", (int)engine_commands.ABResetSwEngData), new SwitchPosition("0.5", "NORM", (int)engine_commands.ABResetSwEngData), new SwitchPosition("0", "ENG DATA", (int)engine_commands.ABResetSwEngData) }, "Engine Interface", "AB RESET Switch, AB RESET/NORM/ENG DATA", "0.1f"));// springloaded_3_pos_tumb(_("AB RESET Switch, AB RESET/NORM/ENG DATA"),devices.ENGINE_INTERFACE, engine_commands.ABResetSwEngData, engine_commands
            AddFunction(new PushButton(this, (int)devices.ENGINE_INTERFACE, (int)engine_commands.FireOheatTestBtn, "575", "Engine Interface", "FIRE & OHEAT DETECT Test Button - Push to test"));// default_button(_("FIRE & OHEAT DETECT Test Button - Push to test"),devices.ENGINE_INTERFACE, engine_commands.FireOheatTestBtn,575)
            #endregion
            #region Oxygen System
            AddFunction(new Switch(this, (int)devices.OXYGEN_INTERFACE, "anim_speed_default", new SwitchPosition[] { new SwitchPosition("1", "PBG", (int)oxygen_commands.SupplyLever), new SwitchPosition("0.5", "ON", (int)oxygen_commands.SupplyLever), new SwitchPosition("0", "OFF", (int)oxygen_commands.SupplyLever) }, "OXYGEN Interface", "Supply Lever, PBG/ON/OFF", "0.1f"));// default_3_position_tumb_small(_("Supply Lever, PBG/ON/OFF"),devices.OXYGEN_INTERFACE, oxygen_commands.SupplyLever,728, false, anim_speed_default
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.OXYGEN_INTERFACE, (int)oxygen_commands.DiluterLever, "727", "1.0", "100 percent", "0.0", "NORM", "OXYGEN Interface", "Diluter Lever, 100 percent/NORM", "0.1f"));// default_2_position_tumb_small(_("Diluter Lever, 100 percent/NORM"),devices.OXYGEN_INTERFACE, oxygen_commands.DiluterLever,727)
            AddFunction(new Switch(this, (int)devices.OXYGEN_INTERFACE, "726", new SwitchPosition[] { new SwitchPosition("1", "EMERGENCY", (int)oxygen_commands.EmergencyLever), new SwitchPosition("0.5", "NORMAL", (int)oxygen_commands.EmergencyLever), new SwitchPosition("0", "TEST MASK", (int)oxygen_commands.EmergencyLever) }, "OXYGEN Interface", "Emergency Lever, EMERGENCY/NORMAL/TEST MASK", "0.1f"));// default_3_position_tumb_small(_("Emergency Lever, EMERGENCY/NORMAL/TEST MASK"),devices.OXYGEN_INTERFACE, oxygen_commands.EmergencyLever,726)
            #endregion
            #region Sensor Power Control Panel
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.SMS, (int)sms_commands.LeftHDPT, "670", "1.0", "ON", "0.0", "OFF", "SMS", "Left HDPT Switch, ON/OFF", "0.1f"));// default_2_position_tumb(_("LEFT HDPT Switch, ON/OFF"),devices.SMS, sms_commands.LeftHDPT, 670)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.SMS, (int)sms_commands.RightHDPT, "671", "1.0", "ON", "0.0", "OFF", "SMS", "Right HDPT Switch, ON/OFF", "0.1f"));// default_2_position_tumb(_("RIGHT HDPT Switch, ON/OFF"),devices.SMS, sms_commands.RightHDPT, 671)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.FCR, (int)fcr_commands.PwrSw, "672", "1.0", "FCR", "0.0", "OFF", "FCR", "FCR Switch, FCR/OFF", "0.1f"));// default_2_position_tumb(_("FCR Switch, FCR/OFF"),devices.FCR, fcr_commands.PwrSw, 672)
            AddFunction(new Switch(this, (int)devices.RALT, "673", new SwitchPosition[] { new SwitchPosition("1", "RDR ALT", (int)ralt_commands.PwrSw), new SwitchPosition("0.5", "STBY", (int)ralt_commands.PwrSw), new SwitchPosition("0", "OFF", (int)ralt_commands.PwrSw) }, "RALT", "RDR ALT Switch, RDR ALT/STBY/OFF", "0.1f"));// default_3_position_tumb(_("RDR ALT Switch, RDR ALT/STBY/OFF"),devices.RALT, ralt_commands.PwrSw, 673)
            #endregion
            #region Avionic Power Panel
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.MMC, (int)mmc_commands.MmcPwr, "715", "1.0", "MMC", "0.0", "OFF", "MMC", "MMC Switch, MMC/OFF", "0.1f"));// default_2_position_tumb(_("MMC Switch, MMC/OFF"),devices.MMC, mmc_commands.MmcPwr,715)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.SMS, (int)sms_commands.StStaSw, "716", "1.0", "ST STA", "0.0", "OFF", "SMS", "ST STA Switch, ST STA/OFF", "0.1f"));// default_2_position_tumb(_("ST STA Switch, ST STA/OFF"),devices.SMS, sms_commands.StStaSw,716)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.MMC, (int)mmc_commands.MFD, "717", "1.0", "MFD", "0.0", "OFF", "MMC", "Switch, /OFF", "0.1f"));// default_2_position_tumb(_("MFD Switch, MFD/OFF"),devices.MMC, mmc_commands.MFD,717)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UFC, (int)ufc_commands.UFC_Sw, "718", "1.0", "UFC", "0.0", "OFF", "UFC", "UFC Switch, UFC/OFF", "0.1f"));// default_2_position_tumb(_("UFC Switch, UFC/OFF"),devices.UFC, ufc_commands.UFC_Sw,718)
            AddFunction(new Switch(this, (int)devices.MIDS, "NO", new SwitchPosition[] { new SwitchPosition("0", "ZERO", (int)mids_commands.PwrSw), new SwitchPosition("0.5", "OFF", (int)mids_commands.PwrSw), new SwitchPosition("1", "ON", (int)mids_commands.PwrSw) }, "MIDS", "MIDS LVT Knob, ZERO/OFF/ON", "0.1f"));// multiposition_switch(_("MIDS LVT Knob, ZERO/OFF/ON"),devices.MIDS, mids_commands.PwrSw, 723, 3, 0.1, NOT_INVERSED, 0.0, anim_speed_default * 0.1, NO
            AddFunction(new Switch(this, (int)devices.INS, "anim_", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)ins_commands.ModeKnob), new SwitchPosition("0.166666666666667", "STOR HDG", (int)ins_commands.ModeKnob), new SwitchPosition("0.333333333333333", "NORM", (int)ins_commands.ModeKnob), new SwitchPosition("0.5", "NAV", (int)ins_commands.ModeKnob), new SwitchPosition("0.666666666666667", "CAL", (int)ins_commands.ModeKnob), new SwitchPosition("0.833333333333333", "INFLT ALIGN", (int)ins_commands.ModeKnob), new SwitchPosition("1", "ATT", (int)ins_commands.ModeKnob) }, "INS", "INS Knob, OFF/STOR HDG/NORM/NAV/CAL/INFLT ALIGN/ATT", "0.1f"));// multiposition_switch(_("INS Knob, OFF/STOR HDG/NORM/NAV/CAL/INFLT ALIGN/ATT"),devices.INS, ins_commands.ModeKnob, 719, 7, 0.1, NOT_INVERSED, 0.0, anim_
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.ELEC_INTERFACE, (int)3101, "722", "1.0", "MAP", "0.0", "OFF", "Elec Interface", "MAP Switch, MAP/OFF", "0.1f"));// default_2_position_tumb(_("MAP Switch, MAP/OFF"),devices.ELEC_INTERFACE, 3101,722)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.ELEC_INTERFACE, (int)3102, "720", "1.0", "GPS", "0.0", "OFF", "Elec Interface", "GPS Switch, GPS/OFF", "0.1f"));// default_2_position_tumb(_("GPS Switch, GPS/OFF"),devices.ELEC_INTERFACE, 3102,720)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.ELEC_INTERFACE, (int)3103, "721", "1.0", "DL", "0.0", "OFF", "Elec Interface", "DL Switch, DL/OFF", "0.1f"));// default_2_position_tumb(_("DL Switch, DL/OFF"),devices.ELEC_INTERFACE, 3103,721)
            #endregion
            #region Modular Mission Computer (MMC)
            AddFunction(new Switch(this, (int)devices.MMC, "105", new SwitchPosition[] { new SwitchPosition("1", "MASTER ARM", (int)mmc_commands.MasterArmSw), new SwitchPosition("0.5", "OFF", (int)mmc_commands.MasterArmSw), new SwitchPosition("0", "SIMULATE", (int)mmc_commands.MasterArmSw) }, "MMC", "MASTER ARM Switch, MASTER ARM/OFF/SIMULATE", "0.1f"));// default_3_position_tumb(_("MASTER ARM Switch, MASTER ARM/OFF/SIMULATE"),devices.MMC, mmc_commands.MasterArmSw,105)
            AddFunction(new PushButton(this, (int)devices.MMC, (int)mmc_commands.EmerStoresJett, "353", "MMC", "EMER STORES JETTISON Button - Push to jettison"));// default_button(_("EMER STORES JETTISON Button - Push to jettison"),devices.MMC, mmc_commands.EmerStoresJett,353)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.MMC, (int)mmc_commands.GroundJett, "355", "1.0", "ENABLE", "0.0", "OFF", "MMC", "GND JETT ENABLE Switch, ENABLE/OFF", "0.1f"));// default_2_position_tumb(_("GND JETT ENABLE Switch, ENABLE/OFF"),devices.MMC, mmc_commands.GroundJett,355)
            AddFunction(new PushButton(this, (int)devices.MMC, (int)mmc_commands.AltRel, "104", "MMC", "ALT REL Button - Push to release"));// default_button(_("ALT REL Button - Push to release"),devices.MMC, mmc_commands.AltRel,104)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.SMS, (int)sms_commands.LaserSw, "103", "1.0", "ARM", "0.0", "OFF", "SMS", "LASER ARM Switch, ARM/OFF", "0.1f"));// default_2_position_tumb(_("LASER ARM Switch, ARM/OFF"),devices.SMS, sms_commands.LaserSw, 103)
            #endregion
            #region Integrated Control Panel (ICP) of Upfront Controls (UFC)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG1_T_ILS, "171", "UFC", "Priority Function Button, 1(T-ILS)"));// short_way_button(_("ICP Priority Function Button, 1(T-ILS)"),devices.UFC, ufc_commands.DIG1_T_ILS,171)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG2_ALOW, "172", "UFC", "Priority Function Button, 2/N(ALOW)"));// short_way_button(_("ICP Priority Function Button, 2/N(ALOW)"),devices.UFC, ufc_commands.DIG2_ALOW,172)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG3, "173", "UFC", "Priority Function Button, 3"));// short_way_button(_("ICP Priority Function Button, 3"),devices.UFC, ufc_commands.DIG3,173)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG4_STPT, "175", "UFC", "Priority Function Button, 4/W(STPT)"));// short_way_button(_("ICP Priority Function Button, 4/W(STPT)"),devices.UFC, ufc_commands.DIG4_STPT,175)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG5_CRUS, "176", "UFC", "Priority Function Button, 5(CRUS)"));// short_way_button(_("ICP Priority Function Button, 5(CRUS)"),devices.UFC, ufc_commands.DIG5_CRUS,176)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG6_TIME, "177", "UFC", "Priority Function Button, 6/E(TIME)"));// short_way_button(_("ICP Priority Function Button, 6/E(TIME)"),devices.UFC, ufc_commands.DIG6_TIME,177)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG7_MARK, "179", "UFC", "Priority Function Button, 7(MARK)"));// short_way_button(_("ICP Priority Function Button, 7(MARK)"),devices.UFC, ufc_commands.DIG7_MARK,179)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG8_FIX, "180", "UFC", "Priority Function Button, 8/S(FIX)"));// short_way_button(_("ICP Priority Function Button, 8/S(FIX)"),devices.UFC, ufc_commands.DIG8_FIX,180)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG9_A_CAL, "181", "UFC", "Priority Function Button, 9(A-CAL)"));// short_way_button(_("ICP Priority Function Button, 9(A-CAL)"),devices.UFC, ufc_commands.DIG9_A_CAL,181)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.DIG0_M_SEL, "182", "UFC", "Priority Function Button, 0(M-SEL)"));// short_way_button(_("ICP Priority Function Button, 0(M-SEL)"),devices.UFC, ufc_commands.DIG0_M_SEL,182)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.COM1, "165", "UFC", "COM Override Button, COM1(UHF)"));// short_way_button(_("ICP COM Override Button, COM1(UHF)"),devices.UFC, ufc_commands.COM1,165)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.COM2, "166", "UFC", "COM Override Button, COM2(VHF)"));// short_way_button(_("ICP COM Override Button, COM2(VHF)"),devices.UFC, ufc_commands.COM2,166)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.IFF, "167", "UFC", "IFF Override Button, IFF"));// short_way_button(_("ICP IFF Override Button, IFF"),devices.UFC, ufc_commands.IFF,167)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.LIST, "168", "UFC", "LIST Override Button, LIST"));// short_way_button(_("ICP LIST Override Button, LIST"),devices.UFC, ufc_commands.LIST,168)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.AA, "169", "UFC", "Master Mode Button, A-A"));// short_way_button(_("ICP Master Mode Button, A-A"),devices.UFC, ufc_commands.AA,169)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.AG, "170", "UFC", "Master Mode Button, A-G"));// short_way_button(_("ICP Master Mode Button, A-G"),devices.UFC, ufc_commands.AG,170)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.RCL, "174", "UFC", "Recall Button, RCL"));// short_way_button(_("ICP Recall Button, RCL"),devices.UFC, ufc_commands.RCL,174)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.ENTR, "178", "UFC", "Enter Button, ENTR"));// short_way_button(_("ICP Enter Button, ENTR"),devices.UFC, ufc_commands.ENTR,178)
            AddFunction(new Axis(this, (int)devices.UFC, (int)ufc_commands.RET_DEPR_Knob, "192", 0.01d, 0.0d, 1.0d, "UFC", "Reticle Depression Control Knob"));// default_axis_limited(_("ICP Reticle Depression Control Knob"),devices.UFC, ufc_commands.RET_DEPR_Knob,192)
            AddFunction(new Axis(this, (int)devices.UFC, (int)ufc_commands.CONT_Knob, "193", 0.01d, 0.0d, 1.0d, "UFC", "Raster Contrast Knob"));// default_axis_limited(_("ICP Raster Contrast Knob"),devices.UFC, ufc_commands.CONT_Knob,193)
            AddFunction(new Axis(this, (int)devices.UFC, (int)ufc_commands.BRT_Knob, "191", 0.01d, 0.0d, 1.0d, "UFC", "Raster Intensity Knob"));// default_axis_limited(_("ICP Raster Intensity Knob"),devices.UFC, ufc_commands.BRT_Knob,191)
            AddFunction(new Axis(this, (int)devices.UFC, (int)ufc_commands.SYM_Knob, "190", 0.01d, 0.0d, 1.0d, "UFC", "Symbology Intensity Knob"));// default_axis_limited(_("ICP HUD Symbology Intensity Knob"),devices.UFC, ufc_commands.SYM_Knob,190)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.Wx, "187", "UFC", "FLIR Polarity Button, Wx"));// short_way_button(_("ICP FLIR Polarity Button, Wx"),devices.UFC, ufc_commands.Wx,187)
            AddFunction(new Switch(this, (int)devices.UFC, "189", new SwitchPosition[] { new SwitchPosition("1", "GAIN", (int)ufc_commands.FLIR_GAIN_Sw), new SwitchPosition("0.5", "LVL", (int)ufc_commands.FLIR_GAIN_Sw), new SwitchPosition("0", "AUTO", (int)ufc_commands.FLIR_GAIN_Sw) }, "UFC", "FLIR GAIN/LEVEL Switch, GAIN/LVL/AUTO", "0.1f"));// default_3_position_tumb_small(_("ICP FLIR GAIN/LEVEL Switch, GAIN/LVL/AUTO"),devices.UFC, ufc_commands.FLIR_GAIN_Sw,189)
                                                                                                                                                                                                                                                                                                                                                        //AddFunction((this, (int)devices.UFC, (int)ufc_commands.DED_INC, "183", "UFC", "DED Increment/Decrement Switch, Up"));// Rocker_switch_positive(_("ICP DED Increment/Decrement Switch, Up"),devices.UFC, ufc_commands.DED_INC,183)
                                                                                                                                                                                                                                                                                                                                                        //AddFunction((this, (int)devices.UFC, (int)ufc_commands.DED_DEC, "183", "UFC", "DED Increment/Decrement Switch, Down"));// Rocker_switch_negative(_("ICP DED Increment/Decrement Switch, Down"),devices.UFC, ufc_commands.DED_DEC,183)
                                                                                                                                                                                                                                                                                                                                                        //AddFunction((this, (int)devices.UFC, (int)ufc_commands.FLIR_INC, "188", "UFC", "FLIR Increment/Decrement Switch, Up"));// Rocker_switch_positive(_("ICP FLIR Increment/Decrement Switch, Up"),devices.UFC, ufc_commands.FLIR_INC,188)
                                                                                                                                                                                                                                                                                                                                                        //AddFunction((this, (int)devices.UFC, (int)ufc_commands.FLIR_DEC, "188", "UFC", "FLIR Increment/Decrement Switch, Down"));// Rocker_switch_negative(_("ICP FLIR Increment/Decrement Switch, Down"),devices.UFC, ufc_commands.FLIR_DEC,188)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UFC, (int)ufc_commands.DCS_RTN, "184", "1.0", "RTN", "0.0", "", "UFC", "Data Control Switch, RTN", "0.1f"));// springloaded_2_pos_tumb_small(_("ICP Data Control Switch, RTN"),devices.UFC, ufc_commands.DCS_RTN,184)
                                                                                                                                                                                 //AddFunction((this, , , "-1}", "", ""));// {-1, -1}
                                                                                                                                                                                 //AddFunction((this, , , "0}}", "", ""));// {{-1,0},{-1,0}}
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UFC, (int)ufc_commands.DCS_SEQ, "184", "1.0", "SEQ", "0.0", "", "UFC", "Data Control Switch, SEQ", "0.1f"));// springloaded_2_pos_tumb_small(_("ICP Data Control Switch, SEQ"),devices.UFC, ufc_commands.DCS_SEQ,184)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UFC, (int)ufc_commands.DCS_UP, "185", "1.0", "UP", "0.0", "", "UFC", "Data Control Switch, UP", "0.1f"));// springloaded_2_pos_tumb_small(_("ICP Data Control Switch, UP"),devices.UFC, ufc_commands.DCS_UP,185)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UFC, (int)ufc_commands.DCS_DOWN, "185", "1.0", "DN", "0.0", "", "UFC", "Data Control Switch, DN", "0.1f"));// springloaded_2_pos_tumb_small(_("ICP Data Control Switch, DN"),devices.UFC, ufc_commands.DCS_DOWN,185)
                                                                                                                                                                                //AddFunction((this, , , "-1}", "", ""));// {-1, -1}
                                                                                                                                                                                //AddFunction((this, , , "0}}", "", ""));// {{-1,0},{-1,0}}
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.F_ACK, "122", "UFC", "F-ACK Button"));// short_way_button(_("F-ACK Button"),devices.UFC, ufc_commands.F_ACK,122)
            AddFunction(new PushButton(this, (int)devices.UFC, (int)ufc_commands.IFF_IDENT, "125", "UFC", "IFF IDENT Button"));// short_way_button(_("IFF IDENT Button"),devices.UFC, ufc_commands.IFF_IDENT,125)
            AddFunction(new Switch(this, (int)devices.UFC, "100", new SwitchPosition[] { new SwitchPosition("1", "SILENT", (int)ufc_commands.RF_Sw), new SwitchPosition("0.5", "QUIET", (int)ufc_commands.RF_Sw), new SwitchPosition("0", "NORM", (int)ufc_commands.RF_Sw) }, "UFC", "RF Switch, SILENT/QUIET/NORM", "0.1f"));// default_3_position_tumb(_("RF Switch, SILENT/QUIET/NORM"),devices.UFC, ufc_commands.RF_Sw,100)
            #endregion
            #region HUD Remote Control Panel
            AddFunction(new Switch(this, (int)devices.MMC, "675", new SwitchPosition[] { new SwitchPosition("1", "VV", (int)mmc_commands.VvVah), new SwitchPosition("0.5", "VAH", (int)mmc_commands.VvVah), new SwitchPosition("0", "VAH", (int)mmc_commands.VvVah) }, "MMC", "Scales Switch, VV/VAH / VAH / OFF", "0.1f"));// default_3_position_tumb(_("HUD Scales Switch, VV/VAH / VAH / OFF"),devices.MMC, mmc_commands.VvVah,675)
            AddFunction(new Switch(this, (int)devices.MMC, "676", new SwitchPosition[] { new SwitchPosition("1", "ATT", (int)mmc_commands.AttFpm), new SwitchPosition("0.5", "FPM", (int)mmc_commands.AttFpm), new SwitchPosition("0", "FPM", (int)mmc_commands.AttFpm) }, "MMC", "Flightpath Marker Switch, ATT/FPM / FPM / OFF", "0.1f"));// default_3_position_tumb(_("HUD Flightpath Marker Switch, ATT/FPM / FPM / OFF"),devices.MMC, mmc_commands.AttFpm,676)
            AddFunction(new Switch(this, (int)devices.MMC, "677", new SwitchPosition[] { new SwitchPosition("1", "DED", (int)mmc_commands.DedData), new SwitchPosition("0.5", "PFL", (int)mmc_commands.DedData), new SwitchPosition("0", "OFF", (int)mmc_commands.DedData) }, "MMC", "DED/PFLD Data Switch, DED / PFL / OFF", "0.1f"));// default_3_position_tumb_small(_("HUD DED/PFLD Data Switch, DED / PFL / OFF"),devices.MMC, mmc_commands.DedData,677)
            AddFunction(new Switch(this, (int)devices.MMC, "678", new SwitchPosition[] { new SwitchPosition("1", "STBY", (int)mmc_commands.DeprRet), new SwitchPosition("0.5", "PRI", (int)mmc_commands.DeprRet), new SwitchPosition("0", "OFF", (int)mmc_commands.DeprRet) }, "MMC", "Depressible Reticle Switch, STBY / PRI / OFF", "0.1f"));// default_3_position_tumb(_("HUD Depressible Reticle Switch, STBY / PRI / OFF"),devices.MMC, mmc_commands.DeprRet,678)
            AddFunction(new Switch(this, (int)devices.MMC, "679", new SwitchPosition[] { new SwitchPosition("1", "CAS", (int)mmc_commands.Spd), new SwitchPosition("0.5", "TAS", (int)mmc_commands.Spd), new SwitchPosition("0", "GND SPD", (int)mmc_commands.Spd) }, "MMC", "Velocity Switch, CAS / TAS / GND SPD", "0.1f"));// default_3_position_tumb_small(_("HUD Velocity Switch, CAS / TAS / GND SPD"),devices.MMC, mmc_commands.Spd,679)
            AddFunction(new Switch(this, (int)devices.MMC, "680", new SwitchPosition[] { new SwitchPosition("1", "RADAR", (int)mmc_commands.Alt), new SwitchPosition("0.5", "BARO", (int)mmc_commands.Alt), new SwitchPosition("0", "AUTO", (int)mmc_commands.Alt) }, "MMC", "Altitude Switch, RADAR / BARO / AUTO", "0.1f"));// default_3_position_tumb_small(_("HUD Altitude Switch, RADAR / BARO / AUTO"),devices.MMC, mmc_commands.Alt,680)
            AddFunction(new Switch(this, (int)devices.MMC, "681", new SwitchPosition[] { new SwitchPosition("1", "DAY", (int)mmc_commands.Brt), new SwitchPosition("0.5", "AUTO BRT", (int)mmc_commands.Brt), new SwitchPosition("0", "NIGHT", (int)mmc_commands.Brt) }, "MMC", "Brightness Control Switch, DAY / AUTO BRT / NIGHT", "0.1f"));// default_3_position_tumb_small(_("HUD Brightness Control Switch, DAY / AUTO BRT / NIGHT"),devices.MMC, mmc_commands.Brt,681)
            AddFunction(new Switch(this, (int)devices.MMC, "682", new SwitchPosition[] { new SwitchPosition("1", "STEP", (int)mmc_commands.Test), new SwitchPosition("0.5", "ON", (int)mmc_commands.Test), new SwitchPosition("0", "OFF", (int)mmc_commands.Test) }, "MMC", "TEST Switch, STEP / ON / OFF", "0.1f"));// default_3_position_tumb_small(_("HUD TEST Switch, STEP / ON / OFF"),devices.MMC, mmc_commands.Test,682)
            #endregion
            #region Audio Control Panels
            AddFunction(new Switch(this, (int)devices.INTERCOM, "anim_sp", new SwitchPosition[] { }, "InternalERCOM", "COMM 1 (UHF) Mode Knob", "0.1f"));// multiposition_switch(_("COMM 1 (UHF) Mode Knob"),devices.INTERCOM, intercom_commands.COM1_ModeKnob,434, 3, 0.5, NOT_INVERSED, 0.0, anim_sp
            AddFunction(new Switch(this, (int)devices.INTERCOM, "anim_sp", new SwitchPosition[] { }, "InternalERCOM", "COMM 2 (VHF) Mode Knob", "0.1f"));// multiposition_switch(_("COMM 2 (VHF) Mode Knob"),devices.INTERCOM, intercom_commands.COM2_ModeKnob,435, 3, 0.5, NOT_INVERSED, 0.0, anim_sp
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.COM1_PowerKnob, "430", 0.01d, 0.0d, 1.0d, "InternalERCOM", "COMM 1 Power Knob"));// default_axis_limited(_("COMM 1 Power Knob"),devices.INTERCOM, intercom_commands.COM1_PowerKnob,430)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.COM2_PowerKnob, "431", 0.01d, 0.0d, 1.0d, "InternalERCOM", "COMM 2 Power Knob"));// default_axis_limited(_("COMM 2 Power Knob"),devices.INTERCOM, intercom_commands.COM2_PowerKnob,431)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.SecureVoiceKnob, "432", 0.01d, 0.0d, 1.0d, "InternalERCOM", "SECURE VOICE Knob"));// default_axis_limited(_("SECURE VOICE Knob"),devices.INTERCOM, intercom_commands.SecureVoiceKnob,432)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.MSL_ToneKnob, "433", 0.01d, 0.0d, 1.0d, "InternalERCOM", "MSL Tone Knob"));// default_axis_limited(_("MSL Tone Knob"),devices.INTERCOM, intercom_commands.MSL_ToneKnob,433)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.TF_ToneKnob, "436", 0.01d, 0.0d, 1.0d, "InternalERCOM", "TF Tone Knob"));// default_axis_limited(_("TF Tone Knob"),devices.INTERCOM, intercom_commands.TF_ToneKnob,436)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.THREAT_ToneKnob, "437", 0.01d, 0.0d, 1.0d, "InternalERCOM", "THREAT Tone Knob"));// default_axis_limited(_("THREAT Tone Knob"),devices.INTERCOM, intercom_commands.THREAT_ToneKnob,437)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.INTERCOM_Knob, "440", 0.01d, 0.0d, 1.0d, "InternalERCOM", "InternalERCOM Knob"));// default_axis_limited(_("INTERCOM Knob"),devices.INTERCOM, intercom_commands.INTERCOM_Knob,440)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.TACAN_Knob, "441", 0.01d, 0.0d, 1.0d, "InternalERCOM", "TACAN Knob"));// default_axis_limited(_("TACAN Knob"),devices.INTERCOM, intercom_commands.TACAN_Knob,441)
            AddFunction(new Axis(this, (int)devices.INTERCOM, (int)intercom_commands.ILS_PowerKnob, "442", 0.01d, 0.0d, 1.0d, "InternalERCOM", "ILS Power Knob"));// default_axis_limited(_("ILS Power Knob"),devices.INTERCOM, intercom_commands.ILS_PowerKnob,442)
            AddFunction(new Switch(this, (int)devices.INTERCOM, "443", new SwitchPosition[] { new SwitchPosition("1", "HOT MIC", (int)intercom_commands.HotMicCipherSw), new SwitchPosition("0.5", "OFF", (int)intercom_commands.HotMicCipherSw), new SwitchPosition("0", "CIPHER", (int)intercom_commands.HotMicCipherSw) }, "InternalERCOM", "HOT MIC CIPHER Switch, HOT MIC / OFF / CIPHER", "0.1f"));// default_3_position_tumb_small(_("HOT MIC CIPHER Switch, HOT MIC / OFF / CIPHER"),devices.INTERCOM, intercom_commands.HotMicCipherSw,443)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.INTERCOM, (int)intercom_commands.VMS_InhibitSw, "696", "1.0", "VOICE MESSAGE", "0.0", "INHIBIT", "InternalERCOM", "Voice Message Inhibit Switch, VOICE MESSAGE/INHIBIT", "0.1f"));// default_2_position_tumb_small(_("Voice Message Inhibit Switch, VOICE MESSAGE/INHIBIT"),devices.INTERCOM, intercom_commands.VMS_InhibitSw,696)
            AddFunction(new Switch(this, (int)devices.INTERCOM, "711", new SwitchPosition[] { new SwitchPosition("1", "LOWER", (int)intercom_commands.IFF_AntSelSw), new SwitchPosition("0.5", "NORM", (int)intercom_commands.IFF_AntSelSw), new SwitchPosition("0", "UPPER", (int)intercom_commands.IFF_AntSelSw) }, "InternalERCOM", "IFF ANT SEL Switch, LOWER/NORM/UPPER", "0.1f"));// default_3_position_tumb_small(_("IFF ANT SEL Switch, LOWER/NORM/UPPER"),devices.INTERCOM, intercom_commands.IFF_AntSelSw,711)
            AddFunction(new Switch(this, (int)devices.INTERCOM, "712", new SwitchPosition[] { new SwitchPosition("1", "LOWER", (int)intercom_commands.UHF_AntSelSw), new SwitchPosition("0.5", "NORM", (int)intercom_commands.UHF_AntSelSw), new SwitchPosition("0", "UPPER", (int)intercom_commands.UHF_AntSelSw) }, "InternalERCOM", "UHF ANT SEL Switch, LOWER/NORM/UPPER", "0.1f"));// default_3_position_tumb_small(_("UHF ANT SEL Switch, LOWER/NORM/UPPER"),devices.INTERCOM, intercom_commands.UHF_AntSelSw,712)
            #endregion
            #region UHF Backup Control Panel
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "anim_spe", new SwitchPosition[] { }, "UHF Control Panel", "UHF CHAN Knob", "0.1f"));// multiposition_switch(_("UHF CHAN Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.ChannelKnob,410, 20, 0.05, NOT_INVERSED, 0.0, anim_spe
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "NOT_INVERS", new SwitchPosition[] { }, "UHF Control Panel", "UHF Manual Frequency Knob 100 MHz", "0.1f"));// multiposition_switch(_("UHF Manual Frequency Knob 100 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector100Mhz,411, 3, 0.1, NOT_INVERS
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "NOT_INVERSED", new SwitchPosition[] { }, "UHF Control Panel", "UHF Manual Frequency Knob 10 MHz", "0.1f"));// multiposition_switch(_("UHF Manual Frequency Knob 10 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector10Mhz,412, 10, 0.1, NOT_INVERSED
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "0", new SwitchPosition[] { }, "UHF Control Panel", "UHF Manual Frequency Knob 1 MHz", "0.1f"));// multiposition_switch(_("UHF Manual Frequency Knob 1 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector1Mhz,413, 10, 0.1, NOT_INVERSED, 0
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "NOT_INVERS", new SwitchPosition[] { }, "UHF Control Panel", "UHF Manual Frequency Knob 0.1 MHz", "0.1f"));// multiposition_switch(_("UHF Manual Frequency Knob 0.1 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector01Mhz,414, 10, 0.1, NOT_INVERS
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "NOT_INV", new SwitchPosition[] { }, "UHF Control Panel", "UHF Manual Frequency Knob 0.025 MHz", "0.1f"));// multiposition_switch(_("UHF Manual Frequency Knob 0.025 MHz"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqSelector0025Mhz,415, 4, 0.25, NOT_INV
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "anim_speed", new SwitchPosition[] { }, "UHF Control Panel", "UHF Function Knob", "0.1f"));// multiposition_switch(_("UHF Function Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.FunctionKnob,417, 4, 0.1, NOT_INVERSED, 0.0, anim_speed
            AddFunction(new Switch(this, (int)devices.UHF_CONTROL_PANEL, "anim_speed_de", new SwitchPosition[] { }, "UHF Control Panel", "UHF Mode Knob", "0.1f"));// multiposition_switch(_("UHF Mode Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.FreqModeKnob,416, 3, 0.1, NOT_INVERSED, 0.0, anim_speed_de
            AddFunction(new PushButton(this, (int)devices.UHF_CONTROL_PANEL, (int)uhf_commands.TToneSw, "418", "UHF Control Panel", "UHF Tone Button"));// default_button(_("UHF Tone Button"),devices.UHF_CONTROL_PANEL, uhf_commands.TToneSw,418)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UHF_CONTROL_PANEL, (int)uhf_commands.SquelchSw, "419", "1.0", "", "0.0", "", "UHF Control Panel", "UHF SQUELCH Switch", "0.1f"));// default_2_position_tumb_small(_("UHF SQUELCH Switch"),devices.UHF_CONTROL_PANEL, uhf_commands.SquelchSw,419)
            AddFunction(new Axis(this, (int)devices.UHF_CONTROL_PANEL, (int)uhf_commands.VolumeKnob, "420", 0.01d, 0.0d, 1.0d, "UHF Control Panel", "UHF VOL Knob"));// default_axis_limited(_("UHF VOL Knob"),devices.UHF_CONTROL_PANEL, uhf_commands.VolumeKnob,420)
            AddFunction(new PushButton(this, (int)devices.UHF_CONTROL_PANEL, (int)uhf_commands.TestDisplayBtn, "421", "UHF Control Panel", "UHF TEST DISPLAY Button"));// default_button(_("UHF TEST DISPLAY Button"),devices.UHF_CONTROL_PANEL, uhf_commands.TestDisplayBtn,421)
            AddFunction(new PushButton(this, (int)devices.UHF_CONTROL_PANEL, (int)uhf_commands.StatusBtn, "422", "UHF Control Panel", "UHF STATUS Button"));// default_button(_("UHF STATUS Button"),devices.UHF_CONTROL_PANEL, uhf_commands.StatusBtn,422)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.UHF_CONTROL_PANEL, (int)uhf_commands.AccessDoor, "anim_speed_default * 0.5", "1.0", "OPEN", "0.0", "CLOSE", "UHF Control Panel", "Access Door, OPEN/CLOSE", "0.1f"));// default_2_position_tumb(_("Access Door, OPEN/CLOSE"),devices.UHF_CONTROL_PANEL, uhf_commands.AccessDoor,734, anim_speed_default * 0.5)
            #endregion
            #region IFF Control Panel
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "anim_speed_defa", new SwitchPosition[] { new SwitchPosition("0", "UFC", (int)iff_commands.CNI_Knob), new SwitchPosition("1", "BACKUP", (int)iff_commands.CNI_Knob) }, "IFF Control Panel", "C & I Knob, UFC/BACKUP", "0.1f"));// multiposition_switch(_("C & I Knob, UFC/BACKUP"),devices.IFF_CONTROL_PANEL, iff_commands.CNI_Knob,542, 2, 1, NOT_INVERSED, 0.0, anim_speed_defa
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "0", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)iff_commands.MasterKnob), new SwitchPosition("0.25", "STBY", (int)iff_commands.MasterKnob), new SwitchPosition("0.5", "LOW", (int)iff_commands.MasterKnob), new SwitchPosition("0.75", "NORM", (int)iff_commands.MasterKnob), new SwitchPosition("1", "EMER", (int)iff_commands.MasterKnob) }, "IFF Control Panel", "IFF MASTER Knob, OFF/STBY/LOW/NORM/EMER", "0.1f"));// multiposition_switch(_("IFF MASTER Knob, OFF/STBY/LOW/NORM/EMER"),devices.IFF_CONTROL_PANEL, iff_commands.MasterKnob,540, 5, 0.1, NOT_INVERSED, 0.0
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "541", new SwitchPosition[] { new SwitchPosition("1", "HOLD", (int)iff_commands.M4CodeSw), new SwitchPosition("0.5", "A", (int)iff_commands.M4CodeSw), new SwitchPosition("0", "B", (int)iff_commands.M4CodeSw) }, "IFF Control Panel", "IFF M-4 CODE Switch, HOLD/ A/B /ZERO", "0.1f"));// default_3_position_tumb(_("IFF M-4 CODE Switch, HOLD/ A/B /ZERO"),devices.IFF_CONTROL_PANEL, iff_commands.M4CodeSw,541)
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "543", new SwitchPosition[] { new SwitchPosition("1", "OUT", (int)iff_commands.M4ReplySw), new SwitchPosition("0.5", "A", (int)iff_commands.M4ReplySw), new SwitchPosition("0", "B", (int)iff_commands.M4ReplySw) }, "IFF Control Panel", "IFF MODE 4 REPLY Switch, OUT/A/B", "0.1f"));// default_3_position_tumb(_("IFF MODE 4 REPLY Switch, OUT/A/B"),devices.IFF_CONTROL_PANEL, iff_commands.M4ReplySw,543)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.IFF_CONTROL_PANEL, (int)iff_commands.M4MonitorSw, "544", "1.0", "OUT", "0.0", "AUDIO", "IFF Control Panel", "IFF MODE 4 MONITOR Switch, OUT/AUDIO", "0.1f"));// default_2_position_tumb_small(_("IFF MODE 4 MONITOR Switch, OUT/AUDIO"),devices.IFF_CONTROL_PANEL, iff_commands.M4MonitorSw,544)
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "553", new SwitchPosition[] { new SwitchPosition("1", "M1", (int)iff_commands.EnableSw), new SwitchPosition("0.5", "M3", (int)iff_commands.EnableSw), new SwitchPosition("0", "OFF", (int)iff_commands.EnableSw) }, "IFF Control Panel", "IFF ENABLE Switch, M1/M3 /OFF/ M3/MS", "0.1f"));// default_3_position_tumb_small(_("IFF ENABLE Switch, M1/M3 /OFF/ M3/MS"),devices.IFF_CONTROL_PANEL, iff_commands.EnableSw,553)
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "iff_commands.M1M3Selector1", new SwitchPosition[] { new SwitchPosition("1", "DIGIT 1", (int)iff_commands.M1M3Selector1_Dec), new SwitchPosition("0.5", "", (int)iff_commands.M1M3Selector1_Dec), new SwitchPosition("0", "", (int)iff_commands.M1M3Selector1_Dec) }, "IFF Control Panel", "IFF MODE 1 Selector Lever, DIGIT 1", "0.1f"));// springloaded_3_pos_tumb(_("IFF MODE 1 Selector Lever, DIGIT 1"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector1_Dec, iff_commands.M1M3Selector1
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "iff_commands.M1M3Selector2", new SwitchPosition[] { new SwitchPosition("1", "DIGIT 2", (int)iff_commands.M1M3Selector2_Dec), new SwitchPosition("0.5", "", (int)iff_commands.M1M3Selector2_Dec), new SwitchPosition("0", "", (int)iff_commands.M1M3Selector2_Dec) }, "IFF Control Panel", "IFF MODE 1 Selector Lever, DIGIT 2", "0.1f"));// springloaded_3_pos_tumb(_("IFF MODE 1 Selector Lever, DIGIT 2"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector2_Dec, iff_commands.M1M3Selector2
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "iff_commands.M1M3Selector3", new SwitchPosition[] { new SwitchPosition("1", "DIGIT 1", (int)iff_commands.M1M3Selector3_Dec), new SwitchPosition("0.5", "", (int)iff_commands.M1M3Selector3_Dec), new SwitchPosition("0", "", (int)iff_commands.M1M3Selector3_Dec) }, "IFF Control Panel", "IFF MODE 3 Selector Lever, DIGIT 1", "0.1f"));// springloaded_3_pos_tumb(_("IFF MODE 3 Selector Lever, DIGIT 1"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector3_Dec, iff_commands.M1M3Selector3
            AddFunction(new Switch(this, (int)devices.IFF_CONTROL_PANEL, "iff_commands.M1M3Selector4", new SwitchPosition[] { new SwitchPosition("1", "DIGIT 2", (int)iff_commands.M1M3Selector4_Dec), new SwitchPosition("0.5", "", (int)iff_commands.M1M3Selector4_Dec), new SwitchPosition("0", "", (int)iff_commands.M1M3Selector4_Dec) }, "IFF Control Panel", "IFF MODE 3 Selector Lever, DIGIT 2", "0.1f"));// springloaded_3_pos_tumb(_("IFF MODE 3 Selector Lever, DIGIT 2"),devices.IFF_CONTROL_PANEL, iff_commands.M1M3Selector4_Dec, iff_commands.M1M3Selector4
            #endregion
            #region KY-58
            AddFunction(new Switch(this, (int)devices.KY58, "anim_speed_default", new SwitchPosition[] { new SwitchPosition("0", "P", (int)ky58_commands.KY58_ModeSw), new SwitchPosition("0.333333333333333", "C", (int)ky58_commands.KY58_ModeSw), new SwitchPosition("0.666666666666667", "LD", (int)ky58_commands.KY58_ModeSw), new SwitchPosition("1", "RV", (int)ky58_commands.KY58_ModeSw) }, "KY58", "KY-58 MODE Knob, P/C/LD/RV", "0.1f"));// multiposition_switch(_("KY-58 MODE Knob, P/C/LD/RV"),devices.KY58, ky58_commands.KY58_ModeSw,705, 4, 0.1, NOT_INVERSED, 0.0, anim_speed_default
            AddFunction(new Axis(this, (int)devices.KY58, (int)ky58_commands.KY58_Volume, "1}", 0.01d, 0.0d, 1.0d, "KY58", "KY-58 VOLUME Knob"));// default_axis_limited(_("KY-58 VOLUME Knob"),devices.KY58, ky58_commands.KY58_Volume,708, 0.0, 0.1, false, false, {0,1})
            AddFunction(new Switch(this, (int)devices.KY58, "anim_spe", new SwitchPosition[] { new SwitchPosition("0", "Z 1-5", (int)ky58_commands.KY58_FillSw), new SwitchPosition("0.142857142857143", "1", (int)ky58_commands.KY58_FillSw), new SwitchPosition("0.285714285714286", "2", (int)ky58_commands.KY58_FillSw), new SwitchPosition("0.428571428571429", "3", (int)ky58_commands.KY58_FillSw), new SwitchPosition("0.571428571428571", "4", (int)ky58_commands.KY58_FillSw), new SwitchPosition("0.714285714285714", "5", (int)ky58_commands.KY58_FillSw), new SwitchPosition("0.857142857142857", "6", (int)ky58_commands.KY58_FillSw), new SwitchPosition("1", "Z ALL", (int)ky58_commands.KY58_FillSw) }, "KY58", "KY-58 FILL Knob, Z 1-5/1/2/3/4/5/6/Z ALL", "0.1f"));// multiposition_switch(_("KY-58 FILL Knob, Z 1-5/1/2/3/4/5/6/Z ALL"),devices.KY58, ky58_commands.KY58_FillSw,706, 8, 0.1, NOT_INVERSED, 0.0, anim_spe
            AddFunction(new Switch(this, (int)devices.KY58, "anim_speed_defaul", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)ky58_commands.KY58_PowerSw), new SwitchPosition("0.5", "ON", (int)ky58_commands.KY58_PowerSw), new SwitchPosition("1", "TD", (int)ky58_commands.KY58_PowerSw) }, "KY58", "KY-58 Power Knob, OFF/ON/TD", "0.1f"));// multiposition_switch(_("KY-58 Power Knob, OFF/ON/TD"),devices.KY58, ky58_commands.KY58_PowerSw,707, 3, 0.5, NOT_INVERSED, 0.0, anim_speed_defaul
            AddFunction(new Switch(this, (int)devices.INTERCOM, "701", new SwitchPosition[] { new SwitchPosition("1", "CRAD 1", (int)intercom_commands.PlainCipherSw), new SwitchPosition("0.5", "PLAIN", (int)intercom_commands.PlainCipherSw), new SwitchPosition("0", "CRAD 2", (int)intercom_commands.PlainCipherSw) }, "InternalERCOM", "PLAIN Cipher Switch, CRAD 1/PLAIN/CRAD 2", "0.1f"));// default_3_position_tumb_small(_("PLAIN Cipher Switch, CRAD 1/PLAIN/CRAD 2"),devices.INTERCOM, intercom_commands.PlainCipherSw,701)
                                                                                                                                                                                                                                                                                                                                                                                                  //AddFunction((this, (int)devices.INTERCOM, (int)intercom_commands.ZeroizeSwCvr, "694", "InternalERCOM", "ZEROIZE Switch Cover, OPEN/CLOSE"));// default_red_cover(_("ZEROIZE Switch Cover, OPEN/CLOSE"),devices.INTERCOM, intercom_commands.ZeroizeSwCvr,694)
            AddFunction(new Switch(this, (int)devices.INTERCOM, "695", new SwitchPosition[] { new SwitchPosition("1", "OFP", (int)intercom_commands.ZeroizeSw), new SwitchPosition("0.5", "OFF", (int)intercom_commands.ZeroizeSw), new SwitchPosition("0", "DATA", (int)intercom_commands.ZeroizeSw) }, "InternalERCOM", "ZEROIZE Switch, OFP/OFF/DATA", "0.1f"));// default_3_position_tumb_small(_("ZEROIZE Switch, OFP/OFF/DATA"),devices.INTERCOM, intercom_commands.ZeroizeSw,695)
            #endregion
            #region HMCS
            AddFunction(new Axis(this, (int)devices.HMCS, (int)hmcs_commands.IntKnob, "392", 0.01d, 0.0d, 1.0d, "HMCS", "HMCS SYMBOLOGY Internal Knob"));// default_axis_limited(_("HMCS SYMBOLOGY INT Knob"),devices.HMCS, hmcs_commands.IntKnob,392)
            #endregion
            #region RWR
            AddFunction(new Axis(this, (int)devices.RWR, (int)rwr_commands.IntKnob, "{", 0.01d, 0.0d, 1.0d, "RWR", "RWR Intensity Knob - Rotate to adjust brightness"));// default_axis_limited(_("RWR Intensity Knob - Rotate to adjust brightness"),devices.RWR, rwr_commands.IntKnob,140, 0, 0.1, NOT_UPDATABLE, NOT_RELATIVE, {
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.Handoff, "141", "RWR", "HANDOFF Button"));// short_way_button(_("RWR Indicator Control HANDOFF Button"),devices.RWR, rwr_commands.Handoff,141)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.Launch, "143", "RWR", "LAUNCH Button"));// short_way_button(_("RWR Indicator Control LAUNCH Button"),devices.RWR, rwr_commands.Launch,143)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.Mode, "145", "RWR", "MODE Button"));// short_way_button(_("RWR Indicator Control MODE Button"),devices.RWR, rwr_commands.Mode,145)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.UnknownShip, "147", "RWR", "UNKNOWN SHIP Button"));// short_way_button(_("RWR Indicator Control UNKNOWN SHIP Button"),devices.RWR, rwr_commands.UnknownShip,147)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.SysTest, "149", "RWR", "SYS TEST Button"));// short_way_button(_("RWR Indicator Control SYS TEST Button"),devices.RWR, rwr_commands.SysTest,149)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.TgtSep, "151", "RWR", "T Button"));// short_way_button(_("RWR Indicator Control T Button"),devices.RWR, rwr_commands.TgtSep,151)
            AddFunction(new Axis(this, (int)devices.RWR, (int)rwr_commands.BrtKnob, "404", 0.01d, 0.0d, 1.0d, "RWR", "DIM Knob - Rotate to adjust brightness"));// default_axis_limited(_("RWR Indicator Control DIM Knob - Rotate to adjust brightness"),devices.RWR, rwr_commands.BrtKnob,404)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.Search, "395", "RWR", "SEARCH Button"));// short_way_button(_("RWR Indicator Control SEARCH Button"),devices.RWR, rwr_commands.Search,395)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.ActPwr, "397", "RWR", "ACT/PWR Button"));// short_way_button(_("RWR Indicator Control ACT/PWR Button"),devices.RWR, rwr_commands.ActPwr,397)
            AddFunction(new PushButton(this, (int)devices.RWR, (int)rwr_commands.Altitude, "399", "RWR", "ALTITUDE Button"));// short_way_button(_("RWR Indicator Control ALTITUDE Button"),devices.RWR, rwr_commands.Altitude,399)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.RWR, (int)rwr_commands.Power, "401", "1.0", "", "0.0", "", "RWR", "POWER Button", "0.1f"));// default_2_position_tumb(_("RWR Indicator Control POWER Button"),devices.RWR, rwr_commands.Power,401)
            #endregion
            #region CMDS
            AddFunction(new PushButton(this, (int)devices.CMDS, (int)cmds_commands.DispBtn, "604", "CMDS", "CHAFF/FLARE Dispense Button - Push to dispense"));// default_button(_("CHAFF/FLARE Dispense Button - Push to dispense"),devices.CMDS, cmds_commands.DispBtn,604)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.RwrSrc, "375", "1.0", "ON", "0.0", "OFF", "CMDS", "RWR Source Switch, ON/OFF", "0.1f"));// default_2_position_tumb_small(_("RWR Source Switch, ON/OFF"),devices.CMDS, cmds_commands.RwrSrc,375)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.JmrSrc, "374", "1.0", "ON", "0.0", "OFF", "CMDS", "JMR Source Switch, ON/OFF", "0.1f"));// default_2_position_tumb_small(_("JMR Source Switch, ON/OFF"),devices.CMDS, cmds_commands.JmrSrc,374)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.MwsSrc, "373", "1.0", "ON", "0.0", "OFF (no function)", "CMDS", "MWS Source Switch, ON/OFF (no function)", "0.1f"));// default_2_position_tumb_small(_("MWS Source Switch, ON/OFF (no function)"),devices.CMDS, cmds_commands.MwsSrc,373)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.Jett, "371", "1.0", "JETT", "0.0", "OFF", "CMDS", "Jettison Switch, JETT/OFF", "0.1f"));// default_2_position_tumb(_("Jettison Switch, JETT/OFF"),devices.CMDS, cmds_commands.Jett,371)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.O1Exp, "365", "1.0", "ON", "0.0", "OFF", "CMDS", "O1 Expendable Category Switch, ON/OFF", "0.1f"));// default_2_position_tumb_small(_("O1 Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.O1Exp,365)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.O2Exp, "366", "1.0", "ON", "0.0", "OFF", "CMDS", "O2 Expendable Category Switch, ON/OFF", "0.1f"));// default_2_position_tumb_small(_("O2 Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.O2Exp,366)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.ChExp, "367", "1.0", "ON", "0.0", "OFF", "CMDS", "CH Expendable Category Switch, ON/OFF", "0.1f"));// default_2_position_tumb_small(_("CH Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.ChExp,367)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CMDS, (int)cmds_commands.FlExp, "368", "1.0", "ON", "0.0", "OFF", "CMDS", "FL Expendable Category Switch, ON/OFF", "0.1f"));// default_2_position_tumb_small(_("FL Expendable Category Switch, ON/OFF"),devices.CMDS, cmds_commands.FlExp,368)
            AddFunction(new Switch(this, (int)devices.CMDS, "NOT_CY", new SwitchPosition[] { new SwitchPosition("0", "BIT", (int)cmds_commands.Prgm), new SwitchPosition("0.25", "1", (int)cmds_commands.Prgm), new SwitchPosition("0.5", "2", (int)cmds_commands.Prgm), new SwitchPosition("0.75", "3", (int)cmds_commands.Prgm), new SwitchPosition("1", "4", (int)cmds_commands.Prgm) }, "CMDS", "PROGRAM Knob, BIT/1/2/3/4", "0.1f"));// multiposition_switch(_("PROGRAM Knob, BIT/1/2/3/4"),devices.CMDS, cmds_commands.Prgm,377, 5, 0.1, NOT_INVERSED, 0.0, anim_speed_default, NOT_CY
            AddFunction(new Switch(this, (int)devices.CMDS, "anim_speed_defaul", new SwitchPosition[] { new SwitchPosition("0", "OFF", (int)cmds_commands.Mode), new SwitchPosition("0.2", "STBY", (int)cmds_commands.Mode), new SwitchPosition("0.4", "MAN", (int)cmds_commands.Mode), new SwitchPosition("0.6", "SEMI", (int)cmds_commands.Mode), new SwitchPosition("0.8", "AUTO", (int)cmds_commands.Mode), new SwitchPosition("1", "BYP", (int)cmds_commands.Mode) }, "CMDS", "MODE Knob, OFF/STBY/MAN/SEMI/AUTO/BYP", "0.1f"));// multiposition_switch(_("MODE Knob, OFF/STBY/MAN/SEMI/AUTO/BYP"),devices.CMDS, cmds_commands.Mode,378, 6, 0.1, NOT_INVERSED, 0.0, anim_speed_defaul
            #endregion
            #region MFD Left
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_1, "300", "MFD Left", "Left  OSB 1"));// mfd_button(_("Left MFD OSB 1"),devices.MFD_LEFT, mfd_commands.OSB_1,300)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_2, "301", "MFD Left", "Left  OSB 2"));// mfd_button(_("Left MFD OSB 2"),devices.MFD_LEFT, mfd_commands.OSB_2,301)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_3, "302", "MFD Left", "Left  OSB 3"));// mfd_button(_("Left MFD OSB 3"),devices.MFD_LEFT, mfd_commands.OSB_3,302)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_4, "303", "MFD Left", "Left  OSB 4"));// mfd_button(_("Left MFD OSB 4"),devices.MFD_LEFT, mfd_commands.OSB_4,303)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_5, "304", "MFD Left", "Left  OSB 5"));// mfd_button(_("Left MFD OSB 5"),devices.MFD_LEFT, mfd_commands.OSB_5,304)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_6, "305", "MFD Left", "Left  OSB 6"));// mfd_button(_("Left MFD OSB 6"),devices.MFD_LEFT, mfd_commands.OSB_6,305)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_7, "306", "MFD Left", "Left  OSB 7"));// mfd_button(_("Left MFD OSB 7"),devices.MFD_LEFT, mfd_commands.OSB_7,306)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_8, "307", "MFD Left", "Left  OSB 8"));// mfd_button(_("Left MFD OSB 8"),devices.MFD_LEFT, mfd_commands.OSB_8,307)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_9, "308", "MFD Left", "Left  OSB 9"));// mfd_button(_("Left MFD OSB 9"),devices.MFD_LEFT, mfd_commands.OSB_9,308)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_10, "309", "MFD Left", "Left  OSB 10"));// mfd_button(_("Left MFD OSB 10"),devices.MFD_LEFT, mfd_commands.OSB_10,309)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_11, "310", "MFD Left", "Left  OSB 11"));// mfd_button(_("Left MFD OSB 11"),devices.MFD_LEFT, mfd_commands.OSB_11,310)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_12, "311", "MFD Left", "Left  OSB 12"));// mfd_button(_("Left MFD OSB 12"),devices.MFD_LEFT, mfd_commands.OSB_12,311)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_13, "312", "MFD Left", "Left  OSB 13"));// mfd_button(_("Left MFD OSB 13"),devices.MFD_LEFT, mfd_commands.OSB_13,312)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_14, "313", "MFD Left", "Left  OSB 14"));// mfd_button(_("Left MFD OSB 14"),devices.MFD_LEFT, mfd_commands.OSB_14,313)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_15, "314", "MFD Left", "Left  OSB 15"));// mfd_button(_("Left MFD OSB 15"),devices.MFD_LEFT, mfd_commands.OSB_15,314)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_16, "315", "MFD Left", "Left  OSB 16"));// mfd_button(_("Left MFD OSB 16"),devices.MFD_LEFT, mfd_commands.OSB_16,315)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_17, "316", "MFD Left", "Left  OSB 17"));// mfd_button(_("Left MFD OSB 17"),devices.MFD_LEFT, mfd_commands.OSB_17,316)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_18, "317", "MFD Left", "Left  OSB 18"));// mfd_button(_("Left MFD OSB 18"),devices.MFD_LEFT, mfd_commands.OSB_18,317)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_19, "318", "MFD Left", "Left  OSB 19"));// mfd_button(_("Left MFD OSB 19"),devices.MFD_LEFT, mfd_commands.OSB_19,318)
            AddFunction(new PushButton(this, (int)devices.MFD_LEFT, (int)mfd_commands.OSB_20, "319", "MFD Left", "Left  OSB 20"));// mfd_button(_("Left MFD OSB 20"),devices.MFD_LEFT, mfd_commands.OSB_20,319)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.GAIN_Rocker_UP, "320", "MFD Left", "Left  GAIN Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Left MFD GAIN Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.GAIN_Rocker_UP, 320)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.GAIN_Rocker_DOWN, "320", "MFD Left", "Left  GAIN Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Left MFD GAIN Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.GAIN_Rocker_DOWN, 320)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.SYM_Rocker_UP, "321", "MFD Left", "Left  SYM Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Left MFD SYM Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.SYM_Rocker_UP, 321)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.SYM_Rocker_DOWN, "321", "MFD Left", "Left  SYM Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Left MFD SYM Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.SYM_Rocker_DOWN, 321)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.CON_Rocker_UP, "322", "MFD Left", "Left  CON Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Left MFD CON Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.CON_Rocker_UP, 322)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.CON_Rocker_DOWN, "322", "MFD Left", "Left  CON Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Left MFD CON Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.CON_Rocker_DOWN, 322)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.BRT_Rocker_UP, "323", "MFD Left", "Left  BRT Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Left MFD BRT Rocker Switch, Up/Increase"),devices.MFD_LEFT, mfd_commands.BRT_Rocker_UP, 323)
                                                                                                                                  //AddFunction((this, (int)devices.MFD_LEFT, (int)mfd_commands.BRT_Rocker_DOWN, "323", "MFD Left", "Left  BRT Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Left MFD BRT Rocker Switch, Down/Decrease"),devices.MFD_LEFT, mfd_commands.BRT_Rocker_DOWN, 323)
            #endregion
            #region MFD Right
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_1, "326", "MFD Right", "Right  OSB 1"));// mfd_button(_("Right MFD OSB 1"),devices.MFD_RIGHT, mfd_commands.OSB_1,326)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_2, "327", "MFD Right", "Right  OSB 2"));// mfd_button(_("Right MFD OSB 2"),devices.MFD_RIGHT, mfd_commands.OSB_2,327)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_3, "328", "MFD Right", "Right  OSB 3"));// mfd_button(_("Right MFD OSB 3"),devices.MFD_RIGHT, mfd_commands.OSB_3,328)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_4, "329", "MFD Right", "Right  OSB 4"));// mfd_button(_("Right MFD OSB 4"),devices.MFD_RIGHT, mfd_commands.OSB_4,329)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_5, "330", "MFD Right", "Right  OSB 5"));// mfd_button(_("Right MFD OSB 5"),devices.MFD_RIGHT, mfd_commands.OSB_5,330)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_6, "331", "MFD Right", "Right  OSB 6"));// mfd_button(_("Right MFD OSB 6"),devices.MFD_RIGHT, mfd_commands.OSB_6,331)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_7, "332", "MFD Right", "Right  OSB 7"));// mfd_button(_("Right MFD OSB 7"),devices.MFD_RIGHT, mfd_commands.OSB_7,332)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_8, "333", "MFD Right", "Right  OSB 8"));// mfd_button(_("Right MFD OSB 8"),devices.MFD_RIGHT, mfd_commands.OSB_8,333)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_9, "334", "MFD Right", "Right  OSB 9"));// mfd_button(_("Right MFD OSB 9"),devices.MFD_RIGHT, mfd_commands.OSB_9,334)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_10, "335", "MFD Right", "Right  OSB 10"));// mfd_button(_("Right MFD OSB 10"),devices.MFD_RIGHT, mfd_commands.OSB_10,335)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_11, "336", "MFD Right", "Right  OSB 11"));// mfd_button(_("Right MFD OSB 11"),devices.MFD_RIGHT, mfd_commands.OSB_11,336)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_12, "337", "MFD Right", "Right  OSB 12"));// mfd_button(_("Right MFD OSB 12"),devices.MFD_RIGHT, mfd_commands.OSB_12,337)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_13, "338", "MFD Right", "Right  OSB 13"));// mfd_button(_("Right MFD OSB 13"),devices.MFD_RIGHT, mfd_commands.OSB_13,338)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_14, "339", "MFD Right", "Right  OSB 14"));// mfd_button(_("Right MFD OSB 14"),devices.MFD_RIGHT, mfd_commands.OSB_14,339)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_15, "340", "MFD Right", "Right  OSB 15"));// mfd_button(_("Right MFD OSB 15"),devices.MFD_RIGHT, mfd_commands.OSB_15,340)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_16, "341", "MFD Right", "Right  OSB 16"));// mfd_button(_("Right MFD OSB 16"),devices.MFD_RIGHT, mfd_commands.OSB_16,341)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_17, "342", "MFD Right", "Right  OSB 17"));// mfd_button(_("Right MFD OSB 17"),devices.MFD_RIGHT, mfd_commands.OSB_17,342)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_18, "343", "MFD Right", "Right  OSB 18"));// mfd_button(_("Right MFD OSB 18"),devices.MFD_RIGHT, mfd_commands.OSB_18,343)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_19, "344", "MFD Right", "Right  OSB 19"));// mfd_button(_("Right MFD OSB 19"),devices.MFD_RIGHT, mfd_commands.OSB_19,344)
            AddFunction(new PushButton(this, (int)devices.MFD_RIGHT, (int)mfd_commands.OSB_20, "345", "MFD Right", "Right  OSB 20"));// mfd_button(_("Right MFD OSB 20"),devices.MFD_RIGHT, mfd_commands.OSB_20,345)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.GAIN_Rocker_UP, "346", "MFD Right", "Right  GAIN Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Right MFD GAIN Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.GAIN_Rocker_UP, 346)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.GAIN_Rocker_DOWN, "346", "MFD Right", "Right  GAIN Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Right MFD GAIN Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.GAIN_Rocker_DOWN, 346)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.SYM_Rocker_UP, "347", "MFD Right", "Right  SYM Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Right MFD SYM Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.SYM_Rocker_UP, 347)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.SYM_Rocker_DOWN, "347", "MFD Right", "Right  SYM Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Right MFD SYM Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.SYM_Rocker_DOWN, 347)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.CON_Rocker_UP, "348", "MFD Right", "Right  CON Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Right MFD CON Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.CON_Rocker_UP, 348)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.CON_Rocker_DOWN, "348", "MFD Right", "Right  CON Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Right MFD CON Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.CON_Rocker_DOWN, 348)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.BRT_Rocker_UP, "349", "MFD Right", "Right  BRT Rocker Switch, Up/Increase"));// Rocker_switch_positive(_("Right MFD BRT Rocker Switch, Up/Increase"),devices.MFD_RIGHT, mfd_commands.BRT_Rocker_UP, 349)
                                                                                                                                     //AddFunction((this, (int)devices.MFD_RIGHT, (int)mfd_commands.BRT_Rocker_DOWN, "349", "MFD Right", "Right  BRT Rocker Switch, Down/Decrease"));// Rocker_switch_negative(_("Right MFD BRT Rocker Switch, Down/Decrease"),devices.MFD_RIGHT, mfd_commands.BRT_Rocker_DOWN, 349)
            #endregion
            #region Instruments
            #endregion
            #region Airspeed/Mach Indicator
            AddFunction(new Axis(this, (int)devices.AMI, (int)ami_commands.SettingKnob, "true", 0.01d, 0.0d, 1.0d, "MI", "SET INDEX Knob"));// default_axis(_("SET INDEX Knob"), devices.AMI, ami_commands.SettingKnob, 71, 0, 0.05, true, true, true)
            #endregion
            #region Altimeter
            AddFunction(new Axis(this, (int)devices.AAU34, (int)alt_commands.ZERO, "true", 0.01d, 0.0d, 1.0d, "AAU34", "Barometric Setting Knob"));// default_axis(_("Barometric Setting Knob"),devices.AAU34, alt_commands.ZERO, 62, 0, 0.1, true, true, true)
            AddFunction(new Switch(this, (int)devices.AAU34, "60", new SwitchPosition[] { new SwitchPosition("1", "ELEC", (int)alt_commands.ELEC), new SwitchPosition("0.5", "OFF", (int)alt_commands.ELEC), new SwitchPosition("0", "PNEU", (int)alt_commands.ELEC) }, "AAU34", "Mode Lever, Elec/OFF/PNEU", "0.1f"));// springloaded_3_pos_tumb(_("Mode Lever, ELEC/OFF/PNEU"),devices.AAU34, alt_commands.ELEC, alt_commands.PNEU, 60)
            #endregion
            #region SAI
            #endregion
            #region ADI
            AddFunction(new Axis(this, (int)devices.ADI, (int)device_commands.Button_1, "22", 0.01d, 0.0d, 1.0d, "ADI", "Pitch Trim Knob"));// default_axis_limited(_("Pitch Trim Knob"),devices.ADI, device_commands.Button_1, 22)
            #endregion
            #region EHSI
            //AddFunction((this, (int)devices.EHSI, (int)ehsi_commands.RightKnobBtn, "44", "EHSI", "CRS Set / Brightness Control Knob"));// default_button_knob(_("CRS Set / Brightness Control Knob"),devices.EHSI, ehsi_commands.RightKnobBtn, ehsi_commands.RightKnob, 43, 44)
            //AddFunction((this, (int)devices.EHSI, (int)ehsi_commands.LeftKnobBtn, "45", "EHSI", "HDG Set Knob"));// default_button_knob(_("HDG Set Knob"),devices.EHSI, ehsi_commands.LeftKnobBtn, ehsi_commands.LeftKnob, 42, 45)
            AddFunction(new PushButton(this, (int)devices.EHSI, (int)ehsi_commands.ModeBtn, "46", "EHSI", "Mode (M) Button"));// default_button(_("Mode (M) Button"),devices.EHSI, ehsi_commands.ModeBtn, 46)
            #endregion
            #region Clock
            AddFunction(new PushButton(this, (int)devices.CLOCK, (int)clock_commands.CLOCK_right_lev_down, "628", "LOCK", "Clock Elapsed Time Knob"));// default_button(_("Clock Elapsed Time Knob"), devices.CLOCK, clock_commands.CLOCK_right_lev_down, 628)
            #endregion
            #region Cockpit Mechanics
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CPT_MECH, (int)cpt_commands.CanopyHandle, "600", "1.0", "UP", "0.0", "DOWN", "Cockpit MECH", "Canopy Handle, UP/DOWN", "0.1f"));// default_2_position_tumb(_("Canopy Handle, UP/DOWN"),devices.CPT_MECH, cpt_commands.CanopyHandle, 600)
            AddFunction(new Switch(this, (int)devices.CPT_MECH, "786", new SwitchPosition[] { new SwitchPosition("1", "UP", (int)cpt_commands.SeatAdjSwitchDown), new SwitchPosition("0.5", "OFF", (int)cpt_commands.SeatAdjSwitchDown), new SwitchPosition("0", "DOWN", (int)cpt_commands.SeatAdjSwitchDown) }, "Cockpit MECH", "SEAT ADJ Switch, UP/OFF/DOWN", "0.1f"));// springloaded_3_pos_tumb_small(_("SEAT ADJ Switch, UP/OFF/DOWN"),devices.CPT_MECH, cpt_commands.SeatAdjSwitchDown, cpt_commands.SeatAdjSwitchUp, 786)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CPT_MECH, (int)cpt_commands.CanopyTHandle, "601", "1.0", "PULL", "0.0", "STOW", "Cockpit MECH", "CANOPY JETTISON T-Handle, PULL/STOW", "0.1f"));// default_2_position_tumb(_("CANOPY JETTISON T-Handle, PULL/STOW"),devices.CPT_MECH, cpt_commands.CanopyTHandle, 601)
            AddFunction(Switch.CreateToggleSwitch(this, (int)devices.CPT_MECH, (int)cpt_commands.EjectionSafetyLever, "785", "1.0", "ARMED", "0.0", "LOCKED", "Cockpit MECH", "Ejection Safety Lever, ARMED/LOCKED", "0.1f"));// default_2_position_tumb(_("Ejection Safety Lever, ARMED/LOCKED"),devices.CPT_MECH, cpt_commands.EjectionSafetyLever, 785)
            AddFunction(new PushButton(this, (int)devices.CPT_MECH, (int)cpt_commands.CanopySwitchClose, "60", "Cockpit MECH", "Canopy Switch, OPEN/HOLD/CLOSE(momentarily)"));// default_button_tumb(_("Canopy Switch, OPEN/HOLD/CLOSE(momentarily)"),devices.CPT_MECH, cpt_commands.CanopySwitchClose, cpt_commands.CanopySwitchOpen, 60
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
