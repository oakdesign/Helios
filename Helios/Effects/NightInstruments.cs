namespace GadrocsWorkshop.Helios.Effects
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using System.Globalization;
    using System.Windows.Media.Effects;
    using System.Xml;

    [HeliosControl("Helios.Effects.NightInstruments", "Night Mode Instruments", "Effects", typeof(DesignModeRectangleRenderer))]
    public class NightInstruments: EffectControl
    {
        private NightInstrumentsEffect _effect;

        // WARNING: we need to maintain our own copy of these values because we cannot access the effect's copy
        // during serialization
        private double _brightness;
        private double _threshold;
        private double _ambient;

        public NightInstruments()
            : base("Night Mode Instruments", LEVEL.LIGHTING)
        {
            _effect = new NightInstrumentsEffect();
            _brightness = _effect.Brightness;
            _threshold = _effect.Threshold;
            _ambient = _effect.Ambient;
        }

        #region Properties
        // XXX this should be a bindable property that can be controlled using the in-game brightness knobs, but it also needs to be adjustable by design, perhaps setting the "middle" or "default" value depending on how brighness knobs start up and act (test this)
        // XXX if successful, share the code for combining design-time brightness and in-game knob values with the NVGs
        public double Brightness
        {
            get { return _brightness; }
            set
            {
                _brightness = value;
                _effect.Brightness = value;
                ConfigManager.LogManager.LogDebug("Night Mode Instruments brightness " + value);
            }
        }
        public double Threshold
        {
            get { return _threshold; }
            set
            {
                _threshold = value;
                _effect.Threshold = value;
                ConfigManager.LogManager.LogDebug("Night Mode Instruments threshold " + value);
            }
        }
        public double Ambient
        {
            get { return _ambient; }
            set
            {
                _ambient = value;
                _effect.Ambient= value;
                ConfigManager.LogManager.LogDebug("Night Mode Instruments ambient brightness " + value);
            }
        }
        protected override Effect Effect => _effect;
        #endregion

        public override void ReadXml(XmlReader reader)
        {
            // WARNING: _effect is locked by another thread, so only access local data
            if (reader.Name == "Brightness")
            {
                Brightness = System.Double.Parse(reader.ReadElementString("Brightness"), CultureInfo.InvariantCulture);
            }
            if (reader.Name == "Threshold")
            {
                Threshold = System.Double.Parse(reader.ReadElementString("Threshold"), CultureInfo.InvariantCulture);
            }
            if (reader.Name == "Ambient")
            {
                Ambient = System.Double.Parse(reader.ReadElementString("Ambient"), CultureInfo.InvariantCulture);
            }
            base.ReadXml(reader);
        }

        public override void WriteXml(XmlWriter writer)
        {
            // WARNING: _effect is locked by another thread, so only access local data
            if (_brightness != NightInstrumentsEffect.DEFAULT_BRIGHTNESS)
            {
                writer.WriteElementString("Brightness", _brightness.ToString(CultureInfo.InvariantCulture));
            }
            if (_threshold != NightInstrumentsEffect.DEFAULT_THRESHOLD)
            {
                writer.WriteElementString("Threshold", _threshold.ToString(CultureInfo.InvariantCulture));
            }
            if (_ambient != NightInstrumentsEffect.DEFAULT_AMBIENT)
            {
                writer.WriteElementString("Ambient", _ambient.ToString(CultureInfo.InvariantCulture));
            }
            base.WriteXml(writer);
        }
    }
}
