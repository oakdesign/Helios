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

    [HeliosControl("HELIOS.M2000C.VTHControl_PANEL", "VTH Control Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_VTHControlPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 530, 340);
        private string _interfaceDeviceName = "VTH Control Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/VTHControlPanel/";
        
        public M2000C_VTHControlPanel()
            : base("VTH Control Panel", new Size(530, 340))
        {
            Size switchSize = new Size(30, 90);
            string longSwitchUp = "{M2000C}/Images/Switches/long-black-up.png";
            string longSwitchMid = "{M2000C}/Images/Switches/long-black-mid.png";
            string longSwitchDown = "{M2000C}/Images/Switches/long-black-down.png";

            AddThreeWayToggle("Altimeter Selector Switch", new Point(370, 25), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.OnOnOn, _interfaceDeviceName,
                "Altimeter Selector Switch", true, longSwitchUp, longSwitchMid, longSwitchDown, ClickType.Touch, false);
            AddThreeWayToggle("Radar Altimeter Power Switch", new Point(370, 130), switchSize, ThreeWayToggleSwitchPosition.Two, ThreeWayToggleSwitchType.OnOnOn, _interfaceDeviceName,
                "Radar Altimeter Power Switch", true, longSwitchUp, longSwitchMid, longSwitchDown, ClickType.Touch, false);

            AddToggleSwitch("Declutter Switch", new Point(56, 78), switchSize, ToggleSwitchPosition.Two, longSwitchUp, longSwitchDown,
                ToggleSwitchType.MomOn, _interfaceDeviceName, "Declutter Switch", true);
            AddToggleSwitch("A/G Gun Reticle Switch", new Point(139, 171), switchSize, ToggleSwitchPosition.Two, longSwitchUp, longSwitchDown,
                ToggleSwitchType.OnOn, _interfaceDeviceName, "A/G Gun Reticle Switch", true);
            AddToggleSwitch("Power Switch", new Point(176, 258), switchSize, ToggleSwitchPosition.Two, longSwitchMid, longSwitchDown,
                ToggleSwitchType.OnOn, _interfaceDeviceName, "Power Switch", true);
            AddToggleSwitch("Auxiliary Gunsight", new Point(359, 258), switchSize, ToggleSwitchPosition.Two, longSwitchMid, longSwitchDown,
                ToggleSwitchType.OnOn, _interfaceDeviceName, "Auxiliary Gunsight", true);

            AddPot("Minimum Altitude Selector", new Point(461, 116), new Size(84, 84), _pathToImages + "minimum-altitude-selector.png", 0d, 360d, 0d, 1d, 0d, 0.1d, _interfaceDeviceName,
                "Minimum Altitude Selector", true, ClickType.Touch, true);
            AddPot("Target Wingspan Knob", new Point(57, 168), new Size(40, 40), _pathToImages + "target-wingspan-knob.png", 0d, 270d, 1d, 0d, 0.75d, 0.05d, _interfaceDeviceName,
                "Target Wingspan Knob", true, ClickType.Touch, false);

            AddButton("HUD Clear Button", new Point(136, 78), new Size(33, 33), _pathToImages + "eff-button.png", _pathToImages + "eff-button.png", "", _interfaceDeviceName, 
                "HUD Clear Button", true);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "vth-control-panel.png"; }
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
