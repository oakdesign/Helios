using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GadrocsWorkshop.Helios
{
    namespace ProfileAwareInterface
    {
        public class ProfileHint : EventArgs
        {
            public string Tag { get; set; }
        }

        public class ProfileConfirmation : EventArgs
        {
            public string Name { get; set; }
        }

        public interface IProfileAwareInterface
        {
            event EventHandler<ProfileAwareInterface.ProfileHint> ProfileHintReceived;
            event EventHandler<ProfileAwareInterface.ProfileConfirmation> ProfileConfirmationReceived;
        }
    }
}
