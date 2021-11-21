from PIL import Image
import numpy as np
from matplotlib import pyplot as plt

input_image = Image.open("/home/pi/ece524_proj/ece524_images/flower_image_1.jpg").convert('L')
resized_image = input_image.resize((600, 400))
print(resized_image.size)
image_grayscale_array = np.asarray(resized_image)
print(image_grayscale_array)
resized_image.save("/home/pi/ece524_proj/image_results/flower_image_1_grayscale.jpg")
plt.title("Output Image")
#plt.imsave("img_show_result.jpg", image_grayscale_array, cmap="gray")
plt.imshow(image_grayscale_array, cmap="gray")
plt.show()
