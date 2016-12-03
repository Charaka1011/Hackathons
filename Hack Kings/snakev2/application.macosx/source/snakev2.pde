import com.leapmotion.leap.*;

Controller controller = new Controller();


snake test;
food apple;
int highScore;
String lastState = "right";

void setup(){
  size(1400, 800);
  frameRate(20);
  test = new snake();
  apple = new food();
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  
  highScore = 0;
  
  controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  controller.enableGesture(Gesture.Type.TYPE_CIRCLE);
  controller.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
}



void draw(){
  background(10);
  drawScoreboard();
  joystick();
  test.move();
  test.display();
  apple.display();
  
  
  if( dist(apple.xpos, apple.ypos, test.xpos.get(0), test.ypos.get(0)) < test.sidelen ){
    apple.reset();
    test.addLink();
  }
  
  if(test.len > highScore){
    highScore= test.len;
  }
  lastState = test.dir;
  
}


void keyPressed(){
  if(key == CODED){
    if(keyCode == LEFT){
      test.dir = "left";
    }
    if(keyCode == RIGHT){
      test.dir = "right";
    }
    if(keyCode == UP){
      test.dir = "up";
    }
    if(keyCode == DOWN){
      test.dir = "down";
    }
  }
}


void drawScoreboard(){
  // draw scoreboard
  stroke(38, 166, 91);
  fill(10);
  rect(90, height-60 , 160, 80 , 10);
  fill(38, 166, 91);
  textSize(17);
  text( "Score: " + test.len, 80, height-80);
  
  fill(38, 166, 91);
  textSize(17);
  text( "High Score: " + highScore, 80, height-50);
}

class food{
  
  // define varibles
  float xpos, ypos;
 
  //constructor
  food(){
    xpos = random(100, width - 100);
    ypos = random(100, height - 100);
  }
  
  
  // functions
 void display(){
   
   fill(150, 40, 27);
   rect(xpos, ypos, 17, 17, 7);
 }
 
 
 void reset(){
    xpos = random(100, width - 100);
    ypos = random(100, height - 100);
 }   
}

class snake{
  
  //define varibles
  int len;
  float sidelen;
  String dir; 
  ArrayList <Float> xpos, ypos;
  
  // constructor
  snake(){
    len = 1;
    sidelen = 17;
    dir = "right";
    xpos = new ArrayList();
    ypos = new ArrayList();
    xpos.add( random(width) );
    ypos.add( random(height) );
  }
  
  // functions
  
  
  void move(){
   for(int i = len - 1; i > 0; i = i -1 ){
    xpos.set(i, xpos.get(i - 1));
    ypos.set(i, ypos.get(i - 1));  
   } 
   if(dir == "left"){
     xpos.set(0, xpos.get(0) - sidelen);
   }
   if(dir == "right"){
     xpos.set(0, xpos.get(0) + sidelen);
   }
   
   if(dir == "up"){
     ypos.set(0, ypos.get(0) - sidelen);
  
   }
   
   if(dir == "down"){
     ypos.set(0, ypos.get(0) + sidelen);
   }
   xpos.set(0, (xpos.get(0) + width) % width);
   ypos.set(0, (ypos.get(0) + height) % height);
   
    // check if hit itself and if so cut off the tail
    if( checkHit() == true){
      len = 1;
      float xtemp = xpos.get(0);
      float ytemp = ypos.get(0);
      xpos.clear();
      ypos.clear();
      xpos.add(xtemp);
      ypos.add(ytemp);
    }
  }
  
  
  
  void display(){
    for(int i = 0; i <len; i++){
      stroke(30, 130, 76);
      fill(38, 166, 91, map(i-1, 0, len-1, 250, 50));
      rect(xpos.get(i), ypos.get(i), sidelen, sidelen);
    }  
  }
  
  
  void addLink(){
    xpos.add( xpos.get(len-1) + sidelen);
    ypos.add( ypos.get(len-1) + sidelen);
    len++;
  }
  
   boolean checkHit(){
    for(int i = 1; i < len; i++){
     if( dist(xpos.get(0), ypos.get(0), xpos.get(i), ypos.get(i)) < sidelen){
       return true;
     } 
    } 
    return false;
   } 
}

  
void joystick(){
        Frame frame = controller.frame();
        GestureList gestures = frame.gestures();
    for(int i = 0; i < gestures.count(); i++){
      Gesture gesture = gestures.get(i);
      if(gesture.type() == Gesture.Type.TYPE_SWIPE){
        SwipeGesture swipe = new SwipeGesture(gesture);
        if(swipe.direction().get(0) > 0.3){
          if(lastState != "left"){
            test.dir = "right";
          }
        }else if(swipe.direction().get(0) < -0.3){
          if(lastState != "right"){
            test.dir = "left";
          }
        }
        else if(swipe.direction().get(1) > 0.2){
          if(lastState != "down"){
          test.dir = "up";
          }
        }else if(swipe.direction().get(1) < -0.2){
          if(lastState != "up"){
          test.dir = "down";
          }
        }
      }else if(gesture.type() == Gesture.Type.TYPE_SCREEN_TAP){
          background(255);      
      }
    }
}