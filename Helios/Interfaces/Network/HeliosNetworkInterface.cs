using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace GadrocsWorkshop.Helios.Interfaces.Network
{
    public abstract class HeliosNetworkInterface : HeliosInterface, INetworkInterface
    {
        protected HeliosNetworkInterface(HeliosInterface parentInterface, string name)
            : base(parentInterface, name)
        {
            // punt
        }

        protected HeliosNetworkInterface(string name)
            : this(null, name)
        {
            // utility
        }

        public abstract void SendData(string text);
    }
}
