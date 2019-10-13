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

namespace GadrocsWorkshop.Helios.Gauges.M2000C
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using GadrocsWorkshop.Helios.Controls;
    using System;
    using System.Globalization;
    using System.Windows;
    using System.Windows.Media;

    [HeliosControl("HELIOS.M2000C.EW_PANEL", "EW Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_EWPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 700, 406);
        private string _interfaceDeviceName = "EW Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/EWPanel/";

        public M2000C_EWPanel()
            : base("EW Panel", new Size(700, 406))
        {
            int row1 = 84, row2 = 96, row3 = 242;
            string commonDrumTape = "{Helios}/Gauges/M2000C/Common/drum_tape.xaml";
            string commonDrumPot = "{M2000C}/Images/Miscellaneous/drum-pot.png";
            string commonSwitches = "{M2000C}/Images/Switches/";

            RotarySwitch modeSwitch = AddRotarySwitch("Mode Switch", new Point(122, 68), new Size(105, 105), _pathToImages + "iff-selector.png", 0, ClickType.Touch,
                _interfaceDeviceName, "Mode Switch", true, null);
            modeSwitch.Positions.Clear();
            modeSwitch.Positions.Add(new RotarySwitchPosition(modeSwitch, 1, "1", 0d));
            modeSwitch.Positions.Add(new RotarySwitchPosition(modeSwitch, 2, "4", 36d));
            modeSwitch.Positions.Add(new RotarySwitchPosition(modeSwitch, 3, "3/2", 64d));
            modeSwitch.Positions.Add(new RotarySwitchPosition(modeSwitch, 4, "3/3", 95d));
            modeSwitch.Positions.Add(new RotarySwitchPosition(modeSwitch, 5, "3/4", 124d));
            modeSwitch.Positions.Add(new RotarySwitchPosition(modeSwitch, 6, "2", 152d));
            modeSwitch.DefaultPosition = 1;

            AddToggleSwitch("L/R Selector", new Point(80, 207), new Size(40, 120), ToggleSwitchPosition.Two, commonSwitches + "long-black-down.png",
                commonSwitches + "long-black-up.png", ToggleSwitchType.OnOn, _interfaceDeviceName, "L/R Selector", true, null, true, true);
            /*
            AddPot("IFF Thousand Selector", new Point(247, row2), new Size(10d, 64d), commonDrumPot, 0d, 0d, 0d, 1d, 0d, 0.1d, _interfaceDeviceName, "IFF Thousand Selector",
                true, ClickType.Touch, true);
            AddPot("IFF Hundreds Selector", new Point(302, row2), new Size(10d, 64d), commonDrumPot, 0d, 0d, 0d, 1d, 0d, 0.1d, _interfaceDeviceName, "IFF Hundreds Selector",
                true, ClickType.Touch, true);
            AddPot("IFF Tens Selector", new Point(359, row2), new Size(10d, 64d), commonDrumPot, 0d, 0d, 0d, 1d, 0d, 0.1d, _interfaceDeviceName, "IFF Tens Selector",
                true, ClickType.Touch, true);
            AddPot("IFF Ones Selector", new Point(409, row2), new Size(10d, 64d), commonDrumPot, 0d, 0d, 0d, 1d, 0d, 0.1d, _interfaceDeviceName, "IFF Ones Selector",
                true, ClickType.Touch, true);
                */
            AddImage("IFF Thousand Selector", commonDrumPot, new Point(247, row2), new Size(10d, 64d), true);
            AddImage("IFF Hundreds Selector", commonDrumPot, new Point(302, row2), new Size(10d, 64d), true);
            AddImage("IFF Tens Selector", commonDrumPot, new Point(359, row2), new Size(10d, 64d), true);
            AddImage("IFF Ones Selector", commonDrumPot, new Point(409, row2), new Size(10d, 64d), true);

            AddDrumGauge("Mode Drum (Thousands)", commonDrumTape, new Point(219, row1), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName,
                "Mode Drum (Thousands)", "thousands Mode Drum", "(0 - 10)", false);
            AddDrumGauge("Mode Drum (Hundreds)", commonDrumTape, new Point(271, row1), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName,
                "Mode Drum (Hundreds)", "hundreds Mode Drum", "(0 - 10)", false);
            AddDrumGauge("Mode Drum (Tens)", commonDrumTape, new Point(326, row1), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName,
                "Mode Drum (Tens)", "tens Mode Drum", "(0 - 10)", false);
            AddDrumGauge("Mode Drum (Ones)", commonDrumTape, new Point(378, row1), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName,
                "Mode Drum (Ones)", "hundreds Mode Drum", "(0 - 10)", false);
                
            RotarySwitch powerModeSwitch = AddRotarySwitch("Power Mode Switch", new Point(497, 67), new Size(105, 105), _pathToImages + "iff-selector.png", 0, ClickType.Touch,
                _interfaceDeviceName, "Power Mode Switch", true);
            powerModeSwitch.Positions.Clear();
            powerModeSwitch.Positions.Add(new RotarySwitchPosition(powerModeSwitch, 1, "OFF", 24d));
            powerModeSwitch.Positions.Add(new RotarySwitchPosition(powerModeSwitch, 2, "SECT", 90d));
            powerModeSwitch.Positions.Add(new RotarySwitchPosition(powerModeSwitch, 3, "CONT", 156d));
            powerModeSwitch.DefaultPosition = 1;

            RotarySwitch ecmModeSwitch = AddRotarySwitch("ECM Mode Switch", new Point(110, 294), new Size(120, 120), _pathToImages + "ecm-mode-selector.png", 0, ClickType.Touch,
                _interfaceDeviceName, "ECM Mode Switch", true);
            ecmModeSwitch.Positions.Clear();
            ecmModeSwitch.Positions.Add(new RotarySwitchPosition(ecmModeSwitch, 1, "VEI", 58d));
            ecmModeSwitch.Positions.Add(new RotarySwitchPosition(ecmModeSwitch, 2, "NORMAL", 90d));
            ecmModeSwitch.Positions.Add(new RotarySwitchPosition(ecmModeSwitch, 3, "PCM", 120d));
            ecmModeSwitch.DefaultPosition = 1;

            AddThreeWayToggle("BR Power Switch", new Point(187, row3), new Size(40, 120), ThreeWayToggleSwitchPosition.One, ThreeWayToggleSwitchType.OnOnOn, _interfaceDeviceName,
                "BR Power Switch", true, commonSwitches + "long-black-up.png", commonSwitches + "long-black-mid.png", commonSwitches + "long-black-down.png", ClickType.Touch);
            AddThreeWayToggle("RWR Power Switch", new Point(243, row3), new Size(40, 120), ThreeWayToggleSwitchPosition.One, ThreeWayToggleSwitchType.OnOnOn, _interfaceDeviceName,
                "RWR Power Switch", true, commonSwitches + "long-black-up.png", commonSwitches + "long-black-mid.png", commonSwitches + "long-black-down.png", ClickType.Touch);
            AddThreeWayToggle("D2M Power Switch", new Point(301, row3), new Size(40, 120), ThreeWayToggleSwitchPosition.One, ThreeWayToggleSwitchType.OnOnOn, _interfaceDeviceName,
                "D2M Power Switch", true, commonSwitches + "long-black-up.png", commonSwitches + "long-black-mid.png", commonSwitches + "long-black-down.png", ClickType.Touch);
            AddThreeWayToggle("Decoy Release Mode Switch", new Point(360, row3), new Size(40, 120), ThreeWayToggleSwitchPosition.One, ThreeWayToggleSwitchType.OnOnOn, _interfaceDeviceName,
                "Decoy Release Mode Switch", true, commonSwitches + "long-black-up.png", commonSwitches + "long-black-mid.png", commonSwitches + "long-black-down.png", ClickType.Touch);

            RotarySwitch decoyDispenserSwitch = AddRotarySwitch("Decoy Release Program Knob", new Point(506, 309), new Size(160, 160), _pathToImages + "decoy-dispenser-program-selector.png",
                0, ClickType.Touch, _interfaceDeviceName, "Decoy Release Program Knob", true);
            decoyDispenserSwitch.Positions.Clear();
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 1, "A", 30d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 2, "1", 60d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 3, "2", 90d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 4, "3", 120d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 5, "4", 150d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 6, "5", 180d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 7, "6", 210d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 8, "7", 239d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 9, "8", 266d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 10, "9", 295d));
            decoyDispenserSwitch.Positions.Add(new RotarySwitchPosition(decoyDispenserSwitch, 11, "10", 323d));
            decoyDispenserSwitch.DefaultPosition = 1;

            AddToggleSwitch("Emergency Hydraulic Pump Switch", new Point(660, 29), new Size(32, 96), ToggleSwitchPosition.Two, commonSwitches + "long-black-up.png",
                commonSwitches + "long-black-down.png", ToggleSwitchType.OnOn, _interfaceDeviceName, "Emergency Hydraulic Pump Switch", true, null, false, false);

            AddToggleSwitch("Audio Warning Switch", new Point(660, 141), new Size(32, 96), ToggleSwitchPosition.Two, commonSwitches + "long-black-up.png",
                commonSwitches + "long-black-down.png", ToggleSwitchType.OnOn, _interfaceDeviceName, "Audio Warning Switch", true, null, false, false);

            ToggleSwitch pitotSwitch = AddToggleSwitch("Pitot Heat Switch", new Point(657, 263), new Size(32, 96), ToggleSwitchPosition.Two, commonSwitches + "long-black-up.png",
                commonSwitches + "long-black-down.png", ToggleSwitchType.OnOn, _interfaceDeviceName, "Pitot Heat Switch", true, null, false, false);

            AddToggleSwitch("Pitot Heat Guard", new Point(650, 270), new Size(55, 132), ToggleSwitchPosition.Two, _pathToImages + "pitot-guard-down.png",
                _pathToImages + "pitot-guard-up.png", ToggleSwitchType.OnOn, _interfaceDeviceName, "Pitot Heat Guard", true, 
                new NonClickableZone[] { new NonClickableZone(new Rect(0, 30, 55, 102), ToggleSwitchPosition.Two, pitotSwitch, ToggleSwitchPosition.One) }, false, false);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "ew-panel.png"; }
        }

        #endregion

        protected override void OnPropertyChanged(PropertyNotificationEventArgs args)
        {
            if (args.PropertyName.Equals("Width") || args.PropertyName.Equals("Height"))
            {
                double scaleX = Width / NativeSize.Width;
                double scaleY = Height / NativeSize.Height;
                _scaledScreenRect.Scale(scaleX, scaleY);
            }
            base.OnPropertyChanged(args);
        }

        public override bool HitTest(Point location)
        {
            if (_scaledScreenRect.Contains(location))
            {
                return false;
            }

            return true;
        }

        public override void MouseDown(Point location)
        {
            // No-Op
        }

        public override void MouseDrag(Point location)
        {
            // No-Op
        }

        public override void MouseUp(Point location)
        {
            // No-Op
        }
    }
}
