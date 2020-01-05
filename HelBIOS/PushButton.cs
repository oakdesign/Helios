using GadrocsWorkshop.Helios;
using static net.derammo.HelBIOS.SchemaVersion1.ItemDefinition;

namespace net.derammo.HelBIOS
{
    internal class PushButton : ItemFunction
    {
        public PushButton(IFunctionTemplate template) : base(template)
        {
            // a value and associated triggers
            HeliosValue heliosValue = new DcsBiosValue(template, new BindingValue(false), "Current state of this button.", "True if the button is currently pushed (either via pressure or toggle), otherwise false.", BindingValueUnits.Boolean);
            Values.Add(heliosValue);
            Triggers.Add(heliosValue);

            HeliosTrigger pushedTrigger = new DcsBiosTrigger(template, "pushed", "Fired when this button is pushed in the simulator.");
            Triggers.Add(pushedTrigger);

            HeliosTrigger releasedTrigger = new DcsBiosTrigger(template, "released", "Fired when this button is released in the simulator.");
            Triggers.Add(releasedTrigger);

            // connect values and triggers
            template.Parent.RegisterInteger(template.Definition.outputs[0], (value) =>
            {
                heliosValue.SetValue(new BindingValue(value != 0), false);
                if (value == 0)
                {
                    releasedTrigger.FireTrigger(BindingValue.Empty);
                } 
                else
                {
                    pushedTrigger.FireTrigger(BindingValue.Empty);
                }
            });

            // create appropriate actions
            foreach (Input input in template.Definition.inputs)
            {
                switch (input._interface)
                {
                    case Input.Interface.set_state:
                        Actions.Add(new DcsBiosAction(template, "push", "Pushes this button in the simulator", 1));
                        Actions.Add(new DcsBiosAction(template, "release", "Releases the button in the simulator.", 0));
                        break;
                    case Input.Interface.fixed_step:
                        // create INC/DEC actions if we want to do that
                        break;
                    case Input.Interface.action:
                        // convert capitalization convention from DCS-BIOS to Helios
                        string actionName = input.argument.ToString().ToLower();
                        if (input.argument != Input.Argument.UNSET)
                        {
                            Actions.Add(new DcsBiosAction(template, actionName, input.description, input.argument));
                        } 
                        else
                        {
                            // REVISIT: is command without argument something we should warn about?
                            // XXX do we send empty string?
                        }
                        break;
                }
            }
        }
    }
}