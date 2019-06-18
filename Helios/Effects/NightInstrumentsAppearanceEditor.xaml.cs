namespace GadrocsWorkshop.Helios.Effects
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using GadrocsWorkshop.Helios.Windows.Controls;
    using System.Windows;

    /// <summary>
    /// Interaction logic for NightInstrumentsAppearanceEditor.xaml
    /// </summary>
    [HeliosPropertyEditor("Helios.Effects.NightInstruments", "Appearance")]
    public partial class NightInstrumentsAppearanceEditor : HeliosPropertyEditor
    {
        public NightInstrumentsAppearanceEditor()
        {
            InitializeComponent();
        }

        private void Slider_GotFocus(object sender, RoutedEventArgs e)
        {
            EffectControl control = Control as EffectControl;
            if (control != null)
            {
                control.StartDesignModeDemo();
            }
        }

        private void Slider_LostFocus(object sender, RoutedEventArgs e)
        {
            EffectControl control = Control as EffectControl;
            if (control != null)
            {
                control.StopDesignModeDemo();
            }
        }
    }
}
