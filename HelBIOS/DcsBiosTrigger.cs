using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    /// <summary>
    /// A HeliosTrigger created from an item definition in DCS-BIOS
    /// 
    /// this layer exists to implement the name translation policy from DCS-BIOS to Helios
    /// </summary>
    internal class DcsBiosTrigger: HeliosTrigger
    {
        public DcsBiosTrigger(IFunctionTemplate template, string verb, string triggerDescription)
            : base(template.Parent.SourceInterface, template.DeviceName, template.UniqueName, verb, triggerDescription)
        {
        }
    }
}