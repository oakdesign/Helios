using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    internal class FunctionTemplate : IFunctionTemplate
    {
        private string _uniqueName;

        public IFunctionParent Parent { get; internal set; }
        public string DeviceName { get; internal set; }
        public string Name { get; internal set; }
        public ManifestVersion1.ItemDefinition Definition { get; internal set; }
        /// <summary>
        /// lazy-created Unique Name for the item, which will be equal to Definition.description if the input data is perfect
        /// </summary>
        public string UniqueName
        {
            get
            {
                if (_uniqueName == null)
                {
                    _uniqueName = ChooseName();
                }
                return _uniqueName;
            }
        }

        private string ChooseName()
        {
            // need to make sure we get a unique name
            string name = Definition.description;
            if ((name != null) && (name.Length > 0))
            {
                if (Parent.AllocateUniqueNamePair(DeviceName, name))
                {
                    return name;
                }
                // this happens when the description text is copied and pasted (see A-10C profile)
                name = $"{name} ({Name})";
                if (Parent.AllocateUniqueNamePair(DeviceName, name))
                {
                    ConfigManager.LogManager.LogWarning($"item {DeviceName}.{Definition.description} renamed to {name} to avoid name collision");
                    return name;
                }
            }
            name = Name;
            int index = 2;
            while (!Parent.AllocateUniqueNamePair(DeviceName, name))
            {
                name = $"{Name}.{index}";
            }
            ConfigManager.LogManager.LogWarning($"item {DeviceName}.{Name} renamed to {name} to avoid name collision");
            return name;
        }
    }
}