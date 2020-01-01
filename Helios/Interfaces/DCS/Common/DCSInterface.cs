//  Copyright 2014 Craig Courtney
//    
//  Helios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Helios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

namespace GadrocsWorkshop.Helios.Interfaces.DCS.Common
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using GadrocsWorkshop.Helios.ProfileAwareInterface;
    using GadrocsWorkshop.Helios.UDPInterface;
    using System;
    using System.Collections.Generic;
    using System.Globalization;
    using System.Xml;


    [HeliosInterface("Helios.DCSExport2", "DCS Exports", typeof(DCSInterfaceEditor), typeof(UniqueHeliosInterfaceFactory), UniquenessKey = "BaseUDPInterface")]
    public class DCSInterface : BaseUDPInterface, IProfileAwareInterface
    {
        private string _vehicleName;
        private string _impersonatedVehicleName;
        private string _exportFunctionsPath;

        // phantom monitor fix 
        private DCSPhantomMonitorFix _phantomFix;

        // protocol to talk to DCS Export script (control messages)
        private DCSExportProtocol _protocol;

        // demultiplexers for all the network codes we support
        private Dictionary<string, DemuxFunction> _demuxes = new Dictionary<string, DemuxFunction>();

        private class DemuxFunction : NetworkFunction
        {
            private string _id;
            private Dictionary<object, NetworkFunction> _subscriptions = new Dictionary<object, NetworkFunction>(); 
                
            public DemuxFunction(BaseUDPInterface sourceInterface, string id):
                base(sourceInterface)
            {
                this._id = id;
            }

            public override ExportDataElement[] GetDataElements()
            {
                return new ExportDataElement[] { new ExportDataElement(_id) };
            }

            public override void ProcessNetworkData(string id, string value)
            {
                foreach (NetworkFunction target in _subscriptions.Values)
                {
                    target.ProcessNetworkData(id, value);
                }
            }

            public override void Reset()
            {
                foreach (NetworkFunction target in _subscriptions.Values)
                {
                    target.Reset();
                }
            }
            
            public void Subscribe(object key, NetworkFunction target)
            {
                _subscriptions.Add(key, target);
            }

            public void Unsubscribe(object key)
            {
                _subscriptions.Remove(key);
            }

            // REVISIT: use this to cull any demuxes that no longer serve anyone
            public bool IsEmpty()
            {
                return _subscriptions.Count == 0;
            }
        }

        public DCSInterface(string name):
            base(name)
        {
            _vehicleName = "";
            _exportFunctionsPath = "";

            NetworkTriggerValue activeVehicle = new NetworkTriggerValue(this, "ACTIVE_VEHICLE", "ActiveVehicle", "Vehicle currently inhabited in DCS.", "Short name of vehicle");
            AddFunction(activeVehicle);
            activeVehicle.ValueReceived += ActiveVehicle_ValueReceived;
            NetworkTriggerValue activeProfile = new NetworkTriggerValue(this, "ACTIVE_PROFILE", "ActiveExportProfile", "Export profile running on DCS.", "Short name of profile");
            AddFunction(activeProfile);
            activeProfile.ValueReceived += ActiveProfile_ValueReceived;
            AddFunction(new NetworkTrigger(this, "ALIVE", "Heartbeat", "Received periodically if there is no other data received"));

            // DCS Interfaces persist their port number per interface type
            Port = int.Parse(ConfigManager.SettingsManager.LoadSetting(Name, "Port", "9089"), CultureInfo.InvariantCulture);
        }

        #region Events
        // this event indicates that the interface received an indication that a profile that 
        // matches the specified hint should be loaded
        public event EventHandler<ProfileHint> ProfileHintReceived;

        // this event indicates that the interface received an indication that the specified
        // profile name is loaded on the other side of the interface
        public event EventHandler<ProfileStatus> ProfileStatusReceived;
        #endregion

        protected override void OnPropertyChanged(PropertyNotificationEventArgs args)
        {
            if (args.PropertyName == nameof(Port))
            {
                ConfigManager.SettingsManager.SaveSetting(Name, "Port", Port.ToString(CultureInfo.InvariantCulture));
            }
            base.OnPropertyChanged(args);
        }

        // we only support selection based on aircraft type
        public IEnumerable<string> Tags {
            get
            {
                return new string[] { _impersonatedVehicleName ?? _vehicleName };
            }
        }

        public string VehicleName
        {
            get => _vehicleName;
        }

        /// <summary>
        /// vehicle-specific file resource to include
        /// </summary>
        public string ExportFunctionsPath { get => _exportFunctionsPath; }
        
        /// <summary>
        /// If not null, the this interface instance is configured to impersonate the specified vehicle name.  This means
        /// that Helios should select it for the given vehicle, instead of the one that the interface natively supports.
        /// </summary>
        public string ImpersonatedVehicleName { get => _impersonatedVehicleName; set => _impersonatedVehicleName = value; }

        protected override void OnProfileChanged(HeliosProfile oldProfile)
        {
            base.OnProfileChanged(oldProfile);

            if (oldProfile != null)
            {
                oldProfile.ProfileTick -= Profile_Tick;
            }

            if (Profile != null)
            {
                Profile.ProfileTick += Profile_Tick;
            }
        }

        void Profile_Tick(object sender, EventArgs e)
        {
            if (_phantomFix != null)
            {
                _phantomFix.Profile_Tick(sender, e);
            }
        }

        private void ActiveProfile_ValueReceived(object sender, NetworkTriggerValue.Value e)
        {
            _protocol?.OnProfileRequestAck(e.Text);
            ProfileStatusReceived?.Invoke(this, new ProfileStatus() { RunningProfile = e.Text });
        }

        private void ActiveVehicle_ValueReceived(object sender, NetworkTriggerValue.Value e)
        {
            ProfileHintReceived?.Invoke(this, new ProfileHint() { Tag = e.Text });
        }

        public void RequestProfile(string name)
        {
            // the interface is supposed to have called OnProfileStarted before this is called,
            // so don't check for null; we want this to crash if this breaks in the future
            _protocol.SendProfileRequest(name);
        }

        public override void Reset()
        {
            base.Reset();
            _protocol?.Reset();
        }

        protected override void OnProfileStarted()
        {
            // these parts are only used at run time (i.e. not in the Profile Editor)
            _protocol = new DCSExportProtocol(this);
            _phantomFix = new DCSPhantomMonitorFix(Name);

            // hook transport via event (transport is our base class) to know when we
            // have to reset our conversation with the client, because the client has 
            // potentially restarted
            ClientChanged += _protocol.BaseUDPInterface_ClientChanged;
        }

        protected override void OnProfileStopped()
        {
            ClientChanged -= _protocol.BaseUDPInterface_ClientChanged;
            _protocol.Stop();
            _protocol = null;
            _phantomFix = null;
        }

        public override void ReadXml(XmlReader reader)
        {
            base.ReadXml(reader);
            if (reader.Name.Equals("ImpersonatedVehicleName"))
            {
                ImpersonatedVehicleName = reader.ReadElementString("ImpersonatedVehicleName");
            }
        }

        public override void WriteXml(XmlWriter writer)
        {
            base.WriteXml(writer);
            if (ImpersonatedVehicleName != null)
            {
                writer.WriteElementString("ImpersonatedVehicleName", ImpersonatedVehicleName);
            }
        }

        internal void Subscribe(object key, NetworkFunction function)
        {
            foreach (ExportDataElement element in function.GetDataElements())
            {
                // lazy create a de-multiplexer
                DemuxFunction demux;
                if (!_demuxes.TryGetValue(element.ID, out demux))
                {
                    demux = new DemuxFunction(this, element.ID);
                    _demuxes.Add(element.ID, demux);
                    AddFunction(demux);
                }
                demux.Subscribe(key, function);
            }
        }

        internal void Unsubscribe(object key)
        {
            foreach(DemuxFunction demux in _demuxes.Values)
            {
                demux.Unsubscribe(key);
            }
        }
    }
}
