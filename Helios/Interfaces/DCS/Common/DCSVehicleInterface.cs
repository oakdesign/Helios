//  Copyright 2014 Craig Courtney
//    
//  Helios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Helios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

using GadrocsWorkshop.Helios.Interfaces.Network;
using System.Xml;

namespace GadrocsWorkshop.Helios.Interfaces.DCS.Common
{
    public class DCSVehicleInterface: HeliosNetworkInterface
    {
        // duplicate this information with type info
        DCSInterface _transport;

        public DCSVehicleInterface(HeliosInterface parent, string name, string vehicleName, string exportFunctionsPath) :
            base(parent, name)
        {
            if (!(parent is DCSInterface))
            {
                throw new System.Exception("DCS vehicle interfaces must be attached to DCSInterface as their parent");
            }
            _transport = parent as DCSInterface;
        }

        // XXX eliminate
        protected HeliosNetworkInterface NetworkInterface { get => this; }

        protected void AddFunction(NetworkFunction function)
        {
            // hook into ProcessNetworkData of _networkInterface
            _transport.Subscribe(this, function);

            // advertise functions
            Triggers.AddSlave(function.Triggers);
            Actions.AddSlave(function.Actions);
            Values.AddSlave(function.Values);
        }

        protected void AddFunction(NetworkFunction function, bool debug)
        {
            function.IsDebugMode = debug;
            AddFunction(function);
        }

        public override void ReadXml(XmlReader reader)
        {
        }

        public override void WriteXml(XmlWriter writer)
        {
        }

        public override void DisconnectBindings()
        {
            // we are removed from the profile, cancel our subscriptions
            _transport.Unsubscribe(this);
            base.DisconnectBindings();
        }

        public override void ReconnectBindings()
        {
            // REVISIT: I believe we don't need to do anything here, because interfaces can't be put back into a profile after deletion
            base.ReconnectBindings();
        }

        public override void SendData(string text)
        {
            _transport.SendData(text);
        }
    }
}