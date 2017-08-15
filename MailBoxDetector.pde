import java.io.BufferedWriter;
import java.io.FileWriter;
import processing.video.*;


int imageIndex=7;
int numPixels;
Capture video;
PImage img;
timer[] countingTime; 
boolean[] start;
boolean[] sent;
int threshold;
int duration=5;
double factor=1;
int numberOfBoxes;
int numberOfBoxVer;
int numberOfBoxHor;

PImage back;
PImage[] imgs;


int[] topLeft;
int[] topRight;
int[] buttomLeft;
int[] buttomRight;
int[][] locX;
int[][] locY;
int clickedTimes;

void setup() {
  //size(640, 480);
  fullScreen();
  img = loadImage("previous.png");

  video = new Capture(this, width, height);
  video.start(); 
  
  numPixels = img.width * img.height;
  loadPixels();
  
  numberOfBoxVer=5;
  numberOfBoxHor=13;
  numberOfBoxes =numberOfBoxVer * numberOfBoxHor;
  
  
  threshold = 120000;
  countingTime = new timer[numberOfBoxes];
  start = new boolean[numberOfBoxes];
  sent = new boolean[numberOfBoxes];
  imgs = new PImage[numberOfBoxes];
  back = loadImage("pr1.png");
  
  for(int p = 0; p < numberOfBoxes; p++){
      countingTime[p] = new timer();
      start[p]=false;
      sent[p]=false;    
      try{
        imgs[p]=loadImage("pr"+(p+1)+".png");
      }catch (NullPointerException e) {
        e.printStackTrace();
        //println("error in finding pr"+(p+1)+".png");
      }
  }

  topLeft = new int[2];
  topRight= new int[2];
  buttomLeft= new int[2];
  buttomRight= new int[2];
  
  locX = new int[13][5];
  locY = new int[13][5];
}
void mouseClicked() {
  
  switch (clickedTimes){
    case(0):
      
      topLeft[0]=mouseX;
      topLeft[1]=mouseY;
      background(255);
      //updatePixels();
      println("click on center of top right box");
      break;
    case(1):
      
      topRight[0]=mouseX;
      topRight[1]=mouseY;
      background(255);
      //updatePixels();
      println("click on center of buttom right box");
      break;
    case(2):
      
      buttomRight[0]=mouseX;
      buttomRight[1]=mouseY;
      background(255);
      //updatePixels();
      println("click on center of buttom left box");
      break;
    case(3):
      
      buttomLeft[0]=mouseX;
      buttomLeft[1]=mouseY;
      background(255);
      //updatePixels();
      println("click anywhere");
      break;
    default:
      println("finish");
      break;
  }
  clickedTimes++;
    
}

void draw() {
  background(255);
  //println (mouseX +"," + mouseY);
  //image(back, 0, 0);
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera
    video.loadPixels(); // Make its pixels[] array available
    
    //for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
    //  pixels[i] = video.pixels[i];
    //}
    //updatePixels();
    
    
    for (int i = 0; i < numPixels; i++){
      color currColor = video.pixels[i];
      color prevColor = img.pixels[i];
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
    }
      
      
    if(clickedTimes<4){
      for (int i = 0; i < numPixels; i++){
        pixels[i] = img.pixels[i];
      }
    }
    else if (clickedTimes==4){
      
      for(int i=0;i<numberOfBoxHor;i++){
        locX[i][0] = (int)(i*((topRight[0] - topLeft[0])/(numberOfBoxHor-1.0)))+topLeft[0];
        locY[i][0] = (int)(i*((topRight[1] - topLeft[1])/(numberOfBoxHor-1.0)))+topLeft[1];
      }
      for(int i=0;i<numberOfBoxHor;i++){
        locX[i][numberOfBoxVer-1] = (int)(i*((buttomRight[0] - buttomLeft[0])/(numberOfBoxHor-1.0)))+buttomLeft[0];
        locY[i][numberOfBoxVer-1] = (int)(i*((buttomRight[1] - buttomLeft[1])/(numberOfBoxHor-1.0)))+buttomLeft[1];
      }
      for(int i=0;i<13;i++){
        for(int j=0;j<5;j++){
           locX[i][j] = (int)(j*((locX[i][numberOfBoxVer-1] - locX[i][0])/(numberOfBoxVer-1.0)))+locX[i][0];
           locY[i][j] = (int)(j*((locY[i][numberOfBoxVer-1] - locY[i][0])/(numberOfBoxVer-1.0)))+locY[i][0];
        }
      }
    }else if (clickedTimes>4){
      
      int len=30;
      int i1=-len/2;
      int i2=len/2;
      int j1=-len/2;
      int j2=len/2;
      int sumDiff = 0; // Amount of movement in the frame
      for(int p = 0; p < numberOfBoxes; p++){
        int center = locY[p % numberOfBoxHor][p / numberOfBoxHor]*width+locX[p % numberOfBoxHor][p / numberOfBoxHor];
        for (int i = i1; i < i2; i++) {
          for (int j = j1; j < j2; j++) { // For each pixel in the video frame...

            color currColor = video.pixels[center+j*(width)+i];
            color prevColor = img.pixels[center+j*(width)+i];

            int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
            int currG = (currColor >> 8) & 0xFF;
            int currB = currColor & 0xFF;

            int prevR = (int)(((prevColor >> 16) & 0xFF)*factor);
            int prevG = (int)(((prevColor >> 8) & 0xFF)*factor);
            int prevB = (int)((prevColor & 0xFF)*factor);

            int diffR = abs(currR - prevR);
            int diffG = abs(currG - prevG);
            int diffB = abs(currB - prevB); 
            sumDiff += diffR + diffG + diffB;//0.27*diffR + 0.72*diffG + 0.07*diffB;
            
          }
        }

        if(!sent[p]) startTimer(sumDiff,p);
        if(sent[p]) reset(sumDiff,p);
        //println("p="+p);
        println(sumDiff); 
        //println("box "+(p%13)+","+(p/13)+",diff="+sumDiff); 
        sumDiff=0;
      }
      
      image(back, 0, 0);
      
      drawCentralPointsAndBorders(i1,i2,j1,j2);
    }
  }
  updatePixels();
  
  for(int p = 0; p < numberOfBoxes; p++){
    if(sent[p]) {
      println("displaying img "+p);
      image(imgs[p], 0, 0);
      //for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      //  pixels[i] = imgs[p].pixels[i];
      //}
    }
  }
}


void drawCentralPointsAndBorders(int i1, int i2, int j1,int j2){
  for(int i=0;i<numberOfBoxHor;i++){
    for(int j=0;j<numberOfBoxVer;j++){
      int a = locY[i][j]*width+locX[i][j];
      int b = locY[i][j]*width+locX[i][j];
      pixels[a]=0;
      pixels[b]=0;
    }
  }
  
  for(int p = 0; p < numberOfBoxes; p++){
    int center = locY[p%13][p/13]*width+locX[p%13][p/13];
    for (int i = i1; i < i2; i++) {
      pixels[center+(j1)*(width)+i] =sent[p]?color(255,0,0):color(0,255,0);
    }
    for (int j = j1; j < j2; j++) { 
      pixels[center+j*(width)+(i1)] =sent[p]?color(255,0,0):color(0,255,0);
    }
    for (int i = i1; i < i2; i++) {
      pixels[center+(j2)*(width)+i] =sent[p]?color(255,0,0):color(0,255,0);
    }
    for (int j = j1; j < j2; j++) { 
      pixels[center+j*(width)+i2] = sent[p]?color(255,0,0):color(0,255,0);
    }
  }  
}
  
void reset(int sumDiff, int p){
  if(sumDiff < threshold && start[p]==false){
      //println("timer "+p+" started"); 
      countingTime[p].start(); 
      start[p]=true;
    }
    if(start[p] && sumDiff > threshold){
      //println("timer "+p+" started but stopped ");
      countingTime[p].empty();
      start[p]=false;
    }
    if(countingTime[p].second()>duration){
      println("restart detecting in "+p);
      countingTime[p].empty(); 
      start[p]=false;
      sent[p]=false;
    }
}
void startTimer(int sumDiff, int p){
    //println("now, time="+countingTime[p].second());
    if(sumDiff >= threshold && start[p]==false){
      //println("timer "+p+" started"); 
      countingTime[p].start(); 
      start[p]=true;
    }
    if(start[p] && sumDiff < threshold){
      //println("timer "+p+" started but stopped ");
      countingTime[p].empty();
      start[p]=false;
    }
    if(countingTime[p].second()>duration){
      println("detected new mail in "+p);
      writeTXT(p);
      countingTime[p].empty(); 
      start[p]=false;
      sent[p]=true;
    }
}
void writeTXT(int p){
  File f = new File(dataPath("targets.txt"));
  String text = p+"";
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }catch (IOException e){
    println("error");
  }
  //pixels[locY[p%13][p/13]*width+locX[p%13][p/13]]=color(256,0,0);
  
}

void keyPressed() {
  
  saveFrame(imageIndex+".png");
  imageIndex++;
}


class timer {
  int startTime = 0, stopTime = 0;
  boolean running = false;  
  
    void start() {
        
        startTime = millis();
        running = true;
    }
    void stop() {
        stopTime = millis();
        running = false;
    }
    void empty() {
        startTime = 0;
        stopTime = 0;
        running = false; 
    }
    int getElapsedTime() {
        int elapsed;
        if (running) {
             elapsed = (millis() - startTime);
        }
        else {
            elapsed = (stopTime - startTime);
        }
        return elapsed;
    }
    
    int minute() {
      return (getElapsedTime() / (1000*60)) % 60;
    }
    int second() {
      return (getElapsedTime() / 1000) % 60;
    }

}