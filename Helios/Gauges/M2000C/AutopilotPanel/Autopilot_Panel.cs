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

    [HeliosControl("HELIOS.M2000C.AUTOPILOT_PANEL", "Autopilot Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_AUTOPILOTPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 400, 383);
        private string _interfaceDeviceName = "Autopilot Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;

        public M2000C_AUTOPILOTPanel()
            : base("Autopilot Panel", new Size(400, 383))
        {
            AddPushButton("Lights Test Button", "test-button", new Point(55, 347), new Size(19, 19));

            AddIndicator("Master Green", "a", new Point(113, 303), new Size(59, 62));
            AddIndicatorPushButton("Master", "p", new Point(92, 325), new Size(59, 62));

            AddIndicator("Altitude Green", "alt", new Point(147, 252), new Size(60, 60));
            AddIndicatorPushButton("Altitude Hold", "2y", new Point(166, 274), new Size(60, 60));

            AddIndicator("Altitude Set Green", "alt", new Point(199, 203), new Size(60, 60));
            AddIndicatorPushButton("Altitude Set", "aff", new Point(218, 225), new Size(60, 60));

            AddIndicator("Not Working Green", "2g", new Point(247, 152), new Size(60, 60));
            AddIndicatorPushButton("Not Working", "2y", new Point(267, 174), new Size(60, 60));

            AddIndicator("Localizer Left Green", "l", new Point(292, 112), new Size(40, 40));
            AddIndicator("Localizer Left", "1y", new Point(313, 133), new Size(40, 40));
            AddIndicator("Localizer Right Green", "g", new Point(315, 90), new Size(40, 40));
            AddIndicatorPushButton("Localizer Right", "1y", new Point(336, 112), new Size(40, 40));
        }

        #region Properties

        public override string BezelImage
        {
            get { return "{M2000C}/Images/AutopilotPanel/autopilot-panel.png"; }
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

        private void AddPushButton(string name, string imagePrefix, Point posn, Size size)
        {
            AddButton(name: name,
                posn: posn,
                size: size,
                image: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + ".png",
                pushedImage: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + ".png",
                buttonText: "",
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true);
        }

        private void AddIndicatorPushButton(string name, string imagePrefix, Point pos, Size size)
        {
            AddIndicatorPushButton(name: name,
                pos: pos,
                size: size,
                image: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + ".png",
                pushedImage: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + ".png",
                textColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text,
                onTextColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text,
                font: "",
                onImage: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + "-on.png",
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true,
                withText: false);
        }

        private void AddIndicator(string name, string imagePrefix, Point posn, Size size)
        {
            AddIndicator(
                name: name,
                posn: posn,
                size: size,
                onImage: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + "-on.png",
                offImage: "{M2000C}/Images/AutopilotPanel/" + imagePrefix + "-off.png",
                onTextColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text
                offTextColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text
                font: "", //don’t need it because not using text
                vertical: false, //don’t need it because not using text
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true,
                withText: false); //added in Composite Visual as an optional value with a default value set to true
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
