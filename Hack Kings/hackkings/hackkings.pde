import com.leapmotion.leap.*;

Controller controller = new Controller();

String lastState = "up";
String selection = "up";

void setup(){
  size(400,400);
  frameRate(20);
  textAlign(CENTER,CENTER);
  background(10);
  fill(38, 166, 91);
  rect(20, 20, width - 40, height - 40, 20);
  fill(10);
  rect(30, 30, width - 60, height - 60, 20);
  textSize(80);
  fill(38, 166, 91);
  text("Menu", 200, 70);
  controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  controller.enableGesture(Gesture.Type.TYPE_CIRCLE);
  controller.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
}

void draw(){
  selectGame();
  drawText();
}

void drawText(){
  fill(10);
  rect(30,178,height-60,100);
   fill(38, 166, 91);
   textSize(40);
   text("1. Snake", 200, 200);
   text("2. Breakout", 200, 250);
   if (selection == "up"){
     fill(170);
     rect(30,178,height-60,50);
     fill(10);
     text("1. Snake", 200, 200);
   }
   else if (selection == "down"){
     fill(170);
     rect(30,228,height-60,50);
     fill(10);
     text("2. Breakout", 200, 250);
   }
}

void selectGame(){
  Frame frame = controller.frame();
  GestureList gestures = frame.gestures();
  for(int i = 0; i < gestures.count(); i++){
    Gesture gesture = gestures.get(i);
    if(gesture.type() == Gesture.Type.TYPE_SWIPE){
      SwipeGesture swipe = new SwipeGesture(gesture);
      if(swipe.direction().get(0) > 0.3){
        if (selection == "up"){
          launch("snakev2.app");
        }else{
          launch("breakout");
        }
       }else if(swipe.direction().get(0) < -0.8){
         exit();
       }else if(swipe.direction().get(1) > 0.2){
          if(selection == "down"){
            selection = "up";
          }
       }else if(swipe.direction().get(1) < -0.2){
          if(selection == "up"){
            selection = "down";
          }
       }
    }
  }
}