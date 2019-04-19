namespace GadrocsWorkshop.Helios.Effects
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using System.Globalization;
    using System.Windows.Media.Effects;
    using System.Xml;

    [HeliosControl("Helios.Effects.GreenNightVision", "Green Night Vision", "Effects", typeof(DesignModeRectangleRenderer))]
    public class GreenNightVision: EffectControl
    {
        private const double DEFAULT_BRIGHTNESS = 1.0;
        private GreenNightVisionEffect _effect;

        // WARNING: we need to maintain our own copy of this value because we cannot access the effect's copy
        // during serialization
        private double _brightness = DEFAULT_BRIGHTNESS;

        public GreenNightVision()
            : base("Green Night Vision", LEVEL.COLOR)
        {
            _effect = new GreenNightVisionEffect() { Brightness = DEFAULT_BRIGHTNESS };
        }
        
        #region Properties
        public double Brightness
        {
            get { return _brightness; }
            set
            {
                _brightness = value;
                _effect.Brightness = value;
            }
        }

        protected override Effect Effect => _effect;
        #endregion

        public override void ReadXml(XmlReader reader)
        {
            if (reader.Name == "Brightness")
            {
                Brightness = System.Double.Parse(reader.ReadElementString("Brightness"), CultureInfo.InvariantCulture);
            }
            base.ReadXml(reader);
        }

        public override void WriteXml(XmlWriter writer)
        {
            if (_brightness != DEFAULT_BRIGHTNESS)
            {
                writer.WriteElementString("Brightness", _brightness.ToString(CultureInfo.InvariantCulture));
            }
            base.WriteXml(writer);
        }
    }
}
