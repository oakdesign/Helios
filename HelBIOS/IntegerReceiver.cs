using net.derammo.HelBIOS.SchemaVersion1;
using System;

namespace net.derammo.HelBIOS
{
    internal class IntegerReceiver : DataReceiver
    {
        private Action<int> _code;
        private int _previousBits;
        private bool _previousBitsValid = false;

        public IntegerReceiver(ItemDefinition.Output output, Action<int> code)
            : base(output)
        {
            _code = code;
            Size = output.max_length;
            if (Size == 0)
            {
                Size = 2;
            }
        }

        public override void ReceiveData(byte[] buffer, int sourceOffset, int size, int targetOffset)
        {
            int value = buffer[Address];
            value |= (buffer[Address + 1] << 8);
            if (_output.mask > 0)
            {
                value &= _output.mask;
            }
            if (_previousBitsValid && (value == _previousBits))
            {
                // don't bother shifting out relevant value, it is unchanged
                return;
            }
            _previousBits = value;
            _previousBitsValid = true;
            if (_output.shift_by > 0)
            {
                value >>= _output.shift_by;
            }
            _code(value);
        }

        public override void Reset(byte[] buffer)
        {
            _previousBits = 0;
            _previousBitsValid = false;
        }
    }
}