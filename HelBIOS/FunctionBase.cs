using GadrocsWorkshop.Helios;

namespace net.derammo.HelBIOS
{
    /// <summary>
    /// base class for most implementations of this interface, without anything special
    /// </summary>
    internal class FunctionBase : IFunction
    {
        public IFunctionParent Parent { get; private set; }
        public HeliosTriggerCollection Triggers { get; protected set; } = new HeliosTriggerCollection();
        public HeliosActionCollection Actions { get; protected set; } = new HeliosActionCollection();
        public HeliosValueCollection Values { get; protected set; } = new HeliosValueCollection();

        public FunctionBase(IFunctionParent parent)
        {
            Parent = parent;
        }
    }
}