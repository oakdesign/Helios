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

using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Windows;

namespace GadrocsWorkshop.Helios.Interfaces.DCS.Common
{
    public class DCSVehicleImpersonation: DependencyObject
    {
        private DCSInterface _dcsInterface;

        // customizable set of DCS vehicles we know about
        private SortedSet<string> _vehicles = CreateVehicleSet();

        // the same data in the only format that WPF can bind successfully at the moment
        private ObservableCollection<string> _vehiclesExport;

        private static SortedSet<string> CreateVehicleSet()
        {
            SortedSet<string> vehicles = new SortedSet<string>
            {
               "A-10C", "AJS37", "AV8BNA", "Bf-109K-4", "C-101CC", "C-101EB", "Christen Eagle II", "F-14B", "F-16C_50", "F-5E-3", "F-86F Sabre", "FA-18C_hornet",
                "FW-190A8", "FW-190D9", "Hawk", "I-16", "Ka-50", "L-39C", "L-39ZA", "M-2000C", "Mi-8MT", "MiG-15bis", "MiG-19P", "MiG-21Bis", "NS430", "P-51D-30-NA",
                "P-51D", "SA342L", "SA342M", "SA342Minigun", "SA342Mistral", "SpitfireLFMkIX", "SpitfireLFMkIXCW", "TF-51D", "UH-1H", "Yak-52",

                // flaming cliffs, no special treatment so far
                "A-10A", "F-15C", "F-16A", "J-11A", "MiG-29A", "MiG-29G", "MiG-29S", "Su-25", "Su-25T", "Su-27", "Su-33"
            };
            // XXX load set from config file and merge
            return vehicles;
        }

        public DCSVehicleImpersonation(DCSInterface dcsInterface)
        {
            _dcsInterface = dcsInterface;
            _vehicles = CreateVehicleSet();
            _vehiclesExport = new ObservableCollection<string>(_vehicles);
            SetValue(VehiclesPropertyKey, _vehiclesExport);

            // default
            if (dcsInterface.ImpersonatedVehicleName != null)
            {
                AddVehicle(dcsInterface.ImpersonatedVehicleName);
                NewVehicle = dcsInterface.ImpersonatedVehicleName;
            }
            else
            {
                NewVehicle = dcsInterface.VehicleName;
            }

            // the interface vehicle name is always a valid selection
            AddVehicle(dcsInterface.VehicleName);
        }

        /// <summary>
        /// the Helios name of the interface
        /// </summary>
        public string InterfaceName
        {
            get => _dcsInterface.Name;
        }

        /// <summary>
        /// this Property is bound to the contents of the combobox to detect when the user enters 
        /// a value that is not in the combobox list
        /// </summary>
        public string NewVehicle
        {
            get { 
                return (string)GetValue(NewVehicleProperty); 
            }
            set
            {
                SetValue(NewVehicleProperty, value);
                AddVehicle(value);
            }
        }
        public static readonly DependencyProperty NewVehicleProperty =
            DependencyProperty.Register("NewVehicle", typeof(string), typeof(DCSInterfaceEditor), new PropertyMetadata(null));

        /// <summary>
        /// This is the selected value for the combobox
        /// </summary>
        public string SelectedVehicle
        {
            get { 
                string configured = (string)GetValue(SelectedVehicleProperty);
                return configured ?? _dcsInterface.VehicleName;
            }
            set { 
                if (value == _dcsInterface.VehicleName)
                {
                    // unset to use default
                    value = null;
                }
                _dcsInterface.ImpersonatedVehicleName = value;
                SetValue(SelectedVehicleProperty, value); 
            }
        }
        public static readonly DependencyProperty SelectedVehicleProperty =
            DependencyProperty.Register("SelectedVehicle", typeof(string), typeof(DCSInterfaceEditor), new PropertyMetadata(null));

        /// <summary>
        /// This is the list of currently allowed values for the combobox
        /// </summary>
        public IEnumerable<string> Vehicles
        {
            get { return (ObservableCollection<string>)GetValue(VehiclesProperty); }
        }
        public static readonly DependencyPropertyKey VehiclesPropertyKey =
            DependencyProperty.RegisterReadOnly("Vehicles", typeof(ObservableCollection<string>), typeof(DCSInterfaceEditor), new PropertyMetadata(null));
        public static readonly DependencyProperty VehiclesProperty = VehiclesPropertyKey.DependencyProperty;

        /// <summary>
        /// add a value to the list of vehicles, if not already there, and export the list in the format required for WPF to bind it
        /// </summary>
        /// <param name="value"></param>
        private void AddVehicle(string value)
        {
            if (!_vehicles.Contains(value))
            {
                _vehicles.Add(value);
                // this is very inefficient but almost never happens
                // so I will do this rather than include some sorted observable collection
                int index = 0;
                foreach (string vehicle in _vehicles)
                {
                    if (vehicle == value)
                    {
                        break;
                    }
                    index++;
                }
                _vehiclesExport.Insert(index, value);
            }
        }
    }
}