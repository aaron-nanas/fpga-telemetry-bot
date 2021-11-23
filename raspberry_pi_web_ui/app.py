from flask import Flask, render_template, request
import time
import os
import serial
import sys
from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import RPi.GPIO as GPIO

write_enable_pin = 23
read_enable_pin = 24

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(write_enable_pin, GPIO.OUT)
GPIO.setup(read_enable_pin, GPIO.OUT)

app = Flask(__name__, template_folder="./templates", static_folder="./static")
ser = serial.Serial(port="/dev/ttyS0", 
                    baudrate=115200, 
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
    input_image = Image.open("/home/pi/ece524_proj/ece524_images/flower_image_1.jpg").convert('L')

    # Resize the input image to 600x400
    resized_image = input_image.resize((600, 400))

    # Convert the grayscale image to an array after resizing
    image_grayscale_array = np.asarray(resized_image)

    # Save the grayscale image
    resized_image.save("/home/pi/ece524_proj/image_results/flower_image_1_grayscale.jpg")

    # Uncomment the following for showing image plot
    # Can work with via SSH with Remote Desktop Connection (Windows) or adding -Y argument when running SSH through Linux terminal
    # plt.title("Output Image")
    # plt.imsave("img_show_result.jpg", image_grayscale_array, cmap="gray")
    # plt.imshow(image_grayscale_array, cmap="gray")
    # plt.show()

    return image_grayscale_array

'''
    This function writes the elements of the image matrix to a file.
    Used to verify that the data being received is correct.
'''
def create_file_for_input_array():
    image_grayscale_array = create_input_image_array()
    num_of_arrays = len(image_grayscale_array)
    print("Input Image Matrix:\n", image_grayscale_array)
    print("Number of Arrays:", num_of_arrays, "\nNumber of Elements in An Array:", len(image_grayscale_array[0]))
    newline_char = "\n"

    print("Writing Array to File...")
    with open(os.path.join("/home/pi/ece524_proj/", "input_image_data.txt"), "w") as file_for_input_array:

        for array_num in range(num_of_arrays):
            for data in image_grayscale_array[array_num]:
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

def test_uart_loopback():
    global isRunning

    restart_serial_port()
    print("Transmitting Data from Pi to FPGA")
    isRunning = True

    image_grayscale_array = create_input_image_array()
    num_of_arrays = len(image_grayscale_array)
    print("Input Image Matrix:\n", image_grayscale_array)
    print("Number of Arrays:", num_of_arrays, "\nNumber of Elements in An Array:", len(image_grayscale_array[0]))

    with open(os.path.join("/home/pi/ece524_proj/", "input_image_data.txt"), "w") as file_for_input_data, open(os.path.join("/home/pi/ece524_proj/", "output_image_data.txt"), "w") as file_for_output_data:
        for array_num in range(num_of_arrays):
            for data in image_grayscale_array[array_num]:
                ser.write(int(data).to_bytes(1, 'big'))
                data_transmitted =  data #int(data).to_bytes(1, 'big').hex()
                print("Writing Data to FPGA:", data_transmitted)
                file_for_input_data.write(f"{data_transmitted}\n")
                data_received = int.from_bytes(ser.read(), "big")
                uart_received_data_list.append(data_received)
                print("Data Transmitted:", data_received)
                file_for_output_data.write(f"{data_received}\n")
                if isRunning == False:
                    break

'''
    Function: transmit_uart_data_from_pi
    
    This function will transmit a data stream of bytes every two seconds
    from the Raspberry Pi's TX pin to the FPGA's RX pin.
'''
def test_transmit_uart_data_from_pi():
    global isRunning

    restart_serial_port()
    isRunning = True
    print("Setting Up Transmission of Image Matrix")
    image_grayscale_array = create_input_image_array()
    num_of_arrays = len(image_grayscale_array)
    print("Input Image Matrix:\n", image_grayscale_array)
    print("Number of Arrays:", num_of_arrays, "\nNumber of Elements in An Array:", len(image_grayscale_array[0]))

    # Write image matrix to BRAM while reading the contents being sent at the same time
    GPIO.output(write_enable_pin, 1)
    GPIO.output(read_enable_pin, 1)
    print("Write Enable Status:", GPIO.input(write_enable_pin))
    print("Read Enable Status:", GPIO.input(read_enable_pin))
    print("Transmitting Data from Pi to FPGA")
    with open(os.path.join("/home/pi/ece524_proj/", "input_image_data.txt"), "w") as file_for_input_data, open(os.path.join("/home/pi/ece524_proj/", "output_image_data.txt"), "w") as file_for_output_data:
        for array_num in range(num_of_arrays):
            for data in image_grayscale_array[array_num]:
                ser.write(int(data).to_bytes(1, 'big'))
                data_transmitted = data #int(data).to_bytes(1, 'big').hex()
                print("Writing Data to FPGA:", data_transmitted)
                file_for_input_data.write(f"{data_transmitted}\n")
                data_received = int.from_bytes(ser.read(), "big")
                #uart_received_data_list.append(data_received)
                print("Data Transmitted:", data_received)
                file_for_output_data.write(f"{data_received}\n")
                if isRunning == False:
                    break

    print("Image Matrix Has Been Written to the FPGA")
    time.sleep(1)
    GPIO.output(write_enable_pin, 0)
    GPIO.output(read_enable_pin, 1)
    print("Write Enable Status:", GPIO.input(write_enable_pin))
    print("Read Enable Status:", GPIO.input(read_enable_pin))
    print("Reading Data from FPGA BRAM")
    # Reading the contents from BRAM
    with open(os.path.join("/home/pi/ece524_proj/", "output_image_data_2.txt"), "w") as file_for_output_data:
        for i in range(0, 240000):
            ser.write(i.to_bytes(18, 'big'))
            data_transmitted = i.to_bytes(18, 'big').hex()
            print("Writing Data to FPGA:", data_transmitted)
            data_received = int.from_bytes(ser.read(), "big")
            #uart_received_data_list.append(data_received)
            print("Data Received from FPGA:", data_received)
            file_for_output_data.write(f"{data_received}\n")
            if isRunning == False:
                break

    GPIO.output(write_enable_pin, 0)
    GPIO.output(read_enable_pin, 0)
    print("Write Enable Status:", GPIO.input(write_enable_pin))
    print("Read Enable Status:", GPIO.input(read_enable_pin))
    print("Transmission of Data from Pi to FPGA Done")

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
    if (request.method == 'POST'):
        if (request.form.get("Forward") == "Forward"):
            print("Driving the Robot Forward")
            test_transmit_uart_data_from_pi()
        elif request.form.get("Backward") == "Backward":
            print("Driving the Robot Backward")
            state = GPIO.input(Tx_Pin)
            if (state == True):
                print("GPIO Pin Active!")
            else:
                print("GPIO Pin LOW")
        elif (request.form.get("Test Raspberry Pi to FPGA") == "Test Raspberry Pi to FPGA"):
            test_transmit_uart_data_from_pi()
        elif (request.form.get("Test FPGA to Raspberry Pi") == "Test FPGA to Raspberry Pi"):
            receive_uart_data_from_fpga()
        elif (request.form.get("Test Full Duplex Mode") == "Test Full Duplex Mode"):
            test_uart_full_duplex()
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