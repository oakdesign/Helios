namespace net.derammo.HelBIOS
{
    /// <summary>
    /// base class for functions generated from a single DCS BIOS item definition
    /// </summary>
    internal class ItemFunction : FunctionBase
    {
        protected string _deviceName;
        protected string _itemName;
        protected SchemaVersion1.ItemDefinition _definition;

        public ItemFunction(IFunctionTemplate template)
            : base(template.Parent)
        {
            this._deviceName = template.DeviceName;
            this._itemName = template.Name;
            this._definition = template.Definition;
        }
    }
}