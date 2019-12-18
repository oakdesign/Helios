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

using System;

namespace GadrocsWorkshop.Helios
{
    public class ProfileHint : EventArgs
    {
        public string Tag { get; set; }
    }

    public class ProfileConfirmation : EventArgs
    {
        public string Name { get; set; }
    }

    /// <summary>
    /// Base class for all hardware and software interface objects.
    /// </summary>
    public abstract class HeliosInterface : HeliosObject
    {
        private string _typeIdentifier;
        private string _basetypeIdentifier;

        protected HeliosInterface(string name)
            : base(name)
        {
        }

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
        public string BaseTypeIdentifier
        {
            get
            {
                if (_basetypeIdentifier == null)
                {
                    HeliosInterfaceDescriptor descriptor = ConfigManager.ModuleManager.InterfaceDescriptors[this.GetType()];
                    _basetypeIdentifier = descriptor.InterfaceType.BaseType.Name;
                }
                return _basetypeIdentifier;
            }
        }

        #endregion

        #region Events
        // this event indicates that the interface received an indication that a profile that 
        // matches the specified hint should be loaded
        [field: NonSerialized]
        public event EventHandler<ProfileHint> ProfileHintReceived;

        // this event indicates that the interface received an indication that the specified
        // profile name is loaded on the other side of the interface
        [field: NonSerialized]
        public event EventHandler<ProfileConfirmation> ProfileConfirmationReceived;
        #endregion

        protected void OnProfileHintReceived(string tag)
        {
            ProfileHintReceived?.Invoke(this, new ProfileHint() { Tag = tag });
        }

        protected void OnProfileConfirmationReceived(string name)
        {
            ProfileConfirmationReceived?.Invoke(this, new ProfileConfirmation() { Name = name });
        }
    }
}
