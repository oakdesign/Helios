namespace GadrocsWorkshop.Helios.Effects
{
    using GadrocsWorkshop.Helios.ComponentModel;
    using GadrocsWorkshop.Helios.Windows.Controls;
    using System.Windows;

    /// <summary>
    /// Interaction logic for GreenNightVisionAppearanceEditor.xaml
    /// </summary>
    [HeliosPropertyEditor("Helios.Effects.GreenNightVision", "Appearance")]
    public partial class GreenNightVisionAppearanceEditor : HeliosPropertyEditor
    {
        public GreenNightVisionAppearanceEditor()
        {
            InitializeComponent();
        }

        private void Slider_GotFocus(object sender, RoutedEventArgs e)
        {
            GreenNightVision control = Control as GreenNightVision;
            if (control != null)
            {
                control.IsEffectActive = true;
            }
        }

        private void Slider_LostFocus(object sender, RoutedEventArgs e)
        {
            GreenNightVision control = Control as GreenNightVision;
            if (control != null)
            {
                control.IsEffectActive = false;
            }
        }
    }
}
