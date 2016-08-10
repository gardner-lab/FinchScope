
//  Active Commutator
// 01.13.15
// WALIII

// Hall sensor controlled actove commutator, driven by a servo motor
// Inspired 
// 
//
#include <Servo.h> 
 
Servo myservo;  
 
int pos = 90;    
const int analogInPin = A0;  
int sensorValue = 0;        // value read from the pot
int setpoint = 512;

void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600); 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
}

void loop() {
  
  
  sensorValue = analogRead(analogInPin);            
 
  Serial.print("sensor = " );                       
  Serial.println(sensorValue);      

  
  if(sensorValue> setpoint+15){
      pos = pos-5;
  myservo.write(pos);
  delay(15);
}

  if(sensorValue < setpoint-15){
    pos = pos+5;
    myservo.write(pos);
    delay(15);
}

if(sensorValue > setpoint-15 && sensorValue < setpoint+15){
pos = 93;
   myservo.write(pos);
}

  delay(10);                     
}
