import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import com.leapmotion.leap.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class BreakoutLeapMotion extends PApplet {


Controller controller = new Controller();

Serial port;

String leapVal;

//Colors used in the game
final int backgroundColor= color(10);
final int ballColor = color(78,205,196);
final int sliderColor = color(224,224,224);
final int colorScheme = color(38, 166, 91); //General color scheme of the game text
final int padding = 20; //padding on objects
final int fps = 50; //frame rate
final int bricksPerLine=5; //Sets the maximum number of bricks each line can have

// General game variables
int gameScreen = 1; // sets which screen to display

//Loading screen
int loaderPosX=130,loaderDirX=2;

//Bricks
int brickHeight;
int brickWidth;
int brickRad=5;
int noOfBricks=20; //Sets the number of bricks for the game
int[][] brickPos= new int[noOfBricks][2]; //Creates an array containing the coordinates of each brick


//Sets the variables for the ball
float ballDirX=3,ballDirY=3; //Controls the direction in which the ball is moving and the speed of the ball
int ballSize =20; //The height and width of the ball(size)
int ballPosX,ballPosY;  // Position of the ball

//Sets the slider variables
int sliderPosX=300;
int sliderPosY=600;
int sliderDirX=10;

//Game screen variables
int scoreBarSize = 50;
int score = 0;
boolean winGame =false;
int sliderWidth;
public void setup() {
  
  //Ball starts from a random positon
  ballPosX=(int)random(padding, width/2-padding);
  ballPosY=(int)random((height/2), sliderPosY-150);
  
  //Generates the size of the brick so that it can vary with the screen size
  brickHeight=(height/noOfBricks)/2;
  brickWidth=(width/5)-15;
  
  sliderPosY=height-50;
  generateBrickPos();
  frameRate(fps);
  
  sliderWidth = (width/7);
  controller.enableGesture(Gesture.Type.TYPE_SWIPE);
  controller.enableGesture(Gesture.Type.TYPE_CIRCLE);
  controller.enableGesture(Gesture.Type.TYPE_SCREEN_TAP);
  controller.enableGesture(Gesture.Type.TYPE_KEY_TAP);
  delay(100);
}

public void draw() {
  // Display the contents of the current screen
  
  background(backgroundColor);
  //Controls the current screen that the user sees
  switch(gameScreen){
    case 1:
      gameScreen();
      break;
    case 2:
      gameOverScreen();
  }
}


/********* SCREEN CONTENTS *********/
public void gameScreen() {
  startGame();
}
public void gameOverScreen() {
  //Displays the score and informs the user if they won or not
  fill(colorScheme);
  textSize(50);
  text("GAME OVER", (width/3)+50, 3*(height/8)); 
  textSize(40);
  text("SCORE:" + score, (width/3)+100, 4*(height/8)); 
  String positionText="YOU LOSE!";
  //Check if the user destroyed all the blocks
  if(checkWinningCondition()){
    positionText="YOU WIN!!";
  }
  text(positionText, (width/3)+80, 5*(height/8));
}

//Sets up the game
public void startGame() {
  joystick();
  drawBall();
  makeBallBounce();
  drawScoreBar();
  drawSlider();
  //draws the bricks in the brickPos array
  for(int i=0;i<noOfBricks;i++){
    drawBrick(brickPos[i][0],brickPos[i][1]);
    //Checks if the ball has collided with the bricks
    if(checkBallCollideBrick(brickPos[i][0],brickPos[i][1])){
      //Destroys the brick by setting its x and y values to 0
      brickPos[i][0]=0;
      brickPos[i][0]=0;
      //Makes the ball bounce off the brick and change direction
      ballDirY*=-1;
    }
  }
  
}


public void drawBall(){
  stroke(colorScheme);
  strokeWeight(2);
  fill(ballColor);
  ellipse(ballPosX, ballPosY, ballSize, ballSize);
}


public void makeBallBounce(){
  //Makes the ball bounce of the wall
  //Causes the ball to move
  ballPosX+=ballDirX;
  ballPosY+=ballDirY;
    //Changes the direction of the ball when it hits the sides of the screen
    if(ballPosX>width-padding){
       ballDirX=ballDirX*-1; 
    }else if(ballPosX<padding){
      //Makes sure that the ball doesn't get stuck on the left side of the screen
      ballPosX=padding;
      //Changes the direction of the ball
      ballDirX=ballDirX*-1; 
    }
    //Changes the direction of the ball if it hit the top of the screen 
    if(ballPosY<(padding+scoreBarSize)){
       ballPosY=padding+scoreBarSize;
       ballDirY=ballDirY*-1; 
    }else if(ballPosY>height-padding){
      //Ends the game if the ball touches the floor/bottom of the screen 
      gameScreen=2;
    }
    if((ballPosY>=sliderPosY && ballPosY<=sliderPosY + 20) && (ballPosX>=sliderPosX && ballPosX<=(sliderPosX+sliderWidth))){
      //Changes ball direction if it hits the paddle
      ballDirY=ballDirY*-1.1f; 
    }
}
public void changeLevel(){
  //Makes the game harder after every 3 points
 if(score%3==0){
   //Checks the direction of the ball (downwards/upwards)
   if(ballDirX>0){
     ballDirX+=1;
     ballDirY+=1;
   }else{
     ballDirX-=1;
     ballDirY-=1;
   }
 }
}

public void drawScoreBar(){
 //Draws the score bar on the screen and displays the 
 fill(0);
 stroke(0);
 rect(0,0,width,scoreBarSize);
 fill(colorScheme);
 textSize(20);
 //Displays the score
 text("SCORE: "+score, 3*(width/4), scoreBarSize/2);
 text("BLOCKS REMAINING: "+(noOfBricks-score), 1*(width/4), scoreBarSize/2); 
 
}

public void drawSlider(){
  //Draws and controls the motion of the paddle
  stroke(38, 166, 91);
  strokeWeight(2);
  fill(colorScheme);
  rect(sliderPosX,sliderPosY,sliderWidth,20,10);
  if(sliderPosX>(width-sliderWidth)-padding){
    //Prevents the slider from going off the right side of the screen
    sliderPosX=(width-sliderWidth)-(padding);
  }else if(sliderPosX<padding){
    //Prevents the slider from going off the left side of the screen
    sliderPosX = padding;
  }else{
    //Control the direction of the paddle
    if(leapVal==null){
    }else{
      //Uses accelerometer readings from the engduino to move the paddle
      if(leapVal.equals("left")){
        //Makes the paddle move to the left
        sliderPosX+=-sliderDirX;
        
      }else if(leapVal.equals("right")){
        //Makes the paddle move to the right
        sliderPosX+=sliderDirX;
      }
    }
  }
}

public void drawBrick(int x,int y){
  if(x>0 && y>0){
    //draws the bricks only the screen only if x and y are >0
    stroke(38, 166, 91);
    strokeWeight(2);
    fill(colorScheme);
    rect(x,y,brickWidth,brickHeight,brickRad);
  }
}

public void generateBrickPos(){
  //Generates the x and y values for each of the bricks in the game and adds the coordinates in to a 2D array(brickPos[][])
  int x=15;
  int y=scoreBarSize+10;
  for(int i=0;i<noOfBricks;i++){
    brickPos[i][0]=x; //Assigns the X coordinates to the 0th term of the 2D array 
    brickPos[i][1]=y; //Assigns the Y coordinates to the 1th term of the 2D array 
    x+=brickWidth+5; //Adds gaps/spaces between the bricks
    //moves the bricks to the next line and ensures that here are only 3 blocks per row
    if((i+1)%bricksPerLine==0 && i!=0){
       //Moving the bricks to a new line by resetting x and increasing y
       x=15;
       y+=brickHeight+10; 
    }
  }
}
public boolean checkBallCollideBrick(int x,int y){
  //Checks whether the ball has collided with the brick and runs the code only if the brick has not already been destroyed(x&y are not equal to 0)
  if((ballPosY>=y && ballPosY<=(y+brickHeight))&&(x-5<=ballPosX && x+brickWidth+5>=ballPosX)&&(x!=0 && y!=0)){
    score++;//Increments the score everytime the ball hits the brick
    changeLevel();//Increases the difficulty of the game gradually
    //If the user has destroyed all the bricks the screen switches to gameOverScreen()
    if(checkWinningCondition()){
      gameScreen=2;
    }
    return true;
  }else{
   return false; 
  }
}

public boolean checkWinningCondition(){
  //Checks whether the winning condition has been met and the user has destroyed all the bricks
  if(score==(noOfBricks)){
   return true; 
  }else{
   return false; 
  }
}


public void joystick(){
        Frame frame = controller.frame();
    for( Hand hand : frame.hands()){
            Vector normal = hand.palmPosition();
            sliderPosX= (int) map(normal.get(0),-200,200,padding,(width-padding)); 
        }
}

public void keyPressed(){
  if(key == CODED){
    if(keyCode == LEFT){
      leapVal = "left";
    }
    if(keyCode == RIGHT){
      leapVal = "right";
    }
    if(keyCode == UP){
      leapVal = "up";
    }
    if(keyCode == DOWN){
      leapVal = "down";
    }
  }
}
  public void settings() {  size(1400,800);  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "BreakoutLeapMotion" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
