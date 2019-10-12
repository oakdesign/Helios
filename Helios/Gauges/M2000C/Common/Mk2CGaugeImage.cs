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

namespace GadrocsWorkshop.Helios.Gauges.M2000C.Mk2CGaugeImage
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using System.Windows;
    using System.Windows.Media;

    [HeliosControl("Helios.M2000C.Mk2CGaugeImage", "Mk2C Gauge Image", "M2000C Gauges", typeof(GaugeRenderer))]
    public class Mk2CGaugeImage : BaseGauge
    {
        private GaugeImage _image;

        public Mk2CGaugeImage()
            : this("Mk2C Gauge Image", "", new Point(0,0), new Size(10d, 15d))
        {
        }

        public Mk2CGaugeImage(string name, string image, Point posn, Size size)
            : base(name, size)
        {
            _image = new GaugeImage(image, new Rect(posn, size));
            _image.Clip = new RectangleGeometry(new Rect(posn.X, posn.Y, size.Width, size.Height));
            Components.Add(_image);
        }
    }
}
