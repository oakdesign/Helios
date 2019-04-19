using System;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Reflection;

namespace GadrocsWorkshop.Helios.Effects
{
    public class GreenNightVisionEffect : ShaderEffect
    {
        private static PixelShader _pixelShader =
            new PixelShader() { UriSource = MakePackUri("Effects/GreenNightVisionEffect.fx.ps") };

        public GreenNightVisionEffect()
        {
            PixelShader = _pixelShader;

            UpdateShaderValue(InputProperty);
            UpdateShaderValue(BrightnessProperty);
        }

        // MakePackUri is a utility method for computing a pack uri
        // for the given resource. 
        public static Uri MakePackUri(string relativeFile)
        {
            Assembly a = typeof(GreenNightVisionEffect).Assembly;

            // Extract the short name.
            string assemblyShortName = a.ToString().Split(',')[0];

            string uriString = "pack://application:,,,/" +
                assemblyShortName +
                ";component/" +
                relativeFile;

            return new Uri(uriString);
        }

        ///////////////////////////////////////////////////////////////////////
        #region Input dependency property

        public Brush Input
        {
            get { return (Brush)GetValue(InputProperty); }
            set { SetValue(InputProperty, value); }
        }

        public static readonly DependencyProperty InputProperty =
            ShaderEffect.RegisterPixelShaderSamplerProperty("Input", typeof(GreenNightVisionEffect), 0);

        #endregion

        ///////////////////////////////////////////////////////////////////////
        #region Brightness dependency property

        public double Brightness
        {
            get { return (double)GetValue(BrightnessProperty); }
            set { SetValue(BrightnessProperty, value); }
        }

        public static readonly DependencyProperty BrightnessProperty =
            DependencyProperty.Register("Brightness", typeof(double), typeof(GreenNightVisionEffect),
                    new UIPropertyMetadata(0.5, PixelShaderConstantCallback(0)));

        #endregion


    }
}