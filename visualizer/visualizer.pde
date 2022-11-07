import processing.serial.*;
import processing.sound.*;
AudioIn input, audio;

Serial myPort;        
int xPos = 1;         
float height_old = 0;
float height_new = 0;
float dataByte = 0;
int BPM = 0;
int beat_old = 0;
float[] beats = new float[500]; 
int beatIndex;
float limit = 650.0;  
boolean belowLimit = true;
String dataString;

PFont poppins;
String title = "Lemon Tree\nFools Garden";

// button properties
int btnX = 345;
int btnY = 170;
int btnWidth = 120;
int btnHeight = 40;
int btnRadius = 15;
boolean stopPressed = false;


void setup () {
  size(800, 500);     
  poppins = createFont("poppins-regular.ttf", 20);
  textFont(poppins);
  
  myPort = new Serial(this, "COM3", 9600); 
  println(myPort);
  myPort.bufferUntil('\n'); // wait until there's a new line
  background(49, 65, 161);

}


void draw () {
      fill(255);
      text(title, 400, 60);
      textAlign(CENTER, CENTER);

        if (millis() % 128 == 0){ // if millis() is a multiply of 128, print the bpm value
          fill(49, 65, 161); // bpm container
          noStroke(); // delete border for the container
          rect(300, 115, 200, 50);
          fill(255);
          text("BPM: " + dataByte, 400, 125);
        }
      
        StopButton(); 
        StopButtonController();
        
        // map the waveform from serial input
        dataByte = map(dataByte, 0, 1023, 0, height/2);
        height_new = height - dataByte; 
        line(xPos - 1, height_old, xPos, height_new);
        height_old = height_new;
        if (xPos >= width) { // if the waveform is at the end of screen, back to the start of the screenWidth (x = 0)
          xPos = 0;
          background(49, 65, 161);
        } 
        else {
          xPos++;
        }
}

void serialEvent (Serial myPort) { // fetching serial data
  try {
      dataString = myPort.readStringUntil('\n'); // keep reading the data until a newline is present
      println(dataString); // print data to the console

  if (dataString != null) { // if the data is present
    dataString = trim(dataString);
    if (dataString.equals("!")) { 
      stroke(255); 
      strokeWeight(2);
      dataByte = float(dataString);  
    }
    else {
      stroke(255); 
      strokeWeight(2);
      dataByte = float(dataString);  // convert Byte ke String
      if (dataByte > limit && belowLimit == true) {
        calculateBPM();
        belowLimit = false;
      }
      else if(dataByte < limit) {
        belowLimit = true;
      }
    }
  }
 }
  catch(RuntimeException e) { // print the stack trace instead of returning an error.
    e.printStackTrace();
  }
}
  
void calculateBPM () {  
  try {
    int beat_new = millis();   // current millisecond
    int diff = beat_new - beat_old;    // time difference beat[i+1] dan beat[i]
    float currentBPM = 60000 / diff;    // beat per mins (1m = 60s = 60000ms)
    beats[beatIndex] = currentBPM;  
    float total = 0.0;
    for (int i = 0; i < 500; i++){
      total += beats[i];
    }
    BPM = int(total / 500);
    beat_old = beat_new;
    beatIndex = (beatIndex + 1) % 500; 
  }
  catch(ArithmeticException e) {
      e.printStackTrace();
     }
}
  
public void StopButton() {
  fill(85, 103, 186);
  rect(btnX, btnY, btnWidth, btnHeight, btnRadius);
  fill(255);
  text("STOP", 407, 185);
}

public void StopButtonController(){
  // if (cursor is inside the button area), stop draw()
  if (mouseX > btnX && mouseX < btnX + btnWidth && mouseY > btnY && mouseY < btnY + btnHeight && mousePressed) {
      stopPressed = !stopPressed;
      noLoop();
      fill(255);
      text("Visualizer stopped.", 400, 250);
  }
}
