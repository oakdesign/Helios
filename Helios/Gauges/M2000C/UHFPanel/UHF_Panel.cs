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

    [HeliosControl("HELIOS.M2000C.UHF_PANEL", "UHF Panel", "M2000C Gauges", typeof(M2000CDeviceRenderer))]
    class M2000C_UHFPanel : M2000CDevice
    {
        private static readonly Rect SCREEN_RECT = new Rect(0, 0, 690, 253);
        private string _interfaceDeviceName = "UHF Panel";
        private Rect _scaledScreenRect = SCREEN_RECT;

        public M2000C_UHFPanel()
            : base("UHF Panel", new Size(690, 253))
        {
            AddRotarySwitch("Mode Selector", new Point(185, 166), new Size(72, 72), "mode-selector");

            AddPot("Channel Selector", new Point(446, 94), "channel-selector",
                0d, 342d, 0.0d, 1d, 0.05d, 0d, true);
                            
            AddIndicatorPushButton("Encryption Light", "green", new Point(113, 173), new Size(27, 27));
            AddIndicatorPushButton("Test", "red", new Point(272, 173), new Size(27, 27));

            AddToggleSwitch("5W/25W Selector", "long-black-", new Point(90, 15), new Size(40, 120), ToggleSwitchPosition.Two, ToggleSwitchType.OnOn);
            AddToggleSwitch("Squelch Switch", "small-black-", new Point(183, 23), new Size(20, 60), ToggleSwitchPosition.One, ToggleSwitchType.OnOn);

            Add3PosnToggle(
                name: "Encryption Switch",
                posn: new Point(263, 47),
                image: "{M2000C}/Images/Switches/small-black-",
                interfaceDevice: _interfaceDeviceName,
                fromCenter: true
                );

            AddDrum("Preset output for display", "{Helios}/Gauges/M2000C/Common/drum_tape.xaml", "Channel", "(1 - 20)", "##",
                new Point(547, 75), new Size(10d, 15d), new Size(14d, 45d));
        }

        #region Properties

        public override string BezelImage
        {
            get { return "{M2000C}/Images/UHFPanel/uhf-panel.png"; }
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

        private void AddToggleSwitch(string name, string imagePrefix, Point posn, Size size, ToggleSwitchPosition defaultPosition, ToggleSwitchType defaultType, bool horizontal = false)
        {
            AddToggleSwitch(name: name,
                posn: posn,
                size: size,
                defaultPosition: defaultPosition,
                positionOneImage: "{M2000C}/Images/Switches/" + imagePrefix + "up.png",
                positionTwoImage: "{M2000C}/Images/SWitches/" + imagePrefix + "down.png",
                defaultType: defaultType,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                horizontal: horizontal,
                fromCenter: false);
        }

        private void Add3PosnToggle(string name, Point posn, string image, string interfaceDevice, bool fromCenter)
        {
            AddThreeWayToggle(
                name: name,
                pos: posn,
                size: new Size(18, 55),
                positionOneImage: image + "up.png",
                positionTwoImage: image + "mid.png",
                positionThreeImage: image + "down.png",
                defaultPosition: ThreeWayToggleSwitchPosition.Two,
                switchType: ThreeWayToggleSwitchType.MomOnMom,
                interfaceDeviceName: interfaceDevice,
                interfaceElementName: name,
                horizontal: false,
                horizontalRender: false,
                clickType: ClickType.Touch,
                fromCenter: fromCenter
                );
        }

        private void AddIndicatorPushButton(string name, string imagePrefix, Point pos, Size size)
        {
            AddIndicatorPushButton(name: name,
                pos: pos,
                size: size,
                image: "{M2000C}/Images/UHFPanel/" + imagePrefix + "-off.png",
                pushedImage: "{M2000C}/Images/UHFPanel/" + imagePrefix + "-pushed.png",
                textColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text,
                onTextColor: Color.FromArgb(0xff, 0x7e, 0xde, 0x72), //don’t need it because not using text,
                font: "",
                onImage: "{M2000C}/Images/UHFPanel/" + imagePrefix + "-on.png",
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true,
                withText: false);
        }

        private void AddPot(string name, Point posn, string imagePrefix, double initialRotation, double rotationTravel, double minValue, double maxValue,
            double initialValue, double stepValue, bool fromCenter)
        {
            AddPot(
                name: name,
                posn: posn,
                size: new Size(140, 140),
                knobImage: "{M2000C}/Images/UHFPanel/" + imagePrefix + ".png",
                initialRotation: initialRotation,
                rotationTravel: rotationTravel,
                minValue: minValue,
                maxValue: maxValue,
                initialValue: initialValue,
                stepValue: stepValue,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: fromCenter,
                clickType: ClickType.Touch,
                isContinuous: true);
        }

        private void AddRotarySwitch(string name, Point posn, Size size, string imagePrefix)
        {
            RotarySwitch rSwitch = AddRotarySwitch(name: name,
                posn: posn,
                size: size,
                knobImage: "{M2000C}/Images/UHFPanel/" + imagePrefix + ".png",
                defaultPosition: 0,
                clickType: ClickType.Touch,
                interfaceDeviceName: _interfaceDeviceName,
                interfaceElementName: name,
                fromCenter: true);
            rSwitch.Positions.Clear();
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 1, "AR", 10d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 2, "M", 100d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 3, "FI", 190d));
            rSwitch.Positions.Add(new RotarySwitchPosition(rSwitch, 4, "H", 280d));
            foreach (RotarySwitchPosition position in rSwitch.Positions)
            {
                AddTrigger(rSwitch.Triggers["position " + position.Index + ".entered"], rSwitch.Name);
            }
            rSwitch.DefaultPosition = 1;
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
