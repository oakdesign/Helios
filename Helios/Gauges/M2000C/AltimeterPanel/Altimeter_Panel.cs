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

    [HeliosControl("HELIOS.M2000C.ALTIMETER_PANEL", "Altimeter Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_ALTIMETERPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 220, 206);
        private string _interfaceDeviceName = "Altimeter Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;

        public M2000C_ALTIMETERPanel()
            : base("Altimeter Panel", new Size(220, 206))
        {
            int row0 = 68, row1 = 150;

            AddDrum("Altitude (Hundreds)", "{Helios}/Gauges/M2000C/AltimeterPanel/alt_drum_tape.xaml", "hundreds altitude", "(0 - 9)", "#",
                new Point(70, row0), new Size(10d, 15d), new Size(14d, 25d));
            AddDrum("Altitude (Tens)", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "tens altitude", "(0 - 9)", "#",
                new Point(88, row0-2), new Size(10d, 15d), new Size(22d, 36d));
            AddDrum("Altitude (Ones)", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "ones altitude", "(0 - 9)", "#",
                new Point(128, row0), new Size(10d, 15d), new Size(14d, 25d));
            AddDrum("Pressure (Thousands)", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "thousands pressure", "(0 - 9)", "#",
                new Point(99, row1), new Size(10d, 15d), new Size(10d, 15d));
            AddDrum("Pressure (Hundreds)", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "hundreds pressure", "(0 - 9)", "#",
                new Point(110, row1), new Size(10d, 15d), new Size(10d, 15d));
            AddDrum("Pressure (Tens)", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "tens pressure", "(0 - 9)", "#",
                new Point(121, row1), new Size(10d, 15d), new Size(10d, 15d));
            AddDrum("Pressure (Ones)", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "ones pressure", "(0 - 9)", "#",
                new Point(132, row1), new Size(10d, 15d), new Size(10d, 15d));

            AddNeedle("Altitude Needle", "{M2000C}/Images/AltimeterPanel/altimeter-needle.png", "altitude needle", "(0 - 10)", 
                new Point(120, 102), new Size(19d, 110d), new Point(10d, 72), BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d });

            AddPot("Barometric Pressure Calibration", new Point(22, 183), new Size(40, 40), "altimeter-knob", 0d, 0d, 0d, 1d, 0d, 0.015d, true);
        }

        #region Properties

        public override string BezelImage
        {
            get { return "{M2000C}/Images/AltimeterPanel/altimeter-panel.png"; }
        }

        #endregion

        private void AddPot(string name, Point posn, Size size, string imagePrefix, double initialRotation, double rotationTravel, double minValue, double maxValue,
            double initialValue, double stepValue, bool fromCenter)
        {
            AddPot(
                name: name,
                posn: posn,
                size: size,
                knobImage: "{M2000C}/Images/AltimeterPanel/" + imagePrefix + ".png",
                initialRotation: initialRotation,
                rotationTravel: rotationTravel,
                minValue: minValue,
                maxValue: maxValue,
                initialValue: initialValue,
                stepValue: stepValue,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true,
                clickType: ClickType.Touch,
                isContinuous: true);
        }

        private void AddDrum(string name, string gaugeImage, string actionIdentifier, string valueDescription, string format, Point posn, Size size, Size renderSize)
        {
            AddDrumGauge(name: name,
                gaugeImage: gaugeImage,
                posn: posn,
                size: size,
                renderSize: renderSize,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                actionIdentifier: actionIdentifier,
                valueDescription: valueDescription,
                format: format,
                fromCenter: false);
        }

        private void AddNeedle(string name, string needleImage, string actionIdentifier, string valueDescription,
            Point posn, Size size, Point centerPoint, BindingValueUnit typeValue, double[] initialCalibration, double[,] calibrationPoints = null)
        {
            AddNeedle(name: name,
                needleImage: needleImage,
                posn: posn,
                size: size,
                centerPoint: centerPoint,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                actionIdentifier: actionIdentifier,
                valueDescription: valueDescription,
                typeValue: typeValue,
                initialCalibration: initialCalibration,
                calibrationPoints: calibrationPoints,
                fromCenter: false);
        }

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
