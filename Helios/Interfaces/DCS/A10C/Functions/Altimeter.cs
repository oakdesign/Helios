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

namespace GadrocsWorkshop.Helios.Interfaces.DCS.A10C.Functions
{
    using GadrocsWorkshop.Helios.Interfaces.DCS.Common;
    using GadrocsWorkshop.Helios.UDPInterface;
    using GadrocsWorkshop.Helios.Util;
    using System;
    using System.Collections.ObjectModel;
    using System.Globalization;

    class Altimeter : NetworkFunction
    {
        private static DCSDataElement[] _dataElements = new DCSDataElement[] { new DCSDataElement("2051", null, true), new DCSDataElement("2059", null, true) };

        private HeliosValue _altitude;
        private HeliosValue _pressure;

        public Altimeter(BaseUDPInterface sourceInterface)
            : base(sourceInterface)
        {
            _altitude = new HeliosValue(sourceInterface, BindingValue.Empty, "Altimeter", "Altitude", "Barometric altitude above sea level of the aircraft.", "Value is adjusted per altimeter pressure setting.", BindingValueUnits.Feet);
            Values.Add(_altitude);
            Triggers.Add(_altitude);

            _pressure = new HeliosValue(sourceInterface, BindingValue.Empty, "Altimeter", "Pressure", "Manually set barometric altitude.", "", BindingValueUnits.InchesOfMercury);
            Values.Add(_pressure);
            Triggers.Add(_pressure);
        }

        public override ExportDataElement[] GetDataElements()
        {
            return _dataElements;
        }

        public override void ProcessNetworkData(string id, string value)
        {
            string[] parts;
            switch (id)
            {
                case "2051":
                    parts = Tokenizer.TokenizeAtLeast(value, 3, ';');
                    double tenThousands = ClampedParse(parts[0], 10000d);
                    double thousands = ClampedParse(parts[1], 1000d);
                    double hundreds = Parse(parts[2], 100d);

                    double altitude = tenThousands + thousands + hundreds;
                    _altitude.SetValue(new BindingValue(altitude), false);
                    break;
                case "2059":
                    parts = Tokenizer.TokenizeAtLeast(value, 4, ';');
                    double tens = ClampedParse(parts[0], 10d);
                    double ones = ClampedParse(parts[1], 1d);
                    double tenths = ClampedParse(parts[2], .1d);
                    double hundredths = Parse(parts[3], .01d);

                    double pressure = tens + ones + tenths + hundredths;
                    _pressure.SetValue(new BindingValue(pressure), false);
                    break;
            }
        }

        private double Parse(string value, double scale)
        {
            double scaledValue = 0d;
            if (double.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture.NumberFormat, out scaledValue))
            {
                if (scaledValue < 1.0d)
                {
                    scaledValue *= scale * 10d;
                }
                else
                {
                    scaledValue = 0d;
                }
            }
            return scaledValue;
        }

        private double ClampedParse(string value, double scale)
        {
            double scaledValue = 0d;
            if (double.TryParse(value, NumberStyles.Float, CultureInfo.InvariantCulture.NumberFormat, out scaledValue))
            {
                if (scaledValue < 1.0d)
                {
                    scaledValue = Math.Truncate(scaledValue * 10d) * scale;
                }
                else
                {
                    scaledValue = 0d;
                }
            }
            return scaledValue;
        }

        public override void Reset()
        {
            _altitude.SetValue(BindingValue.Empty, true);
            _pressure.SetValue(BindingValue.Empty, true);
        }

    }
}
