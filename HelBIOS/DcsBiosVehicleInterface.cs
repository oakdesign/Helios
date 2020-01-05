using GadrocsWorkshop.Helios;
using GadrocsWorkshop.Helios.ComponentModel;
using GadrocsWorkshop.Helios.Interfaces.Network;
using net.derammo.HelBIOS.ManifestVersion1;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using System.Xml;

namespace net.derammo.HelBIOS
{
    [HeliosInterface("HelBIOS.DcsBiosVehicleInterface", "DCS-BIOS Vehicle", null, typeof(DcsBiosVehicleInterfaceFactory), Parent = "HelBIOS.DcsBiosInterface")]
    public class DcsBiosVehicleInterface : HeliosNetworkInterface, IFunctionParent
    {
        public static readonly string TYPE_ID = "HelBIOS.DcsBiosVehicleInterface";
        private DcsBiosInterface _parent;
        private static Dictionary<ItemDefinition.ControlType, IFunctionFactory> _factories = new Dictionary<ItemDefinition.ControlType, IFunctionFactory>();

        private HeliosTrigger _connectedTrigger;
        private HeliosTrigger _disconnectedTrigger;

        /// <summary>
        /// our start up cost is very high due to dynamic generation of the interface, so we only do this
        /// once we are actually in use.  this boolean guards doing this start up once
        /// </summary>
        private bool _loaded = false;

        /// <summary>
        /// used to help our function generators pick unique names, by tracking which ones are used
        /// </summary>
        private HashSet<string> _uniqueKeys = new HashSet<string>();

        static DcsBiosVehicleInterface()
        {
            _factories.Add(ItemDefinition.ControlType.selector, new SelectorFactory());
            _factories.Add(ItemDefinition.ControlType.analog_gauge, new AnalogGaugeFactory());

        }

        public DcsBiosVehicleInterface(HeliosInterface parentInterface, string name) : base(parentInterface, name)
        {
            _parent = parentInterface as DcsBiosInterface;

            _connectedTrigger = new HeliosTrigger(this, "", "", "Connected", "Fired on first DCS data received on this interface.");
            Triggers.Add(_connectedTrigger);

            _disconnectedTrigger = new HeliosTrigger(this, "", "", "Disconnected", "Fired on DCS change to a different vehicle or shut down.");
            Triggers.Add(_disconnectedTrigger);
        }

        public HeliosObject SourceInterface => this;

        public HeliosObject CommandInterface => this;

        protected override void OnProfileChanged(HeliosProfile oldProfile)
        {
            // this is how we know we were actually added, and not just created for the list of
            // available interfaces
            if (Profile != null)
            {
                // real initialization
                LoadModule();
            }
            base.OnProfileChanged(oldProfile);
        }

        public override void ReadXml(XmlReader reader)
        {
            // XXX
            // get ready for servicing bindings
            LoadModule();
        }

        public override void SendData(string text)
        {
            // XXX
        }

        public override void WriteXml(XmlWriter writer)
        {
            // XXX
        }

        private void LoadModule()
        {
            // only init once
            if (_loaded) {
                return;
            }
            Task loading = LoadModuleAsync();
            loading.Wait();
            _loaded = true;
        }

        private async Task LoadModuleAsync() {
            using (FileStream fs = File.OpenRead(_parent.GetDefinitionFilePath(Name)))
            {
                System.Text.Json.JsonSerializerOptions options = new System.Text.Json.JsonSerializerOptions
                {
                    ReadCommentHandling = System.Text.Json.JsonCommentHandling.Skip,
                    AllowTrailingCommas = true
                };
                options.Converters.Add(new DcsBiosEnumConverterFactory());
                ModuleDefinition definition = await JsonSerializer.DeserializeAsync<ModuleDefinition>(fs, options).ConfigureAwait(false);
                foreach (KeyValuePair<string, DeviceDefinition> device in definition)
                {
                    foreach (KeyValuePair<string, ItemDefinition> item in device.Value)
                    {
                        if (_factories.TryGetValue(item.Value.control_type, out IFunctionFactory factory))
                        {
                            IFunction function = factory.CreateFunction(new FunctionTemplate()
                            {
                                Parent = this,
                                DeviceName = device.Key,
                                Name = item.Key,
                                Definition = item.Value
                            });

                            if (function != null)
                            {
                                // install in this interface
                                Triggers.AddSlave(function.Triggers);
                                Actions.AddSlave(function.Actions);
                                Values.AddSlave(function.Values);
                            }
                            else
                            {
                                // log and put on TODO list
                            }
                        }
                    }
                }
                return;
            }
        }

        public void SendCommand(string identifier, int argument)
        {
            throw new NotImplementedException();
        }

        public void SendCommand(string identifier, CommandArgument argument)
        {
            throw new NotImplementedException();
        }

        public void SendCommand(string identifier, ItemDefinition.Input.Argument argument)
        {
            throw new NotImplementedException();
        }

        public void SendCommand(string identifier, double argument)
        {
            throw new NotImplementedException();
        }

        public void RegisterInteger(ItemDefinition.Output output, Action<int> code)
        {
            ExportProtocol.IDataReceiver receiver = new IntegerReceiver(output, code);
            _parent.RegisterReceiver(receiver);
        }

        public bool AllocateUniqueNamePair(string deviceName, string itemName)
        {
            string key = $"{deviceName}\n{itemName}";
            return _uniqueKeys.Add(key);
        }
    }
}