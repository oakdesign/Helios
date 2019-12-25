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
        protected string _dcsPath;
        protected bool _phantomFix;
        protected int _phantomLeft;
        protected int _phantomTop;
        protected long _nextCheck = 0;
        protected string _exportDeviceName;

        // protocol to talk to DCS Export script (control messages)
        protected DCSExportProtocol _protocol;

        public DCSInterface(string name, string exportDeviceName)
            : base(name)
        {
            _exportDeviceName = exportDeviceName;

            // XXX temp until we get rid of alternate names
            AlternateName = exportDeviceName;

            DCSConfigurator config = new DCSConfigurator(name, DCSPath);
            Port = config.Port;
            _phantomFix = config.PhantomFix;
            _phantomLeft = config.PhantomFixLeft;
            _phantomTop = config.PhantomFixTop;

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

        private string DCSPath
        {
            get
            {
                if (_dcsPath == null)
                {
                    RegistryKey pathKey = Registry.CurrentUser.OpenSubKey(@"Software\Eagle Dynamics\DCS World");
                    if (pathKey != null)
                    {
                        _dcsPath = (string)pathKey.GetValue("Path");
                        pathKey.Close();
                        ConfigManager.LogManager.LogDebug($"{Name} Interface Editor - Found DCS Path (Path=\"" + _dcsPath + "\")");
                    }
                    else
                    {
                        _dcsPath = "";
                    }
                }
                return _dcsPath;
            }
        }

        // we only support selection based on aircraft type
        public IEnumerable<string> Tags {
            get
            {
                return new string[] { _exportDeviceName };
            }
        }

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
            if (_phantomFix && System.Environment.TickCount - _nextCheck >= 0)
            {
                System.Diagnostics.Process[] dcs = System.Diagnostics.Process.GetProcessesByName("DCS");
                if (dcs.Length == 1)
                {
                    IntPtr hWnd = dcs[0].MainWindowHandle;
                    NativeMethods.Rect dcsRect;
                    NativeMethods.GetWindowRect(hWnd, out dcsRect);

                    if (dcsRect.Width > 640 && (dcsRect.Left != _phantomLeft || dcsRect.Top != _phantomTop))
                    {
                        NativeMethods.MoveWindow(hWnd, _phantomLeft, _phantomTop, dcsRect.Width, dcsRect.Height, true);
                    }
                }
                _nextCheck = System.Environment.TickCount + 5000;
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
            _protocol = new DCSExportProtocol(this);

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
        }
    }
}
