from flask import Flask, render_template, request, jsonify, flash, redirect, url_for
from PIL import Image
from matplotlib import pyplot as plt
import time
import os
import serial
import sys
import numpy as np
import RPi.GPIO as GPIO
import random
import logging
import ctypes
import subprocess

# Raspberry Pi GPIO Pin Definitions
reset_pin = 4
write_enable_input_bram_pin = 23
read_enable_input_bram_pin = 24
write_enable_output_bram_pin = 27
read_enable_output_bram_pin = 22
rx_instruction_active = 6

# Raspberry Pi GPIO Pin Configuration
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(reset_pin, GPIO.OUT)
GPIO.setup(write_enable_input_bram_pin, GPIO.OUT)
GPIO.setup(read_enable_input_bram_pin, GPIO.OUT)
GPIO.setup(write_enable_output_bram_pin, GPIO.OUT)
GPIO.setup(read_enable_output_bram_pin, GPIO.OUT)
GPIO.setup(rx_instruction_active, GPIO.OUT)
GPIO.output(reset_pin, 0)
GPIO.output(rx_instruction_active, 0)

# Initializes the constructor for Flask, specifying the template/static folders for the web UI
app = Flask(__name__, template_folder="./templates", static_folder="./static")

# Initializes the serial port of the Raspberry Pi, with a baud rate of 921600
# Change port name when using a different port
ser = serial.Serial(port="/dev/ttyS0", 
                    baudrate=921600,
                    bytesize=serial.EIGHTBITS, 
                    parity=serial.PARITY_NONE, 
                    stopbits=serial.STOPBITS_ONE, 
                    timeout=None)

# Global variable used to indicate whether or not there is a currently running function
isRunning = False

# Global Counter Variable for Servo Position
servo_position_counter = 1

# Initializing parameters used for the original input image and the save file path after it has been resized and converted to grayscale
camera_input_image = "/home/pi/ece524_proj/ece524_images/input_image.jpg"
sample_input_image = "/home/pi/ece524_proj/ece524_images/dog_image_1.jpg"
input_image_save_file_path = "/home/pi/ece524_proj/static/input_images/saved_input_image.jpg"

def capture_still_photo():
    logging.info("Capturing still photo...")
    subprocess.run(["libcamera-jpeg", "-o", "ece524_images/input_image.jpg"])
    logging.info("Input image has been captured!")

'''
    Function: restart_serial_port()
    Parameters: None
    This function restarts the serial port on the Raspberry Pi.
    Closes the serial port then immediately opens it.
'''
def restart_serial_port():
    logging.info("Restarting Serial Port")
    ser.close()
    logging.info("Opening Serial Port")
    ser.open()

'''
    Function: enable_reset()
    Parameters: None
    This function will enable the RESET pin on the FPGA high
    for a short amount of time, and sets it back to low.
'''
def enable_reset():
    logging.info("Resetting FPGA")
    GPIO.output(reset_pin, 1)
    time.sleep(0.00001)
    GPIO.output(reset_pin, 0)
    time.sleep(0.00001)
    logging.info("FPGA Reset Done")

'''
    Function: create_input_image_array():
    Parameters: None
    
    This function opens the input image and converts it to grayscale.
    Then, it resizes the input image to 600x400, and converts the grayscale image into an array.
    Afterwards, it saves the the grayscale image to the image_results directory.

    It returns the image array after it has been resized and padded with zeros.
'''
def create_input_image_array(camera_input_image, sample_input_image, input_image_save_file_path, camera_mode_status):
    if (camera_mode_status == "on"):
        # Take a still photo with the camera and save
        capture_still_photo()
        # Open the input image and convert to grayscale
        logging.info("Reading the image and converting it to grayscale...")
        input_image = Image.open(camera_input_image).convert('L')
    else:
        # Open the input image and convert to grayscale
        logging.info("Reading the image and converting it to grayscale...")
        input_image = Image.open(sample_input_image).convert('L')
    
    # Resize the input image to 600x400
    logging.info("Resizing the original image to 600 x 400...")
    resized_image = input_image.resize((600, 400))

    # Convert the grayscale image to an array after resizing
    logging.info("Converting the resized image to a Numpy array...")
    image_grayscale_array = np.asarray(resized_image)

    # Pad the image with zeros:
    logging.info("Padding the resized array with zeros...")
    padded_image_grayscale_array = np.pad(image_grayscale_array - image_grayscale_array.min(), pad_width = 1, mode = "constant")

    # Save the grayscale image
    logging.info(f"Resized and padded image has been saved to the following directory: \n {input_image_save_file_path}")
    resized_image.save(input_image_save_file_path)

    return padded_image_grayscale_array

'''
    Function: create_file_for_input_array()
    Parameters: None

    This function writes the elements of the image matrix to a file.
    Used to verify that the data being received is correct.
'''
def create_file_for_input_array():
    image_grayscale_as_list = list()
    padded_image_grayscale_array = create_input_image_array(camera_input_image, sample_input_image, input_image_save_file_path, camera_mode_status)
    num_of_arrays = len(padded_image_grayscale_array)
    logging.info(f"Input Image Matrix: \n{padded_image_grayscale_array}")
    logging.info(f"Number of Arrays: {num_of_arrays}")
    logging.info(f"Number of Elements in An Array: {len(padded_image_grayscale_array[0])}")
    logging.info("Writing Array to File...")
    with open(os.path.join("/home/pi/ece524_proj/", "input_image_data.txt"), "w") as file_for_input_array:

        for array_num in range(num_of_arrays):
            for data in padded_image_grayscale_array[array_num]:
                file_for_input_array.write(f"{int(data)}\n")
                image_grayscale_as_list.append(int(data))
        
        logging.info("Finished writing array to file")

    return image_grayscale_as_list

'''
    Function: send_image_instruction(selected_filter)
    Parameters:
        - selected_filter: The name of the filter selected by the user
        from the web UI. Type: str
        - selected_threshold_value_int: The threshold value selected by the user using the slider
    
    This function sends the instruction (24-bits total) to the FPGA.
    The first byte will enable the spatial filter process and disables
    the other modes. During execution, the rx_instruction_active is set high,
    and after the instruction has been set, it sets rx_instruction_active to low.

    The second byte will contain the values for filter_select.
    The third byte currently does not have a significant purpose.
'''
def send_image_instruction(selected_filter, selected_threshold_value_int):
    logging.info("Start of Rx Image Instruction")
    GPIO.output(rx_instruction_active, 1)
    if (selected_filter == "Smoothing Filter"):
        ser.write(int(2).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
    if (selected_filter == "Laplacian Edge Detection Filter"):
        ser.write(int(2).to_bytes(1, 'big'))
        ser.write(int(1).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
    if (selected_filter == "Threshold Filter"):
        logging.info(f"Threshold Value: {selected_threshold_value_int}")
        ser.write(int(2).to_bytes(1, 'big'))
        ser.write(int(2).to_bytes(1, 'big'))
        ser.write(selected_threshold_value_int.to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
    if (selected_filter == "Image Inversion Filter"):
        ser.write(int(2).to_bytes(1, 'big'))
        ser.write(int(3).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
        ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)
    logging.info("Image Instruction Sent to FPGA")

'''
    Function: test_uart_loopback_1()
    Parameters: None

    This function serves to test the UART communication between the Raspberry Pi and the FPGA.
    First, it restarts the Raspberry Pi's serial port and then enable the RESET pin of the FPGA.
    Then, it transmits the values 0 to 255 to the FPGA and reads it back. The results are
    written to the log file "test_uart_loopback_1_log.txt".
'''
def test_uart_loopback_1():
    global isRunning

    restart_serial_port()
    logging.info("Starting UART Loopback Test 1")
    isRunning = True

    # Enabling Reset
    enable_reset()

    GPIO.output(write_enable_input_bram_pin, 1)
    GPIO.output(read_enable_input_bram_pin, 1)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_rx_instruction, 0)

    tx_start_time = time.perf_counter()
    with open(os.path.join("/home/pi/ece524_proj/", "test_logs/test_uart_loopback_1_log.txt"), "w") as file_for_output_data:
        for data_transmitted in range(0, 255):
            ser.write(data_transmitted.to_bytes(1, 'big'))
            file_for_output_data.write(f"[Tx] Data Written to FPGA: {data_transmitted}\n")
            data_received = int.from_bytes(ser.read(), "big")
            file_for_output_data.write(f"[Rx] Data Received from FPGA: {data_received}\n")
            if isRunning == False:
                break

        tx_end_time = time.perf_counter()
        file_for_output_data.write(f"Elapsed Time: {tx_end_time - tx_start_time}\n")
    
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_rx_instruction, 0)
    logging.info("UART Loopback Test 1 Done!")
    logging.info(f"Elapsed Time: {tx_end_time - tx_start_time}\n")

'''
    Function: test_uart_loopback_2()
    Parameters: None

    This function serves to test the UART communication between the Raspberry Pi and the FPGA.
    First, it restarts the Raspberry Pi's serial port and then enable the RESET pin of the FPGA.
    Then, it transmits random values in the range of 0 to 255 to the FPGA and reads it back. The results are
    written to the log file "test_uart_loopback_2_log.txt".
'''
def test_uart_loopback_2():
    global isRunning

    restart_serial_port()
    logging.info("Starting UART Loopback Test 2")
    isRunning = True

    # Enabling Reset
    enable_reset()

    GPIO.output(write_enable_input_bram_pin, 1)
    GPIO.output(read_enable_input_bram_pin, 1)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_rx_instruction, 0)

    tx_start_time = time.perf_counter()
    with open(os.path.join("/home/pi/ece524_proj/", "test_logs/test_uart_loopback_2_log.txt"), "w") as file_for_output_data:
        for i in range(255):
            for j in range(255):
                random_int_data = random.randrange(0, 255)
                ser.write(random_int_data.to_bytes(1, 'big'))
                file_for_output_data.write(f"[Tx] Data Written to FPGA: {random_int_data}\n")
                data_received = int.from_bytes(ser.read(), "big")
                file_for_output_data.write(f"[Rx] Data Received from FPGA: {data_received}\n")
                if isRunning == False:
                    break

        tx_end_time = time.perf_counter()
        file_for_output_data.write(f"Elapsed Time: {tx_end_time - tx_start_time}\n")
    
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_rx_instruction, 0)
    logging.info("UART Loopback Test 2 Done!")
    logging.info(f"Elapsed Time: {tx_end_time - tx_start_time}\n")

'''
    Function: read_and_save_image(input_image_text_file, output_image_text_file, input_image_name, output_image_name)
    Parameters:
        - input_image_text_file: The name of the file that contains the input image that
        was transmitted and read back from the FPGA
        - output_image_text_file: The name of the file that contains the output image after
        it has been processed by the spatial filter. This is read back from the FPGA's output BRAM.
        - input_image_name: The name of the input image file that is saved in the "static" directory
        - output_image_name: The name of the output image file that is saved in the "static" directory

    This function is responsible for the following tasks:
        - Reads the input/output image file and appends the data to a list
        - Converts this list to a Numpy array
        - Reshapes the array to the specified num_rows and num_cols
        - Plots the image array and saves it in the specified directory

'''

def read_and_save_image(input_image_text_file, output_image_text_file, input_image_name, output_image_name):
    input_image_list = list()
    output_image_list = list()

    with open(os.path.join("/home/pi/ece524_proj/", input_image_text_file), "r") as file_for_input_data:
        for input_data_index, input_data in enumerate(file_for_input_data):
            input_image_list.append(int(input_data))

        img_array = np.asarray(input_image_list)
        reshaped_img_array = img_array.reshape(402, 602) # Input Image: 402 rows and 602 columns (Padded)
        plt.imsave(input_image_name, reshaped_img_array, cmap='gray')

    with open(os.path.join("/home/pi/ece524_proj/", output_image_text_file), "r") as file_for_output_data:
        for output_data_index, output_data in enumerate(file_for_output_data):
            output_image_list.append(int(output_data))

        img_array = np.asarray(output_image_list)
        reshaped_img_array = img_array.reshape(400, 600) # Output Image: 400 rows and 600 columns
        plt.imsave(output_image_name, reshaped_img_array, cmap='gray')

'''
    Function: apply_spatial_filter_to_image(selected_filter, input_image_file, output_image_file)
    Parameters:
        - selected_filter: The name of the filter selected by the user
        - input_image_file: The name of the text file that the input image is written to
        - output_image_file: The name of the text file that the output image is written to
    
    This function will transmit the image matrix to the FPGA, and once the FPGA has finished
    applying the filter, it will output back the contents of the output BRAM to the
    Raspberry Pi. Then, the data received will be written to an output file.
    The function read_and_save_output_image() will be called in order to read the output file
    and save the matrix as an image file.
'''
def apply_spatial_filter_to_image(selected_filter, input_image_file, output_image_file, selected_threshold_value_int, camera_mode_status):
    global isRunning

    restart_serial_port()
    isRunning = True
    logging.info("Setting Up Transmission of Image Matrix...")
    padded_image_grayscale_array = create_input_image_array(camera_input_image, sample_input_image, input_image_save_file_path, camera_mode_status)
    num_of_arrays = len(padded_image_grayscale_array)
    logging.info(f"Input Image Matrix: \n{padded_image_grayscale_array}")
    logging.info(f"Number of Arrays: {num_of_arrays}")
    logging.info(f"Number of Elements in An Array: {len(padded_image_grayscale_array[0])}")

    enable_reset()

    # Write image matrix to BRAM while reading the contents being sent at the same time
    GPIO.output(write_enable_input_bram_pin, 1)
    GPIO.output(read_enable_input_bram_pin, 1)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(rx_instruction_active, 0)
    logging.info(f"Write Enable Input BRAM Status: {GPIO.input(write_enable_input_bram_pin)}")
    logging.info(f"Read Enable Input BRAM Status: {GPIO.input(read_enable_input_bram_pin)}")
    logging.info(f"Write Enable Output BRAM Status: {GPIO.input(write_enable_output_bram_pin)}")
    logging.info(f"Read Enable Output BRAM Status: {GPIO.input(read_enable_output_bram_pin)}")
    logging.info("Transmitting Image Matrix from Raspberry Pi to FPGA's Input BRAM...")

    tx_start_time = time.perf_counter()
    with open(os.path.join("/home/pi/ece524_proj/", input_image_file), "w") as file_for_input_data:
        for array_num in range(num_of_arrays):
            for input_data in padded_image_grayscale_array[array_num]:
                ser.write(int(input_data).to_bytes(1, 'big'))
                data_received = int.from_bytes(ser.read(), "big")
                file_for_input_data.write(f"{data_received}\n")
                if isRunning == False:
                    break

    logging.info("Image Matrix Has Been Sent to the FPGA")
    tx_end_time = time.perf_counter()
    logging.info(f"Elapsed Time: {tx_end_time - tx_start_time}")

    # Set all enable pins LOW
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)

    # Send Instruction for Spatial Filter to FPGA
    logging.info("Starting Filter Process")
    send_image_instruction(selected_filter, selected_threshold_value_int)
    time.sleep(2)

    logging.info("Reading Data from FPGA Output BRAM")
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 1)
    logging.info(f"Write Enable Input BRAM Status: {GPIO.input(write_enable_input_bram_pin)}")
    logging.info(f"Read Enable Input BRAM Status: {GPIO.input(read_enable_input_bram_pin)}")
    logging.info(f"Write Enable Output BRAM Status: {GPIO.input(write_enable_output_bram_pin)}")
    logging.info(f"Read Enable Output BRAM Status: {GPIO.input(read_enable_output_bram_pin)}")

    # Reading the contents from BRAM
    rx_start_time = time.perf_counter()
    with open(os.path.join("/home/pi/ece524_proj/", output_image_file), "w") as file_for_output_data:
        for rx_row_num in range(600):
            for rx_data in range(400):
                ser.write(rx_data.to_bytes(2, 'big')) # Does not directly write to BRAM; used to signal Tx for data valid pulse
                if (selected_filter == "Laplacian Edge Detection Filter"):
                    data_received = ctypes.c_byte(int.from_bytes(ser.read(), "big")).value
                else:
                    data_received = int.from_bytes(ser.read(), "big")
                file_for_output_data.write(f"{data_received}\n")
                if isRunning == False:
                    break
    
    rx_end_time = time.perf_counter()
    logging.info("Transmission of Data from Raspberry Pi to FPGA Done!")
    logging.info(f"Elapsed Time: {tx_end_time - tx_start_time}")
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    logging.info(f"Write Enable Input BRAM Status: {GPIO.input(write_enable_input_bram_pin)}")
    logging.info(f"Read Enable Input BRAM Status: {GPIO.input(read_enable_input_bram_pin)}")
    logging.info(f"Write Enable Output BRAM Status: {GPIO.input(write_enable_output_bram_pin)}")
    logging.info(f"Read Enable Output BRAM Status: {GPIO.input(read_enable_output_bram_pin)}")

'''
    Function: stop_data_transmission()
    Parameters: None

    This function checks if the Raspberry Pi's serial port is open. It closes an open serial port, then sets the isRunning flag false.
'''
def stop_data_transmission():
    global isRunning
    if (ser.isOpen() == True):
        logging.info("Serial Port Currently Open")
        logging.info("Setting isRunning flag as false")
        isRunning = False
        logging.info("Closing Serial Port")
        ser.write(b'\x00')
        ser.close()
        logging.info("Serial Port Closed")
    else:
        logging.warning("Serial Port Already Closed")

def move_forward(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(63).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_backward(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(207).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_left(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(175).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_right(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(95).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_diagonal_forward_left(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(54).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_diagonal_forward_right(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(57).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_diagonal_backward_left(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(201).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_diagonal_backward_right(selected_duty_cycle_int):
    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(198).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def spin_counterclockwise(selected_duty_cycle_int):

    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(15).to_bytes(1, 'big')) # Set as 0000 1111
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def spin_clockwise(selected_duty_cycle_int):

    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(1).to_bytes(1, 'big'))   # Active Mode: 0000 0001
    ser.write(selected_duty_cycle_int.to_bytes(1, 'big')) # Duty Cycle: Speed Level
    ser.write(int(255).to_bytes(1, 'big')) # Set as 1111 1111 (Motor Direction | PWM Enable)
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)

    time.sleep(2)
    stop_motors()

    logging.info("Drive Instruction Sent to FPGA")

def move_square_pattern(selected_duty_cycle_int):

    move_right(selected_duty_cycle_int)
    move_backward(selected_duty_cycle_int)
    move_left(selected_duty_cycle_int)
    move_forward(selected_duty_cycle_int)

def move_all_directions(selected_duty_cycle_int):

    move_forward(selected_duty_cycle_int)
    move_backward(selected_duty_cycle_int)
    move_left(selected_duty_cycle_int)
    move_right(selected_duty_cycle_int)
    move_diagonal_forward_left(selected_duty_cycle_int)
    move_diagonal_forward_right(selected_duty_cycle_int)
    move_diagonal_backward_left(selected_duty_cycle_int)
    move_diagonal_backward_right(selected_duty_cycle_int)
    spin_counterclockwise(selected_duty_cycle_int)
    spin_clockwise(selected_duty_cycle_int)

def stop_motors():

    enable_reset()

    logging.info("Start of Rx Drive Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)
    logging.info("Drive Instruction Sent to FPGA")

def move_camera_left(servo_position_counter):
    enable_reset()

    logging.info("Start of Rx Servo Camera Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(4).to_bytes(1, 'big'))
    ser.write(int(servo_position_counter).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)
    logging.info("Servo Camera Instruction Sent to FPGA")

def move_camera_right(servo_position_counter):
    enable_reset()

    logging.info("Start of Rx Servo Camera Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(4).to_bytes(1, 'big'))
    ser.write(int(servo_position_counter).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)
    logging.info("Servo Camera Instruction Sent to FPGA")

def move_camera_180_degrees():
    enable_reset()

    logging.info("Start of Rx Servo Camera Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(4).to_bytes(1, 'big'))
    ser.write(int(10).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)
    logging.info("Servo Camera Instruction Sent to FPGA")

def reset_servo_camera_position():
    enable_reset()

    logging.info("Start of Rx Servo Camera Instruction")
    GPIO.output(rx_instruction_active, 1)
    ser.write(int(4).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    ser.write(int(0).to_bytes(1, 'big'))
    GPIO.output(rx_instruction_active, 0)
    logging.info("Servo Camera Instruction Sent to FPGA")

# No caching at all for API endpoints.
@app.after_request
def add_header(response):
    # response.cache_control.no_store = True
    response.headers['Cache-Control'] = 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0, max-age=0'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '-1'
    return response

# Primary Flask function that handles user requests from the web UI
@app.route("/", methods=['GET', 'POST'])
def index():
    global servo_position_counter
    logging.info(request.method)
    input_image_name = "static/input_image_result.jpg"
    output_image_name = "static/output_filtered_image_result.jpg"
    input_image_text_file = "input_image_data_to_BRAM.txt"
    output_image_text_file = "output_image_data_from_BRAM.txt"

    if (request.method == 'POST'):
        if (request.form.get("Spin Counter-Clockwise") == "Spin Counter-Clockwise"):
            logging.info("Spinning the Robot Counter-Clockwise")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            spin_counterclockwise(selected_duty_cycle_int)
            
        elif request.form.get("Spin Clockwise") == "Spin Clockwise":
            logging.info("Spinning the Robot Clockwise")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            spin_clockwise(selected_duty_cycle_int)
        
        elif request.form.get("Forward") == "Forward":
            logging.info("Moving the Robot Forward")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_forward(selected_duty_cycle_int)
        
        elif request.form.get("Backward") == "Backward":
            logging.info("Moving the Robot Backward")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_backward(selected_duty_cycle_int)
        
        elif request.form.get("Left") == "Left":
            logging.info("Moving the Robot Left")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_left(selected_duty_cycle_int)

        elif request.form.get("Right") == "Right":
            logging.info("Moving the Robot Right")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_right(selected_duty_cycle_int)
        
        elif request.form.get("Diagonal Forward Left") == "Diagonal Forward Left":
            logging.info("Moving the Robot Diagonal Forward Left")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_diagonal_forward_left(selected_duty_cycle_int)

        elif request.form.get("Diagonal Forward Right") == "Diagonal Forward Right":
            logging.info("Moving the Robot Diagonal Forward Right")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_diagonal_forward_right(selected_duty_cycle_int)

        elif request.form.get("Diagonal Backward Left") == "Diagonal Backward Left":
            logging.info("Moving the Robot Diagonal Backward Left")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_diagonal_backward_left(selected_duty_cycle_int) 

        elif request.form.get("Diagonal Backward Right") == "Diagonal Backward Right":
            logging.info("Moving the Robot Diagonal Backward Right")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_diagonal_backward_right(selected_duty_cycle_int) 

        elif request.form.get("Square Pattern") == "Square Pattern":
            logging.info("Moving the Robot Square Pattern")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_square_pattern(selected_duty_cycle_int) 

        elif request.form.get("All Directions") == "All Directions":
            logging.info("Moving the Robot in All Directions")
            selected_duty_cycle = str(request.form["motor_speed_slider"])
            selected_duty_cycle_int = int(selected_duty_cycle)
            logging.info(f"Threshold Value: {selected_duty_cycle_int}")
            move_all_directions(selected_duty_cycle_int) 

        elif request.form.get("Stop Motors") == "Stop Motors":
            logging.info("Stopping the Robot")
            stop_motors()

        elif request.form.get("Reset FPGA") == "Reset FPGA":
            enable_reset()
        
        elif request.form.get("Move Camera Left") == "Move Camera Left":
            logging.info("Moving the Camera to the Left")
            if (servo_position_counter < 2):
                servo_position_counter = 1
            else:
                servo_position_counter = servo_position_counter - 1

            logging.info(f"Servo Counter: {servo_position_counter}")
            move_camera_left(servo_position_counter)
        
        elif request.form.get("Move Camera Right") == "Move Camera Right":
            logging.info("Moving the Camera to the Right")
            if (servo_position_counter > 9):
                servo_position_counter = 10
            else:
                servo_position_counter = servo_position_counter + 1
            
            logging.info(f"Servo Counter: {servo_position_counter}")
            move_camera_right(servo_position_counter)
        
        elif request.form.get("Move Camera 180 Degrees") == "Move Camera 180 Degrees":
            logging.info("Moving the Camera 180 Degrees")
            move_camera_180_degrees()
        
        elif request.form.get("Reset Position") == "Reset Position":
            servo_position_counter = 1
            print("Servo Counter:", servo_position_counter)
            reset_servo_camera_position()

        elif (request.form.get("Apply Spatial Filter") == "Apply Spatial Filter"):
            selected_filter = str(request.form["image-filter"] + " Filter")
            selected_threshold_value = str(request.form["threshold_slider"])
            selected_threshold_value_int = int(selected_threshold_value)
            camera_mode_status = str(request.form.get("camera-trigger-switch"))

            logging.info(f"Camera Mode Status: {camera_mode_status}")
            logging.info(f"Threshold Value: {selected_threshold_value}")
        
            logging.info("Applying Spatial Filter to Image...")
            logging.info(f"Selected Filter: {selected_filter}")
            apply_spatial_filter_to_image(selected_filter, input_image_text_file, output_image_text_file, selected_threshold_value_int, camera_mode_status)
            logging.info("Spatial Filter Has Been Applied!")
            logging.info("Reading Input and Output Images...")
            logging.info("Saving Images...")
            read_and_save_image(input_image_text_file, output_image_text_file, input_image_name, output_image_name)
            logging.info("Input and Output Images Ready!")
            
            return render_template("index.html", applied_filter = selected_filter)
        
        elif (request.form.get("Test UART Loopback 1") == "Test UART Loopback 1"):
            test_uart_loopback_1()

        elif (request.form.get("Test UART Loopback 2") == "Test UART Loopback 2"):
            test_uart_loopback_2()

        elif (request.form.get("Stop Data Transmission") == "Stop Data Transmission"):
            stop_data_transmission()

        else:
            logging.info("No UART Data Stream Present.")
            stop_data_transmission()

    elif request.method == 'GET':
        logging.info("No Post Back Call")
        return render_template("index.html")

    return render_template("index.html")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                format="[%(asctime)s.%(msecs)06d] [%(levelname)s] %(message)s",
                datefmt="%Y-%m-%d %H:%M:%S",
                handlers=[
                    logging.FileHandler(filename="web_ui_logs.txt", 
                    mode="w"),
                    logging.StreamHandler()
                ])

    if (os.path.exists("static/input_image_result.jpg")):
        os.remove("static/input_image_result.jpg")
    if (os.path.exists("static/output_filtered_image_result.jpg")):
        os.remove("static/output_filtered_image_result.jpg")
    if (os.path.exists("input_image_data_to_BRAM.txt")):
        os.remove("input_image_data_to_BRAM.txt")
    if (os.path.exists("output_image_data_from_BRAM.txt")):
        os.remove("output_image_data_from_BRAM.txt")

    app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
    app.config['TEMPLATES_AUTO_RELOAD'] = True
    app.run(host="localhost", port=8000, debug=True)
