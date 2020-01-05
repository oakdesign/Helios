using net.derammo.HelBIOS;
using System.Collections.Generic;
using static net.derammo.HelBIOS.ManifestVersion1.ItemDefinition;

namespace net.derammo.HelBIOS
{
    internal class SelectorFactory : IFunctionFactory
    {
        public IFunction CreateFunction(IFunctionTemplate template)
        {
            switch (template.Definition.api_variant)
            {
                case ApiVariant.momentary_last_position:
                    return new PushButton(template);
            }
            return null;
        }
    }
}