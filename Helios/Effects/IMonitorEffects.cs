using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GadrocsWorkshop.Helios.Effects
{
    /// <summary>
    /// Monitors may support up to three effects that can be combined.  At any one time,
    /// each of these levels can have zero or one effect attached.   They are applied to the output
    /// in the logical order:
    /// 
    /// LIGHTING: to be used for an effect representing the lighting applied to the controls viewed
    /// OPTICS: to be used for an effect like night vision goggles or other optics
    /// PERCEPTION: to be used for an effect representing the pilot's perception, such as blackout or redout
    /// </summary>
    public enum LEVEL
    {
        PERCEPTION,
        OPTICS,
        LIGHTING
    }

    /// <summary>
    /// Main windows that implement this interface support the attachment of one or more effects to 
    /// System.Windows.FrameworkElement instances that enclose all the controls on a particular 
    /// logical monitor.
    /// 
    /// Since the structure of different main windows will differ, the responsibility for choosing
    /// appropriate targets for the Effect instances lies on the implementor of this interface.  
    /// 
    /// This interface should be implemented by the object that is returned by 
    /// System.Windows.Application.Current.MainWindow
    /// </summary>
    public interface IMonitorEffects
    {
        System.Windows.FrameworkElement FindEffectTarget(Monitor monitor, LEVEL level);
    }
}
