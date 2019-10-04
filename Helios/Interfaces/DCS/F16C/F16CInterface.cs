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
