using net.derammo.HelBIOS.SchemaVersion1;

namespace net.derammo.HelBIOS
{
    internal abstract class DataReceiver : ExportProtocol.IDataReceiver
    {
        protected ItemDefinition.Output _output;

        public int Address => _output.address;
        
        public int Size { get; protected set; }
        
        public virtual bool NeedsUpdateNotification => false;

        public DataReceiver(ItemDefinition.Output output)
        {
            _output = output;
        }

        public virtual void NotifyUpdate(byte[] buffer)
        {
            // no op
        }

        public abstract void ReceiveData(byte[] buffer, int sourceOffset, int size, int targetOffset);

        public abstract void Reset(byte[] buffer);
    }
}