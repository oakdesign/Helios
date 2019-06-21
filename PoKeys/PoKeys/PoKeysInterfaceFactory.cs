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

namespace GadrocsWorkshop.Helios.Interfaces.PoKeys
{
    using global::PoKeys;
    using System;
    using System.Collections.Generic;

    public class PoKeysInterfaceFactory : HeliosInterfaceFactory
    {
        private static Manager _manager;

        private static Manager PoKeysManager
        {
            get
            {
                if (_manager == null)
                {
                    _manager = new Manager();
                    _manager.open();
                    System.Threading.Thread.Sleep(1000);
                }
                return _manager;
            }
        }

        public override List<HeliosInterface> GetInterfaceInstances(HeliosInterfaceDescriptor descriptor, HeliosProfile profile)
        {
            HashSet<int> serialNumbers = new HashSet<int>();
            List<HeliosInterface> interfaces = new List<HeliosInterface>();

            foreach (HeliosInterface currentInterface in profile.Interfaces)
            {
                PoKeysInterface PoKeysInterface = currentInterface as PoKeysInterface;
                if (PoKeysInterface != null)
                {
                    serialNumbers.Add(PoKeysInterface.SerialNumber);
                }
            }

            foreach (PoKeys pokeys in PoKeysManager.Devices)
            {
                if (!serialNumbers.Contains(pokeys.SerialNumber))
                {
                    switch (pokeys.Type)
                    {
                        case "PoKeysStepper":
                            //if (descriptor.TypeIdentifier.Equals("Helios.PoKeys.UnipolarStepperBoard"))
                            //{
                            //    interfaces.Add(new PoKeysStepperBoard(pokeys.SerialNumber));
                            //}
                            //break;
                        case "PoKeysLED":
                            if (descriptor.TypeIdentifier.Equals("Helios.PoKeys.LedBoard"))
                            {
                                interfaces.Add(new PoKeysLEDBoard(pokeys.SerialNumber));
                            }
                            break;
                        //case "PoKeysAdvancedServo":
                        //case "PoKeysServo":
                        //    if (descriptor.TypeIdentifier.Equals("Helios.PoKeys.AdvancedServoBoard"))
                        //    {
                        //        interfaces.Add(new PoKeysServoBoard(pokeys.SerialNumber));
                        //    }
                        //    break;
                        default:
                            break;
                    }
                    ConfigManager.LogManager.LogInfo("Found PoKeys Type = " + pokeys.Type + " Serail Number = " + pokeys.SerialNumber.ToString());
                }
            }

            return interfaces;
        }

        private bool IsUnique(HeliosInterfaceDescriptor descriptor, HeliosProfile profile)
        {
            foreach (HeliosInterface heliosInterface in profile.Interfaces)
            {
                HeliosInterfaceDescriptor interfaceDescriptor = ConfigManager.ModuleManager.InterfaceDescriptors[heliosInterface.GetType()];
                if (interfaceDescriptor.TypeIdentifier.Equals(descriptor.TypeIdentifier))
                {
                    // If any existing interfaces in the profile have the same type identifier do not add them.
                    return false;
                }
            }

            return true;
        }
    }
}
