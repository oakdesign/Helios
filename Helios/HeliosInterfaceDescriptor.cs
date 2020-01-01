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

namespace GadrocsWorkshop.Helios
{
    using System;
    using System.Collections.Generic;

    using GadrocsWorkshop.Helios.ComponentModel;

    public class HeliosInterfaceDescriptor
    {
        private HeliosInterfaceAttribute _interfaceAttribute;
        private Type _interfaceType;
        private HeliosInterfaceFactory _factory;

        public HeliosInterfaceDescriptor(Type type, HeliosInterfaceAttribute attribute)
        {
            _interfaceType = type;
            _interfaceAttribute = attribute;
        }

        public Type InterfaceType
        {
            get
            {
                return _interfaceType;
            }
        }

        public Type InterfaceEditorType
        {
            get
            {
                return _interfaceAttribute.InterfaceEditorType;
            }
        }

        public string TypeIdentifier
        {
            get
            {
                return _interfaceAttribute.TypeIdentifier;
            }
        }

        public string UniquenessKey
        {
            get => _interfaceAttribute.UniquenessKey ?? _interfaceAttribute.TypeIdentifier;
        }
        
        public string ParentTypeIdentifier
        {
            get => _interfaceAttribute.Parent;
        }

        public string Name
        {
            get
            {
                return _interfaceAttribute.Name;
            }
        }

        public HeliosInterfaceFactory Factory
        {
            get
            {
                if (_factory == null)
                {
                    _factory = (HeliosInterfaceFactory)Activator.CreateInstance(_interfaceAttribute.Factory);
                }
                return _factory;
            }
        }

        /// <summary>
        /// If true an isntance of this control will automatically be added to a new profile.
        /// </summary>
        public bool AutoAdd
        {
            get
            {
                return _interfaceAttribute.AutoAdd;
            }
        }

        public HeliosInterface CreateInstance()
        {
            // does this interface require its name?
            System.Reflection.ConstructorInfo ctor = _interfaceType.GetConstructor(new[] { typeof(string) });
            if (ctor != null)
            {
                return (HeliosInterface)Activator.CreateInstance(_interfaceType, new object[] { Name });
            }
            return (HeliosInterface)Activator.CreateInstance(_interfaceType);
        }

        public HeliosInterface CreateInstance(HeliosInterface parent)
        {
            // does this interface require its name?
            System.Reflection.ConstructorInfo ctor = _interfaceType.GetConstructor(new[] { typeof(HeliosInterface), typeof(string) });
            if (ctor != null)
            {
                return (HeliosInterface)Activator.CreateInstance(_interfaceType, new object[] { parent, Name });
            }
            // crash if incorrect constructor
            return (HeliosInterface)Activator.CreateInstance(_interfaceType, new object[] { parent });
        }


        public List<HeliosInterface> GetNewInstances(HeliosProfile profile)
        {
            return Factory.GetInterfaceInstances(this, profile);
        }

        public List<HeliosInterface> GetAutoAddInstances(HeliosProfile profile)
        {
            return Factory.GetAutoAddInterfaces(this, profile);
        }
    }
}
