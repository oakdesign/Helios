# Creating a New Aircraft
This falls into two different activities, the first is ***Interface*** which defines all of the codes coming over the UDP socket to Control Center, and also the codes that Control Center's profile will send back to DCS over the network.  The second activity is by far the most complex & time consuming, and this is creating all of the visual ***gauges*** and ***controls*** necessary for the profile to act like a virtual cockpit. 
Best practise is for the gauges and controls to be created with knowledge of the interface they should be bound to, so they can automatically bind to that interface without manual binding being necessary.  Only newer gauges and controls have this capability.
## The Interface
Finding the correct and complete codes to define the interface is not easy, and for certain information that needs to be forcabily extracted from DCS, these codes need to be created.
## The Visual Components
### Images & Templates
Images should be created as **resources** in a project that creates a DLL to allow organisational benefits for the user and developer.  Templates should also be added to the same project however these should be defined as **content** 
### Gauges & Controls
These can be of all levels of complexity, from a simple device containing two buttons and an indicator, to a complex HSI or UFC.
