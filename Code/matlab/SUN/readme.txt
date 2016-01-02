This is the matlab function that generates saliency maps used in paper Lingyun Zhang, Matthew H. Tong, Tim K. Marks, Honghao Shan & Garrison W. Cottrell (2008). SUN: A Bayesian framework for saliency using natural statistics. Journal of Vision, 8(7):32, 1-20, http://journalofvision.org/8/7/32/, doi:10.1167/8.7.32

The two *.m are essentially the same except for that saliencyimage_convolution.m is implemented with convolution. The results from the two should be the same except for small numerical differences. The convolution version is slower, but can take larger images without running out of memory.

The functions only take RGB formatted color images, to run saliency maps on gray images or other format color images, first convert to RGB format.

The functions take two parameters, first is the image to calculate saliency on, second is a scale parameter. 

Example of using the functions:

>> img=imread('lena.png');
>> simg1=saliencyimage(img,0.5);
>> simg2=saliencyimage_convolution(img,0.5);


 