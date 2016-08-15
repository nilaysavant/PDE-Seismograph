/* seismograph v0.1 beta
 *
 * Author: Nilay Savant
 *
 * Description : dsd projekt
 * 
 * 
 */

//Vertices of shock waves
int X[] = new int[1];
int Y[] = new int[1];
int vert_num = 1;
int x_interval_dist = 10; //in pixels

// Referance - from where drawing starts on screen
int x_ref = width/2;
int y_ref = height/2;

//amplitude magnification factor 
float amp_mag_fac = 0.2;

//osc_button_button_buttonillation simulator button (temporary)
boolean osc_button = false; 
boolean osc_toggle = false;

//time variables
int init_time = 0;
int amp_time[] = new int[1];


// screen 0, 1, or 2
int screen = 1;

float sw = width*height/pow(10, 4) + 1.5; 
//long init_time=0;
//Button start_button;

/*
//Button Class
 class Button 
 {
 String label;
 float x;    // top left corner x position
 float y;    // top left corner y position
 float w;    // width of button
 float h;    // height of button
 
 Button(String labelB, float xpos, float ypos, float widthB, float heightB) 
 {
 label = labelB;
 x = xpos;
 y = ypos;
 w = widthB;
 h = heightB;
 }
 
 void draw() 
 {
 fill(218);
 stroke(141);
 rectMode(CENTER);
 rect(x,y, w, h, 10);
 textAlign(CENTER, CENTER);
 fill(0);
 textSize((w+h)/10);
 text(label, x, y);
 }
 
 boolean mouseIsOver() 
 {
 if (mouseX > (x-(w/2)) && mouseX < (x + (w/2)) && mouseY > (y-(h/2)) && mouseY < (y + (h/2))) 
 {
 return true;
 }
 return false;
 }
 boolean pressed()
 {
 if(mousePressed)
 {
 if (mouseIsOver())
 {
 return true;
 }
 }
 return false;
 
 }
 }
 */





// Setup function
void setup() 
{
  size(800, 800); 

  x_ref = width/2;
  y_ref = height/2;

  //Start point 
  Y[0] = y_ref;
  X[0] = x_ref;
  amp_time[0] = 0;
  x_interval_dist = 10;
  //start_button = new Button("START" , width/2, height/2, width/2, height/4);

  // Size of the window
  
  //Vertice iterator
  vert_num = 1;

  osc_button = false;
}





void keyPressed()
{
  if (key == 'w') // if 'w' is pressed
  {
    osc_button = true;
  }
}
void keyReleased()
{
  if (key == 'w') // if 'w' is released
  {
    osc_button = false;
  }
}


void draw()
{
  background(255);
  fill(0);
  smooth();
  if (osc_button)
  {

    if (osc_toggle == false)
    {
      println("osc_button = true");
      init_time = millis();
      osc_toggle = true;
    }
  } else if (osc_button == false)
  {

    if (osc_toggle == true)
    {
      println("osc_button = false");
      amp_time = append(amp_time, millis() - init_time); 

      Y = append(Y, y_ref -int(amp_time[vert_num] * amp_mag_fac));
      X = append(X, x_ref);
      println(Y);
      
      vert_num += 1;
      for(int a=X.length-1;a>0;a--)
      {
        X[a-1] = X[a] - x_interval_dist;
        
      }
      
      
      
      
      //println(X[vert_num]+ " " +vert_num);
      

      osc_toggle = false;
    }
  }
  for (int i = 0; i < X.length; i++)
  {
    if(i%2 == 0)
    {
 
      line(X[i]-5, y_ref, X[i], abs(Y[i]));
      line(X[i],abs(Y[i]), X[i]+5, y_ref);
    }
    else
    {
      line(X[i]-5, y_ref, X[i], width - abs(Y[i]));
      line(X[i],width - abs(Y[i]), X[i]+5, y_ref);
      
    }

   
  } 
  
}






/*
void initScreen() //Initial Start Screen
 {
 start_button.draw();
 if (start_button.pressed())
 {
 screen = 1;
 }
 
 }*/