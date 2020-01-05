﻿using GadrocsWorkshop.Helios;
using GadrocsWorkshop.Helios.ComponentModel;
using GadrocsWorkshop.Helios.Interfaces.Network;
using GadrocsWorkshop.Helios.ProfileAwareInterface;
using GadrocsWorkshop.Helios.Util;
using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using System.Text.Json;
using System.Threading.Tasks;

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
                new ManifestVersion1.ItemDefinition.Output()
                {
                    address = 0,
                    max_length = 24,
                    type = ManifestVersion1.ItemDefinition.Output.Type._string
                },
                ReceiveVehicleName));
        }

        public IEnumerable<string> Tags => new List<string>() { "XXX dummy" };


        public IEnumerable<string> InstalledVehicles { get => _installedVehicles.Keys; }

#pragma warning disable CS0067 // The event 'DcsBiosInterface.ProfileStatusReceived' is never used
        public event EventHandler<ProfileStatus> ProfileStatusReceived;
#pragma warning restore CS0067 // The event 'DcsBiosInterface.ProfileStatusReceived' is never used
        public event EventHandler<ProfileHint> ProfileHintReceived;

        internal string GetDefinitionFilePath(string name)
        {
            return _installedVehicles[name];
        }

#pragma warning disable CS0067 // The event 'DcsBiosInterface.ClientChanged' is never used
        public event EventHandler<ClientChange> ClientChanged;
#pragma warning restore CS0067 // The event 'DcsBiosInterface.ClientChanged' is never used

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

        private class PluginIndexRecord
        {
            public string pluginDir { get; set; }
            public string luaFile { get; set; }
        }

        private class PluginManifest
        {
            public int manifestVersion { get; set; }
            public string moduleDefinitionName { get; set; }
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
            PluginIndexRecord[] index = JsonSerializer.Deserialize<PluginIndexRecord[]>(indexJson);
            foreach(PluginIndexRecord record in index)
            {
                string manifestJson = File.ReadAllText(System.IO.Path.Combine(record.pluginDir, "dcs-bios-plugin-manifest.json"));
                PluginManifest manifest = JsonSerializer.Deserialize<PluginManifest>(manifestJson);
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