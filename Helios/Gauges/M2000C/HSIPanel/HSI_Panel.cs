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
    using System.Windows;
    using System.Windows.Media;
    using GadrocsWorkshop.Helios.Gauges.M2000C;

    [HeliosControl("HELIOS.M2000C.HSI_PANEL", "HSI Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_HSIPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 300, 287);
        private string _interfaceDeviceName = "HSI Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/HSIPanel/";

        public M2000C_HSIPanel()
            : base("HSI Panel", new Size(300, 287))
        {
            int row0 = 84;
            int column0 = 95, column1 = 128, column2 = 158, column3 = 188;
            string commonDrumTape = "{Helios}/Gauges/M2000C/Common/drum_tape.xaml";
            string voidImage = "{M2000C}/Images/Miscellaneous/void.png";

            AddDrumGauge("Distance (Decimals)", commonDrumTape, new Point(column3, row0), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName, "Distance (Decimals)", 
                "decimal distance", "(0 - 9)", false);
            AddDrumGauge("Distance (Ones)", commonDrumTape, new Point(column2, row0), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName, "Distance (Ones)",
                "ones distance", "(0 - 9)", false);
            AddDrumGauge("Distance (Tens)", commonDrumTape, new Point(column1, row0), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName, "Distance (Tens)",
                "tens distance", "(0 - 9)", false);
            AddDrumGauge("Distance (Hundreds)", commonDrumTape, new Point(column0, row0), new Size(10d, 15d), new Size(20d, 30d), "#", _interfaceDeviceName, "Distance (Hundreds)",
                "hundreds distance", "(0 - 9)", false);

            AddNeedle("Compass Rose", _pathToImages + "hsi-rose.png", new Point(150d, 141d), new Size(250d, 250d), new Point(125d, 125d), _interfaceDeviceName, "Compass Rose",
                "compass", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 360d, 1d, 0d }, null, false);

            AddIndicator("Flag distance", new Point(90, 93), new Size(120, 15), _pathToImages + "distance-flag.png", voidImage,
                default, default, "", false, _interfaceDeviceName, "Flag distance", false, false);
            AddIndicator("Flag 1", new Point(98, 143), new Size(30, 15), _pathToImages + "left-flag.png", voidImage,
                default, default, "", false, _interfaceDeviceName, "Flag 1", false, false);
            AddIndicator("Flag 2", new Point(172, 143), new Size(30, 15), _pathToImages + "right-flag.png", voidImage, 
                default, default, "", false, _interfaceDeviceName, "Flag 2", false, false);
            AddIndicator("Flag CAP", new Point(140, 168), new Size(30, 15), _pathToImages + "right-flag.png", voidImage, 
                default, default, "", false, _interfaceDeviceName, "Flag CAP", false, false);

            AddNeedle("Direction Needle", _pathToImages + "direction-needle.png", new Point(152, 141), new Size(40d, 20d), new Point(20d, 130d), _interfaceDeviceName, "Direction Needle", 
                "direction needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);
            double[,] modeCalibrationPoints = new double[,] {
                 { 0.2d, 186d },
                 { 0.3d, 169d },
                 { 0.4d, 154d },
                 { 0.5d, 138d },
                };
            AddNeedle("Mode Needle", _pathToImages + "mode-selector-needle.png", new Point(150, 125), new Size(23d, 23d), new Point(11d, 100d), _interfaceDeviceName, "Mode Needle",
                "mode needle", "(0 - 6)", BindingValueUnits.Degrees, new double[] { 0d, 220d, 0.6d, 120d }, modeCalibrationPoints, false);
            AddNeedle("Big Needle", _pathToImages + "big-needle.png", new Point(152, 141), new Size(20d, 184d), new Point(10d, 100d), _interfaceDeviceName, "Big Needle",
                "big needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);
            AddNeedle("Small Needle", _pathToImages + "small-needle.png", new Point(157, 145), new Size(8d, 202d), new Point(4d, 101d), _interfaceDeviceName, "Small Needle",
                "small needle", "(0 - 360)", BindingValueUnits.Degrees, new double[] { 0d, 0d, 1d, 360d }, null, false);

            AddImage("Fixed Rose", _pathToImages + "fixed-rose.png", new Point(150d, 141d), new Size(260d, 260d), true);

            AddPot("VAD Selector", new Point(30,260), new Size(45, 45), _pathToImages + "vad-selector.png", 0d, 360d, 0d, 1d, 0d, 0.1d, _interfaceDeviceName, "VAD Selector", 
                true, ClickType.Touch, true);
            AddRotarySwitch("Mode Selector", new Point(270, 260), new Size(45, 45), "mode-selector");
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "hsi-panel.png"; }
        }

        #endregion

/*        private void AddPot(string name, Point posn, Size size, string imagePrefix, double initialRotation, double rotationTravel, double minValue, double maxValue,
            double initialValue, double stepValue, bool fromCenter)
        {
            AddPot(
                name: name,
                posn: posn,
                size: size,
                knobImage: "{M2000C}/Images/HSIPanel/" + imagePrefix + ".png",
                initialRotation: initialRotation,
                rotationTravel: rotationTravel,
                minValue: minValue,
                maxValue: maxValue,
                initialValue: initialValue,
                stepValue: stepValue,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true,
                clickType: ClickType.Touch);
        }
        */
        private void AddRotarySwitch(string name, Point posn, Size size, string imagePrefix)
        {
            RotarySwitch rSwitch = AddRotarySwitch(name: name,
                posn: posn,
                size: size,
                knobImage: "{M2000C}/Images/HSIPanel/" + imagePrefix + ".png",
                defaultPosition: 0,
                clickType: ClickType.Touch,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true);
            rSwitch.Positions.Clear();
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 1, "Cv/NAV", 0d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 2, "NAV", 20d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 3, "TAC", 40d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 4, "VAD", 60d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 5, "rho", 80d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 6, "theta", 100d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 7, "TEL", 120d));
            rSwitch.DefaultPosition = 2;
        }
        /*
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

                private void AddIndicator(string name, string imagePrefix, Point posn, Size size)
                {
                    AddIndicator(
                        name: name,
                        posn: posn,
                        size: size,
                        onImage: "{M2000C}/Images/HSIPanel/" + imagePrefix + ".png",
                        offImage: "{M2000C}/Images/Miscellaneous/void.png",
                        onTextColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text
                        offTextColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text
                        font: "", //don’t need it because not using text
                        vertical: false, //don’t need it because not using text
                        interfaceDeviceName: _interfaceDeviceName,
                        interfaceElementName: name,
                        fromCenter: false,
                        withText: false); //added in Composite Visual as an optional value with a default value set to true
                }
                */
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
