function [ saliencyMap ] = GetSR(fileName)
%GETSR Summary of this function goes here
%   Detailed explanation goes here

%% Read image from file 
inImgOrg = im2double(rgb2gray(imread(fileName)));
inImg = imresize(inImgOrg, 64/size(inImgOrg, 2));

imgSize = size(inImgOrg);

%% Spectral Residual
myFFT = fft2(inImg); 
myLogAmplitude = log(abs(myFFT));
myPhase = angle(myFFT);
mySpectralResidual = myLogAmplitude - imfilter(myLogAmplitude, fspecial('average', 3), 'replicate'); 
saliencyMap = abs(ifft2(exp(mySpectralResidual + i*myPhase))).^2;

%% After Effect
saliencyMap = mat2gray(imfilter(saliencyMap, fspecial('gaussian', [10, 10], 2.5)));
saliencyMap = imresize(saliencyMap, imgSize(1:2));
%imshow(saliencyMap); 

end

