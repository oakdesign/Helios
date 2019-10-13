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

    [HeliosControl("HELIOS.M2000C.CanopyPanel", "Canopy Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_CanopyPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 300, 266);
        private string _interfaceDeviceName = "Canopy Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;
        string _pathToImages = "{M2000C}/Images/CanopyPanel/";

        public M2000C_CanopyPanel()
            : base("Canopy Panel", new Size(300, 266))
        {
            PushButton canopyHoldButton = AddButton("Canopy Hold", new Point(18, 0), new Size(78,87), _pathToImages + "canopy-holding-handle.png", _pathToImages + "canopy-holding-handle.png",
                "", _interfaceDeviceName, "Canopy Hold", false);

            AddThreeWayToggle("Canopy Lever", new Point(0,0), new Size(300,266), ThreeWayToggleSwitchPosition.One, ThreeWayToggleSwitchType.OnOnOn,
                _interfaceDeviceName, "Canopy Lever", false, _pathToImages + "canopy-handle-down.png", _pathToImages + "canopy-handle-mid.png", _pathToImages + "canopy-handle-up.png",
                ClickType.Touch, true, false, new NonClickableZone[] { new NonClickableZone(new Rect(0,0,96,87), true, canopyHoldButton)});
        }

        #region Properties

        public override string BezelImage
        {
            get { return _pathToImages + "canopy-panel.png"; }
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
