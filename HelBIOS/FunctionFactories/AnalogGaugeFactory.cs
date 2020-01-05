namespace net.derammo.HelBIOS
{
    internal class AnalogGaugeFactory : IFunctionFactory
    {
        public IFunction CreateFunction(IFunctionTemplate template)
        {
            return new AnalogValue(template);
        }
    }
}