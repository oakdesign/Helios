using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GadrocsWorkshop.Helios.UDPInterface
{
    // a network function that presents as a changeable string value
    public class NetworkTriggerValue : NetworkFunction
    {
        private string _id;
        private HeliosValue _value;
        private HeliosTrigger _receivedTrigger;

        public NetworkTriggerValue(BaseUDPInterface sourceInterface, string id, string name, string description, string valueDescription)
            : base(sourceInterface)
        {
            _id = id;
            _value = new HeliosValue(sourceInterface, BindingValue.Empty, "", name, description, valueDescription, BindingValueUnits.Text);
            Values.Add(_value);
            Triggers.Add(_value);
            _receivedTrigger = new HeliosTrigger(sourceInterface, "", name, "received", description);
        }

        // optional additional trigger for received event regardless of whether the data changes
        public HeliosTrigger Received()
        {
            return _receivedTrigger;
        }

        public override void ProcessNetworkData(string id, string value)
        {
            BindingValue bound = new BindingValue(value);
            _value.SetValue(bound, false);
            _receivedTrigger.FireTrigger(bound);
        }

        public override ExportDataElement[] GetDataElements()
        {
            return new ExportDataElement[] { new ExportDataElement(_id) };
        }

        public override void Reset()
        {
            _value.SetValue(BindingValue.Empty, true);
        }
    }
}
