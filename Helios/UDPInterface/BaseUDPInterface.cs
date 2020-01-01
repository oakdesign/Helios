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

namespace GadrocsWorkshop.Helios.UDPInterface
{
    using GadrocsWorkshop.Helios.ProfileAwareInterface;
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using System.Net;
    using System.Net.Sockets;
    using System.Text;
    using System.Timers;


    public class BaseUDPInterface : HeliosInterface
    {
        // const during lifetime, no access control required
        private readonly AsyncCallback _socketDataCallback;
        private static readonly System.Text.Encoding _iso_8859_1 = System.Text.Encoding.GetEncoding("iso-8859-1");  // This is the locale of the lua exports program

        // event handlers are thread safe, no access control required
        /// <summary>
        /// event to notify potentially other threads that the client connection has changed
        /// </summary>
        public event EventHandler<ProfileAwareInterface.ClientChange> ClientChanged;

        /// <summary>
        /// accessed only by main thread
        /// </summary>
        private class MainThreadAccess
        {
            static private int _id = System.Threading.Thread.CurrentThread.ManagedThreadId;

            private int _port = 9089;
            private NetworkFunctionCollection _functions = new NetworkFunctionCollection();
            private Dictionary<string, NetworkFunction> _functionsById = new Dictionary<string, NetworkFunction>();

            private EndPoint _client = null;
            private string _clientID = ClientChange.NO_CLIENT;

            private HeliosTrigger _connectedTrigger;
            private HeliosTrigger _disconnectedTrigger;
            private HeliosTrigger _profileLoadedTrigger;

            private Timer _startuptimer;

            // XXX to be removed
            private string _alternatename = "";

            public int Port
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _port;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _port = value;
                }
            }

            public NetworkFunctionCollection Functions
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _functions;
                }
            }

            public Dictionary<string, NetworkFunction> FunctionsById
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _functionsById;
                }
            }

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

            public string ClientID
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _clientID;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _clientID = value;
                }
            }

            public HeliosTrigger ConnectedTrigger
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _connectedTrigger;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _connectedTrigger = value;
                }
            }

            public HeliosTrigger DisconnectedTrigger
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _disconnectedTrigger;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _disconnectedTrigger = value;
                }
            }

            public HeliosTrigger ProfileLoadedTrigger
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _profileLoadedTrigger;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _profileLoadedTrigger = value;
                }
            }

            public Timer StartupTimer
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _startuptimer;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _startuptimer = value;
                }
            }

            public string Alternatename
            {
                get
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    return _alternatename;
                }
                set
                {
                    Debug.Assert(System.Threading.Thread.CurrentThread.ManagedThreadId == _id);
                    _alternatename = value;
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

        private class SendContext
        {
            // buffer for datagram to be sent
            // NOTE: send size is entire buffer for now, since we don't reuse these
            public byte[] dataBuffer = null;
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

                // tokens parsed out on socket thread pool to avoid loading main thread
                public string[] tokens = new string[1024];
                public int tokenCount = 0;

                public void Clear()
                {
                    fromEndPoint = new IPEndPoint(IPAddress.Any, 0);
                    bytesReceived = 0;
                    tokenCount = 0;
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

        public BaseUDPInterface(string name)
            : base(name)
        {
            // const
            _socketDataCallback = new AsyncCallback(OnDataReceived);

            _main.ConnectedTrigger = new HeliosTrigger(this, "", "", "Connected", "Fired on DCS connect.");
            Triggers.Add(_main.ConnectedTrigger);

            _main.DisconnectedTrigger = new HeliosTrigger(this, "", "", "Disconnected", "Fired on DCS disconnect.");
            Triggers.Add(_main.DisconnectedTrigger);

            _main.ProfileLoadedTrigger = new HeliosTrigger(this, "", "", "Profile Delay Start", "Fired 10 seconds after DCS profile is started.");
            Triggers.Add(_main.ProfileLoadedTrigger);

            _main.Functions.CollectionChanged += new System.Collections.Specialized.NotifyCollectionChangedEventHandler(Functions_CollectionChanged);
        }

        void Functions_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            if (e.Action == System.Collections.Specialized.NotifyCollectionChangedAction.Remove ||
                e.Action == System.Collections.Specialized.NotifyCollectionChangedAction.Replace)
            {
                foreach (NetworkFunction function in e.OldItems)
                {
                    Triggers.RemoveSlave(function.Triggers);
                    Actions.RemoveSlave(function.Actions);
                    Values.RemoveSlave(function.Values);

                    foreach (ExportDataElement element in function.GetDataElements())
                    {
                        if (_main.FunctionsById.ContainsKey(element.ID))
                        {
                            _main.FunctionsById.Remove(element.ID);
                        }
                    }
                }
            }
            if (e.Action == System.Collections.Specialized.NotifyCollectionChangedAction.Add ||
                e.Action == System.Collections.Specialized.NotifyCollectionChangedAction.Replace)
            {
                foreach (NetworkFunction function in e.NewItems)
                {
                    Triggers.AddSlave(function.Triggers);
                    Actions.AddSlave(function.Actions);
                    Values.AddSlave(function.Values);

                    foreach (ExportDataElement element in function.GetDataElements())
                    {
                        if (!_main.FunctionsById.ContainsKey(element.ID))
                        {
                            _main.FunctionsById.Add(element.ID, function);
                        }
                        else
                        {
                            ConfigManager.LogManager.LogError("UDP interface created duplicate function ID. (Interface=\"" + Name + "\", Function ID=\"" + element.ID + "\")");
                        }
                    }
                }
            }
        }

        public int Port
        {
            get
            {
                return _main.Port;
            }
            set
            {
                if (!_main.Port.Equals(value))
                {
                    int oldValue = _main.Port;
                    _main.Port = value;
                    OnPropertyChanged("Port", oldValue, value, false);
                }
            }
        }

        public string AlternateName
        {
            get
            {
                return _main.Alternatename;
            }
            set
            {
                if (!_main.Alternatename.Equals(value))
                {
                    string oldValue = _main.Alternatename;
                    _main.Alternatename = value;
                    OnPropertyChanged("AlternateName", oldValue, value, false);
                }
            }
        }

        public NetworkFunctionCollection Functions
        {
            get
            {
                return _main.Functions;
            }
        }

        protected override void OnProfileChanged(HeliosProfile oldProfile)
        {
            base.OnProfileChanged(oldProfile);
            if (oldProfile != null)
            {
                oldProfile.ProfileStarted -= new EventHandler(Profile_ProfileStarted);
                oldProfile.ProfileStopped -= new EventHandler(Profile_ProfileStopped);
            }

            if (Profile != null)
            {
                Profile.ProfileStarted += new EventHandler(Profile_ProfileStarted);
                Profile.ProfileStopped += new EventHandler(Profile_ProfileStopped);
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

                ConfigManager.LogManager.LogDebug("UDP interface waiting for socket data. (Interface=\"" + Name + "\")");
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
                            ConfigManager.LogManager.LogError("UDP interface unable to recover from socket reset, no longer receiving data. (Interface=\"" + Name + "\")");
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
                // offload parsing from main thread to socket thread pool, without lock held
                ParseReceived(owned);

                // pass ownership to main thread, process synchronously
                Dispatcher.Invoke(new Action(() => this.DispatchReceived(owned)), System.Windows.Threading.DispatcherPriority.Send);
            }

            // start next receive
            WaitForData(_shared.FetchReceiveContext() ?? new ReceiveContext());
        }

        private static void ParseReceived(ReceiveContext owned)
        {
            for(int messageIndex=0; messageIndex<owned.Length; messageIndex++)
            {
                ReceiveContext.Message message = owned.Read(messageIndex);
                message.tokenCount = 0;
                int parseCount = message.bytesReceived - 1;
                int offset = 8;
                for (int scan = 9; scan < parseCount; scan++)
                {
                    if (message.data[scan] == 0x3a || message.data[scan] == 0x3d)
                    {
                        int size = scan - offset - 1;
                        message.tokens[message.tokenCount++] = _iso_8859_1.GetString(message.data, offset + 1, size);
                        offset = scan;
                    }
                }
                message.tokens[message.tokenCount++] = _iso_8859_1.GetString(message.data, offset + 1, parseCount - offset - 1);
                if (message.tokenCount % 1 > 0)
                {
                    // don't allow odd number of tokens because a lot of the parsing code is unsafe
                    message.tokenCount--;
                }
            }
        }

        private void DispatchReceived(ReceiveContext owned)
        {
            if (owned.Length > 1)
            {
                ConfigManager.LogManager.LogInfo($"received {owned.Length} UDP messages in batch");
            }

            // REVISIT: could skip ahead if this batch contains a client change
            for (int messageIndex = 0; messageIndex < owned.Length; messageIndex++)
            {
                ReceiveContext.Message message = owned.Read(messageIndex);
                // store address and port, since we need it for outgoing messages
                _main.Client = message.fromEndPoint;
                if (message.bytesReceived < 13)
                {
                    HandleShortMessage(message.data, message.bytesReceived);
                    continue;
                }

                // Don't create the extra strings if we don't need to
                if (ConfigManager.LogManager.LogLevel == LogLevel.Debug)
                {
                    ConfigManager.LogManager.LogDebug("UDP Interface received packet. (Interface=\"" + Name + "\", Packet=\"" + _iso_8859_1.GetString(message.data, 0, message.bytesReceived) + "\")");
                }

                // handle client restart or change in client
                String packetClientID = _iso_8859_1.GetString(message.data, 0, 8);
                if (!_main.ClientID.Equals(packetClientID))
                { 
                    ConfigManager.LogManager.LogInfo("UDP interface new client connected, sending data reset command. (Interface=\"" + Name + "\", Client=\"" + _main.Client.ToString() + "\", Client ID=\"" + packetClientID + "\")");
                    _main.ConnectedTrigger.FireTrigger(BindingValue.Empty);
                    string fromValue = _main.ClientID ?? ProfileAwareInterface.ClientChange.NO_CLIENT;
                    _main.ClientID = packetClientID;
                    ClientChanged?.Invoke(this, new ProfileAwareInterface.ClientChange() { FromOpaqueHandle = fromValue, ToOpaqueHandle = packetClientID });
                    SendData("R");
                }

                for (int tokenIndex = 0; tokenIndex < message.tokenCount; tokenIndex += 2)
                {
                    if (_main.FunctionsById.ContainsKey(message.tokens[tokenIndex]))
                    {
                        NetworkFunction function = _main.FunctionsById[message.tokens[tokenIndex]];
                        function.ProcessNetworkData(message.tokens[tokenIndex], message.tokens[tokenIndex + 1]);
                    }
                    else
                    {
                        ConfigManager.LogManager.LogWarning("UDP interface received data for missing function. (Key=\"" + message.tokens[tokenIndex] + "\")");
                    }
                }
            }

            _shared.ReturnReceiveContext(owned);
        }


        private void HandleShortMessage(byte[] dataBuffer, int receivedByteCount)
        {
            string RecString = _iso_8859_1.GetString(dataBuffer, 0, receivedByteCount);
            // Special case for legacy Disconnect
            if (RecString.Contains("DISCONNECT"))
            {
                ConfigManager.LogManager.LogInfo("UDP interface disconnect from Lua.");
                _main.DisconnectedTrigger.FireTrigger(BindingValue.Empty);
                return;
            }
            ConfigManager.LogManager.LogWarning("UDP interface short packet received. (Interface=\"" + Name + "\")");
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
                ConfigManager.LogManager.LogError("UDP interface threw unhandled exception handling socket reset. (Interface=\"" + Name + "\")", se);
                return false;
            }
        }

        public void SendData(string data)
        {
            try
            {
                if ((_main.Client != null) && (_main.ClientID != ClientChange.NO_CLIENT))
                {
                    ConfigManager.LogManager.LogDebug("UDP interface sending data. (Interface=\"" + Name + "\", Data=\"" + data + "\")");
                    SendContext context = new SendContext();
                    context.dataBuffer = _iso_8859_1.GetBytes(data + "\n");
                    _shared.ServerSocket.BeginSendTo(context.dataBuffer, 0, context.dataBuffer.Length, SocketFlags.None, _main.Client, OnDataSent, context);
                }
            }
            catch (SocketException se)
            {
                HandleSocketException(se);
            }
            catch (Exception e)
            {
                ConfigManager.LogManager.LogError("UDP interface threw exception sending data. (Interface=\"" + Name + "\")", e);
            }
        }

        /// <summary>
        /// socket thread pool callback
        /// </summary>
        /// <param name="asyncResult"></param>
        private void OnDataSent(IAsyncResult asyncResult)
        {
            SendContext context = asyncResult.AsyncState as SendContext;
            // currently we don't need to do anything on send
            // we are only using the async send API in order to match async reads and writes,
            // because we don't want to be an atypical user of the API
        }

        void Profile_ProfileStopped(object sender, EventArgs e)
        {
            CloseSocket();
            if (_main.StartupTimer != null)
                _main.StartupTimer.Stop();


            // hook for descendants
            OnProfileStopped();
        }


        private void OpenSocket()
        {
            EndPoint bindEndPoint = new IPEndPoint(IPAddress.Any, Port);
            Socket socket = new Socket(AddressFamily.InterNetwork,
                                      SocketType.Dgram,
                                      ProtocolType.Udp);
            socket.ExclusiveAddressUse = false;
            // https://github.com/BlueFinBima/Helios/issues/140
            socket.Bind(bindEndPoint);

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

        void Profile_ProfileStarted(object sender, EventArgs e)
        {
            ConfigManager.LogManager.LogDebug("UDP interface starting. (Interface=\"" + Name + "\")");
            try
            {
                _main.Client = new IPEndPoint(IPAddress.Any, 0);
                _main.ClientID = ClientChange.NO_CLIENT;
                OpenSocket();

                // 10 seconds for Delayed Startup
                Timer timer = new Timer(10000);
                timer.AutoReset = false; // only once
                timer.Elapsed += OnStartupTimer;
                _main.StartupTimer = timer;
                timer.Start();
                ConfigManager.LogManager.LogDebug("Startup timer started.");

                WaitForData(new ReceiveContext());

                // hook for descendants
                OnProfileStarted();
            }
            catch (System.Net.Sockets.SocketException se)
            {
                ConfigManager.LogManager.LogError("UDP interface startup error. (Interface=\"" + Name + "\")");
                ConfigManager.LogManager.LogError("UDP Socket Exception on Profile Start.  " + se.Message, se);
            }
        }

        /// <summary>
        /// timer thread callback
        /// </summary>
        /// <param name="source"></param>
        /// <param name="e"></param>
        private void OnStartupTimer(Object source, System.Timers.ElapsedEventArgs e)
        {
            // sync notify
            Dispatcher.Invoke(new Action(OnDelayedStartup));
        }

        private void OnDelayedStartup()
        { 
            ConfigManager.LogManager.LogInfo("Startup Delay timer triggered.");
            _main.ProfileLoadedTrigger.FireTrigger(BindingValue.Empty);
        }

        public override void ReadXml(System.Xml.XmlReader reader)
        {
            // No Op
        }

        public override void WriteXml(System.Xml.XmlWriter writer)
        {
            // No Op
        }

        protected void AddFunction(NetworkFunction function)
        {
            Functions.Add(function);
        }

        protected void AddFunction(NetworkFunction function, bool debug)
        {
            function.IsDebugMode = debug;
            Functions.Add(function);
        }

        public override void Reset()
        {
            base.Reset();
            foreach (NetworkFunction function in Functions)
            {
                function.Reset();
            }
            SendData("R");
        }

        public bool CanSend
        {
            get
            {
                return _shared.Started;
            }
        }

        protected virtual void OnProfileStarted()
        {
            // no code in base implementation
        }

        protected virtual void OnProfileStopped()
        {
            // no code in base implementation
        }
    }
}