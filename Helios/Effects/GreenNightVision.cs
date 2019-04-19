namespace GadrocsWorkshop.Helios.Effects
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using System.Windows.Media.Effects;
    using System.Xml;

    [HeliosControl("Helios.Effects.GreenNightVision", "Green Night Vision", "Effects", typeof(DesignModeRectangleRenderer))]
    public class GreenNightVision: EffectControl
    {
        private GreenNightVisionEffect _effect;

        public GreenNightVision()
            : base("Green Night Vision", LEVEL.COLOR)
        {
            _effect = new GreenNightVisionEffect() { Brightness = 1.0 };
        }
        
        #region Properties
        public double Brightness
        {
            get { return _effect.Brightness; }
            set
            {
                _effect.Brightness = value;
            }
        }

        protected override Effect Effect => _effect;
        #endregion

        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
        }

        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
        }
    }
}
