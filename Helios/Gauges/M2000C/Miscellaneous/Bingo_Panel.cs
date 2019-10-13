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
    using System.Windows.Media;

    [HeliosControl("HELIOS.M2000C.Bingo_PANEL", "Bingo Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_BingoPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 138, 170);
        private string _interfaceDeviceName = "Bingo Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/Miscellaneous/";
        string commonDrumTape = "{Helios}/Gauges/M2000C/Common/drum_tape.xaml";

        public M2000C_BingoPanel()
            : base("Bingo Panel", new Size(138, 170))
        {
            AddDrumGauge("Bingo Fuel 1 000 kg", commonDrumTape, new Point(28, 105), new Size(10d, 15d), new Size(16d, 24d), "#", _interfaceDeviceName, "Bingo Fuel 1 000 kg", "Bingo Fuel 1 000 kg", "0 - 9", false);
            AddDrumGauge("Bingo Fuel 100 kg", commonDrumTape, new Point(66, 105), new Size(10d, 15d), new Size(16d, 24d), "#", _interfaceDeviceName, "Bingo Fuel 100 kg", "Bingo Fuel 100 kg", "0 - 9", false);
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "bingo-panel.png"; }
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
