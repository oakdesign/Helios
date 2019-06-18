using System;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Effects;
using System.Reflection;

namespace GadrocsWorkshop.Helios.Effects
{
    public class NightInstrumentsEffect : ShaderEffect
    {
        public const double DEFAULT_BRIGHTNESS = 0.75;
        public const double DEFAULT_THRESHOLD = 0.6;
        public const double DEFAULT_AMBIENT = 0.15;

        private static PixelShader _pixelShader =
            new PixelShader() { UriSource = MakePackUri("Effects/NightInstrumentsEffect.fx.ps") };

        public NightInstrumentsEffect()
        {
            PixelShader = _pixelShader;
            Brightness = DEFAULT_BRIGHTNESS;
            Threshold = DEFAULT_THRESHOLD;
            Ambient = DEFAULT_AMBIENT;

            UpdateShaderValue(InputProperty);
            UpdateShaderValue(BrightnessProperty);
            UpdateShaderValue(ThresholdProperty);
            UpdateShaderValue(AmbientProperty);
        }

        // MakePackUri is a utility method for computing a pack uri
        // for the given resource. 
        public static Uri MakePackUri(string relativeFile)
        {
            Assembly a = typeof(NightInstrumentsEffect).Assembly;

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
            ShaderEffect.RegisterPixelShaderSamplerProperty("Input", typeof(NightInstrumentsEffect), 0);

        #endregion

        ///////////////////////////////////////////////////////////////////////
        #region Brightness dependency property

        public double Brightness
        {
            get {
                return (double)GetValue(BrightnessProperty);
            }
            set {
                // this is sometimes accessed from a worker thread during XML processing
                if (Dispatcher.CheckAccess())
                {
                    SetValue(BrightnessProperty, value);
                }
                else
                {
                    Dispatcher.Invoke(() =>
                    {
                        SetValue(BrightnessProperty, value);
                    });
                }
            }
        }

        public static readonly DependencyProperty BrightnessProperty =
            DependencyProperty.Register("Brightness", typeof(double), typeof(NightInstrumentsEffect),
                    new UIPropertyMetadata(DEFAULT_BRIGHTNESS, PixelShaderConstantCallback(0)));

        #endregion

        #region Threshold dependency property

        public double Threshold
        {
            get
            {
                return (double)GetValue(ThresholdProperty);
            }
            set
            {
                // this is sometimes accessed from a worker thread during XML processing
                if (Dispatcher.CheckAccess())
                {
                    SetValue(ThresholdProperty, value);
                }
                else
                {
                    Dispatcher.Invoke(() =>
                    {
                        SetValue(ThresholdProperty, value);
                    });
                }
            }
        }

        public static readonly DependencyProperty ThresholdProperty =
            DependencyProperty.Register("Threshold", typeof(double), typeof(NightInstrumentsEffect),
                    new UIPropertyMetadata(DEFAULT_THRESHOLD, PixelShaderConstantCallback(1)));

        #endregion

        #region Ambient dependency property

        public double Ambient
        {
            get
            {
                return (double)GetValue(AmbientProperty);
            }
            set
            {
                // this is sometimes accessed from a worker thread during XML processing
                if (Dispatcher.CheckAccess())
                {
                    SetValue(AmbientProperty, value);
                }
                else
                {
                    Dispatcher.Invoke(() =>
                    {
                        SetValue(AmbientProperty, value);
                    });
                }
            }
        }

        public static readonly DependencyProperty AmbientProperty =
            DependencyProperty.Register("Ambient", typeof(double), typeof(NightInstrumentsEffect),
                    new UIPropertyMetadata(DEFAULT_AMBIENT, PixelShaderConstantCallback(2)));

        #endregion
    }
}