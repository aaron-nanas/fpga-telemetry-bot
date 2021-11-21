# UART Simulation Results

## Testing Strategies
- Wrote the testbench code for simulation
- Viewed UART data stream using an oscilloscope by inspecting the Raspberry Pi's Tx pin
- Displayed data received by the FPGA in hexadecimal form using a Pmod Seven-Segment Display

## UART Rx

### Test Case 1: Receiving Vector of "10001111"

![Rx Result 1](./screenshots/uart_rx_simulation_result1.png)

### Test Case 2: Receiving Vector of "10101010"

![Rx Result 2](./screenshots/uart_rx_simulation_result2.png)

## UART Tx

### Test Case 1: Serially Transmitting 0xFA

![Tx Result 1](./screenshots/uart_tx_simulation_result1.png)

### Test Case 2: Serially Transmitting 0xAB

![Tx Result 2](./screenshots/uart_tx_simulation_result2.png)

Full Waveform for both test Tx test cases:

![Tx Full Waveform](./screenshots/uart_tx_simulation_result3_full.png)

## Top-Level UART

### Test Case: Receiving and Transmitting 0x8F

Full Waveform Results of UART Rx/Tx:

![UART Full Result 1](./screenshots/uart_byte_full_transmission.png)

![UART Full Result 2](./screenshots/uart_top_full_result.png)

## FPGA Resources Used for Top-Level UART

- LUTs: 68
- FFs: 56

![FPGA Resources for UART](./screenshots/uart_top_fpga_resources.png)