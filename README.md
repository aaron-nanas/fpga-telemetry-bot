# Description
WIP: An FPGA-based robot car with the following features:
* GPS
* Track humidity and temperature levels
* 9-axis motion tracking

# Block Diagram of Design
![Block Diagram](./screenshots/updated-fpga-telemetry-block-diagram.png)

# Parts
| Part | QTY | Price ($) | Link |
| --- | --- | --- | --- |
| Zybo Z7-20 FPGA/SoC | -- | -- | --
| FireBeetle ESP32 Microcontroller | 1 | 6.90 per unit | [Product Link](https://www.dfrobot.com/product-1590.html)
| 12V 170 RPM DC Gear Motor | 4 | 15.00 per unit | [Product Link](https://www.servocity.com/170-rpm-econ-gear-motor/)
| Dual Channel DC Motor Driver | 2 | 22.00 per unit | [Product Link](https://www.robotshop.com/en/cytron-10a-5-30v-dual-channel-dc-motor-driver.html)
| 12V 3000mAh NiMH Battery | 1 | 35.00 per unit | [Product Link](https://www.servocity.com/nimh-battery-12v-3000mah-xt30-connector-mh-fc-20a-fuse-12-20/)
| GPS Option 1: GPS Breakout - NEO-M9N, SMA (Qwiic) | 1 | 70.00 per unit | [Product Link](https://www.sparkfun.com/products/17285)
| Humidity and Temperature Sensor | 1 | 10.00 per unit | [Product Link](https://www.sparkfun.com/products/13763)
| 9DoF IMU Breakout | 1 | 17.00 per unit | [Product Link](https://www.amazon.com/SparkFun-Breakout-ICM-20948-connection-Accelerometer-Magnetometer/dp/B07VNV3WKL/)
| 3604 Series Omni Wheel (14mm Bore, 120mm Diameter) | 4 | 9.00 per unit | [Product Link](https://www.servocity.com/3604-series-omni-wheel-14mm-bore-120mm-diameter/)

# Project Timeline
- [ ] September: Interface sensors and motors, establish communication protocol between Zybo/Zedboard and ESP32
- [ ] October: Work on power and chassis once all external peripherals are functional
- [ ] November: Finalize bot

# Development Tools
* Software: Vivado
* Languages: VHDL, C++, C, Python, MATLAB
* Development Board Used: Zybo Z7-20, ESP32

# Contributors
* Jose Martinez
* Aaron Nanas

# References
## General Design Ideas
- [OpenCores](https://opencores.org/projects)
    - **Note**: Requires an account to download design files
## UART
- [ECE UNM UART Slides](http://ece-research.unm.edu/jimp/vhdl_fpgas/slides/UART.pdf)
- [Nandland: UART, Serial Port, RS-232 Interface](https://www.nandland.com/vhdl/modules/module-uart-serial-port-rs232.html)
