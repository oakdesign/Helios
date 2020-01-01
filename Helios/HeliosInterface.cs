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
    /// <summary>
    /// Base class for all hardware and software interface objects.
    /// </summary>
    public abstract class HeliosInterface : HeliosObject
    {
        private string _typeIdentifier;
        private HeliosInterface _parentInterface;

        protected HeliosInterface(HeliosInterface parentInterface, string name)
            : base(name)
        {
            _parentInterface = parentInterface;
        }

        protected HeliosInterface(string name)
            : this(null, name)
        {
            // utility
        }

        /// <summary>
        /// null if this is is a top-level interface, otherwise has a stable reference to the parent interface
        /// </summary>
        public HeliosInterface ParentInterface { get => _parentInterface; }

        #region Properties
        public override string TypeIdentifier
        {
            get
            {
                if (_typeIdentifier == null)
                {
                    HeliosInterfaceDescriptor descriptor = ConfigManager.ModuleManager.InterfaceDescriptors[this.GetType()];
                    _typeIdentifier = descriptor.TypeIdentifier;
                }
                return _typeIdentifier;
            }
        }

        #endregion
    }
}
