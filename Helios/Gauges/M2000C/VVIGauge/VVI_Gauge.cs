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

    [HeliosControl("HELIOS.M2000C.VVI_GAUGE", "VVI Gauge", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_VVIGAUGE : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 140, 140);
        private string _interfaceDeviceName = "VVI Gauge";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/VVIGauge/";

        public M2000C_VVIGAUGE()
            : base("VVI Gauge", new Size(140, 140))
        {
            double[,] vviCalibrationPoints = new double[,] {
                 { -0.5d, 113d },
                 { -0.4d, 130d },
                 { -0.3d, 155d },
                 { -0.2d, 180d },
                 { -0.15d, 196d },
                 { -0.1d, 220d },
                 { -0.05d, 240d },
                 { 0d, 270d },
                 { 0.05d, 300d },
                 { 0.1d, 320d },
                 { 0.15d, 344d },
                 { 0.2d, 360d },
                 { 0.3d, 385d },
                 { 0.4d, 410d },
                 { 0.5d, 427d },
                };
            AddNeedle("VVI Needle", _pathToImages + "vvi-needle.png", new Point(72, 70), new Size(75d, 75d), new Point(37.5d, 37.5d), _interfaceDeviceName, "VVI Needle",
                "VVI needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { -0.6d, 103d, 0.6d, 436d }, vviCalibrationPoints, false);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "vvi-gauge.png"; }
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
