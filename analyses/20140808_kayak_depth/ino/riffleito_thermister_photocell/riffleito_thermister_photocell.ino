#include <JeeLib.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include <RTClib.h>
#include <RTC_DS3231.h>

ISR(WDT_vect) { Sleepy::watchdogEvent(); }

int debug = 1;
int led = A2;
int photoPin = A0;
int photoReading;

RTC_DS3231 RTC;

// On the Ethernet Shield, CS is pin 4. Note that even if it's not
// used as the CS pin, the hardware CS pin (10 on most Arduino boards,
// 53 on the Mega) must be left as an output or the SD library
// functions will not work.
const int chipSelect = 7;    
int SDpower = 5;
int sensorPower = 4;

char filename[] = "LOGGER00.csv";
File dataFile;
String fileHeader = "DATETIME,RTC_TEMP_C,TEMP_C,PHOTO,BATTERY_LEVEL";

#define LOG_INTERVAL  5000 // millsec between readings

#define BATTERYPIN A3

// which analog pin to connect
#define THERMISTORPIN A1         
// resistance at 25 degrees C
#define THERMISTORNOMINAL 10000      
// temp. for nominal resistance (almost always 25 C)
#define TEMPERATURENOMINAL 25   
// how many samples to take and average, more takes longer
// but is more 'smooth'
#define NUMSAMPLES 5
// The beta coefficient of the thermistor (usually 3000-4000)
#define BCOEFFICIENT 3950
// the value of the 'other' resistor
#define SERIESRESISTOR 10000    
 
int samples[NUMSAMPLES];
 
void setup(void) {
  if (debug==1){
    Serial.begin(9600);
  }    
  
  pinMode(led, OUTPUT); 

    
  pinMode(SDpower,OUTPUT);
  pinMode(sensorPower,OUTPUT);
  digitalWrite(SDpower,LOW);
  digitalWrite(sensorPower,LOW);

  //initialize the SD card  
  if (debug==1){
    Serial.println();
    Serial.print("Initializing SD card...");
  }
  pinMode(SS, OUTPUT);
  
  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {  
    if (debug==1){
      Serial.println("Card failed, or not present");
    }
    // don't do anything more:
    while (1) ;
  }

  if (debug==1) {
    Serial.println("card initialized.");
  }
  
  for (uint8_t i = 0; i < 100; i++) {
    filename[6] = i/10 + '0';
    filename[7] = i%10 + '0';
    if (! SD.exists(filename)) {
      // only open a new file if it doesn't exist
      if (debug==1) {
        Serial.print("Writing to file: " );
        Serial.println(filename);
      }
      dataFile = SD.open(filename, FILE_WRITE);
      dataFile.println(fileHeader);
      dataFile.close();
      break;  // leave the loop!
    }
  }
  
  //shut down the SD and the sensor -- HIGH is off
  //digitalWrite(SDpower,HIGH);
  //digitalWrite(sensorPower,HIGH);
  
  pinMode(led, OUTPUT); 
  
  // for i2c for RTC
  Wire.begin();
  RTC.begin();
  
  //analogReference(EXTERNAL);
 
  // check on the RTC
  if (! RTC.isrunning()) {
    if (debug==1){
      Serial.println("RTC is NOT running!");
    }
      // following line sets the RTC to the date & time this sketch was compiled
    RTC.adjust(DateTime(__DATE__, __TIME__));
  }
  
  DateTime now = RTC.now();
  DateTime compiled = DateTime(__DATE__, __TIME__);
  if (now.unixtime() < compiled.unixtime()) {
    Serial.println("RTC is older than compile time! Updating");
    RTC.adjust(DateTime(__DATE__, __TIME__));
  }
  Serial.println();
  Serial.println(fileHeader);

}
 
void loop(void) {
  digitalWrite(led, LOW);
  //delay(200);
  
  if (debug==0) {
    Sleepy::loseSomeTime(LOG_INTERVAL); //-- will interfere with serial, so don't use when debugging 
  } else {
    delay (LOG_INTERVAL); // use when debugging -- loseSomeTime does goofy things w/ serial
  }

  // wake up the SD card and the sensor
  //digitalWrite(SDpower,LOW);
  //digitalWrite(sensorPower,LOW);

  // take thermister readings
  uint8_t i;
  float average;
 
  // take N samples in a row, with a slight delay
  for (i=0; i< NUMSAMPLES; i++) {
   samples[i] = analogRead(THERMISTORPIN);
   delay(10);
  }
 
  // average all the samples out
  average = 0;
  for (i=0; i< NUMSAMPLES; i++) {
     average += samples[i];
  }
  average /= NUMSAMPLES;
 
  //Serial.print("Average analog reading "); 
  //Serial.println(average);
 
  // convert the value to resistance
  average = 1023 / average - 1;
  average = SERIESRESISTOR / average;
  //Serial.print("Thermistor resistance "); 
  //Serial.println(average);
 
  float temp_C;
  float temp_F;
  temp_C = average / THERMISTORNOMINAL;     // (R/Ro)
  temp_C = log(temp_C);                     // ln(R/Ro)
  temp_C /= BCOEFFICIENT;                   // 1/B * ln(R/Ro)
  temp_C += 1.0 / (TEMPERATURENOMINAL + 273.15); // + (1/To)
  temp_C = 1.0 / temp_C;                    // Invert
  temp_C -= 273.15;                         // convert to C
  temp_F = temp_C*9.0/5.0 + 32.0;        // convert to F
   DateTime now = RTC.now();
  // long unixNow = now.unixtime();
  
  digitalWrite(led, HIGH);
  delay(50);
  // delay(1000);
 
  // read photo cell
  photoReading = analogRead(photoPin);  
 
//  Serial.print("Analog reading = ");
//  Serial.println(photoReading);     // the raw analog reading
   
  // Get the battery level
  int batteryLevel = analogRead(BATTERYPIN);
  
  // Onboard temp from the RTC
  // RTC.forceTempConv(true);  //DS3231 does this every 64 seconds, we are simply testing the function here
  float rtcTemp = RTC.getTempAsFloat();
  
  // make a string for assembling the data to log:
  String dataString = "";
  
  // dataString += String(unixNow);
  dataString += now.year();
  dataString += "-";
  dataString += padInt(now.month(), 2);
  dataString += "-";
  dataString += padInt(now.day(), 2);
  dataString += " ";
  dataString += padInt(now.hour(), 2);
  dataString += ":";
  dataString += padInt(now.minute(), 2);
  dataString += ":";
  dataString += padInt(now.second(), 2);
  dataString += ",";
  dataString += int2string((int) (rtcTemp*100));
  dataString += ",";
  dataString += int2string((int) (temp_C*100));
  dataString += ",";
  dataString += photoReading;
  dataString += ",";
  dataString += batteryLevel;

  // Open up the file we're going to log to!
  // dataFile = SD.open(outFileName, FILE_WRITE);
  dataFile = SD.open(filename, FILE_WRITE);
  if (!dataFile) {
    if (debug==1){
      Serial.print("Error opening file:");
      Serial.println(filename);
    }
    
    // Wait forever since we cant write data
    while (1) ;
  }
  
  // Write the string to the card
  dataFile.println(dataString);
  dataFile.close();
  
  if (debug==1) {
    Serial.println(dataString);
  }
   
  // The following line will 'save' the file to the SD card after every
  // line of data - this will use more power and slow down how much data
  // you can read but it's safer! 
  // If you want to speed up the system, remove the call to flush() and it
  // will save the file only every 512 bytes - every time a sector on the 
  // SD card is filled with data.
  // dataFile.flush();
  // dataFile.close(); //<--- may be unnecessary
 
 
  // Shut down the SD and the sensor
  // digitalWrite(SDpower,HIGH);
  // digitalWrite(sensorPower,HIGH);
  
  //delay(1000);
}

String padInt(int x, int pad) {
  String strInt = String(x);
  
  String str = "";
  
  if (strInt.length() >= pad) {
    return strInt;
  }
  
  for (int i=0; i < (pad-strInt.length()); i++) {
    str += "0";
  }
  
  str += strInt;
  
  return str;
}

String int2string(int x) {
  // formats an integer as a string assuming x is in 1/100ths
  String str = String(x);
  int strLen = str.length();
  if (strLen <= 2) {
    str = "0." + str;
  } else if (strLen <= 3) {
    str = str.substring(0, 1) + "." + str.substring(1);
  } else if (strLen <= 4) {
    str = str.substring(0, 2) + "." + str.substring(2);
  } else {
    str = "-9999";
  }
  
  return str;
}
