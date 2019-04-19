using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GadrocsWorkshop.Helios.Effects
{
    public enum LEVEL
    {
        COLOR,
        LIGHT
    }

    public interface IMonitorEffects
    {
        System.Windows.FrameworkElement findEffectTarget(Monitor monitor, LEVEL level);
    }
}
