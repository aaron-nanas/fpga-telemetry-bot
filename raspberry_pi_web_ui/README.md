# Description
This repository contains the project files for the Raspberry Pi. It includes the following:

- Front-end: HTML/CSS/Javascript code for the web UI
    - Web UI with Flask as the web framework to provide wireless control to the FPGA
    - [Check out the Flask documentation here.](https://flask.palletsprojects.com/en/2.0.x/installation/#python-version)
- Back-end: Python scripts that achieve the following
    - Transmit and receive data to/from the FPGA using the `serial` module
    - Capture a photo (600x400) with the Raspberry Pi camera and convert it into an image matrix
    - Receive the processed image matrix (after applying a spatial filter) from the FPGA and convert it into an image file
    - Display both the input and output images