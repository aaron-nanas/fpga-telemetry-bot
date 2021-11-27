from flask import Flask, render_template, request, jsonify, flash, redirect, url_for
import time
import os
import serial
import sys
from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import RPi.GPIO as GPIO
import random

reset_pin = 4
write_enable_input_bram_pin = 23
read_enable_input_bram_pin = 24
write_enable_output_bram_pin = 27
read_enable_output_bram_pin = 22
start_filtering_pin = 26

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(reset_pin, GPIO.OUT)
GPIO.setup(write_enable_input_bram_pin, GPIO.OUT)
GPIO.setup(read_enable_input_bram_pin, GPIO.OUT)
GPIO.setup(write_enable_output_bram_pin, GPIO.OUT)
GPIO.setup(read_enable_output_bram_pin, GPIO.OUT)
GPIO.setup(start_filtering_pin, GPIO.OUT)
GPIO.output(reset_pin, 0)

app = Flask(__name__, template_folder="./templates", static_folder="./static")

ser = serial.Serial(port="/dev/ttyS0", 
                    baudrate=921600,
                    bytesize=serial.EIGHTBITS, 
                    parity=serial.PARITY_NONE, 
                    stopbits=serial.STOPBITS_ONE, 
                    timeout=None)

isRunning = False
uart_received_data_list = list()
image_grayscale_as_list = list()

'''
    This function opens the input image and converts it to grayscale.
    Then, it resizes the input image to 600x400, and converts the grayscale image into an array.
    Afterwards, it saves the the grayscale image to the image_results directory.
'''
def create_input_image_array():
    # Open the input image and convert to grayscale
    input_image = Image.open("/home/pi/ece524_proj/ece524_images/dog_image_2.jpeg").convert('L')

    # Resize the input image to 600x400
    resized_image = input_image.resize((600, 400))

    # Convert the grayscale image to an array after resizing
    image_grayscale_array = np.asarray(resized_image)

    # Pad the image with zeros:
    #padded_image_grayscale_array = np.pad(image_grayscale_array, pad_width = 1, mode = "minimum")
    padded_image_grayscale_array = np.pad(image_grayscale_array - image_grayscale_array.min(), pad_width = 1, mode = "constant")

    # Save the grayscale image
    resized_image.save("/home/pi/ece524_proj/static/input_images/dog_image_grayscale_2.jpeg")

    # Uncomment the following for showing image plot
    # Can work with via SSH with Remote Desktop Connection (Windows) or adding -Y argument when running SSH through Linux terminal
    # plt.title("Output Image")
    # plt.imsave("img_show_result.jpg", padded_image_grayscale_array, cmap="gray")
    # plt.imshow(padded_image_grayscale_array, cmap="gray")
    # plt.show()

    return padded_image_grayscale_array

'''
    This function writes the elements of the image matrix to a file.
    Used to verify that the data being received is correct.
'''
def create_file_for_input_array():
    padded_image_grayscale_array = create_input_image_array()
    num_of_arrays = len(padded_image_grayscale_array)
    print("Input Image Matrix:\n", padded_image_grayscale_array)
    print("Number of Arrays:", num_of_arrays, "\nNumber of Elements in An Array:", len(padded_image_grayscale_array[0]))

    print("Writing Array to File...")
    with open(os.path.join("/home/pi/ece524_proj/", "input_image_data.txt"), "w") as file_for_input_array:

        for array_num in range(num_of_arrays):
            for data in padded_image_grayscale_array[array_num]:
                file_for_input_array.write(f"{int(data)}\n")
                image_grayscale_as_list.append(int(data))
        
        print("Finished writing array to file")

    return image_grayscale_as_list

'''
    This function takes in a grayscale image matrix as a list.
    It transforms the list into an array, and reshapes it accordingly.
    Then, it saves the figure of the array as a grayscale image file.
'''
def reshape_and_show_image_from_list(image_grayscale_as_list):
    output_image_array = np.asarray(image_grayscale_as_list)
    reshaped_output_image_array = output_image_array.reshape(400, 600)
    plt.imsave("img_show_result_2.jpg", reshaped_output_image_array, cmap="gray")

def restart_serial_port():
    print("Restarting Serial Port")
    ser.close()
    print("Opening Serial Port")
    ser.open()

def enable_reset():
    print("Resetting FPGA")
    GPIO.output(reset_pin, 1)
    time.sleep(0.00001)
    GPIO.output(reset_pin, 0)
    time.sleep(0.00001)
    print("FPGA Reset Done")

def test_uart_loopback_1():
    global isRunning

    restart_serial_port()
    print("Starting UART Loopback Test 1")
    isRunning = True

    # Enabling Reset
    enable_reset()

    GPIO.output(write_enable_input_bram_pin, 1)
    GPIO.output(read_enable_input_bram_pin, 1)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_filtering_pin, 0)

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
    GPIO.output(start_filtering_pin, 0)
    print("UART Loopback Test 1 Done!")
    print(f"Elapsed Time: {tx_end_time - tx_start_time}\n")

def test_uart_loopback_2():
    global isRunning

    restart_serial_port()
    print("Starting UART Loopback Test 2")
    isRunning = True

    # Enabling Reset
    enable_reset()

    GPIO.output(write_enable_input_bram_pin, 1)
    GPIO.output(read_enable_input_bram_pin, 1)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_filtering_pin, 0)

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
    GPIO.output(start_filtering_pin, 0)
    print("UART Loopback Test 2 Done!")
    print(f"Elapsed Time: {tx_end_time - tx_start_time}\n")

'''
    Function: read_and_save_output_image(input_image_text_file, output_image_text_file)
'''

def read_and_save_output_image(input_image_text_file, output_image_text_file, input_image_name, output_image_name):
    input_image_list = list()
    output_image_list = list()

    with open(os.path.join("/home/pi/ece524_proj/", input_image_text_file), "r") as file_for_input_data:
        for input_data_index, input_data in enumerate(file_for_input_data):
            input_image_list.append(int(input_data))

        img_array = np.asarray(input_image_list)
        reshaped_img_array = img_array.reshape(402, 602)
        plt.imsave(input_image_name, reshaped_img_array, cmap='gray')

    with open(os.path.join("/home/pi/ece524_proj/", output_image_text_file), "r") as file_for_output_data:
        for output_data_index, output_data in enumerate(file_for_output_data):
            output_image_list.append(int(output_data))

        img_array = np.asarray(output_image_list)
        reshaped_img_array = img_array.reshape(400, 600)
        plt.imsave(output_image_name, reshaped_img_array, cmap='gray')

'''
    Function: apply_spatial_filter_to_image
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
def apply_spatial_filter_to_image(selected_filter, input_image_file, output_image_file):
    global isRunning

    restart_serial_port()
    isRunning = True
    print("Setting Up Transmission of Image Matrix")
    padded_image_grayscale_array = create_input_image_array()
    num_of_arrays = len(padded_image_grayscale_array)
    print("Input Image Matrix:\n", padded_image_grayscale_array)
    print("Number of Arrays:", num_of_arrays, "\nNumber of Elements in An Array:", len(padded_image_grayscale_array[0]))

    # Enabling Reset
    enable_reset()

    # Write image matrix to BRAM while reading the contents being sent at the same time
    GPIO.output(write_enable_input_bram_pin, 1)
    GPIO.output(read_enable_input_bram_pin, 1)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_filtering_pin, 0)
    print("Write Enable Input BRAM Status:", GPIO.input(write_enable_input_bram_pin))
    print("Read Enable Input BRAM Status:", GPIO.input(read_enable_input_bram_pin))
    print("Write Enable Output BRAM Status:", GPIO.input(write_enable_output_bram_pin))
    print("Read Enable Output BRAM Status:", GPIO.input(read_enable_output_bram_pin))
    print("Start Filter Status:", GPIO.input(start_filtering_pin))
    print("Transmitting Data from Pi to FPGA")
    print("Selected Filter:", selected_filter)

    tx_start_time = time.perf_counter()
    with open(os.path.join("/home/pi/ece524_proj/", input_image_file), "w") as file_for_input_data:
        for array_num in range(num_of_arrays):
            for input_data in padded_image_grayscale_array[array_num]:
                ser.write(int(input_data).to_bytes(1, 'big'))
                data_received = int.from_bytes(ser.read(), "big")
                file_for_input_data.write(f"{data_received}\n")
                if isRunning == False:
                    break

    print("Image Matrix Has Been Written to the FPGA")
    tx_end_time = time.perf_counter()
    print("Elapsed Time:", tx_end_time - tx_start_time)

    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    print("Starting Filter Process")
    GPIO.output(start_filtering_pin, 1)
    print("Start Filter Status:", GPIO.input(start_filtering_pin))
    time.sleep(2)
    print("Reading Data from FPGA BRAM")
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 1)
    print("Write Enable Input BRAM Status:", GPIO.input(write_enable_input_bram_pin))
    print("Read Enable Input BRAM Status:", GPIO.input(read_enable_input_bram_pin))
    print("Write Enable Output BRAM Status:", GPIO.input(write_enable_output_bram_pin))
    print("Read Enable Output BRAM Status:", GPIO.input(read_enable_output_bram_pin))

    # Reading the contents from BRAM
    rx_start_time = time.perf_counter()
    with open(os.path.join("/home/pi/ece524_proj/", output_image_file), "w") as file_for_output_data:
        for rx_row_num in range(600):
            for rx_data in range(400):
                ser.write(rx_data.to_bytes(2, 'big')) # Does not directly write to BRAM; used to signal Tx for data valid pulse
                data_received = int.from_bytes(ser.read(), "big")
                file_for_output_data.write(f"{data_received}\n")
                if isRunning == False:
                    break
    
    rx_end_time = time.perf_counter()
    print("Transmission of Data from Pi to FPGA Done")
    print("Elapsed Time:", rx_end_time - rx_start_time)
    GPIO.output(write_enable_input_bram_pin, 0)
    GPIO.output(read_enable_input_bram_pin, 0)
    GPIO.output(write_enable_output_bram_pin, 0)
    GPIO.output(read_enable_output_bram_pin, 0)
    GPIO.output(start_filtering_pin, 0)
    print("Write Enable Input BRAM Status:", GPIO.input(write_enable_input_bram_pin))
    print("Read Enable Input BRAM Status:", GPIO.input(read_enable_input_bram_pin))
    print("Write Enable Output BRAM Status:", GPIO.input(write_enable_output_bram_pin))
    print("Read Enable Output BRAM Status:", GPIO.input(read_enable_output_bram_pin))
    print("Start Filter Status:", GPIO.input(start_filtering_pin))

def receive_uart_data_from_fpga():
    restart_serial_port()
    print("Receiving UART data stream from FPGA")

def test_uart_full_duplex():
    restart_serial_port()
    print("Testing UART Full-Duplex")
    print("Processing Tx/Rx Simultaneously")

def stop_data_transmission():
    global isRunning
    if (ser.isOpen() == True):
        print("Serial Port Currently Open")
        print("Setting isRunning flag as false")
        isRunning = False
        print("Closing Serial Port")
        ser.write(b'\x00')
        ser.close()
        print("Serial Port Closed")
    else:
        print("Serial Port Already Closed")

@app.route("/", methods=['GET', 'POST'])
def index():
    print(request.method)
    input_image_name = "input_image_result.jpg"
    output_image_name = "output_filtered_image_result.jpg"
    input_image_text_file = "input_image_data_to_BRAM.txt"
    output_image_text_file = "output_image_data_from_BRAM.txt"

    if (request.method == 'POST'):
        if (request.form.get("Forward") == "Forward"):
            print("Driving the Robot Forward")

        elif request.form.get("Backward") == "Backward":
            print("Driving the Robot Backward")
            state = GPIO.input(Tx_Pin)
            if (state == True):
                print("GPIO Pin Active!")
            else:
                print("GPIO Pin LOW")

        elif (request.form.get("Apply Spatial Filter") == "Apply Spatial Filter"):
            selected_filter = str(request.form["image-filter"] + " Filter")
            print("Applying Spatial Filter to Image...")
            print("Selected Filter:", selected_filter)
            apply_spatial_filter_to_image(selected_filter, input_image_text_file, output_image_text_file)

            print("Reading Input and Output Images then Saving...")
            read_and_save_output_image(input_image_text_file, output_image_text_file, input_image_name, output_image_name)
            print("Input and Output Images Ready")

            image_results_folder = os.path.join('static', 'image_results_for_ui')
            app.config['UPLOAD_FOLDER'] = image_results_folder
            
            path_of_input_image = os.path.join(app.config['UPLOAD_FOLDER'], input_image_name)
            path_of_output_image = os.path.join(app.config['UPLOAD_FOLDER'], output_image_name)

            return render_template("index.html", applied_filter = selected_filter, input_image_src = path_of_input_image, output_image_src = path_of_output_image)
        
        elif (request.form.get("Test UART Loopback 1") == "Test UART Loopback 1"):
            test_uart_loopback_1()

        elif (request.form.get("Test UART Loopback 2") == "Test UART Loopback 2"):
            test_uart_loopback_2()

        elif (request.form.get("Stop Data Transmission") == "Stop Data Transmission"):
            stop_data_transmission()

        else:
            print("No UART Data Stream Present.")
            stop_data_transmission()

    elif request.method == 'GET':
        print("No Post Back Call")
        return render_template("index.html")

    return render_template("index.html")

if __name__ == "__main__":
    app.run(host="localhost", port=8000, debug=True)