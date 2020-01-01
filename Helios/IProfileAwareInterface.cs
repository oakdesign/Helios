﻿using System;
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

        public class ProfileStatus : EventArgs
        {
            public string RunningProfile { get; set; }
        }

        public class ClientChange: EventArgs
        {
            /// <summary>
            /// the only handle value which we may interpret, all other values are opaque
            /// </summary>
            static public string NO_CLIENT = "";
            public string FromOpaqueHandle { get; set; }
            public string ToOpaqueHandle { get; set; }
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
            event EventHandler<ProfileAwareInterface.ProfileStatus> ProfileStatusReceived;

            /// <summary>
            /// Fired to indicate the interface would like a profile with a tag matching
            /// the hint received.
            /// </summary>
            event EventHandler<ProfileAwareInterface.ProfileHint> ProfileHintReceived;

            /// <summary>
            /// Fired to indicate that the interface may no longer be connected to the same
            /// endpoint as before.
            /// </summary>
            event EventHandler<ProfileAwareInterface.ClientChange> ClientChanged;
            
            /// <summary>
            /// Tags that can be used to match a profile containing this interface to a future
            /// profile hint.  
            /// </summary>
            IEnumerable<string> Tags { get; }

            /// <summary>
            /// Request that the interface provide the information for the specified profile name,
            /// and send a ProfileStatusReceived event when this is accomplished.
            /// </summary>
            /// <param name="name"></param>
            void RequestProfile(string name);
        }
    }
}
