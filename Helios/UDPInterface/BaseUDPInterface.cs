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
            private string _clientID = "";

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
            // no synchronization required, stable while socket threads are active
            public Socket _socket = null;

            // lock on all the other fields, public access ok so we can lock larger
            // sections of code and rely on re-entrant locking to avoid deadlock
            public object Lock { get; } = new object();

            // fields synchronized via properties
            private bool _started = false;

            public bool Started
            {
                get
                {
                    lock (Lock)
                    {
                        return _started;
                    }
                }
                set
                {
                    lock (Lock)
                    {
                        _started = value;
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
        }

        private class SendContext
        {
            // buffer for datagram to be sent
            // NOTE: send size is entire buffer for now, since we don't reuse these
            public byte[] dataBuffer = null;
        }

        /// <summary>
        /// owned by the socket thread pool thread that is currently processing the receive operation, then
        /// ownership is handed off to main thread for final processing.  object is not reused
        /// </summary>
        private class ReceiveContext
        {
            // buffer for datagram received
            public byte[] dataBuffer = new byte[2048];

            // fill level of buffer
            public int bytesReceived = 0;

            // source of datagram received
            public EndPoint fromEndPoint = new IPEndPoint(IPAddress.Any, 0);

            // tokens parsed out on socket thread pool to avoid loading main thread
            public string[] tokens = new string[1024];
            public int tokenCount = 0;
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
                        _shared.ServerSocket.BeginReceiveFrom(context.dataBuffer, 0, context.dataBuffer.Length, SocketFlags.None, ref context.fromEndPoint, _socketDataCallback, context);
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
                ReceiveContext context = asyncResult.AsyncState as ReceiveContext;
                try
                {
                    context.bytesReceived = _shared.ServerSocket.EndReceiveFrom(asyncResult, ref context.fromEndPoint);
                    owned = context;
                }
                catch (SocketException se)
                {
                    // NOTE: EndReceiveFrom isn't retriable, because the receive won't we valid after we reset socket
                    if (!HandleSocketException(se))
                    {
                        // no new receive attempt
                        return;
                    }
                }
            }

            if (owned != null)
            {
                // offload parsing from main thread to socket thread pool
                ParseReceived(owned);

                // pass ownership to main thread
                Dispatcher.Invoke(new Action(() => this.DispatchReceived(owned)), System.Windows.Threading.DispatcherPriority.Send);
            }

            // start next receive
            // REVISIT: could use a pool of context objects if we want to do some of the memory management ourselves
            WaitForData(new ReceiveContext());
        }

        private static void ParseReceived(ReceiveContext owned)
        {
            owned.tokenCount = 0;
            int parseCount = owned.bytesReceived - 1;
            int lastIndex = 8;
            for (int i = 9; i < parseCount; i++)
            {
                if (owned.dataBuffer[i] == 0x3a || owned.dataBuffer[i] == 0x3d)
                {
                    int size = i - lastIndex - 1;
                    owned.tokens[owned.tokenCount++] = _iso_8859_1.GetString(owned.dataBuffer, lastIndex + 1, size);
                    lastIndex = i;
                }
            }
            owned.tokens[owned.tokenCount++] = _iso_8859_1.GetString(owned.dataBuffer, lastIndex + 1, parseCount - lastIndex - 1);
            if (owned.tokenCount % 1 > 0)
            {
                // don't allow odd number of tokens because a lot of the parsing code is unsafe
                owned.tokenCount--;
            }
        }

        private void DispatchReceived(ReceiveContext context)
        {
            // store address and port, since we need it for outgoing messages
            _main.Client = context.fromEndPoint;
            if (context.bytesReceived < 13)
            {
                HandleShortMessage(context.dataBuffer, context.bytesReceived);
                return;
            }

            // Don't create the extra strings if we don't need to
            if (ConfigManager.LogManager.LogLevel == LogLevel.Debug)
            {
                ConfigManager.LogManager.LogDebug("UDP Interface received packet. (Interface=\"" + Name + "\", Packet=\"" + _iso_8859_1.GetString(context.dataBuffer, 0, context.bytesReceived) + "\")");
            }

            // handle client restart or change in client
            String packetClientID = _iso_8859_1.GetString(context.dataBuffer, 0, 8);
            if (!_main.ClientID.Equals(packetClientID))
            {
                ConfigManager.LogManager.LogInfo("UDP interface new client connected, sending data reset command. (Interface=\"" + Name + "\", Client=\"" + _main.Client.ToString() + "\", Client ID=\"" + packetClientID + "\")");
                _main.ConnectedTrigger.FireTrigger(BindingValue.Empty);
                _main.ClientID = packetClientID;
                SendData("R");
            }

            for (int i = 0; i < context.tokenCount; i += 2)
            {
                if (_main.FunctionsById.ContainsKey(context.tokens[i]))
                {
                    NetworkFunction function = _main.FunctionsById[context.tokens[i]];
                    function.ProcessNetworkData(context.tokens[i], context.tokens[i + 1]);
                }
                else
                {
                    ConfigManager.LogManager.LogWarning("UDP interface received data for missing function. (Key=\"" + context.tokens[i] + "\")");
                }
            }
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
                if (_main.Client != null && _main.ClientID.Length > 0)
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
                _shared.Started = true;
            }
        }

        private void CloseSocket()
        {
            Socket socket = null;
            lock (_shared.Lock)
            {
                _shared.Started = false;
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
                _main.ClientID = "";
                OpenSocket();

                // 10 seconds for Delayed Startup
                Timer timer = new Timer(10000);
                timer.AutoReset = false; // only once
                timer.Elapsed += OnStartupTimer;
                timer.Start();
                _main.StartupTimer = timer;

                ConfigManager.LogManager.LogInfo("Startup timer started.");
                WaitForData(new ReceiveContext());
            }
            catch (System.Net.Sockets.SocketException se)
            {
                ConfigManager.LogManager.LogError("UDP interface startup error. (Interface=\"" + Name + "\")");
                ConfigManager.LogManager.LogError("UDP Socket Exception on Profile Start.  " + se.Message, se);
            }

        }

        private void OnStartupTimer(Object source, System.Timers.ElapsedEventArgs e)
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
    }
}