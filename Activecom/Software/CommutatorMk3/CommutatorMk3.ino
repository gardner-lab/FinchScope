
//==============[Active Commutator ]==============//
//  by WALIII                                     //
//                                                //
//                                                //    
//                                                //
//=================={ENDOSCPOE}===================//
//------------------- V 1.0 ----------------------//

#include <Stepper.h>

// change this to the number of steps on your motor
#define STEPS 200
#define NOFIELD 505L 
#define TOMILLIGAUSS 1953
int speed2 = 300;
int numSteps = 1000;


Stepper mystepper(STEPS, 9, 8, 11, 10);
Stepper mystepper2(STEPS, 8, 11, 10, 8);

// the previous reading from the analog input
  int raw = 0;   // Range : 0..1024
  int compensated = 0;                 // adjust relative to no applied field 
  int gauss = 0;
 

void setup()
{
   Serial.begin(9600);
  // set the speed of the motor to 30 RPMs
  mystepper.setSpeed(speed2); // Fastest speed is 120 rpm
  mystepper2.setSpeed(speed2);
}

void DoMeasurement()
{
  
  float raw = analogRead(0);   // Range : 0..1024
  float compensated = raw - NOFIELD;                 // adjust relative to no applied field 
  float gauss = pow(compensated * TOMILLIGAUSS,2);
  Serial.print(gauss);
  Serial.print(" Gauss ");

  if (gauss > 30)  {   Serial.println("( to the RIGHT)");
    mystepper.step(-numSteps);
    mystepper2.step(0);}
    
  else if(gauss < -30) {  Serial.println("(to the LEFT)");
     mystepper.step(numSteps);
    mystepper2.step(0);}
    
  else               Serial.println();
}

void loop()
{
  delay(10);
  DoMeasurement();
  delay(50);
  
}
