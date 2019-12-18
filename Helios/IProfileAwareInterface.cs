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
            /// <summary>
            /// Fired to indicate the interface is providing information related
            /// to the specified profile name.  This name is not necessarily the 
            /// same as the HeliosProfile.Name
            ///
            /// This event can be fired with or without a previous RequestProfile call.
            /// </summary>
            event EventHandler<ProfileAwareInterface.ProfileHint> ProfileHintReceived;

            event EventHandler<ProfileAwareInterface.ProfileConfirmation> ProfileConfirmationReceived;

            IEnumerable<string> Tags { get; }

            /// <summary>
            /// Request that the interface provide the information for the specified profile name,
            /// and send a ProfileConfirmationReceived event when this is accomplished.
            /// </summary>
            /// <param name="name"></param>
            void RequestProfile(string name);
        }
    }
}
