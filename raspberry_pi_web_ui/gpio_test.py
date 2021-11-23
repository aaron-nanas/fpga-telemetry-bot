import RPi.GPIO as GPIO
import sys
import time

GPIO_TEST_PIN = 26

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(GPIO_TEST_PIN, GPIO.IN)

print("Status", GPIO.input(GPIO_TEST_PIN))

# while True:
#     try:
#         print("GPIO High")
#         GPIO.output(Tx_Pin, 1)
#         print("Write Enable Pin Status:", GPIO.input(Write_Enable_Pin))
#         time.sleep(2)
#         print("GPIO Low")
#         GPIO.output(Tx_Pin, 0)
#         print("Write Enable Pin Status:", GPIO.input(Write_Enable_Pin))
#         time.sleep(2)
#     except KeyboardInterrupt:
#         print("Interrupted!")
#         GPIO.output(Tx_Pin, 0)
#         sys.exit(1)

