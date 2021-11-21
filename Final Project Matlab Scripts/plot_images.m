% Jose L Martinez
% Matlab script used to display 3 images from imagegen.mlx
figure
subplot(1, 3, 1),
imshow(im1), title("Original Grayscale Image")
subplot(1, 3, 2),
imshow(IM2, []), title("Smoothed Image (MATLAB)")
subplot(1, 3, 3),
imshow(IM3, []), title("Smoothed Image (VHDL)")

figure
subplot(1, 3, 1),
imshow(im1), title("Original Grayscale Image")
subplot(1, 3, 2),
imshow(IM4, []), title("Edge Detection Image (MATLAB)")
subplot(1, 3, 3),
imshow(IM5, []), title("Edge Detection Image (VHDL)")
