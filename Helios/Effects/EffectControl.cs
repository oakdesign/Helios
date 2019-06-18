
using System.Windows;
using System.Windows.Media.Effects;

namespace GadrocsWorkshop.Helios.Effects
{
    public abstract class EffectControl : GadrocsWorkshop.Helios.Controls.RectangleDeocration
    {
        private bool _effectActive = false;
        private HeliosValue _effectActiveValue;
        private LEVEL _effectLevel;

        public EffectControl(string name, LEVEL level)
        {
            Name = name;
            BorderThickness = 1;
            CornerRadius = 5;

            _effectLevel = level;
            _effectActive = false;

            HeliosAction toggleEffectActiveAction = new HeliosAction(this, "", "active", "toggle", "Toggles whether this effect is active on its containing monitor.");
            toggleEffectActiveAction.Execute += new HeliosActionHandler(ToggleEffectActiveAction_Execute);
            Actions.Add(toggleEffectActiveAction);

            _effectActiveValue = new HeliosValue(this, new BindingValue(false), "", "active", "Indicates if  this effect is active on its containing monitor.", "True if effect is being shown.", BindingValueUnits.Boolean);
            _effectActiveValue.Execute += new HeliosActionHandler(SetEffectActiveAction_Execute);
            Values.Add(_effectActiveValue);
            Actions.Add(_effectActiveValue);
        }

        #region Properties
        public bool IsEffectActive
        {
            get
            {
                return _effectActive;
            }
            set
            {
                if (!_effectActive.Equals(value))
                {
                    _effectActive = value;
                    _effectActiveValue.SetValue(new BindingValue(_effectActive), false);

                    // NOTE: we can navigate up to the logical monitor object, but not the WPF FrameworkElement that represents the monitor (either MonitorWindow or MonitorDocument)
                    // so we bounce this request off Application.Current.MainWindow, which can optionally let us do so, depending on the context in which we run
                    if (value)
                    {
                        installEffect(Application.Current.MainWindow as IMonitorEffects);
                    }
                    else
                    {
                        // ignoring result, which will be false if we are not the current effect
                        uninstallEffect(Application.Current.MainWindow as IMonitorEffects);
                    }
                    OnPropertyChanged("IsEffectActive", !value, value, false);
                }
            }
        }

        protected abstract Effect Effect
        {
            get;
        }

        #endregion

        #region Actions
        void SetEffectActiveAction_Execute(object action, HeliosActionEventArgs e)
        {
            IsEffectActive = e.Value.BoolValue;
        }

        void ToggleEffectActiveAction_Execute(object action, HeliosActionEventArgs e)
        {
            IsEffectActive = !IsEffectActive;
        }
        #endregion


        void installEffect(IMonitorEffects monitorEffects)
        {
            if (monitorEffects == null)
            {
                // ignore functionality not supported in this context
                return;
            }
            FrameworkElement target = monitorEffects.FindEffectTarget(Monitor, _effectLevel);
            if (target == null)
            {
                return;
            }
            target.Effect = Effect;
        }

        bool uninstallEffect(IMonitorEffects monitorEffects)
        {
            if (monitorEffects == null)
            {
                // ignore functionality not supported in this context
                return false;
            }
            FrameworkElement target = monitorEffects.FindEffectTarget(Monitor, _effectLevel);
            if (target == null)
            {
                return false;
            }
            if (target.Effect != Effect)
            {
                // not ours
                return false;
            }
            // uninstall but do not deallocate effect
            target.Effect = null;
            return true;
        }

        public void StartDesignModeDemo()
        {
            // temporarily activate effect
            IsEffectActive = true;
            ConfigManager.LogManager.LogDebug("Effect temporarily installed");
        }

        public void StopDesignModeDemo()
        {
            // if temporarily activated, undo it
            IsEffectActive = false;
            ConfigManager.LogManager.LogDebug("Effect uninstalled");
        }
    }
}
