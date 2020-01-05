using net.derammo.HelBIOS.SchemaVersion1;
using System;

namespace net.derammo.HelBIOS
{
    internal class StringReceiver : DataReceiver
    {
        private static readonly System.Text.Encoding _iso_8859_1 = System.Text.Encoding.GetEncoding("iso-8859-1");  // This is the locale of the lua exports program

        private Action<string> _code;
        private bool _dirty = false;

        /// <summary>
        /// the state of the string buffer after the last update
        /// </summary>
        private byte[] _previous;

        /// <summary>
        ///  this array tracks writes to the bytes of this string on the current update
        /// if any messages are lost, not all bytes will be written and we don't use the resulting value
        ///    
        /// NOTE: DCS-BIOS writes the entire buffer every update, filling in the unused parts of the string with
        /// ASCII space 0x20, even if the string is zero-terminated before that
        /// </summary>
        private bool[] _valid;

        public StringReceiver(ItemDefinition.Output output, Action<string> code)
            : base(output)
        {
            _code = code;
            Size = output.max_length;
            if (Size == 0)
            {
                GadrocsWorkshop.Helios.ConfigManager.LogManager.LogError($"string values must have a defined max_length; '{output.description ?? "(missing description)"}' at address {output.address} will not receive values");
            }
            _previous = new byte[Size];
            _valid = new bool[Size];
        }

        public override void ReceiveData(byte[] buffer, int sourceOffset, int size, int targetOffset)
        {
            if (Size == 0)
            {
                // disabled
                return;
            }
            for (int i = 0; (i < size) && ((i + targetOffset) < Size); i++)
            {
                if ((!_dirty) && (_previous[targetOffset + i] != buffer[sourceOffset + i]))
                {
                    _dirty = true;
                }
                _valid[targetOffset + i] = true;
            }
        }

        public override void Reset(byte[] buffer)
        {
            _dirty = false;
            Array.Clear(_previous, 0, _previous.Length);
            Array.Clear(_valid, 0, _valid.Length);
        }

        public override void NotifyUpdate(byte[] buffer)
        {
            if (_dirty)
            {
                // check if we have received all slices
                if (Array.Exists(_valid, (flag) => !flag))
                {
                    // did not receive all pieces
                    return;
                }
                // determine length, zero terminated
                int length = Array.FindIndex(buffer, _output.address, Size, (c) => c == 0);
                if (length < 0)
                {
                    length = Size;
                }
                string value = _iso_8859_1.GetString(buffer, _output.address, length);
                _code(value);

                // this is now our reference
                Array.Copy(buffer, _output.address, _previous, 0, Size);
                _dirty = false;
            }
        }

        public override bool NeedsUpdateNotification => true;
    }
}