﻿//  Copyright 2014 Craig Courtney
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
using System.Windows;

namespace GadrocsWorkshop.Helios.Interfaces.DCS.Common
{
    public class DCSVehicleImpersonation: DependencyObject
    {
        private DCSInterface _dcsInterface;

        // a lot of code that just connects to a combobox
        private EditableComboBoxModel _impersonatedNameSelection;

        public DCSVehicleImpersonation(DCSInterface dcsInterface)
        {
            _dcsInterface = dcsInterface;

            // instead of using a callback interface, we can use lambdas to bind specific values, so
            // we could have multiple combobox models supported by this class
            _impersonatedNameSelection = new EditableComboBoxModel();
            _impersonatedNameSelection.LoadItemSet = () => CreateItemSet();
            _impersonatedNameSelection.GetCurrentValue = () => _dcsInterface.ImpersonatedVehicleName;
            _impersonatedNameSelection.GetDefaultValue = () => _dcsInterface.VehicleName;
            _impersonatedNameSelection.SetCurrentValue = (value) => _dcsInterface.ImpersonatedVehicleName = value;
            _impersonatedNameSelection.Init();
            _impersonatedNameSelection.NewItemAdded += OnItemAdded;
            SetValue(ImpersonatedVehicleNameProperty, _impersonatedNameSelection);
        }

        private void OnItemAdded(object sender, EditableComboBoxModel.NewItemAddedArgs e)
        {
            // XXX persist e.value
        }

        /// <summary>
        /// the Helios name of the interface
        /// </summary>
        public string InterfaceName
        {
            get => _dcsInterface.Name;
        }

        // access to the bindings for WPF
        public EditableComboBoxModel ImpersonatedVehicleName { get => _impersonatedNameSelection; }
        public static readonly DependencyProperty ImpersonatedVehicleNameProperty =
            DependencyProperty.Register("ImpersonatedVehicleName", typeof(EditableComboBoxModel), typeof(DCSVehicleImpersonation), new PropertyMetadata(null));

        SortedSet<string> CreateItemSet()
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
    }
}