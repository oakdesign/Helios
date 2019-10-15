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
    using System.Collections;
    using System.Globalization;
    using System.Windows;
    using System.Windows.Media;

    [HeliosControl("HELIOS.M2000C.VTB_PANEL", "VTB Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_VTBPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 551, 602);
        private string _interfaceDeviceName = "VTB Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/VTBPanel/";
        
        public M2000C_VTBPanel()
            : base("VTB Panel", new Size(551, 602))
        {
            int row0 = 120, row1 = 203, row2 = 286, row3 = 370, row4 = 482, row5 = 529;
            int column0 = 20, column1 = 505;
            Size switchSize = new Size(24, 48);
            string shortSwitchUp = "{M2000C}/Images/Switches/short-black-up.png";
            string shortSwitchMid = "{M2000C}/Images/Switches/short-black-mid.png";
            string shortSwitchDown = "{M2000C}/Images/Switches/short-black-down.png";

            AddThreeWayToggle("Begin/End Parameter", new Point(column0, row0), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, 
                "Begin/End Parameter", true, shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("N Parameter", new Point(column0, row1), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "N Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("P Parameter", new Point(column0, row2), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "P Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("B Parameter", new Point(column0, row3), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "B Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("C Parameter", new Point(column1, row0), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "C Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("Z Parameter", new Point(column1, row1), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "Z Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("M Parameter", new Point(column1, row2), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "M Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("T Parameter", new Point(column1, row3), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.MomOnMom, _interfaceDeviceName, "T Parameter", true,
                shortSwitchUp, shortSwitchMid, shortSwitchDown, ClickType.Touch, false);
            AddToggleSwitch("Power Switch", new Point(517, row4), switchSize, ToggleSwitchPosition.Two, shortSwitchUp, shortSwitchDown,
                ToggleSwitchType.OnOn, _interfaceDeviceName, "Power Switch", true);
            AddToggleSwitch("Symbology Declutter", new Point(94, row5), switchSize, ToggleSwitchPosition.Two, shortSwitchUp, shortSwitchDown,
                ToggleSwitchType.MomOn, _interfaceDeviceName, "Symbology Declutter", true);
            AddToggleSwitch("Map Reframe", new Point(152, row5), switchSize, ToggleSwitchPosition.Two, shortSwitchUp, shortSwitchDown,
                ToggleSwitchType.OnOn, _interfaceDeviceName, "Map Reframe", true);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "vtb-panel.png"; }
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
