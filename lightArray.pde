/*
MODES:
0: oscillate
1: on
2: off
3: random
4: fade
5: midi listener
6:





*/
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
Textlabel options;
CheckBox optionsbox;
int[] optionsArray = new int[10];

MidiBus lightArray; // The MidiBus
ControlP5 controlP5;
SimpleThread MIDIThread;

void setup() {
	size(490,260, OPENGL);
	background(0);
        smooth();
        GUISetup();
        MIDIThread = new SimpleThread("midi");
        MIDIThread.start();
        int[] light = new int[12];
        for (int k=0; k<11; k++)
        {
          softLight[k] = 0;
        }
}

void GUISetup() {
  // set up GUI
  String[] outputs = MidiBus.availableOutputs();
  String[] inputs = MidiBus.availableInputs();
  
  controlP5 = new ControlP5(this);
  programlabel = controlP5.addTextlabel("programlabel", "Programs", 350, 65);
  Radio programs = controlP5.addRadio("programs",350,80);
  programs.deactivateAll();
  programs.add("on", 1);
  programs.add("off", 2);
  programs.add("oscillate", 0);
  programs.add("fade", 4);
  programs.add("random", 3);
  
  midioutlabel = controlP5.addTextlabel("midioutlabel", "MIDI Outputs", 200, 65);
  Radio midioutdevices = controlP5.addRadio("midioutdevices",200,80);
  midioutdevices.deactivateAll();
  for (int i=0; i<(outputs.length-1); i++) {
    midioutdevices.add(outputs[i], i);
  }
  
  midiinlabel = controlP5.addTextlabel("midiinlabel", "MIDI Inputs", 100, 65);
  Radio midiindevices = controlP5.addRadio("midiindevices",100,80);
  midiindevices.deactivateAll();
  for (int i=0; i<(inputs.length-1); i++) {
    midiindevices.add(inputs[i], i);
  }
  
  options = controlP5.addTextlabel("options", "Options", 10, 65);
  optionsbox = controlP5.addCheckBox("optionsbox",10,80);
  optionsbox.setItemsPerRow(3);
  optionsbox.setSpacingColumn(30);
  optionsbox.setSpacingRow(10); 
  optionsbox.addItem("notes -> cc",0);
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

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isGroup()) {
    if (theEvent.group().name() == "optionsbox") {
      for(int i=0;i<theEvent.group().arrayValue().length;i++) {
        optionsArray[i] = (int)theEvent.group().arrayValue()[i];
        print (optionsArray[i]);
      }
    }
  }
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

void controllerChange(int channel, int number, int value) {
	MIDIThread.MIDILightIn(number, value);
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
     if (controller >= 0 && controller <= 12) {
       softLight[controller] = value*2;
     }
     lightArray.sendControllerChange(0, controller+36, value);
   }
   
   void MIDILightIn (int controller, int value) {
     if (controller >= 36 && controller <= 47 ) {
       softLight[controller-36] = value*2;
     }
     
     lightArray.sendControllerChange(0, controller, value);
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
          
          else {
            delay(10);
            //FIX THIS. WITHOUT THIS THE CPU USE GOES THROUGH THE ROOF. NEED A WAY
            //TO SLEEP THIS THREAD WHEN IT'S NOT IN USE.
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
