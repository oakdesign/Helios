#Notes on Auto Binding#

The "device" and the "name" from then interface AddFunction need to match exactly with the InterfaceDeviceName and the InterfaceElementName used on the CompositeVisual object that is defined in your device.
Within the code for the device component, the "name" used on the Addcontrol needs to be unique, and the "Name" for the control should have the base class name for the device component prepended (with a trailing underscore).

[HeliosControl("Helios.AV8B.SMC", "Stores Management Panel", "AV-8B", typeof(AV8BDeviceRenderer))]
The HeliosControlAttribute "name" is not used in the autobinding.

Make sure that you are not adding actions or triggers in the device component code.  These are added by CompositeVisual.  Likewise do not do a child add in the device component code.


##Example:##

in AV8BInterface.cs
		AddFunction(new PushButton(this, SMC, "3407", "407", "Stores Management", "Station 1 Button"));

in SMC.cs (the code for the component device)
        public SMC_AV8B()
            : base("SMC", new Size(1231, 470))

		AddButton("Station 1", 383, 392, new Size(50, 50), "Station 1 Button");	
		
		private void AddButton(string name, double x, double y, Size size, bool horizontal, bool altImage, string interfaceElementName)
        {
            Point pos = new Point(x, y);
            PushButton button = AddButton(
                    name: "Station 1",
                    posn: pos,
                    size: size,
                    image: "{Helios}/Images/Buttons/tactile-dark-round.png",
                    pushedImage: "{Helios}/Images/Buttons/tactile-dark-round-in.png",
                    buttonText: "",
                    interfaceDeviceName: "Stores Management",
                    interfaceElementName: "Station 1 Button",
                    fromCenter: false
                    );
            button.Name = "SMC_" + "Station 1";
        }

##Problem Solving:##

Setting a stop in CompositeVisual.cs around line 231 "ConfigManager.LogManager.LogError("Cannot find child " + defaultBinding.ChildName);" gives you a view of what is not binding.
		
Correct binding values can be determined by setting a breackpoint in HeliosBinding.cs around line 49 and then doing a manual binding.		
			
