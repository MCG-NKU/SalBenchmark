% Example of color Harris detector and of color boosted Harris detector.
%
% Note that a straight forward extention from luminance to color yields only
% few changes (compare fig.2 & 4) This is caused by the fact that also in the RGB-image most
% contrast changes are in the luminance direction. Only in the case of
% iso-luminance large differences are expected.
%
% By applying color boosting the color information content of detected points is
% increased. For more information on color boosting see:
%
% LITERATURE:
% J. van de Weijer, Th. Gevers, J-M Geusebroek
% "Boosting Color Saliency in Image Feature Detection"
% IEEE Trans. Pattern Analysis and Machine Intelligence,
% vol. 27 (4), April 2005.

input_im=double(imread('castle.tif'));          % corel image
sigma_g=1.5;
sigma_a=5;
nPoints=30;

%% compute RGB-Harris Detector
[EnIm]= ColorHarris(input_im,sigma_g,sigma_a,0.04,1);

% extract corners in total nPoints
[x_max,y_max,corner_im,num_max]=getmaxpoints(EnIm,nPoints);

% visualize corners 
output_im=visualize_corners(input_im,corner_im);

figure(1);imshow(uint8(input_im));
figure(2);imshow(uint8(output_im));title('color Harris');

%% compute color boosted Harris Detector
% compute boosting matrix
% here the matrix is based on a single image 
% (for retrieval the Boosting matrix could also be pre-computed on a data set)
Mboost = BoostMatrix(input_im);

% apply matrix to image
boost_im= BoostImage(input_im,Mboost);

% Optional check if boosting matrix is identity matrix after color boosting
% Mboost2 = BoostMatrix(boost_im)

% compute Harris Energy
[EnIm]= ColorHarris(boost_im,sigma_g,sigma_a,0.04,1);

% extract corners in total nPoints
[x_max,y_max,corner_im2,num_max]=getmaxpoints(EnIm,nPoints);

% visualize corners 
output_im2=visualize_corners(input_im,corner_im2);
figure(3);imshow(uint8(output_im2));title('color boosted Harris');

%% compute color luminance Harris Detector
luminance_im=make_image(sum(input_im,3),sum(input_im,3),sum(input_im,3));
[EnIm]= ColorHarris(luminance_im,sigma_g,sigma_a,0.04,1);

% extract corners in total nPoints
[x_max,y_max,corner_im2,num_max]=getmaxpoints(EnIm,nPoints);

% visualize corners 
output_im3=visualize_corners(input_im,corner_im2);

figure(4);imshow(uint8(output_im3));title('Luminance Image');