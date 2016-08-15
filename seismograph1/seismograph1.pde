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
int init_time = 0; // initial time to check for amplitude
int amp_time[] = new int[1];
int wave_delay = 4000; // max time after last earthquake to be considered a wave of earthquake
int wave_stop_time = 0; // time to be noted when a wave stops
int max_cons_amp_time = 1500; // max amp time to be considered

int wave_dist = x_interval_dist * 2; //Distance between two wave beats

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

  //Reference from where drawing starts on screen
  x_ref = width-width/6;
  y_ref = height/2;

  //Start point 
  Y[0] = y_ref;
  X[0] = x_ref;
  
  
  amp_time[0] = 0; // Starting Amplitude = 0 
  
  max_cons_amp_time = 1500; // max amp time to be considered
  
  x_interval_dist = (4 * width)/800;  //Horizontal dist between waves
  
  wave_dist = x_interval_dist * 4; //Distance between two wave beats
  
  //start_button = new Button("START" , width/2, height/2, width/2, height/4);
  
  //amplitude magnification factor 
  amp_mag_fac = (0.2 * height)/800;
  
  wave_delay = 4000; // max time after last earthquake to be considered a wave of earthquake
  wave_stop_time = 0; // time to be noted when a wave stops
  
  //Vertice iterator
  vert_num = 1;

  osc_button = false; // button for wave simulation
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
  
  line(0, height/8, width, height/8); // line dividing menubar from wave monitor
  
  if (osc_button)
  {

    if (osc_toggle == false)
    {
      println("osc_button = true");
      
      init_time = millis();
      if((init_time - wave_stop_time) > wave_delay)
      {
        Y = append(Y, y_ref);
        X = append(X, x_ref);
        amp_time = append(amp_time, 0);
        Y = append(Y, y_ref);
        X = append(X, x_ref+wave_dist/2);
        amp_time = append(amp_time, 0);
        for(int a=X.length-1;a>0;a--)
        {
          X[a] = X[a] - wave_dist;
        }
        
      }
      
      osc_toggle = true;
    }
  } 
  else if (osc_button == false)
  {

    if (osc_toggle == true)
    {
      println("osc_button = false");
      int temp_time = millis() - init_time;
      if(temp_time < max_cons_amp_time)
      {
        amp_time = append(amp_time, temp_time); 
        wave_stop_time = millis();
      
        Y = append(Y, y_ref -int(amp_time[amp_time.length-1] * amp_mag_fac));
        X = append(X, x_ref);
        println(Y);
      
        vert_num += 1;
        for(int a=X.length-1;a>0;a--)
        {
          X[a] = X[a] - x_interval_dist;
        
        }
        
      }
      osc_toggle = false;
    }
  }
  for (int i = 0; i < X.length; i++)
  {
    if(i%2 == 0)
    {
 
      line(X[i]-(x_interval_dist/2), y_ref, X[i], abs(Y[i]));
      line(X[i],abs(Y[i]), X[i]+(x_interval_dist/2), y_ref);
    }
    else
    {
      line(X[i]-(x_interval_dist/2), y_ref, X[i], height - abs(Y[i]));
      line(X[i],height - abs(Y[i]), X[i]+(x_interval_dist/2), y_ref);
      
    }
    if(i>0)
    { 
      if( (Y[i-1] == y_ref) && (Y[i] == y_ref))
      {
        line(X[i], height/8 , X[i], height);
      }
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