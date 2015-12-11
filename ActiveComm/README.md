
![ScreenShot](ActiveComm.jpg)


###ActiveComm
The ActiveComm is a simple low noise active(driven by a motor and sensor) commutator designed for ABA electrophysiology and optophysiology.

Parts List:
https://docs.google.com/a/bu.edu/spreadsheets/d/18mCksBi6qS9Ah4pYq2-t6xsRfTHRStpMuj2Iyy4ihCQ/edit?usp=sharing




## Assembly

 Get 3D printed files, these can be ordered through 3D hubs, local hackerspace/makespace, or local university service.
 Boston University has mid/low-resolution 3D printing  on site.


Schematic:
![ScreenShot](schematic.png)




## Wiring:
The wiring is simple. On the Arduino:

    PIN 09: Servo output
    PIN A0: Hall sensor output


Make sure the Hall sensor is wired correctly:

![ScreenShot](hall_sensor.png)

On the serial monitor, with no magnet, pin A0 should read ~512. The sketch is programmed to do this already

Inspiration:
http://web.mit.edu/fee/Public/Publications/FeeLeonardo2001.pdf
