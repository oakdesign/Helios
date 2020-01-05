//  Copyright 2014 Craig Courtney
//    
//  Helios is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Helios is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

namespace net.derammo.HelBIOS
{
    using static GadrocsWorkshop.Helios.ConfigManager;
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Net;
    using System.Net.Sockets;

    public class MulticastListener
    {
        // const during lifetime, no access control required
        private readonly AsyncCallback _socketDataCallback;
        private readonly IMessageReceiver _receiver;

        // event handlers are thread safe, no access control required
        /// <summary>
        /// event to notify potentially other threads that the client connection has changed
        /// </summary>
        public event EventHandler<GadrocsWorkshop.Helios.ProfileAwareInterface.ClientChange> ClientChanged;

        /// <summary>
        /// accessed only by main thread
        /// </summary>
        private class MainThreadAccess
        {
            static private int _id = System.Threading.Thread.CurrentThread.ManagedThreadId;
            private EndPoint _client = null;

            public EndPoint Client
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _client;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _client = value;
                }
            }
        }

        /// <summary>
        /// accessed by multiple threads (main and socket pool, or multiple socket pool)
        /// </summary>
        private class SharedAccess
        {
            // contention between main and socket threads due to read/write and error recovery open/close
            private Socket _socket = null;

            // accessed during socket re-open from various threads
            private int _port = 5010;

            // pool of receive contexts
            private Queue<ReceiveContext> _receiveContexts = new Queue<ReceiveContext>();
            private const int _cachedReceiveContexts = 16;

            // lock on all the other fields, public access ok so we can lock larger
            // sections of code and rely on re-entrant locking to avoid deadlock
            public object Lock { get; } = new object();

            public bool Started
            {
                get
                {
                    lock (Lock)
                    {
                        return _socket != null;
                    }
                }
            }

            public Socket ServerSocket
            {
                get
                {
                    lock (Lock)
                    {
                        return _socket;
                    }
                }
                set
                {
                    lock (Lock)
                    {
                        _socket = value;
                    }
                }
            }

            public int Port
            {
                get
                {
                    lock (Lock)
                    {
                        return _port;
                    }
                }
                set
                {
                    lock (Lock)
                    {
                        _port = value;
                    }
                }
            }

            /// <summary>
            /// returns clean ReceiveContext or null
            /// </summary>
            /// <returns></returns>
            public ReceiveContext FetchReceiveContext()
            {
                lock(Lock)
                {
                    if (_receiveContexts.Count > 0)
                    {
                        return _receiveContexts.Dequeue();
                    }
                    else
                    {
                        return null;
                    }
                }
            }

            /// <summary>
            /// adds a receive context back to the pool
            /// </summary>
            public void ReturnReceiveContext(ReceiveContext context)
            {
                context.Clear();
                lock(Lock)
                {
                    if (_receiveContexts.Count < _cachedReceiveContexts)
                    {
                        _receiveContexts.Enqueue(context);
                    }
                }
            }
        }

        /// <summary>
        /// owned by the socket thread pool thread that is currently processing the receive operation, then
        /// ownership is handed off to main thread for final processing.  object is not reused (yet)
        /// </summary>
        private class ReceiveContext
        {
            public class Message
            {
                // preallocated space
                public byte[] data = new byte[2048];

                // fill level
                public int bytesReceived = 0;

                // source of datagram received
                public EndPoint fromEndPoint = new IPEndPoint(IPAddress.Any, 0);

                // XXX anything we want to offload and preparse here?

                public void Clear()
                {
                    fromEndPoint = new IPEndPoint(IPAddress.Any, 0);
                    bytesReceived = 0;
                }
            }

            // buffers for datagrams received on one context switch
            // XXX tune size
            private Message[] _messages = new Message[10];

            // number of buffers filled
            private int _messagesFilled = 0;

            public void Clear()
            {
                _messagesFilled = 0;
            }

            public int Length
            {
                get => _messagesFilled;
            }

            public int Capacity
            {
                get => _messages.Length;
            }

            public Message BeginWrite()
            {
                if (_messagesFilled >= _messages.Length)
                {
                    throw new IndexOutOfRangeException("logic error: attempt to fill receive context past capacity");
                }
                if (_messages[_messagesFilled] == null)
                {
                    // lazy allocate
                    _messages[_messagesFilled] = new Message();
                } else
                {
                    _messages[_messagesFilled].Clear();
                }
                return _messages[_messagesFilled];
            }

            public Message ContinueWrite(int index)
            {
                if (index != _messagesFilled)
                {
                    throw new IndexOutOfRangeException("logic error: attempt to continue write that is not current");
                }
                return _messages[index];
            }

            public void EndWrite()
            {
                _messagesFilled++;
            }

            public Message Read(int index)
            {
                if (index >= _messagesFilled)
                {
                    throw new IndexOutOfRangeException("logic error: attempt to read receive context past fill level");
                }
                return _messages[index];
            }
        }

        private MainThreadAccess _main = new MainThreadAccess();
        private SharedAccess _shared = new SharedAccess();

        // access to the dispatcher for the HeliosObject that owns us, so we can schedule work on correct main thread
        private System.Windows.Threading.Dispatcher _dispatcher;

        public MulticastListener(System.Windows.Threading.Dispatcher dispatcher, IMessageReceiver receiver)
        {
            // const
            _dispatcher = dispatcher;
            _receiver = receiver;
            _socketDataCallback = new AsyncCallback(OnDataReceived);
        }

        public int Port
        {
            get
            {
                return _shared.Port;
            }
            set
            {
                int oldValue;
                lock (_shared.Lock)
                {
                    oldValue = _shared.Port;
                    if (!_shared.Port.Equals(value))
                    {
                        _shared.Port = value;
                    }
                }
                if (!oldValue.Equals(value))
                {
                    // XXX OnPropertyChanged("Port", oldValue, value, false);
                }
            }
        }

        /// <summary>
        /// exclusive ownership of context is transfered to the callee
        /// </summary>
        /// <param name="context"></param>
        private void WaitForData(ReceiveContext context)
        {
            // large critical section to ensure started state does not change
            lock (_shared.Lock)
            {
                if (!_shared.Started)
                {
                    return;
                }
                do
                {
                    try
                    {
                        ReceiveContext.Message message = context.BeginWrite();
                        _ = _shared.ServerSocket.BeginReceiveFrom(message.data, 0, message.data.Length, SocketFlags.None, ref message.fromEndPoint, _socketDataCallback, context);
                        break;
                    }
                    catch (SocketException se)
                    {
                        if (!HandleSocketException(se))
                        {
                            LogManager.LogError("DCS-BIOS UDP listener unable to recover from socket reset, no longer receiving data.");
                            break;
                        }
                        // else retry forever
                    }
                } while (true);
            }
        }

        /// <summary>
        /// socket thread pool callback
        /// </summary>
        /// <param name="asyncResult"></param>
        private void OnDataReceived(IAsyncResult asyncResult)
        {
            ReceiveContext owned = null;
            lock (_shared.Lock)
            {
                if (!_shared.Started)
                {
                    // ignore, we shut down since requesting receive
                    return;
                }
                Socket socket = _shared.ServerSocket;
                ReceiveContext context = asyncResult.AsyncState as ReceiveContext;
                try
                {
                    ReceiveContext.Message message = context.ContinueWrite(0);
                    message.bytesReceived = _shared.ServerSocket.EndReceiveFrom(asyncResult, ref message.fromEndPoint);
                    context.EndWrite();
                }
                catch (SocketException se)
                {
                    // NOTE: EndReceiveFrom isn't retriable, because the receive won't we valid after we reset socket
                    if (!HandleSocketException(se))
                    {
                        // no new receive attempt
                        return;
                    }

                    // recovered with probably a new socket
                    socket = _shared.ServerSocket;
                }
                // drain the socket, as much as allowed, to share the context switch to main
                while ((socket.Available > 0) && (context.Length < context.Capacity))
                {
                    ReceiveContext.Message message = context.BeginWrite();
                    SocketError errorCode = default;
                    try
                    {
                        message.bytesReceived = socket.Receive(message.data, 0, message.data.Length, SocketFlags.None, out errorCode);
                    }
                    catch (SocketException se)
                    {
                        if (HandleSocketException(se))
                        {
                            // recovered with probably a new socket
                            socket = _shared.ServerSocket;
                        } else {
                            // dead, stop trying to drain
                            break;
                        }
                    }
                    // REVISIT: this is a little bit ugly, but safe
                    if ((errorCode == SocketError.Success) && (message.bytesReceived > 0))
                    {
                        context.EndWrite();
                    }
                }
                owned = context;
            }

            // NOTE: owned must not be null here, so crash if it is.  
            // it could be empty if all we did this iteration is throw and reset the socket 
            if (owned.Length > 0)
            {
                // pass ownership to main thread, process synchronously
                _dispatcher.Invoke(new Action(() => this.DispatchReceived(owned)), System.Windows.Threading.DispatcherPriority.Send);
            }

            // start next receive
            WaitForData(_shared.FetchReceiveContext() ?? new ReceiveContext());
        }

        private static void ParseReceived(ReceiveContext owned)
        {
            for(int messageIndex=0; messageIndex<owned.Length; messageIndex++)
            {
                ReceiveContext.Message message = owned.Read(messageIndex);
            }
        }

        private void DispatchReceived(ReceiveContext owned)
        {
            if (owned.Length > 1)
            {
                LogManager.LogDebug($"received {owned.Length} UDP messages in batch");
            }

            for (int messageIndex = 0; messageIndex < owned.Length; messageIndex++)
            {
                ReceiveContext.Message message = owned.Read(messageIndex);
                _receiver.HandleMessage(message.data, message.bytesReceived);
            }
            _shared.ReturnReceiveContext(owned);
        }

        private bool HandleSocketException(SocketException se)
        {
            if ((SocketError)se.ErrorCode == SocketError.ConnectionReset)
            {
                CloseSocket();
                OpenSocket();
                return true;
            }
            else
            {
                LogManager.LogError("DCS-BIOS UDP listener threw unhandled exception handling socket reset", se);
                return false;
            }
        }

        private void OpenSocket()
        {
            IPAddress bindAddress = IPAddress.Any;
            EndPoint bindEndPoint = new IPEndPoint(bindAddress, Port);
            Socket socket = new Socket(AddressFamily.InterNetwork,
                                      SocketType.Dgram,
                                      ProtocolType.Udp);

            socket.ExclusiveAddressUse = false;
            socket.Bind(bindEndPoint);

            // XXX configurable
            IPAddress multicastAddress = IPAddress.Parse("239.255.50.10");
            MulticastOption multicastOption = new MulticastOption(multicastAddress, bindAddress);
            socket.SetSocketOption(SocketOptionLevel.IP, SocketOptionName.AddMembership, multicastOption);

            lock (_shared.Lock)
            {
                _shared.ServerSocket = socket;
            }
        }

        private void CloseSocket()
        {
            Socket socket = null;
            lock (_shared.Lock)
            {
                socket = _shared.ServerSocket;
                _shared.ServerSocket = null;
            }
            // shutdown without holding lock
            socket?.Close();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <exception cref="System.Net.Sockets.SocketException">on failure to create and bind socket</exception>
        public void Start()
        {
            OpenSocket();
            WaitForData(new ReceiveContext());
        }

        public void Stop()
        {
            CloseSocket();
            // NOTE: any currently pending receive will be ignored, because we are not "Started" any longer
        }
    }
}