using GadrocsWorkshop.Helios;
using GadrocsWorkshop.Helios.ComponentModel;
using GadrocsWorkshop.Helios.Interfaces.Network;
using GadrocsWorkshop.Helios.ProfileAwareInterface;
using GadrocsWorkshop.Helios.Util;
using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using System.Text.Json;

namespace net.derammo.HelBIOS
{
    [HeliosInterface("HelBIOS.DcsBiosInterface", "DCS-BIOS", null, typeof(DcsBiosInterfaceFactory), UniquenessKey = "BaseUDPInterface")]
    public class DcsBiosInterface : HeliosNetworkInterface, IProfileAwareInterface
    {
        private Dictionary<string, string> _installedVehicles;
        private MulticastListener _udpListener;
        private ExportProtocol _protocol = new ExportProtocol();

        /// <summary>
        /// our start up cost is very high due to dynamic generation of the interface, so we only do this
        /// once we are actually in use.  this boolean guards doing this start up once
        /// </summary>
        private bool _loaded = false;

        public DcsBiosInterface(string name) : base(name)
        {
            _installedVehicles = new Dictionary<string, string>() { };

            // meta information we consume ourselves
            RegisterReceiver(new StringReceiver(
                new SchemaVersion1.ItemDefinition.Output()
                {
                    address = 0,
                    max_length = 24,
                    type = SchemaVersion1.ItemDefinition.Output.Type._string
                },
                ReceiveVehicleName));
            RegisterReceiver(new IntegerReceiver(
                new SchemaVersion1.ItemDefinition.Output()
                {
                    address = 0xfffe,
                    type = SchemaVersion1.ItemDefinition.Output.Type.integer
                },
                ReceiveUpdateCounters));
        }

        public IEnumerable<string> Tags => new List<string>() { "XXX dummy" };


        public IEnumerable<string> InstalledVehicles { get => _installedVehicles.Keys; }

        public event EventHandler<ProfileStatus> ProfileStatusReceived;
        public event EventHandler<ProfileHint> ProfileHintReceived;

        internal string GetDefinitionFilePath(string name)
        {
            return _installedVehicles[name];
        }

        public event EventHandler<ClientChange> ClientChanged;

        public override void ReadXml(XmlReader reader)
        {
            // get ready
            LoadPlugins();
        }

        public override void ReconnectBindings()
        {
            base.ReconnectBindings();
        }

        public void RequestProfile(string name)
        {
            // XXX
        }

        public override void SendData(string text)
        {
            throw new NotImplementedException();
        }

        public override void WriteXml(XmlWriter writer)
        {
            // XXX
        }

        protected override void OnProfileChanged(HeliosProfile oldProfile)
        {
            base.OnProfileChanged(oldProfile);
            if (oldProfile != null)
            {
                oldProfile.ProfileStarted -= new EventHandler(Profile_ProfileStarted);
                oldProfile.ProfileStopped -= new EventHandler(Profile_ProfileStopped);
            }

            if (Profile != null)
            {
                // this is how we know we were actually added, and not just created for the list of
                // available interfaces
                LoadPlugins();
                
                // wait for profile start
                Profile.ProfileStarted += new EventHandler(Profile_ProfileStarted);
                Profile.ProfileStopped += new EventHandler(Profile_ProfileStopped);
            }
        }

        private void ReceiveVehicleName(string value)
        {
            ProfileHintReceived?.Invoke(this, new ProfileHint() { Tag = value });
        }

        private void ReceiveUpdateCounters(int values)
        {
            // these update counters are sent as the last thing in each frame, so we can
            // use it to trigger updates instead of waiting for the next sync to start
            // from DCS-BIOS MetadataEnd.lua:
            //
            // --place update counters at address 0xfffe
            // -- DCS - BIOS guarantees that the value for address 0xfffe
            // -- will be the last one that is written in each update.
            // -- Clients can use that as an "update complete" signal.
            // -- At the point when the write access to 0xfffe has been received,
            // -- all string values have been completely updated(so the client
            // -- can assume they are in a consistent state) and some time will
            // -- pass until the next update has to be processed, so it is a good
            // -- trigger to update graphical displays and do other time-consuming
            // -- operations.
            //
            _protocol.NotifyUpdate();
        }

        private void Profile_ProfileStarted(object sender, EventArgs e)
        {
            // NOTE: we don't have a Dispatcher unless the profile is active
            _udpListener = new MulticastListener(Dispatcher, _protocol);
            _udpListener.Start();
        }

        private void Profile_ProfileStopped(object sender, EventArgs e)
        {
            _udpListener.Stop();
            _udpListener = null;
        }

        private void LoadPlugins()
        {
            if (_loaded)
            {
                return;
            }
            _loaded = true;
            string indexFile = System.IO.Path.Combine(KnownFolders.AppDataRoaming, "DCS-BIOS", "Plugins", "dcs-lua-index.json");
            if (!File.Exists(indexFile))
            {
                ConfigManager.LogManager.LogError($"DCS-BIOS is missing its plugin index in '{indexFile}'; no vehicles loaded");
                return;
            }
            string indexJson = File.ReadAllText(indexFile);
            SchemaVersion1.PluginIndexRecord[] index = JsonSerializer.Deserialize<SchemaVersion1.PluginIndexRecord[]>(indexJson);
            foreach(SchemaVersion1.PluginIndexRecord record in index)
            {
                string manifestJson = File.ReadAllText(System.IO.Path.Combine(record.pluginDir, "dcs-bios-plugin-manifest.json"));
                SchemaVersion1.PluginManifest manifest = JsonSerializer.Deserialize<SchemaVersion1.PluginManifest>(manifestJson);
                if (manifest.manifestVersion != 1)
                {
                    ConfigManager.LogManager.LogError($"DCS-BIOS manifest version {manifest.manifestVersion} is unsupported;  vehicle {manifest.moduleDefinitionName} not loaded");
                    continue;
                }
                _installedVehicles.Add($"DCS-BIOS {manifest.moduleDefinitionName}", System.IO.Path.Combine(record.pluginDir, $"{manifest.moduleDefinitionName}.json"));
            }
        }

        internal void RegisterReceiver(ExportProtocol.IDataReceiver receiver)
        {
            _protocol.Add(receiver);
        }
    }
}
