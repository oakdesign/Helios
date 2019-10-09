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

    [HeliosControl("HELIOS.M2000C.FUEL_PANEL", "Fuel Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_FuelPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 223, 396);
        private string _interfaceDeviceName = "Fuel Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/FuelPanel/";

        public M2000C_FuelPanel()
            : base("Fuel Panel", new Size(223, 396))
        {
            int row1 = 6, row2 = 178, row3 = 199, row4 = 220, row5 = 163, row6 = 71;
            int column1 = 93, column2 = 81, column3 = 102, column4 = 122;
            string commonDrumTape = "{Helios}/Gauges/M2000C/Common/drum_tape.xaml";

            //First row
            AddIndicator("Air Refueling", new Point(column1, row1), new Size(28, 28), _pathToImages + "air-refueling-on.png", _pathToImages + "air-refueling-off.png", 
                default, default, "", false, _interfaceDeviceName, "Air Refueling", false, false);
            //Second row
            AddIndicator("left-rl", new Point(column2, row2), new Size(21, 21), _pathToImages + "rl-on.png", _pathToImages + "rl-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);
            AddIndicator("center-rl", new Point(column3, row2), new Size(21, 21), _pathToImages + "rl-on.png", _pathToImages + "rl-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);
            AddIndicator("right-rl", new Point(column4, row2), new Size(21, 21), _pathToImages + "rl-on.png", _pathToImages + "rl-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);
            //Third row
            AddIndicator("left-av", new Point(column2, row3), new Size(21, 21), _pathToImages + "av-on.png", _pathToImages + "av-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);
            AddIndicator("right-av", new Point(column4, row3), new Size(21, 21), _pathToImages + "av-on.png", _pathToImages + "av-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);
            //Forth row
            AddIndicator("left-v", new Point(column2, row4), new Size(21, 21), _pathToImages + "v-on.png", _pathToImages + "v-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);
            AddIndicator("right-v", new Point(column4, row4), new Size(21, 21), _pathToImages + "v-on.png", _pathToImages + "v-off.png",
                default, default, "", false, _interfaceDeviceName, "left-rl", false, false);

            RotarySwitch rSwitch = AddRotarySwitch("Fuel CrossFeed Switch", new Point(112, 360), new Size(45, 45), _pathToImages + "fuel-transfer-knob.png", 0,  ClickType.Touch,
                _interfaceDeviceName, "Fuel CrossFeed Switch", true);
            rSwitch.Positions.Clear();
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 1, "OFF", 0d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 2, "ON", 90d));
            rSwitch.DefaultPosition = 1;

            AddRectangleFill("Internal Fuel Quantity Needle", new Point(41, row5), new Size(5, 182), Color.FromArgb(0xff, 0xff, 0xff, 0xff), 0d, _interfaceDeviceName, "Internal Fuel Quantity Needle", false);
            AddRectangleFill("Total Fuel Quantity Needle", new Point(192, row5), new Size(5, 182), Color.FromArgb(0xff, 0xff, 0xff, 0xff), 0d, _interfaceDeviceName, "Total Fuel Quantity Needle", false);

            AddDrumGauge("Internal Fuel Quantity (Tens)", commonDrumTape, new Point(82, row6), new Size(10d, 15d), new Size(12d, 19d), "#", _interfaceDeviceName,
                "Internal Fuel Quantity (Tens)", "tens quantity", "(0 - 10)", false);
            AddDrumGauge("Internal Fuel Quantity (Hundreds)", commonDrumTape, new Point(55, row6), new Size(10d, 15d), new Size(12d, 19d), "#", _interfaceDeviceName,
                "Internal Fuel Quantity (Hundreds)", "hundreds quantity", "(0 - 10)", false);
            AddDrumGauge("Internal Fuel Quantity (Thousands)", commonDrumTape, new Point(29, row6), new Size(10d, 15d), new Size(12d, 19d), "#", _interfaceDeviceName,
                "Internal Fuel Quantity (Thousands)", "thousands quantity", "(0 - 10)", false);
            AddDrumGauge("Total Fuel Quantity (Tens)", commonDrumTape, new Point(178, row6), new Size(10d, 15d), new Size(12d, 19d), "#", _interfaceDeviceName,
                "Total Fuel Quantity (Tens)", "tens quantity", "(0 - 10)", false);
            AddDrumGauge("Total Fuel Quantity (Hundreds)", commonDrumTape, new Point(154, row6), new Size(10d, 15d), new Size(12d, 19d), "#", _interfaceDeviceName,
                "Total Fuel Quantity (Hundreds)", "hundreds quantity", "(0 - 10)", false);
            AddDrumGauge("Total Fuel Quantity (Thousands)", commonDrumTape, new Point(129, row6), new Size(10d, 15d), new Size(12d, 19d), "#", _interfaceDeviceName, 
                "Total Fuel Quantity (Thousands)", "thousands quantity", "(0 - 10)", false);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "fuel-panel.png"; }
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
