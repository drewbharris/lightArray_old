import processing.core.*; 
import processing.xml.*; 

import themidibus.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class lightArray extends PApplet {

 //Import the library

MidiBus lightArray; // The MidiBus

public void setup() {
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

public void draw() {
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

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "lightArray" });
  }
}
