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
    using GadrocsWorkshop.Helios.ProfileAwareInterface;
    using GadrocsWorkshop.Helios.UDPInterface;
    using Microsoft.Win32;
    using System;
    using System.Collections.Generic;

    public class DCSInterface : BaseUDPInterface, IProfileAwareInterface
    {
        protected string _exportDeviceName;
        protected string _exportFunctionsPath;
        protected DCSPhantomMonitorFix _phantomFix;

        // protocol to talk to DCS Export script (control messages)
        protected DCSExportProtocol _protocol;

        // phantom monitor fix 

        public DCSInterface(string name, string exportDeviceName, string exportFunctionsPath)
            : base(name)
        {
            _exportDeviceName = exportDeviceName;
            _exportFunctionsPath = exportFunctionsPath;

            // XXX temp until we get rid of alternate names
            AlternateName = exportDeviceName;

            NetworkTriggerValue activeVehicle = new NetworkTriggerValue(this, "ACTIVE_VEHICLE", "ActiveVehicle", "Vehicle currently inhabited in DCS.", "Short name of vehicle");
            AddFunction(activeVehicle);
            activeVehicle.ValueReceived += ActiveVehicle_ValueReceived;
            NetworkTriggerValue activeProfile = new NetworkTriggerValue(this, "ACTIVE_PROFILE", "ActiveExportProfile", "Export profile running on DCS.", "Short name of profile");
            AddFunction(activeProfile);
            activeProfile.ValueReceived += ActiveProfile_ValueReceived;
            AddFunction(new NetworkTrigger(this, "ALIVE", "Heartbeat", "Received periodically if there is no other data received"));
        }

        #region Events
        // this event indicates that the interface received an indication that a profile that 
        // matches the specified hint should be loaded
        [field: NonSerialized]
        public event EventHandler<ProfileHint> ProfileHintReceived;

        // this event indicates that the interface received an indication that the specified
        // profile name is loaded on the other side of the interface
        [field: NonSerialized]
        public event EventHandler<ProfileStatus> ProfileStatusReceived;
        #endregion

        // we only support selection based on aircraft type
        public IEnumerable<string> Tags {
            get
            {
                return new string[] { _exportDeviceName };
            }
        }

        /// <summary>
        /// vehicle-specific file resource to include
        /// </summary>
        public string ExportFunctionsPath { get => _exportFunctionsPath; }

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
    }
}
