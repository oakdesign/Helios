using net.derammo.HelBIOS;
using System.Collections.Generic;
using static net.derammo.HelBIOS.SchemaVersion1.ItemDefinition;

namespace net.derammo.HelBIOS
{
    internal class DisplayFactory : IFunctionFactory
    {
        public IFunction CreateFunction(IFunctionTemplate template)
        {
            if (template.Definition.outputs.Length > 0)
            {
                if (template.Definition.outputs[0].type == Output.Type._string)
                {
                    return new Text(template);
                }
            }
            return null;
        }
    }
}