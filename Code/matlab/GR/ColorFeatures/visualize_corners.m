function output_im=visualize_corners(input_im,corner_im);

mask=(dilation33(dilation33(corner_im)));
mask2=dilation33(dilation33(mask));
output_im=input_im;

output_im(:,:,1)=(~mask2).*output_im(:,:,1)+(mask)*255;
output_im(:,:,2)=(~mask2).*output_im(:,:,2)+(mask)*255;
output_im(:,:,3)=(~mask2).*output_im(:,:,3)+(mask)*255;

