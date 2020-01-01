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

namespace GadrocsWorkshop.Helios
{
    using System.Windows.Threading;

    public class BaseDeserializer
    {
        private delegate object CreateObjectDelegate(string type, string typeId);
        private CreateObjectDelegate _objectCreator;
        private delegate HeliosInterface CreateInterfaceDelegate(string typeId, HeliosInterfaceCollection loaded);
        private CreateInterfaceDelegate _interfaceCreator;
        private Dispatcher _dispatcher;

        public BaseDeserializer(Dispatcher dispatcher)
        {
            _objectCreator = new CreateObjectDelegate(DispCreateNewObject);
            _interfaceCreator = new CreateInterfaceDelegate(DispCreateNewInterface);
            _dispatcher = dispatcher;
        }

        protected Dispatcher Dispatcher
        { get { return _dispatcher; } }

        #region Object Creation Methods

        protected object CreateNewObject(string type, string typeId)
        {
            return Dispatcher.Invoke(_objectCreator, type, typeId);
        }

        protected HeliosInterface CreateNewInterface(string typeId, HeliosInterfaceCollection loaded)
        {
            return Dispatcher.Invoke(_interfaceCreator, typeId, loaded) as HeliosInterface;
        }

        private HeliosInterface DispCreateNewInterface(string typeId, HeliosInterfaceCollection loaded)
        {
            HeliosInterfaceDescriptor descriptor = ConfigManager.ModuleManager.InterfaceDescriptors[typeId];
            if (descriptor == null)
            {
                ConfigManager.LogManager.LogError("Ignoring interface not supported by this version of Helios: " + typeId);
                return null;
            }

            HeliosInterface heliosInterface = null;
            if (descriptor.ParentTypeIdentifier != null)
            {
                foreach (HeliosInterface candidate in loaded)
                {
                    if (candidate.TypeIdentifier == descriptor.ParentTypeIdentifier)
                    {
                        // bind to first matching interface
                        heliosInterface = descriptor.CreateInstance(candidate);
                        break;
                    }
                }
                if (heliosInterface == null)
                {
                    ConfigManager.LogManager.LogError($"Child interface {typeId} could not locate its parent {descriptor.ParentTypeIdentifier}; interface not loaded");
                }
            } 
            else
            {
                heliosInterface = descriptor.CreateInstance();
            }
            if (heliosInterface != null)
            {
                heliosInterface.Dispatcher = _dispatcher;
            }
            return heliosInterface;
        }

        private object DispCreateNewObject(string type, string typeId)
        {
            switch (type)
            {
                case "Monitor":
                    return new Monitor();

                case "Visual":
                    HeliosVisual visual = ConfigManager.ModuleManager.CreateControl(typeId);
                    if (visual == null)
                    {
                        ConfigManager.LogManager.LogError("Ignoring control not supported by this version of Helios: " + typeId);
                        return null;
                    }
                    visual.Dispatcher = _dispatcher;
                    return visual;

                case "Interface":
                    throw new System.Exception("logic error: use CreateNewInterface for interfaces");

                case "Binding":
                    return new HeliosBinding();

            }
            return null;
        }

        #endregion
    }
}
