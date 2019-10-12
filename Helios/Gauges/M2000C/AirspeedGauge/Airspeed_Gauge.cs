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
    using System.Windows;

    [HeliosControl("HELIOS.M2000C.AIRSPEED_GAUGE", "Airspeed Gauge", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_AIRSPEEDGAUGE : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 200, 200);
        private string _interfaceDeviceName = "Airspeed Gauge";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/AirspeedGauge/";

        public M2000C_AIRSPEEDGAUGE()
            : base("Airspeed Gauge", new Size(200, 200))
        {
            double[,] airspeedCalibrationPoints = new double[,] {
                 { 0.05d, 18d },
                 { 0.06d, 24d },
                 { 0.07d, 30d },
                 { 0.08d, 37d },
                 { 0.09d, 45d },
                 { 0.10d, 51d },
                 { 0.15d, 90d },
                 { 0.20d, 125d },
                 { 0.25d, 160d },
                 { 0.30d, 188d },
                 { 0.35d, 213d },
                 { 0.40d, 235d },
                 { 0.45d, 255d },
                 { 0.50d, 270d },
                 { 0.60d, 302d },
                 { 0.70d, 330d },
                };
            AddNeedle("Airspeed Needle", _pathToImages + "airspeed-needle.png", new Point(100, 100), new Size(150d, 150d), new Point(75d, 75d), _interfaceDeviceName, "Airspeed Needle",
                "Airspeed needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 11d, 0.8d, 356d }, airspeedCalibrationPoints, false);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "airspeed-gauge.png"; }
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
