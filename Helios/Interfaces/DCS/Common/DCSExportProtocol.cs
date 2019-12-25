using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using GadrocsWorkshop.Helios.ProfileAwareInterface;
using GadrocsWorkshop.Helios.UDPInterface;

namespace GadrocsWorkshop.Helios.Interfaces.DCS.Common
{
    public class DCSExportProtocol
    {
        private HeliosProfile _profile;
        private RetriedRequest _requestExportProfile;
        private string _requestedExportProfile;

        public class RetriedRequest
        {
            private HeliosProfile _profile;
            private BaseUDPInterface _udp;

            private string _request;
            private Timer _timer = new Timer();
            private int _retries = 0;
            private string _description = "";

            private int _retryLimit;

            public RetriedRequest(UDPInterface.BaseUDPInterface udp, HeliosProfile profile)
            {
                _profile = profile;
                _udp = udp;

                // REVISIT: configurable?
                _retryLimit = 3;
                _timer.Interval = 1000;

                _timer.Elapsed += Timer_Elapsed;
            }

            public void Send(string request, string description)
            {
                _timer.Stop();
                _request = request;
                _retries = 0;
                _description = description;
                if (_udp.CanSend)
                {
                    ConfigManager.LogManager.LogDebug($"sending {_description}");
                    _udp.SendData(_request);
                }
                _timer.Start();
            }

            public void Restart()
            {
                _retries = 0;
                _timer.Start();
            }

            public void Stop()
            {
                _request = null;
                _timer.Stop();
            }

            // callback on timer worker thread
            private void Timer_Elapsed(object sender, ElapsedEventArgs e)
            {
                // if profile is unloaded, do nothing
                _profile?.Dispatcher.Invoke((Action)OnRetry, System.Windows.Threading.DispatcherPriority.Normal);
            }

            private void OnRetry()
            {
                if (_retries >= _retryLimit)
                {
                    // no answer after max retries; the export script is either not there or does not support the command
                    // we are using (normal case if some other Export script is used)
                    ConfigManager.LogManager.LogWarning($"giving up on {_description} after {_retries} attempts");
                    _timer.Stop();
                    return;
                }
                if ((_request != null) && _udp.CanSend)
                {
                    ConfigManager.LogManager.LogDebug($"retrying{_description}");
                    _udp.SendData(_request);
                    _retries++;
                }
            }
        }

        public DCSExportProtocol(UDPInterface.BaseUDPInterface udp, HeliosProfile profile)
        {
            _profile = profile;
            _requestExportProfile = new RetriedRequest(udp, profile);
        }

        public void SendProfileRequest(string profileShortName)
        {
            _requestedExportProfile = profileShortName;
            _requestExportProfile.Send($"P{profileShortName}", $"request to install export profile {profileShortName}");
        }
        
        public void OnProfileRequestAck(string profileShortName)
        {
            if (_requestedExportProfile == profileShortName)
            {
                // this acknowledges our attempt to load this profile, if the name matches what we are trying to load
                // cancel retries of "P" command
                _requestExportProfile.Stop();
            }
        }

        /// <summary>
        /// stop any current requests, but keep this object usable
        /// </summary>
        public void Stop()
        {
            _requestExportProfile.Stop();
        }

        public void Reset()
        {
            _requestExportProfile.Restart();
        }

        // callback on socket worker thread
        public void BaseUDPInterface_ClientChanged(object sender, ProfileAwareInterface.ClientChange e)
        {
            _profile?.Dispatcher.Invoke((Action)OnClientChanged, System.Windows.Threading.DispatcherPriority.Normal);
        }

        private void OnClientChanged()
        {
            _requestExportProfile.Restart();
        }
    }
}
