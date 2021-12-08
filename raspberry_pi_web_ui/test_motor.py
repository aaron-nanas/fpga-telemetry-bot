import serial
import time

ser = serial.Serial(port="/dev/ttyS0", 
                    baudrate=921600,
                    bytesize=serial.EIGHTBITS, 
                    parity=serial.PARITY_NONE, 
                    stopbits=serial.STOPBITS_ONE, 
                    timeout=None)

while True:
    #ser.write(int(255).to_bytes(1, 'big'))
    # time.sleep(5)
    #ser.write(int(1).to_bytes(1, 'big'))
    ser.write(int(2).to_bytes(1, 'big'))
    # time.sleep(5)