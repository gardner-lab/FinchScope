## Active Commutator


ActiveCommMk1: For active commutators driven by servo motors. reads from sensor every */200ms

ActiveCommMk1: This is identical to ActiveCommMk1, but has magnet orientation swapped, and reads from sensor  */50ms.

CommutatorMk3: For quieter, stepper motor driven commutators. Requires some additional hardware (i.e. stepper motor and stepper motor driver). Additional parts may not interface smoothly with servo driven design.

## Loading the software:

As a troubleshooting measure, the code incorporates a readout of the Hall sensor value. 8bits of information gives the range from 0-1024. A lack of magnetic field should read a value of  ~512. A positive/negative magnetic deflection should give a reading above or below this reading. The code is calibrated for the sensor listed in the parts file.
