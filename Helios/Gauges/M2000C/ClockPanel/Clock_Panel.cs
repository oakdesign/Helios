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
    using GadrocsWorkshop.Helios.Gauges.M2000C.Mk2CNeedle;

    [HeliosControl("HELIOS.M2000C.CLOCK_PANEL", "Clock Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_CLOCKPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 215, 243);
        private string _interfaceDeviceName = "Clock Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/ClockPanel/";

        public M2000C_CLOCKPanel()
            : base("Clock Panel", new Size(215, 243))
        {
            int centerX = 106, centerY = 104;

            AddNeedle("Hours Needle", _pathToImages + "hours-needle.png", new Point(centerX, centerY), new Size(13d, 58d), new Point(6.5d, 52d), _interfaceDeviceName, "Hours Needle",
                "Hours needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);
            AddNeedle("Minutes Needle", _pathToImages + "minutes-needle.png", new Point(centerX, centerY), new Size(13d, 76d), new Point(6.5d, 70d), _interfaceDeviceName, "Minutes Needle",
                "Minutes needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);
            AddNeedle("Seconds Needle", _pathToImages + "seconds-needle.png", new Point(centerX, centerY), new Size(13d, 78d), new Point(6.5d, 72d), _interfaceDeviceName, "Seconds Needle",
                "Seconds needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);
            AddNeedle("Little Needle", _pathToImages + "little-needle.png", new Point(107, 142), new Size(6d, 26d), new Point(3d, 23d), _interfaceDeviceName, "Little Needle",
                "Little needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);
            AddNeedle("Clock Rose", _pathToImages + "clock-rose.png", new Point(centerX, centerY), new Size(206d, 206d), new Point(103d, 103d), _interfaceDeviceName, "Clock Rose",
                "Clock Rose", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);

            AddRotarySwitch("Rotary Switch", new Point(107, 223), new Size(40, 40), _pathToImages + "rotary-switch.png", 0, _interfaceDeviceName, "Rotary Switch", true);
            AddButton("Push Button", new Point(107, 223), new Size(30, 30), _pathToImages + "push-button.png", _pathToImages + "push-button.png", "",
                _interfaceDeviceName, "Push Button", true);
            AddToggleSwitch("Tige", new Point(170, 202), new Size(14, 40), ToggleSwitchPosition.One, _pathToImages + "tige-pushed.png", _pathToImages + "tige-released.png", ToggleSwitchType.OnOn,
                _interfaceDeviceName, "Tige", false);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "clock-panel.png"; }
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
