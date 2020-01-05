using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    internal class AnalogValue : ItemFunction
    {
        public AnalogValue(IFunctionTemplate template) : base(template)
        {
            // a value
            // XXX need to merge unit information and descriptions for Helios purposes
            HeliosValue heliosValue = new DcsBiosValue(template, new BindingValue(0), "Current analog value.", "", BindingValueUnits.Numeric);
            Values.Add(heliosValue);
            Triggers.Add(heliosValue);

            // connect value
            double scale = System.Convert.ToDouble(template.Definition.outputs[0].max_value) / 2.0;
            if (scale == 0)
            {
                ConfigManager.LogManager.LogError($"missing 'max_value' in item '{template.DeviceName}.{template.Name}'; cannot bind to analog value");
            } 
            else
            {
                template.Parent.RegisterInteger(template.Definition.outputs[0], (value) =>
                {
                    double mapped = (System.Convert.ToDouble(value) / scale) - 1.0;
                    heliosValue.SetValue(new BindingValue(mapped), false);
                });
            }
        }
    }
}