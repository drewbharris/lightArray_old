import themidibus.*; //Import the library
import controlP5.*;
import processing.opengl.*;
int[] softLight = new int[12];
int midiIn = -1;
int midiOut = -1;
Textlabel midioutlabel;
Textlabel midiinlabel;
Textlabel programlabel;
Textlabel heading;
//test


MidiBus lightArray; // The MidiBus
ControlP5 controlP5;
SimpleThread MIDIThread;

void setup() {
	size(490,260, OPENGL);
	background(0);
        smooth();
        String[] outputs = MidiBus.availableOutputs();
        String[] inputs = MidiBus.availableInputs();
        
        // set up GUI
        controlP5 = new ControlP5(this);
        Radio programs = controlP5.addRadio("programs",300,80);
        programs.deactivateAll();
        programs.add("on", 1);
        programs.add("off", 2);
        programs.add("oscillate", 0);
        programs.add("fade", 4);
        programs.add("random", 3);
        
        Radio midioutdevices = controlP5.addRadio("midioutdevices",100,80);
        midioutdevices.deactivateAll();
        for (int i=0; i<(outputs.length-1); i++) {
          midioutdevices.add(outputs[i], i);
        }
        
        Radio midiindevices = controlP5.addRadio("midiindevices",0,80);
        midiindevices.deactivateAll();
        for (int i=0; i<(inputs.length-1); i++) {
          midiindevices.add(inputs[i], i);
        }
        
        // set up oscillator
        MIDIThread = new SimpleThread("midi");
        MIDIThread.start();

	
        int[] light = new int[12];
        for (int k=0; k<11; k++)
        {
          softLight[k] = 0;
        }
        
        midioutlabel = controlP5.addTextlabel("midioutlabel", "MIDI Outputs", 100, 65);
        midiinlabel = controlP5.addTextlabel("midiinlabel", "MIDI Inputs", 0, 65);
        programlabel = controlP5.addTextlabel("programlabel", "Programs", 300, 65);
        heading = controlP5.addTextlabel("heading", "grmnygrmny.lightarray", 200, 20);
}

void draw() {
  stroke(255);
  for (int l=0; l<12; l++) {
    fill(softLight[l]);
    rect(10+(l*40), 200, 30, 30);
  }
  midioutlabel.draw(this);
  midiinlabel.draw(this);
  programlabel.draw(this);
        
}



void programs(int theID) {
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
    case(4):
      MIDIThread.mode(4); // random mode
      break; 
  }
  println("a radio event.");
}

void midiindevices(int theID) {
  midiIn = theID;
  lightArray = new MidiBus(this, midiIn, midiOut); 
}


void midioutdevices(int theID) {
  midiOut = theID;
  lightArray = new MidiBus(this, midiIn, midiOut); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

void pauseProgram() {
if (MIDIThread.running == true) {
      MIDIThread.pause();
    }
}

void unpauseProgram() {
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
  void start () {
    running = true;
    super.start();
  }
  
  void pause () {
    paused = true;
  }
  
  void unpause () {
    paused = false;
  }
  
  void mode (int m) {
    mode = m;
  }
 
 
   void MIDILight (int controller, int value) {
     softLight[controller] = value*2;
     lightArray.sendControllerChange(0, controller+36, value);
   }
   
   
  void run () {
    while (running) {
      if (!paused)
      {
        if (mode == 0) {
            for (double i=0; i<3.14; i=i+0.1)
                {
                  for (int j=0; j<12; j++)
                  {
                    double osc = Math.sin(i)*127;
                    int value = (int)osc;
                    MIDILight(j, value);
                  }
                  delay(30);
                  
                }
                for (double i=3.14; i>=0; i=i-0.1)
                {
                    for (int j=0; j<12; j++)
                    {
                      double osc = Math.sin(i)*127;
                      int value = (int)osc;
              	    MIDILight(j, value);
                    }
                    delay(30);
                }
          }
        else if (mode == 1) {
              for (int j=0; j<12; j++)
              {
                MIDILight(j, 127);
              }
              mode = 1000;
              }
        
             
        else if (mode == 2) {
          for (int j=0; j<12; j++)
          {
            MIDILight(j, 0);
          }
          mode = 1000;
          }
          
        else if (mode == 3) {
          int controller = (int)random(12);
          int randomValue = (int)random(127);
          MIDILight(controller, randomValue);   
          delay(30);
        }
        
        else if (mode == 4) {
            for (int i=0; i<128; i++)
                {
                  for (int j=0; j<12; j++)
                  {
                    MIDILight(j, i);
                  }
                  delay(10);
                  
                }
                for (int i=127; i>=0; i--)
                {
                  for (int j=0; j<12; j++)
                  {
                    MIDILight(j, i);
                  }
                  delay(10);
                }
          }
    }
    }
      System.out.println(id + " thread is done!");
    }
   
   
    // Our method that quits the thread
    void quit() {
      running = false;  // Setting running to false ends the loop in run()
      //interrupt();
    }
}
