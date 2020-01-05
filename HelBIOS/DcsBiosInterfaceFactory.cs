using GadrocsWorkshop.Helios;
using Microsoft.Win32;
using System;
using System.Collections.Generic;

namespace net.derammo.HelBIOS
{
    public class DcsBiosInterfaceFactory : UniqueHeliosInterfaceFactory
    {
        public static string InstallPath { get; private set; }

        public override List<HeliosInterface> GetInterfaceInstances(HeliosInterfaceDescriptor descriptor, HeliosProfile profile)
        {
            RegistryKey root = Microsoft.Win32.RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64);
            RegistryKey installedKey = root.OpenSubKey(@"SOFTWARE\\DCS-BIOS\DCS-BIOS Hub");
            if (installedKey != null)
            {
                string path = installedKey.GetValue("Path") as String;
                if (path != null)
                {
                    InstallPath = path;
                    return base.GetInterfaceInstances(descriptor, profile);
                }
            }
            // refuse to create any instances
            return new List<HeliosInterface>();
        }
    }
}
