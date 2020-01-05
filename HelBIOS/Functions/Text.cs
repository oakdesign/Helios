using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    internal class Text : ItemFunction
    {
        public Text(IFunctionTemplate template) : base(template)
        {
            // a basic string value
            HeliosValue heliosValue = new DcsBiosValue(template, new BindingValue(""), "Current text value.", "", BindingValueUnits.Text);
            Values.Add(heliosValue);
            Triggers.Add(heliosValue);

            // connect value
            template.Parent.RegisterString(template.Definition.outputs[0], (value) =>
            {
                heliosValue.SetValue(new BindingValue(value), false);
            });
        }
    }
}