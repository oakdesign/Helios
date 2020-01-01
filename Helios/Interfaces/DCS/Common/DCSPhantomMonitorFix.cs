﻿//  Copyright 2014 Craig Courtney
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
    using System.Globalization;

    /// <summary>
    /// common between Runtime class and the configuration class
    /// 
    /// NOTE: this factoring is excessive for normal cases, and it is done to 
    /// untangle the code base, which was instantiating the previous version of
    /// this object in various contexts
    /// </summary>
    public class DCSPhantomMonitorFixBase : NotificationObject
    {
        protected string _prefPrefix;
        protected bool _enabled;
        protected int _leftPosition;
        protected int _topPosition;

        protected DCSPhantomMonitorFixBase(string prefPrefix)
        {
            _prefPrefix = prefPrefix;
            _enabled = ConfigManager.SettingsManager.LoadSetting(_prefPrefix, "PhantomMonitorFix", false);
            _leftPosition = int.Parse(ConfigManager.SettingsManager.LoadSetting(_prefPrefix, "PhantomMonitorLeft", "0"), CultureInfo.InvariantCulture);
            _topPosition = int.Parse(ConfigManager.SettingsManager.LoadSetting(_prefPrefix, "PhantomMonitorTop", "0"), CultureInfo.InvariantCulture);
        }
    }

    /// <summary>
    /// this class is instantiated in the interface editor at configuration time, but it
    /// cannot run
    /// </summary>
    public class DCSPhantomMonitorFixConfig : DCSPhantomMonitorFixBase
    {
        public DCSPhantomMonitorFixConfig(string prefPrefix) : base(prefPrefix)
        {
            // no new code
        }

        public bool Enabled
        {
            get
            {
                return _enabled;
            }
            set
            {
                if (!_enabled.Equals(value))
                {
                    bool oldValue = _enabled;
                    _enabled = value;
                    OnPropertyChanged("Enabled", oldValue, value, false);
                    ConfigManager.SettingsManager.SaveSetting(_prefPrefix, "PhantomMonitorFix", _enabled);
                }
            }
        }

        public int LeftPosition
        {
            get
            {
                return _leftPosition;
            }
            set
            {
                if (!_leftPosition.Equals(value))
                {
                    int oldValue = _leftPosition;
                    _leftPosition = value;
                    OnPropertyChanged("LeftPosition", oldValue, value, false);
                    ConfigManager.SettingsManager.SaveSetting(_prefPrefix, "PhantomMonitorLeft", _leftPosition.ToString(CultureInfo.InvariantCulture));
                }
            }
        }

        public int TopPosition
        {
            get
            {
                return _topPosition;
            }
            set
            {
                if (!_topPosition.Equals(value))
                {
                    int oldValue = _topPosition;
                    _topPosition = value;
                    OnPropertyChanged("TopPosition", oldValue, value, false);
                    ConfigManager.SettingsManager.SaveSetting(_prefPrefix, "PhantomMonitorTop", _topPosition.ToString(CultureInfo.InvariantCulture));
                }
            }
        }
    }

    /// <summary>
    /// if enabled, will periodically move the main DCS window to work around a known problem
    /// </summary>
    public class DCSPhantomMonitorFix : DCSPhantomMonitorFixConfig
    {
        private long _nextCheck = 0;

        public DCSPhantomMonitorFix(string prefPrefix) : base(prefPrefix)
        {
            // no new code
        }

        public void Profile_Tick(object sender, System.EventArgs e)
        {
            if (_enabled && (System.Environment.TickCount - _nextCheck >= 0))
            {
                System.Diagnostics.Process[] dcs = System.Diagnostics.Process.GetProcessesByName("DCS");
                if (dcs.Length == 1)
                {
                    System.IntPtr hWnd = dcs[0].MainWindowHandle;
                    NativeMethods.GetWindowRect(hWnd, out NativeMethods.Rect dcsRect);
                    if (dcsRect.Width > 640 && (dcsRect.Left != _leftPosition|| dcsRect.Top != _topPosition))
                    {
                        NativeMethods.MoveWindow(hWnd, _leftPosition, _topPosition, dcsRect.Width, dcsRect.Height, true);
                    }
                }
                _nextCheck = System.Environment.TickCount + 5000;
            }
        }
    }
}
