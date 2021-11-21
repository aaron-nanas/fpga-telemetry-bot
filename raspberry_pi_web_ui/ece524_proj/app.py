from flask import Flask, render_template, request
import time
import os
import serial

app = Flask(__name__, template_folder="./templates", static_folder="./static")
ser = serial.Serial(port="/dev/ttyS0", 
                    baudrate=115200, 
                    bytesize=serial.EIGHTBITS, 
                    parity=serial.PARITY_NONE, 
                    stopbits=serial.STOPBITS_ONE, 
                    timeout=None)

isRunning = False
uart_received_data_list = list()

def restart_serial_port():
    print("Restarting Serial Port")
    ser.close()
    print("Opening Serial Port")
    ser.open()

'''
    Function: transmit_uart_data_from_pi
    
    This function will transmit a data stream of bytes every two seconds
    from the Raspberry Pi's TX pin to the FPGA's RX pin.
'''
def test_transmit_uart_data_from_pi():
    global isRunning

    restart_serial_port()
    print("Transmitting Data from Pi to FPGA")
    isRunning = True
    for i in range(0, 260, 5):
        ser.write(i.to_bytes(1, 'big'))
        data_transmitted = i.to_bytes(1, 'big').hex()
        print("Writing Data to FPGA:", data_transmitted)
        data_received = int.from_bytes(ser.read(), "big")
        print("Receiving Data from FPGA:", data_received)
        uart_received_data_list.append(data_received)
        if isRunning == False:
            break

    print("Transmission of Data from Pi to FPGA Done")
    print("List of Received Data:", uart_received_data_list)

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
            turn_led_on()
        elif request.form.get("Backward") == "Backward":
            print("Driving the Robot Backward")
            turn_led_off()
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