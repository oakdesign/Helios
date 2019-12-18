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
    using System.Timers;

    public class DCSInterface : BaseUDPInterface, IProfileAwareInterface
    {
        protected string _dcsPath;
        protected bool _phantomFix;
        protected int _phantomLeft;
        protected int _phantomTop;
        protected long _nextCheck = 0;
        protected string _exportDeviceName;
        protected Timer _retryRequestExportProfile = new Timer();
        protected string _requestedExportProfile;

        public DCSInterface(string name, string exportDeviceName)
            : base(name)
        {
            _exportDeviceName = exportDeviceName;

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

            // REVISIT: configurable?
            _retryRequestExportProfile.Interval = 3000;
            _retryRequestExportProfile.Elapsed += OnRetryRequestExportProfile;
        }

        #region Events
        // this event indicates that the interface received an indication that a profile that 
        // matches the specified hint should be loaded
        [field: NonSerialized]
        public event EventHandler<ProfileHint> ProfileHintReceived;

        // this event indicates that the interface received an indication that the specified
        // profile name is loaded on the other side of the interface
        [field: NonSerialized]
        public event EventHandler<ProfileConfirmation> ProfileConfirmationReceived;
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
            if (e.Text == _requestedExportProfile)
            {
                // this acknowledges our attempt to load this profile, if the name matches what we are trying to load
                // cancel retries of "P" command
                _requestedExportProfile = null;

                // stop, if running
                _retryRequestExportProfile.Stop();
            }
            ProfileConfirmationReceived?.Invoke(this, new ProfileConfirmation() { Name = e.Text });
        }

        private void ActiveVehicle_ValueReceived(object sender, NetworkTriggerValue.Value e)
        {
            ProfileHintReceived?.Invoke(this, new ProfileHint() { Tag = e.Text });
        }

        public void RequestProfile(string name)
        {
            _requestedExportProfile = name;
            if (CanSend)
            {
                ConfigManager.LogManager.LogDebug($"sending request for exports '{_requestedExportProfile}'");
                SendData($"P{name}");
            }
            _retryRequestExportProfile.Stop();
            _retryRequestExportProfile.Start();
        }

        private void OnRetryRequestExportProfile(object sender, ElapsedEventArgs e)
        {
            if ((_requestedExportProfile != null) && CanSend)
            {
                ConfigManager.LogManager.LogDebug($"retrying request for exports '{_requestedExportProfile}'");
                SendData($"P{_requestedExportProfile}");
            }
        }

        public override void Reset()
        {
            base.Reset();
            _requestedExportProfile = null;
            _retryRequestExportProfile.Stop();
        }

        protected override void OnProfileStarted()
        {
            if ((_requestedExportProfile != null) && CanSend)
            {
                ConfigManager.LogManager.LogDebug($"sending request for exports '{_requestedExportProfile}' after DCS interface initialized");
                SendData($"P{_requestedExportProfile}");
            }
        }
    }
}
