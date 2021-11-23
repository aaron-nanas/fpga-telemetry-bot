from PIL import Image
import numpy as np
from matplotlib import pyplot as plt
import os
import sys

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
    image_grayscale_as_list = list()
    image_grayscale_array = create_input_image_array()
    num_of_arrays = len(image_grayscale_array)
    print("Input Image Matrix:\n", image_grayscale_array)
    print("Number of Arrays:", num_of_arrays, "\nNumber of Elements in An Array:", len(image_grayscale_array[0]))
    newline_char = "\n"

    print("Writing Array to File...")
    with open(os.path.join("/home/pi/ece524_proj/", "input_image_data.txt"), "r") as file_for_input_array:

        for array_num in range(num_of_arrays):
            for data in image_grayscale_array[array_num]:
                #file_for_input_array.write(f"{int(data)}\n")
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
    

if __name__ == "__main__":
    # image_grayscale_as_list = create_file_for_input_array()
    # reshape_and_show_image_from_list(image_grayscale_as_list)
    output_image_list = list()
    with open(os.path.join("/home/pi/ece524_proj/", "output_image_data_2.txt"), "r") as file_for_input_array:
        for output_data_index, output_data in enumerate(file_for_input_array):
            output_image_list.append(int(output_data))

        img_array = np.asarray(output_image_list)
        reshaped_img_array = img_array.reshape(400, 600)
        plt.imshow(reshaped_img_array, cmap='gray')
        plt.title("Output Image After Multiplication")
        plt.show()