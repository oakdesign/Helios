using GadrocsWorkshop.Helios;
using System.Collections.Generic;

namespace net.derammo.HelBIOS
{
    internal class DcsBiosVehicleInterfaceFactory : HeliosInterfaceFactory
    {
        public override List<HeliosInterface> GetInterfaceInstances(HeliosInterfaceDescriptor descriptor, HeliosProfile profile)
        {
            HashSet<string> loaded = new HashSet<string>();
            DcsBiosInterface parent = null;
            foreach (HeliosInterface heliosInterface in profile.Interfaces)
            {
                HeliosInterfaceDescriptor interfaceDescriptor = ConfigManager.ModuleManager.InterfaceDescriptors[heliosInterface.GetType()];
                if (interfaceDescriptor.TypeIdentifier == "HelBIOS.DcsBiosInterface")
                {
                    parent = heliosInterface as DcsBiosInterface;
                }
                if (interfaceDescriptor.TypeIdentifier == "HelBIOS.DcsBiosVehicleInterface")
                {
                    loaded.Add(heliosInterface.Name);
                }
            }
            List<HeliosInterface> newInstances = new List<HeliosInterface>();
            if (parent != null)
            {
                foreach(string vehicle in parent.InstalledVehicles)
                {
                    if (!loaded.Contains(vehicle))
                    {
                        HeliosInterface available = descriptor.CreateInstance(parent);
                        available.Name = vehicle;
                        newInstances.Add(available);
                    }
                }
            }
            return newInstances;
        }
    }
}