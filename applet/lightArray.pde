import themidibus.*; //Import the library

MidiBus lightArray; // The MidiBus

void setup() {
	size(400,400);
	background(0);

	MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

	// Either you can
	//                   Parent In Out
	//                     |    |  |
	//myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

	// or you can ...
	//                   Parent         In                   Out
	//                     |            |                     |
	//myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

	// or for testing you could ...
	//                 Parent  In        Out
	//                   |     |          |
	lightArray = new MidiBus(this, -1, "Bus 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
        int[] light = new int[12];
}

void draw() {
        for (int i=0; i<128; i++)
        {
          
            for (int j=0; j<13; j++)
            {
    	    lightArray.sendControllerChange(0, j, i);
                
            }
            delay(50);
            
        }
        for (int i=127; i>=0; i--)
        {
            for (int j=0; j<13; j++)
            {
    	    lightArray.sendControllerChange(0, j, i);
                
            }
            delay(50);
        }
        
}

