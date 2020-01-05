using GadrocsWorkshop.Helios;
using Microsoft.Win32;
using System;
using System.Collections.Generic;

namespace net.derammo.HelBIOS
{
    public class DcsBiosInterfaceFactory : UniqueHeliosInterfaceFactory
    {
        // XXX HACK test
        //static DcsBiosInterfaceFactory()
        //{
        //    string testText = System.IO.File.ReadAllText("FA-18C_hornet.json");
        //    System.Text.Json.JsonSerializerOptions options = new System.Text.Json.JsonSerializerOptions
        //    {
        //        ReadCommentHandling = System.Text.Json.JsonCommentHandling.Skip,
        //        AllowTrailingCommas = true
        //    };
        //    options.Converters.Add(new DcsBiosEnumConverterFactory());
        //    try
        //    {
        //        ManifestVersion1.ModuleDefinition definition = System.Text.Json.JsonSerializer.Deserialize<ManifestVersion1.ModuleDefinition>(testText, options);
        //    } 
        //    catch (Exception ex)
        //    {
        //        Console.WriteLine(ex.ToString());
        //    }

        //    // test create module
        //    DcsBiosInterface testParent = new DcsBiosInterface("Test Parent");
        //    HeliosProfile testProfile = new HeliosProfile();
        //    testParent.Profile = testProfile;
        //    DcsBiosVehicleInterface testChild = new DcsBiosVehicleInterface(testParent, "DCS-BIOS FA-18C_hornet");
        //    testChild.Profile = testProfile;
        //}

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
