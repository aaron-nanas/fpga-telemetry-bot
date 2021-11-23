import time
import os
import sys
import serial
import RPi.GPIO as GPIO

uart_received_data_list = list()

o_tx_pin = 4
Write_Enable_Pin = 23
Read_Enable_Pin = 24

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(o_tx_pin, GPIO.IN)
GPIO.setup(Write_Enable_Pin, GPIO.OUT)
GPIO.setup(Read_Enable_Pin, GPIO.OUT)

ser = serial.Serial(port="/dev/ttyS0", 
                    baudrate=115200, 
                    bytesize=serial.EIGHTBITS, 
                    parity=serial.PARITY_NONE, 
                    stopbits=serial.STOPBITS_ONE, 
                    timeout=None)

def test_loopback():
    GPIO.output(Write_Enable_Pin, 1)
    GPIO.output(Read_Enable_Pin, 1)
    with open(os.path.join("/home/pi/ece524_proj/", "output_image_data_3.txt"), "w") as file_for_output_data:
        for i in range(0, 240000):
            GPIO.output(Read_Enable_Pin, 1)
            ser.write(i.to_bytes(18, 'big'))
            data_transmitted = i.to_bytes(18, 'big').hex()
            print("Writing Data to FPGA:", data_transmitted)
            if (GPIO.input(o_tx_pin) == 0):
                data_received = int.from_bytes(ser.read(), "big")
                print("Data Received from FPGA:", data_received)
                uart_received_data_list.append(data_received)
                file_for_output_data.write(f"{data_received}\n")
        time.sleep(0.0001)
    
    print(uart_received_data_list)

test_loopback()
ser.write(b'\x00')
# ser.close()
# ser.open()