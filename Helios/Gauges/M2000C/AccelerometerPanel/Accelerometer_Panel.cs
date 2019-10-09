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

    [HeliosControl("HELIOS.M2000C.ACCELEROMETER_PANEL", "Accelerometer Gauge", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_ACCELEROMETERPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 150, 143);
        private string _interfaceDeviceName = "Accelerometer Gauge";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/AccelerometerGauge/";

        public M2000C_ACCELEROMETERPanel()
            : base("Accelerometer Gauge", new Size(150, 143))
        {
            double[,] acceleratorCalibrationPoints = new double[,] {
                 { -0.4d, 160d },
                 { -0.3d, 183d },
                 { -0.2d, 205d },
                 { -0.1d, 229d },
                 { 0d, 252d },
                 { 0.1d, 270d },
                 { 0.2d, 297d },
                 { 0.3d, 320d },
                 { 0.4d, 342d },
                 { 0.5d, 3d },
                 { 0.6d, 26d },
                 { 0.7d, 47d },
                 { 0.8d, 70d },
                 { 0.9d, 91d },
                 { 1.0d, 113d },
                };
            AddNeedle("Accelerometer Needle", _pathToImages + "accelerometer-needle.png", new Point(89, 65), new Size(10d, 66d), new Point(5d, 43), _interfaceDeviceName, "Accelerometer Needle", 
                "accelerometer needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { -0.5d, 135d, 1d, 100d }, acceleratorCalibrationPoints, false);

            AddPot("Accelerometer knob", new Point(20, 125), new Size(30, 30), _pathToImages + "accelerometer-knob.png", 0d, 0d, 0d, 1d, 0d, 0.015d, 
                _interfaceDeviceName, "Accelerometer knob", true);//not use so far in DCS
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "accelerometer-gauge.png"; }
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
