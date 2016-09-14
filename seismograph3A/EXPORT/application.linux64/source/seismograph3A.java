import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class seismograph3A extends PApplet {

/* seismograph v0.2 beta
 * WITH ACCEL SENSOR
 * Author: Nilay Savant
 *
 * Description : dsd projekt
 * 
 * 
 */



Serial myPort;  // Create object from Serial class
int serial_baud_rate; //baud rate or serial data transmission
String val;      // Data received from the serial port

boolean t = false; //temp var
int avg_times = 10; //no of times times to take avg of initial sensor values
int s0[] = new int[1];
int s1[] = new int[1];

//Vertices of shock waves
int X[] = new int[1];
int Y[] = new int[1];
int x_interval_dist = 10; //in pixels

// Referance - from where drawing starts on screen
int x_ref = width/2;
int y_ref = height/2;

//amplitude magnification factor 
float amp_mag_fac = 0.2f;

//osc_button_button_buttonillation simulator button (temporary)
boolean osc_button = false; 
boolean osc_toggle = false;

//time variables
float amp[] = new float[1]; // for storing the amplitude
int wave_delay = 4000; // max time after last earthquake to be considered a wave of earthquake
int wave_stop_time = 0; // time to be noted when a wave stops

int max_cons_amp = 12500; // max amp to be considered
int min_cons_amp = 1000; // min amplitude to consider  

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
boolean create_end_data_table = false; // Toggle switch for exporting separte table in the end of app

//Live data File
PrintWriter logger;

boolean screenshot_toggle = false; //For screen shot
boolean screenshot_switch = true; //Extrenally controlled screnshot switch (true to give regular screenshots, false for no screenshots)

//SENSOR
int sensor0 = 0;
int sensor1 = 0;
int sensor2 = 1; // for proximity sensor
int sensor0_d, sensor1_d; // for storing initial sensor data
float sensor_amp; // for sensor amp storage
float sensor_amp_t = 0.0f; // temp sensor amp measurement
float sensor_amp_max; // for max sensor amp storage in half a oscillation
boolean proximity = false; //If proximity sensor is present or not (def false)

boolean on = true; //for starting wait

float sw = width*height/pow(10, 4) + 0.1f; 

// SETUP FUNCTION <----------------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<
public void setup() //   <----------------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<
{
   //800,800 default
  
  t = false; //temp var
  
  serial_baud_rate = 9600; //baud rate or serial data transmission (def 9600)
  
  //amplitude magnification factor 
  amp_mag_fac = 0.2f;
  
  //osc_button_button_buttonillation simulator button (temporary)
  osc_button = false; 
  osc_toggle = false;
  
  avg_times = 10; //no of times times to take avg of initial sensor values
  
  //time variables
  wave_delay = 4000; // max time after last earthquake to be considered a wave of earthquake
  
  max_cons_amp = 12500; // max amp time to be considered
  min_cons_amp = 1000; // min amplitude to consider 
  
  on = true; //for starting wait
  
  screenshot_toggle = false; //For screen shot
  screenshot_switch = true; //Extrenally controlled screnshot switch (true to give regular screenshots, false for no screenshots) 
  
  create_end_data_table = false; // Toggle switch for exporting separte table in the end of app 

  //Reference from where drawing starts on screen
  x_ref = width-width/6; 
  y_ref = height/2;
  
  x_interval_dist = (4 * width)/800;  //Horizontal dist between waves //def (4 * width)/800; 
  wave_dist = x_interval_dist * 4; //Distance between two wave beats //def x_interval_dist * 4;
  
  proximity = false; //If proximity sensor is present or not (def false)
  
  //CONFIG FILE LOAD
  String port = null;
  float amp_mag = 0.3f;
  XML config = loadXML("data/config/config.xml"); //Loads XML config file
  XML port_xml = config.getChild("seismograph_config/port"); 
  port = port_xml.getContent();  //assigns the content from the <port> tags to port
  XML amp_mag_xml = config.getChild("seismograph_config/amp_mag_factor");
  amp_mag = amp_mag_xml.getFloatContent(); //assigns the content from the <amp_mag_factor> tags to amp_mag
  XML wave_delay_xml = config.getChild("seismograph_config/wave_delay");
  wave_delay = wave_delay_xml.getIntContent(); //assigns the content from the <wave_delay> tags to wave_delay
  XML avg_times_xml = config.getChild("seismograph_config/avg_times");
  avg_times = avg_times_xml.getIntContent();
  XML max_cons_amp_xml = config.getChild("seismograph_config/max_cons_amp");
  max_cons_amp = max_cons_amp_xml.getIntContent();
  XML min_cons_amp_xml = config.getChild("seismograph_config/min_cons_amp");
  min_cons_amp = min_cons_amp_xml.getIntContent();
  XML screenshot_switch_xml = config.getChild("seismograph_config/screenshot_switch");
  screenshot_switch = PApplet.parseBoolean(screenshot_switch_xml.getContent());
  XML create_end_data_table_xml = config.getChild("seismograph_config/create_end_data_table");
  create_end_data_table = PApplet.parseBoolean(create_end_data_table_xml.getContent());
  XML x_ref_xml = config.getChild("seismograph_config/x_ref");
  x_ref = width-width/6 + x_ref_xml.getIntContent();
  XML x_interval_dist_xml = config.getChild("seismograph_config/x_interval_dist");
  x_interval_dist = (4 * width)/800 + x_interval_dist_xml.getIntContent();
  XML serial_baud_rate_xml = config.getChild("seismograph_config/serial_baud_rate");
  serial_baud_rate = serial_baud_rate_xml.getIntContent();
  XML proximity_xml = config.getChild("seismograph_config/proximity");
  proximity = PApplet.parseBoolean(proximity_xml.getContent());

  //Start point 
  Y[0] = y_ref;
  X[0] = x_ref;

  amp[0] = 0.0f; // Starting Amplitude = 0 
  
  //amplitude magnification factor 
  println("AMP ::: "+amp_mag);
  amp_mag_fac = (amp_mag * height)/800; //defalut (0*2 * height)800
  
  wave_stop_time = 0; // time to be noted when a wave stops

  //Data Table
  table = new Table();
  table.addColumn("S.No");
  table.addColumn("X");
  table.addColumn("Y");
  table.addColumn("Amplitude");
  table.addColumn("Time Stamp");
  
  //Data File(live)
  logger = createWriter("data/"+hour()+"h"+minute()+"m"+second()+"s"+day()+"D"+month()+"M"+year()+"Y"+".csv"); 
  logger.println("S.No,X,Y,Amplitude,Time Stamp");
  
  osc_button = false; // button for wave simulation
  
  //SENSOR
  sensor0 = 0;
  sensor1 = 0;
  sensor_amp_max = 0.0f;
  sensor_amp_t = 0.0f; // temp sensor amp measurement
  sensor2 = 1; // for proximity sensor
  
  //SERIAL
  //String portName = Serial.list()[0];
  saveStrings("serial_all_ports.txt", Serial.list());
  printArray(Serial.list());
  myPort = new Serial(this, port, 9600); // REQUIRED 
  println("connected to serial: " + port);
  
}
// SERIAL EVENT <----------------------------------------<<<<<<<
public void serialEvent(Serial myPort) 
{  
  if(on)
  {
    delay(1000);
    on = false;
  } 
  if(myPort.available() > 0)
  {
 
    //get the ASCII string
    String inString = myPort.readStringUntil('\n'); // read it and store it in val
    if (inString != null) 
    {
      // trim off any whitespace:
      inString = trim(inString);
      // split the string on the commas and convert the
      // resulting substrings into an integer array:
      int[] sensors = PApplet.parseInt(split(inString, "\t"));
      // if the array has at least two elements, you know
      // you got the whole thing.  Put the numbers in the
      
      // sensor variables:
      if (proximity == true && sensors.length >= 3) 
      {
        sensor0 = sensors[0]; //ax
        sensor1 = sensors[1]; //ay
        sensor2 = sensors[2]; //Proximity
        
        if(avg_times > 0)
        {
          s0 = append(s0, sensor0);
          s1 = append(s1, sensor1);
          if(avg_times == 1)
          {
            int avg0=0, avg1=0;
           for(int a = 0; a < s0.length; a++)
           {
             avg0 = avg0 + s0[a];
             avg1 = avg1 + s1[a];
           }
           sensor0_d = PApplet.parseInt(avg0/s0.length);
           sensor1_d = PApplet.parseInt(avg1/s0.length);
          }
          
          avg_times = avg_times - 1;
        }
        sensor_amp_t = sqrt(pow(sensor0_d-sensor0,2)+pow(sensor1_d-sensor1,2));
        //println(sensor_amp_t);
        if (sensor2 == 0) // off mean
        {  
          sensor_amp = sensor_amp_t;
          osc_button = true;
        }
        else if (sensor2 == 1) // on mean
        {
          //sensor_amp = sensor_amp_t;
          osc_button = false;
        }
         
      }
      else if (proximity == false && sensors.length >= 2) 
      {
        sensor0 = sensors[0]; //ax
        sensor1 = sensors[1]; //ay
        if(avg_times > 0)
        {
          s0 = append(s0, sensor0);
          s1 = append(s1, sensor1);
          if(avg_times == 1)
          {
            int avg0=0, avg1=0;
           for(int a = 0; a < s0.length; a++)
           {
             avg0 = avg0 + s0[a];
             avg1 = avg1 + s1[a];
           }
           sensor0_d = PApplet.parseInt(avg0/s0.length);
           sensor1_d = PApplet.parseInt(avg1/s0.length);
          }
          
          avg_times = avg_times - 1;
        }
        sensor_amp_t = sqrt(pow(sensor0_d-sensor0,2)+pow(sensor1_d-sensor1,2));
        //println(sensor_amp_t);
        if (sensor_amp_t > min_cons_amp)
        {  
          sensor_amp = sensor_amp_t;
          osc_button = true;
        }
        else
        {
          osc_button = false;
        } 
      }
    }
  }
}
// DRAW FUNCTION <----------------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<
public void draw() //   <----------------------------------------------------------------------------------------<<<<<<<<<<<<<<<<<<<
{
  background(255);
  stroke(0);
  fill(0);
  smooth();
  strokeWeight(sw);
  
  textSize(height/12);
  textAlign(CENTER);
  text("SEISMOGRAPH", width/2, height/10);
  textSize(height/52);
  textAlign(CENTER);
  text("sensor_amplitude = ", width/10, height/10);
  text(sensor_amp_t, width/10 + 110, height/10);
  textSize(height/80);
  textAlign(RIGHT);
  line(0, height/8, width, height/8); // line dividing menubar from wave monitor

  if (osc_button) // off mean
  {
    if (osc_toggle == false)
    {
      sensor_amp_max = max(sensor_amp,sensor_amp_max);
      osc_toggle = true;
    }
  } 
  else if (osc_button == false) //onn mean
  {
    if (osc_toggle == true)
    {
      wave_stop_time = millis();
      t = true;
      if (sensor_amp_max < max_cons_amp)
      { 
        amp = append(amp, sensor_amp_max); 
        Y = append(Y, y_ref -PApplet.parseInt(map(amp[amp.length-1] * amp_mag_fac, 0, max_cons_amp, 0, height/2)));//int((amp[amp.length-1]) * amp_mag_fac));  // PREVIOUSLY---> Y = append(Y, y_ref -int((amp_time[amp_time.length-1]) * amp_mag_fac));
        X = append(X, x_ref);
        
        logger.println(amp.length-1+","+X[amp.length-1]+","+Y[amp.length-1]+","+amp[amp.length-1]+","); //logging data to csv file
        
        for (int a=X.length-1; a>0; a--)
        {
          X[a] = X[a] - x_interval_dist;
        }
      }
      sensor_amp_max = 0;
      osc_toggle = false;
    } 
    else if (osc_toggle == false)
    {
      int temp = millis();
      if ((temp - wave_stop_time) > wave_delay && t == true)
      {
        println("wave end");
        wave_stop_time = millis();

        Y = append(Y, y_ref);
        X = append(X, x_ref);
        amp = append(amp, 0.0f);
        logger.println(amp.length-1+","+X[amp.length-1]+","+Y[amp.length-1]+","+amp[amp.length-1]+",");
        Y = append(Y, y_ref);
        X = append(X, x_ref+wave_dist/2);
        amp = append(amp, 0.0f);
        logger.println(amp.length-1+","+X[amp.length-1]+","+Y[amp.length-1]+","+amp[amp.length-1]+","+hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y");

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
  if ((screenshot_toggle == true) && (screenshot_switch == true)) //for screenshots
  {
    saveFrame("screenshots/quake-"+(ival.length-1)+" "+ival[ival.length-1]+" "+hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y"+".png"); // SCREEN SHOT
    screenshot_toggle = false;
  }
  logger.flush(); // Writes the remaining data to the file(for live writing)
}
public void exit()
{
  if (screenshot_switch == true)
  {
    saveFrame("screenshots/quake-"+(ival.length-1)+" "+ival[ival.length-1]+" "+hour()+"h"+minute()+"m"+second()+"s"+" "+day()+"D"+month()+"M"+year()+"Y"+".png"); // SCREEN SHOT
  }
  logger.flush();  // Writes the remaining data to the file
  logger.close();
  if(create_end_data_table) // To create end data table
  {
    createDataTable();
  }
  myPort.stop();
  println("Closing sketch");
}

public void createDataTable() // creates a table from the data of arrays and saves it to a csv file with date-time name as passed in the arguments
{
  for (int i = 0; i < X.length; i++)
  {
    TableRow newRow = table.addRow();
    newRow.setInt("S.No", table.getRowCount() - 1);
    newRow.setInt("X", X[i]);
    newRow.setInt("Y", Y[i]);
    newRow.setFloat("Amplitude", amp[i]);
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
  saveTable(table, "data/"+hour()+"h"+minute()+"m"+second()+"s"+day()+"D"+month()+"M"+year()+"Y"+".csv");
  println("table exported");
}

public void Time(int hour, int min, int sec, int day, int month, int year, int x, int y, int i)
{
  text(i, x, y);
  text(hour+":"+min+":"+sec, x, y+10);
  text(day+"/"+month+"/"+year, x, y+20);
}
  public void settings() {  size(1200, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "seismograph3A" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
