#include <NMEAGPS.h>
#include <GPSport.h>
#include <TinyGPSPlus.h>

NMEAGPS  gps; // This parses the GPS characters
TinyGPSPlus gpsA;
gps_fix  fix; // This holds on to the latest values

// BE WARNED, THIS VERSION WAS MADE SPECIFICALLY TO simultaneously COLLECT DATA FOR MATERDAY's ML MODEL THING AND TO TEST THE COORDINATE ACCURACY
// OF THE GPS MODULE IN THE CHASSIS WITH AN ANTENNA

// IT WILL PRINT STUFF ONTO THE SERIAL TERMINAL AND THE SD CARD AT THE SAME TIME
// THE SERIAL TERMINAL WILL INCLUDE INFORMATION FROM THE DIFFERENT NMEA SENTENCES
// THE SD CARD WILL SIMPLY HAVE LONGITUDE AND LATITUDE INSIDE OF IT

// IF YOU ONLY WANT TO COLLECT DATA FOR ML TRAINING IN OR OUT OF THE CHASSIS, JUST USE THE V1 of this script


//-----------------
// Check configuration

#include <SD.h>
File file;
const int SD_CS_PIN = 10;
char filename[13];

//-----------------
// Micro SD card Setup

#ifndef NMEAGPS_PARSE_GSV
  #error You must define NMEAGPS_PARSE_GSV in NMEAGPS_cfg.h!
#endif

#ifndef NMEAGPS_PARSE_SATELLITES
  #error You must define NMEAGPS_PARSE_SATELLITES in NMEAGPS_cfg.h!
#endif

#ifndef NMEAGPS_PARSE_SATELLITE_INFO
  #error You must define NMEAGPS_PARSE_SATELLITE_INFO in NMEAGPS_cfg.h!
#endif

//-----------------

void setup() {
  Serial.begin(9600);      
  gpsPort.begin(9600);
  gpsPort.print("$PMTK314,0,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0*28\r\n");
  //Collects GSV, RMC, GGA, GSA

  while (!Serial)
    ;

  gpsPort.begin(9600);

  if (!SD.begin(SD_CS_PIN)) {
    Serial.println("SD failed");
    while (1);
  }

  file = SD.open("GPSdata.csv", FILE_WRITE);

  if (!file) {
    Serial.println("File failed");
    while(1);
  }


}

void loop() {
  if (gpsPort.available()) {
    Serial.write(gpsPort.read());
  }

    file.print(gpsA.location.lat(), 7);
    file.print( ',');
    file.print(gpsA.location.lng(), 7);
    file.print('\n');

    file.flush();

  }









