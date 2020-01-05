using GadrocsWorkshop.Helios;
using System.Collections.Generic;

namespace net.derammo.HelBIOS
{
    /// <summary>
    /// DCS-BIOS Export parser, not assuming alignment of synchronization eye catcher, so
    /// we process everything byte by byte
    /// 
    /// based on DCS-BIOS Arduino library version 
    /// https://github.com/dcs-bios/dcs-bios-arduino-library/blob/master/src/internal/Protocol.cpp
    /// </summary>
    internal class ExportProtocol : IMessageReceiver
    {
        private enum State
        {
            WAIT_FOR_SYNC,
            ADDRESS_LOW,
            ADDRESS_HIGH,
            COUNT_LOW,
            COUNT_HIGH,
            DATA_LOW,
            DATA_HIGH
        }
        private State state = State.WAIT_FOR_SYNC;
        private int sync_byte_count = 0;
        private int address;
        private int writeIndex;
        private int count;
        private int size;
        private byte[] _buffer = new byte[0x10000];

        public interface IDataReceiver
        {
            int Address { get; }

            int Size { get; }

            /// <summary>
            /// if true, this data element wants to be notified on frame sync
            /// </summary>
            bool NeedsSyncNotification { get; }

            void ReceiveData(byte[] buffer, int sourceOffset, int size, int targetOffset);
            void NotifySync(byte[] buffer);
            void Reset(byte[] buffer);
        }

        // functions that can process writes
        private List<IDataReceiver> _customers = new  List<IDataReceiver>();

        // brute force dispatch table, indexed by address/2
        private List<IDataReceiver>[] _dispatch = new List<IDataReceiver>[0x10000 / 2];

        // those receivers that need to know when sync happens
        private List<IDataReceiver> _syncAwareCustomers = new List<IDataReceiver>();

        internal ExportProtocol()
        {
        }

        private void ProcessByte(byte c)
        {
            switch (state)
            {
                case State.WAIT_FOR_SYNC:
                    /* do nothing */
                    break;

                case State.ADDRESS_LOW:
                    address = c;
                    state = State.ADDRESS_HIGH;
                    break;

                case State.ADDRESS_HIGH:
                    address = (c << 8) | address;
                    if (address != 0x5555)
                    {
                        state = State.COUNT_LOW;
                        writeIndex = address;
                    }
                    else
                    {
                        state = State.WAIT_FOR_SYNC;
                    }
                    break;

                case State.COUNT_LOW:
                    count = c;
                    state = State.COUNT_HIGH;
                    break;

                case State.COUNT_HIGH:
                    count = (c << 8) | count;
                    size = count;
                    state = State.DATA_LOW;
                    break;

                case State.DATA_LOW:
                    _buffer[writeIndex] = c;
                    writeIndex++;
                    count--;
                    state = State.DATA_HIGH;
                    break;

                case State.DATA_HIGH:
                    _buffer[writeIndex] = c;
                    writeIndex++;
                    count--;
                    if (count == 0)
                    {
                        // done writing
                        DispatchWrites(address, size);
                        state = State.ADDRESS_LOW;
                    }
                    else
                    {
                        state = State.DATA_LOW;
                    }
                    break;
            }

            if (c == 0x55)
            {
                sync_byte_count++;
            }
            else
            {
                sync_byte_count = 0;
            }

            if (sync_byte_count == 4)
            {
                state = State.ADDRESS_LOW;
                sync_byte_count = 0;
                NotifySync();
            }
        }

        public void HandleMessage(byte[] data, int bytesReceived)
        {
            for (int i=0; i<bytesReceived; i++)
            {
                ProcessByte(data[i]);
            }
        }

        public void Add(IDataReceiver receiver)
        {
            // string subscribers might have odd size, round it up
            int size = receiver.Size + (receiver.Size % 2);

            // register for every uint16 in the range
            for (int scan = receiver.Address / 2; scan < (receiver.Address + size) / 2; scan++)
            {
                if (_dispatch[scan] == null)
                {
                    _dispatch[scan] = new List<IDataReceiver>();
                }
                _dispatch[scan].Add(receiver);
            }

            // register for sync
            if (receiver.NeedsSyncNotification)
            {
                _syncAwareCustomers.Add(receiver);
            }
        }

        private void DispatchWrites(int address, int size)
        {
            for (int scan = address / 2; scan < (address + size) / 2; scan++)
            {
                if (_dispatch[scan] != null)
                {
                    foreach(IDataReceiver receiver in _dispatch[scan])
                    {
                        int location = scan * 2;
                        receiver.ReceiveData(_buffer, location, 2, location - receiver.Address);
                    }
                }
            }
        }

        private void NotifySync()
        {
            foreach (IDataReceiver receiver in _syncAwareCustomers)
            {
                receiver.NotifySync(_buffer);
            }
        }
    }
}