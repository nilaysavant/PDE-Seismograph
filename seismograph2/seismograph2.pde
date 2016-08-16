/* seismograph v0.1 beta
 *
 * Author: Nilay Savant
 *
 * Description : dsd projekt
 * 
 * 
 */

import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

//CONFIG FILE

boolean t = false; //temp var

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

//DATE-TIME register variables
int sec[] = new int[1];  // Values from 0 - 59
int min[] = new int[1];  // Values from 0 - 59
int hour[] = new int[1];    // Values from 0 - 23

int day[] = new int[1];    // Values from 1 - 31
int month[] = new int[1];  // Values from 1 - 12
int year[] = new int[1];   // 2003, 2004, 2005, etc.
int ival[] = new int[1]; // For storing i val at beat

//DATA TABLE- for storing the amplitude data
Table table;

boolean screenshot_toggle = false; //For screen shot

float sw = width*height/pow(10, 4) + 0.1; 
//long init_time=0;

// Setup function
void setup() 
{
  size(1200, 800); //800,800 default
  
  //CONFIG FILE LOAD
  String port = null;
  float amp_mag = 0.3;
  String config[] = loadStrings("data/config/config.txt");
  port = config[0]; //assign port from  config file
  amp_mag = float(config[1]); //initialise amp_mag from config file

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

  //amplitude magnification factor 
  println("AMP :::"+amp_mag);
  amp_mag_fac = (amp_mag * height)/800; //defalut (0*2 * height)800
  
  
  wave_delay = 4000; // max time after last earthquake to be considered a wave of earthquake
  wave_stop_time = 0; // time to be noted when a wave stops

  //Vertice iterator
  vert_num = 1;

  //Data Table
  table = new Table();

  table.addColumn("S.No");
  table.addColumn("X");
  table.addColumn("Y");
  table.addColumn("Amplitude");
  table.addColumn("Time Stamp");

  osc_button = false; // button for wave simulation
  
  //Serial Ports File
  //serial_all_ports = createWriter("serial_all_ports.txt");
  
  //SERIAL
  //String portName = Serial.list()[0];
  saveStrings("serial_all_ports.txt", Serial.list());
  printArray(Serial.list());
  myPort = new Serial(this, port, 115200); // REQUIRED 
  println("connected to serial: " + port);
  
}

/*
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
 */

void serialEvent(Serial myPort) 
{
  int val = myPort.read();         // read it and store it in val
  //println(val);
  if (val == '1')
  {
    osc_button = false;
  } else if (val == '0')
  {
    osc_button = true;
  }
}

void draw()
{
  background(255);
  stroke(0);
  fill(0);
  smooth();
  strokeWeight(sw);
  
  textSize(height/12);
  textAlign(CENTER);
  text("DIGITAL SEISMOGRAPH", width/2, height/10);
  textSize(height/80);
  textAlign(RIGHT);
  line(0, height/8, width, height/8); // line dividing menubar from wave monitor

  if (osc_button) // off mean
  {
    if (osc_toggle == false)
    {
      init_time = millis();
      osc_toggle = true;
    }
  } else if (osc_button == false) //onn mean
  {
    if (osc_toggle == true)
    {
      wave_stop_time = millis();
      t = true;
      int temp_time = millis() - init_time;
      if (temp_time < max_cons_amp_time)
      {
        amp_time = append(amp_time, temp_time); 
        Y = append(Y, y_ref -int((amp_time[amp_time.length-1]) * amp_mag_fac));  // PREVIOUSLY---> Y = append(Y, y_ref -int((amp_time[amp_time.length-1]) * amp_mag_fac));
        X = append(X, x_ref);
        
        vert_num += 1;
        
        for (int a=X.length-1; a>0; a--)
        {
          X[a] = X[a] - x_interval_dist;
        }
      }
      osc_toggle = false;
    } else if (osc_toggle == false)
    {
      int temp = millis();
      if ((temp - wave_stop_time) > wave_delay && t == true)
      {
        println("wave end");
        wave_stop_time = millis();

        Y = append(Y, y_ref);
        X = append(X, x_ref);
        amp_time = append(amp_time, 0);
        Y = append(Y, y_ref);
        X = append(X, x_ref+wave_dist/2);
        amp_time = append(amp_time, 0);


        //Register date time for this wave beat
        sec = append(sec, second());  // Values from 0 - 59
        min = append(min, minute());
        hour = append(hour, hour());

        day = append(day, day());
        month = append(month, month());
        year = append(year, year());

        ival = append(ival, X.length - 1);

        screenshot_toggle = true;

        for (int a=X.length-1; a>0; a--)
        {
          X[a] = X[a] - wave_dist;
        }
        t = false;
      }
    }
    osc_toggle = false;
  }

  for (int i = 0; i < X.length; i++)
  {

    if (i%2 == 0)
    {

      line(X[i]-(x_interval_dist/2), y_ref, X[i], abs(Y[i]));
      line(X[i], abs(Y[i]), X[i]+(x_interval_dist/2), y_ref);
    } else
    {
      line(X[i]-(x_interval_dist/2), y_ref, X[i], height - abs(Y[i]));
      line(X[i], height - abs(Y[i]), X[i]+(x_interval_dist/2), y_ref);
    }
    if (i>0)
    { 
      for (int a = 0; a<ival.length; a++)
      {
        if (i == ival[a])//( (Y[i-1] == y_ref) && (Y[i] == y_ref))
        {
          line(X[i], height/8, X[i], height);
          Time(hour[a], min[a], sec[a], day[a], month[a], year[a], X[i], height/8 + 10, a);
        }
      }
    }
  }
  if (screenshot_toggle == true)
  {
    saveFrame("quake-"+(ival.length-1)+" "+ival[ival.length-1]+" "+hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y"+".png"); // SCREEN SHOT
    screenshot_toggle = false;
  }
}
void exit()
{
  for (int i = 0; i < X.length; i++)
  {
    TableRow newRow = table.addRow();
    newRow.setInt("S.No", table.getRowCount() - 1);
    newRow.setInt("X", X[i]);
    newRow.setInt("Y", Y[i]);
    newRow.setInt("Amplitude", amp_time[i]);
    if (i>0)
    { 
      for (int a = 0; a<ival.length; a++)
      {
        if (i == ival[a])//( (Y[i-1] == y_ref) && (Y[i] == y_ref))
        {
          newRow.setString("Time Stamp", hour[a]+"h"+min[a]+"m"+sec[a]+"s"+" "+day[a]+"D"+month[a]+"M"+year[a]+"Y");
        }
      }
    }
    if (i == (X.length-1))
    {
      newRow.setString("Time Stamp", hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y");
    }
  }
  saveTable(table, "data/"+hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y"+".csv");
  saveFrame("quake-"+(ival.length-1)+" "+ival[ival.length-1]+" "+hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y"+".png"); // SCREEN SHOT
  println("Closing sketch");
}

void Time(int hour, int min, int sec, int day, int month, int year, int x, int y, int i)
{
  text(i, x, y);
  text(hour+":"+min+":"+sec, x, y+10);
  text(day+"/"+month+"/"+year, x, y+20);
}