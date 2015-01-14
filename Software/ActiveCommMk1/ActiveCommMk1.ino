
//  Active Commutator
// 01.13.15
// WALIII

// Hall sensor controlled active commutator
// Inspired by: http://web.mit.edu/fee/Public/Publications/FeeLeonardo2001.pdf
// 



#include <Servo.h> 
 
Servo myservo;  
int pos = 90;    
const int analogInPin = A8;  
int sensorValue = 0;        // value read from the pot

void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600); 
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object 
}

void loop() {
  
  
  sensorValue = analogRead(analogInPin);            
 
  Serial.print("sensor = " );                       
  Serial.print(sensorValue);      

  
  if(sensorValue> 510){
      pos = pos+5;
  myservo.write(pos);
  delay(15);
}

  if(sensorValue < 490){
    pos = pos-5;
    myservo.write(pos);
    delay(15);
}

if(sensorValue > 490 && sensorValue <510){
pos = 90;
   myservo.write(pos);
}

  delay(200);                     
}
