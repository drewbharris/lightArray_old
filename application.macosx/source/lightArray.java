import processing.core.*; 
import processing.xml.*; 

import themidibus.*; 
import controlP5.*; 
import processing.opengl.*; 

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


int[] softLight = new int[12];


MidiBus lightArray; // The MidiBus
ControlP5 controlP5;
SimpleThread MIDIThread;

public void setup() {
	size(800,600, OPENGL);
	background(0);
        smooth();
        // set up GUI
        controlP5 = new ControlP5(this);
        Radio programs = controlP5.addRadio("programs",50,160);
        programs.deactivateAll();
        programs.add("on", 1);
        programs.add("off", 2);
        programs.add("oscillate", 0);
        programs.add("random", 3);
        
        // set up oscillator
        MIDIThread = new SimpleThread("midi");
        MIDIThread.start();
        

	MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
	lightArray = new MidiBus(this, -1, "Bus 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
        int[] light = new int[12];
        for (int k=0; k<11; k++)
        {
          softLight[k] = 0;
        }
}

public void draw() {
  stroke(255);
  for (int l=0; l<12; l++) {
    fill(softLight[l]);
    rect(10+(l*40), 10, 30, 30);
  }
        
}

public void programs(int theID) {
  switch(theID) {
    case(0):
      MIDIThread.mode(0); // oscillation mode
      break;
    case(1):
      MIDIThread.mode(1); // on mode
      break;  
    case(2):
      MIDIThread.mode(2); // off mode
      break;  
    case(3):
      MIDIThread.mode(3); // random mode
      break;  
  }
  println("a radio event.");
}

public void pauseProgram() {
if (MIDIThread.running == true) {
      MIDIThread.pause();
    }
}

public void unpauseProgram() {
if (MIDIThread.running == false) {
      MIDIThread.unpause();
    }
}


class SimpleThread extends Thread {
 
  boolean running;           // Is the thread running?  Yes or no?
  String id;                 // Thread name
  int mode=1000;
  boolean paused = false;
 
  // Constructor, create the thread
  // It is not running by default
  SimpleThread (String s) {
    running = false;
    id = s;
  }
 
  // Overriding "start()"
  public void start () {
    running = true;
    super.start();
  }
  
  public void pause () {
    paused = true;
  }
  
  public void unpause () {
    paused = false;
  }
  
  public void mode (int m) {
    mode = m;
  }
 
  public void run () {
    while (running) {
      if (!paused)
      {
        if (mode == 0) {
            for (double i=0; i<3.14f; i=i+0.1f)
                {
                  for (int j=36; j<48; j++)
                  {
                    double osc = Math.sin(i)*127;
                    int value = (int)osc;
                    softLight[j-36] = value*2;
                    lightArray.sendControllerChange(0, j, value); 
                  }
                  delay(30);
                  
                }
                for (double i=3.14f; i>=0; i=i-0.1f)
                {
                    for (int j=36; j<48; j++)
                    {
                      double osc = Math.sin(i)*127;
                      int value = (int)osc;
              	    lightArray.sendControllerChange(0, j, value);   
                    }
                    delay(30);
                }
          }
        else if (mode == 1) {
              for (int j=36; j<48; j++)
              {
                lightArray.sendControllerChange(0, j, 127); 
                softLight[j-36] = 255;
              }
              mode = 1000;
              }
        
             
        else if (mode == 2) {
          for (int j=36; j<48; j++)
          {
            lightArray.sendControllerChange(0, j, 0); 
            softLight[j-36] = 0;
          }
          mode = 1000;
          }
          
        else if (mode == 3) {
          int controller = (int)random(12)+36;
          int randomValue = (int)random(127);
          softLight[controller-36] = randomValue*2;
    	  lightArray.sendControllerChange(0, controller, (int)random(127));   
          delay(30);
        }
    }
    }
      System.out.println(id + " thread is done!");
    }
   
   
    // Our method that quits the thread
    public void quit() {
      running = false;  // Setting running to false ends the loop in run()
      //interrupt();
    }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "lightArray" });
  }
}
