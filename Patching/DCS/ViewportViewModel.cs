﻿using System.Windows;
using GadrocsWorkshop.Helios.Windows;

namespace GadrocsWorkshop.Helios.Patching.DCS
{
    public class ViewportViewModel : HeliosViewModel<ShadowVisual>
    {
        #region Private

        private Vector _globalOffset;
        private Rect _monitor = new Rect(0, 0, 1, 1);
        private double _scale;
        private Rect _viewport = new Rect(0, 0, 1, 1);

        #endregion

        internal ViewportViewModel(ShadowVisual data, Vector globalOffset, double scale) : base(data)
        {
            _globalOffset = globalOffset;
            _scale = scale;
            Update(data.Monitor);
            Update(data.Visual);

            Data.ViewportChanged += Data_ViewportChanged;
            Data.MonitorChanged += Data_MonitorChanged;
        }

        private void Data_MonitorChanged(object sender, RawMonitorEventArgs e)
        {
            // some geometry of our containing monitor may have happened
            Update(e.Raw);
        }

        // not automatically called because we are strongly referenced by event
        internal void Dispose()
        {
            Data.ViewportChanged -= Data_ViewportChanged;
            Data.MonitorChanged -= Data_MonitorChanged;
        }

        private void Data_ViewportChanged(object sender, RawViewportEventArgs e)
        {
            // some geometry change may have happened to our viewport specifically
            Update(e.Raw);
        }

        internal void Update(Monitor monitor)
        {
            _monitor.X = monitor.Left;
            _monitor.Y = monitor.Top;
            _monitor.Width = monitor.Width;
            _monitor.Height = monitor.Height;
            Update();
        }

        internal void Update(Vector globalOffset)
        {
            _globalOffset = globalOffset;
            Update();
        }

        internal void Update(HeliosVisual viewport)
        {
            _viewport.X = viewport.Left;
            _viewport.Y = viewport.Top;
            _viewport.Width = viewport.Width;
            _viewport.Height = viewport.Height;
            Update();
        }

        internal void Update(double scale)
        {
            _scale = scale;
            Update();
        }

        private void Update()
        {
            Rect absolute = _viewport;
            absolute.Offset(_monitor.X, _monitor.Y);
            absolute.Offset(_globalOffset);
            absolute.Scale(_scale, _scale);
            Rect = absolute;
            ConfigManager.LogManager.LogDebug($"scaled viewport view {GetHashCode()} for monitor setup UI is {Rect}");
        }

        public static readonly DependencyProperty RectProperty =
            DependencyProperty.Register("Rect", typeof(Rect), typeof(ViewportViewModel), new PropertyMetadata(null));

        public Rect Rect
        {
            get => (Rect) GetValue(RectProperty);
            set => SetValue(RectProperty, value);
        }
    }
}