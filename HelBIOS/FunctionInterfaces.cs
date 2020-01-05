using GadrocsWorkshop.Helios;
using System;

namespace net.derammo.HelBIOS
{
    /// <summary>
    /// grouped information provided when constructing function implementations from an item definition
    /// </summary>
    internal interface IFunctionTemplate
    {
        IFunctionParent Parent { get; }
        string DeviceName { get; }
        string Name { get; }
        string UniqueName { get; }
        ManifestVersion1.ItemDefinition Definition { get; }
    }

    internal interface IFunctionFactory
    {
        IFunction CreateFunction(IFunctionTemplate template);
    }

    /// <summary>
    /// DCS-BIOS command arguments that we need to know, because we don't read them from the definition
    /// </summary>
    public enum CommandArgument
    {
        INC,
        DEC
    }

    internal interface IFunctionParent
    {
        HeliosObject SourceInterface { get; }
        HeliosObject CommandInterface { get; }


        void SendCommand(string identifier, int argument);
        void SendCommand(string identifier, CommandArgument argument);
        void SendCommand(string identifier, ManifestVersion1.ItemDefinition.Input.Argument argument);
        void SendCommand(string identifier, double argument);

        bool AllocateUniqueNamePair(string deviceName, string itemName);

        void RegisterInteger(ManifestVersion1.ItemDefinition.Output output, Action<int> code);
    }

    internal interface IFunction
    {
        IFunctionParent Parent { get; }
        HeliosTriggerCollection Triggers { get; }
        HeliosActionCollection Actions { get; }
        HeliosValueCollection Values { get; }
    }
}