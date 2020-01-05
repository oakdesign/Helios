using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    /// <summary>
    /// A HeliosValue created from an item definition in DCS-BIOS
    /// 
    /// this layer exists to implement the name translation policy from DCS-BIOS to Helios
    /// </summary>
    internal class DcsBiosValue : HeliosValue
    {
        public DcsBiosValue(IFunctionTemplate template, BindingValue initialValue, string valueName, string valueDescription, BindingValueUnit unit)
            : base(template.Parent.SourceInterface, initialValue, template.DeviceName, template.UniqueName, valueName, valueDescription, unit)
        {
        }
    }
}