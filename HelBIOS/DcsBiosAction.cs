using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    internal class DcsBiosAction : HeliosAction
    { 
        /// <summary>
        /// sends a command with a numeric value as the command argument
        /// </summary>
        /// <param name="template"></param>
        /// <param name="actionName"></param>
        /// <param name="actionDescription"></param>
        /// <param name="argument"></param>
        public DcsBiosAction(IFunctionTemplate template, string actionName, string actionDescription, int argument)
            : base(template.Parent.CommandInterface, template.DeviceName, template.UniqueName, actionName, actionDescription)
        {
            Execute += (action, eventArgs) => { template.Parent.SendCommand(template.Definition.identifier, argument); };
        }

        /// <summary>
        /// sends a command with a numeric value as the command argument
        /// </summary>
        /// <param name="template"></param>
        /// <param name="actionName"></param>
        /// <param name="actionDescription"></param>
        /// <param name="argument"></param>
        public DcsBiosAction(IFunctionTemplate template, string actionName, string actionDescription, double argument)
            : base(template.Parent.CommandInterface, template.DeviceName, template.UniqueName, actionName, actionDescription)
        {
            Execute += (action, eventArgs) => { template.Parent.SendCommand(template.Definition.identifier, argument); };
        }

        /// <summary>
        /// sends a command with an argument specified in the definition
        /// </summary>
        /// <param name="template"></param>
        /// <param name="actionName"></param>
        /// <param name="actionDescription"></param>
        /// <param name="argument"></param>
        public DcsBiosAction(IFunctionTemplate template, string actionName, string actionDescription, ManifestVersion1.ItemDefinition.Input.Argument argument)
            : base(template.Parent.CommandInterface, template.DeviceName, template.UniqueName, actionName, actionDescription)
        {
            Execute += (action, eventArgs) => { template.Parent.SendCommand(template.Definition.identifier, argument); };
        }

        /// <summary>
        /// sends a command with a well-known DCS-BIOS command argument
        /// </summary>
        /// <param name="template"></param>
        /// <param name="actionName"></param>
        /// <param name="actionDescription"></param>
        /// <param name="argument"></param>
        public DcsBiosAction(IFunctionTemplate template, string actionName, string actionDescription, CommandArgument argument)
            : base(template.Parent.CommandInterface, template.DeviceName, template.UniqueName, actionName, actionDescription)
        {
            Execute += (action, eventArgs) => { template.Parent.SendCommand(template.Definition.identifier, argument); };
        }
    }
}