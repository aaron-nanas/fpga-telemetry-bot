import time
import subprocess

subprocess.run(["libcamera-jpeg", "-o", "test_camera.jpg"])
print("Image Captured!")