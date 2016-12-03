import ddf.minim.*;
import ddf.minim.analysis.*;
import com.leapmotion.leap.*;
import com.leapmotion.leap.Controller;


Minim minim;
PImage img;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
Controller controller = new Controller();
String valInLeap;
int currentSong = 0;
int counter = 0;
int  r = 300;
float rad = 70;
String[] songNames= {"Breaking The Habit - Linkin Park.mp3","Fast Lane - Real Steel.mp3","How To Save A Life - the fray.mp3","Like A G6 - Far East Movement.mp3","Crank That (Soulja Boy) - Soulja Boy.mp3"};
void setup()
{  
  //img = loadImage("");
  size(displayWidth, displayHeight);
  frameRate(30);
  minim = new Minim(this);
  player = minim.loadFile(songNames[currentSong]);
  meta = player.getMetaData();
  
  beat = new BeatDetect();
  player.loop();
  background(10);
  noCursor();
  controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  controller.enableGesture(Gesture.Type.TYPE_CIRCLE);
  controller.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
}

void draw()
{ 
  joystick();
  if(valInLeap=="right" && counter == 0){
    currentSong++;
    player.pause();
    //player.loadFileIntoBuffer(songNames[currentSong], MultiChannelBuffer outBuffer);
    counter++;
  }else if(valInLeap=="left" && counter == 0){
    currentSong--;
    player = minim.loadFile(songNames[currentSong]);
    counter++;
  }
  
  float t = map(mouseX, 0, width, 0, 1);
  beat.detect(player.mix);
  fill(5,75,125, 20);
  noStroke();
  rect(0, 0, width, height);
  translate(width/2, height/2);
  noFill();
  fill(-1, 10);
  if (beat.isOnset()){
    int color1 = (int)random(0,15);
    int color2 = (int)random(70,85);
    int color3 = (int)random(120,135);
    background(color1,color2,color3);
    rad = rad*0.9;
  }
  else rad = 70;
  //ellipse(0, 0, 2*rad, 2*rad);
  stroke(-1, 50);
  int bsize = player.bufferSize();
  for (int i = 0; i < bsize - 1; i+=5)
  {
    float x = (r)*cos(i*2*PI/bsize);
    float y = (r)*sin(i*2*PI/bsize);
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    line(x, y, x2, y2);
  }
  beginShape();
  noFill();
  stroke(-1 , 50);
  for (int i = 0; i < bsize; i+=30)
  {
    float x2 = (r + player.left.get(i)*90)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*90)*sin(i*2*PI/bsize);
    vertex(x2, y2);
    pushStyle();
    stroke(-1);
    strokeWeight(2);
    point(x2, y2);
    popStyle();
  }
  endShape();
  beginShape();
  scale(2);
  translate(-(width/3),0);
  noFill();
  stroke(-1, 50);
  for (int i = 0; i < bsize; i+=30)
  {
    float x2 = (i + player.left.get(i)*30);
    float y2 = (0 + player.left.get(i)*30);
    vertex(x2, y2);
    pushStyle();
    stroke(-1);
    strokeWeight(2);
    point(x2, y2);
    popStyle();
  }
  endShape();
 // if (flag)
 // showMeta();
  //imageMode(CENTER);
  //image(img, width/3, 0,250,200);
}


void showMeta() {
  int time =  meta.length();
  textSize(50);
  textAlign(CENTER);
  text( (int)(time/1000-millis()/1000)/60 + ":"+ (time/1000-millis()/1000)%60, -7, 21);
}

boolean flag =false;
void mousePressed() {
  if (dist(mouseX, mouseY, width/2, height/2)<150) flag =!flag;
}

//
/*boolean sketchFullScreen() {
  return true;
}*/

void keyPressed() {
  if(key==' ')exit();
  if(key=='s')saveFrame("###.jpeg");
  if(key=='r'){
    background(10);
  }
}

void joystick(){
  Frame frame = controller.frame();
  GestureList gestures = frame.gestures();
    for(int i = 0; i < gestures.count(); i++){
      Gesture gesture = gestures.get(i);
      if(gesture.type() == Gesture.Type.TYPE_SWIPE){
        SwipeGesture swipe = new SwipeGesture(gesture);
        if(swipe.direction().get(0) > 0.5){
          valInLeap = "right";
        }else if(swipe.direction().get(0) < -0.5){
          valInLeap = "left";
        }
        else if(swipe.direction().get(1) > 0.4){
          valInLeap = "up";
        }else if(swipe.direction().get(1) < -0.4){
           valInLeap = "down";
        }
      }
    }
}