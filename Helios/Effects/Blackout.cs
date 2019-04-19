namespace GadrocsWorkshop.Helios.Effects
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using System.Windows.Media;
    using System.Windows.Media.Effects;
    using System.Xml;

    [HeliosControl("Helios.Effects.Blackout", "Blackout", "Effects", typeof(DesignModeRectangleRenderer))]
    public class Blackout: EffectControl
    {
        private BlackoutEffect _effect;
        private double _intensity = 0.0;
        private HeliosValue _intensityValue;

        public Blackout()
            : base("Blackout", LEVEL.PERCEPTION)
        {
            _effect = new BlackoutEffect() { Intensity = 0.0 };
            FillColor = Colors.Black;
            BorderColor = Colors.White;

            _intensityValue = new HeliosValue(this, new BindingValue(false), "", "intensity", "Indicates current intensity of blackout effect, from 0.0 to 1.0.", "0.0 disables the effect.", BindingValueUnits.Numeric);
            _intensityValue.Execute += new HeliosActionHandler(SetIntensityAction_Execute);
            Values.Add(_intensityValue);
            Actions.Add(_intensityValue);
        }
        
        #region Properties
        public double Intensity
        {
            get { return _effect.Intensity; }
            set
            {
                double oldValue = _effect.Intensity;
                double newValue = System.Math.Min(1.0, value);
                if (newValue != oldValue)
                {
                    _effect.Intensity = newValue;
                    IsEffectActive = (newValue > 0.0);
                    OnPropertyChanged("Intensity", oldValue, newValue, false);
                }
            }
        }

        protected override Effect Effect => _effect;
        #endregion

        #region Actions
        void SetIntensityAction_Execute(object action, HeliosActionEventArgs e)
        {
            Intensity = e.Value.DoubleValue;
        }
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
