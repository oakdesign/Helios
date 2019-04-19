using System;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Reflection;

namespace GadrocsWorkshop.Helios.Effects
{
    public class BlackoutEffect: ShaderEffect
    {
        private static PixelShader _pixelShader =
            new PixelShader() { UriSource = MakePackUri("Effects/BlackoutEffect.fx.ps") };

        public BlackoutEffect()
        {
            PixelShader = _pixelShader;

            UpdateShaderValue(InputProperty);
            UpdateShaderValue(IntensityProperty);
        }

        // MakePackUri is a utility method for computing a pack uri
        // for the given resource. 
        public static Uri MakePackUri(string relativeFile)
        {
            Assembly a = typeof(BlackoutEffect).Assembly;

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
            ShaderEffect.RegisterPixelShaderSamplerProperty("Input", typeof(BlackoutEffect), 0);

        #endregion

        ///////////////////////////////////////////////////////////////////////
        #region Intensity dependency property

        public double Intensity
        {
            get { return (double)GetValue(IntensityProperty); }
            set { SetValue(IntensityProperty, value); }
        }

        public static readonly DependencyProperty IntensityProperty =
            DependencyProperty.Register("Intensity", typeof(double), typeof(BlackoutEffect),
                    new UIPropertyMetadata(0.5, PixelShaderConstantCallback(0)));

        #endregion


    }
}