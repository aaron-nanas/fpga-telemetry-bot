# Description
This directory contains the overall project files.

# Top-Level Controller: Instruction Register Process

The top-level controller interfaces the following components:
- Spatial Filter FSM Controller
- Quad DC Motor Controller
- Distance Sensor
- Servo Controller

It initially receives 3 bytes from the Raspberry Pi via UART, which is turned into a 24-bit instruction stored in a register. It processes the 24-bit instruction received from the Raspberry Pi and applies enable signals accordingly

## General Flow of Instruction:

The Tx pin of the Raspberry Pi will first transmit the instructions to the top-level controller. This instruction will contain 24 bits, and the FSM controller will handle which signals should be set depending on the active mode specified.

Each byte sent will then be concatenated and stored into a register with a width of (23 downto 0)
Then, the FSM controller decodes the 24-bit data

### Drive Mode Example

If drive_mode = '1' and 3 bytes are transmitted to the FPGA such as `1111 1111 1110 0110 0000 0001`, 
then the Raspberry Pi will send this instruction sequentially as such:

```
GPIO.output(drive_mode_pin, 1)
ser.write(b'\x01') [0000 0001]
ser.write(b'\xE6') [1110 0110]
ser.write(b'\xFF') [1111 1111]
```

First Upper Byte: PWM Enable and Motor Direction: 11111111
- The upper 4 bits enable all the PWM outputs for the 4 DC motors (in this case, all of them are on)
- The lower 4 bits set the direction for the 4 DC motors (in this case, all forward)
Second Middle Byte: The duty cycle amount: 11100110
- In this case, since 11100110 = 230 in decimal, about 90% duty cycle is set for the four motors
- The range is 0 to 255
Third Lower Byte: Sets the active mode.
- Modes Available:
    - Drive Mode Enable: `0000 0001`
    - Spatial Filter Mode Enable: `0000 0010`
    - Sensor Mode Enable: `0000 0100`
    - Servo Control Enable: `0000 1000`

### Spatial Filter Mode

If spatial_filter_mode = '1' and 3 bytes are transmitted to the FPGA such as `0000 0000 0000 0001 0000 0010`, then Raspberry Pi will send this instruction sequentially as such:

```
GPIO.output(spatial_filter_mode, 1)
ser.write(b'\x02') [0000 0010]
ser.write(b'\x01') [0000 0001]
ser.write(b'\x00') [0000 0000]
```

Second Middle Byte: 
- Reserved for Spatial Filter Index
    - Example: 0000 0001 -> Chooses the Laplacian Filter
    Bits Enabled for Filters:
    - `0000 0000`: Average Filter
    - `0000 0001`: Laplacian Filter
    - `0000 0010`: Threshold Filter
    - `0000 0011`: Image Inversion

Upper Byte:
- Reserved for Threshold Value
    - Determined by the user's input from the Web UI (default of 150)

## Servo Mode Example
- The servo can be controlled if the first lower byte is set as `0000 1000`, and its position is determined by the middle byte. For instance, if the middle byte is `0000 1010`, then the servo will rotate 180 degrees in the clockwise direction.
