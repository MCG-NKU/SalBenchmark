function smap=saliencyimage_convolution(img,scale)
% function smap=saliencyimage(img,scale)
%   Calculate saliency map for color image, at certain scale

% each filter is zero summed
% load ICA basis functions
load stats;
d=size(B1,1); % number of filters
D=size(B1,2); % color filter streched length
fsize=D/3; % length of filter at each channel
psize=sqrt(fsize); % square filter

% preprocess image
if scale~=1
    img = imresize(img,scale);
end
img=double(img);
img=img/std(img(:));
[height width ignore] = size(img);

% process each channel
smap=zeros(height-psize+1,width-psize+1);
for f=1:d
    S = conv2(img(:,:,1),reshape(B1(f,1:fsize),psize,psize),'valid');
    S = S+conv2(img(:,:,2),reshape(B1(f,fsize+1:2*fsize),psize,psize),'valid');
    S = S+conv2(img(:,:,3),reshape(B1(f,2*fsize+1:3*fsize),psize,psize),'valid');
    smap=smap+(abs(S)/sigmas(f)).^thetas(f);
end


