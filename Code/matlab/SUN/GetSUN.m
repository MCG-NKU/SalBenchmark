function salMap=GetSUN(img,scale)
% function smap=saliencyimage(img,scale)
%   Calculate saliency map for color image, at certain scale

% load ICA basis functions, filters are zero summed
load stats;
d=size(B1,1); % number of filters
D=size(B1,2); % color filter streched length
fsize=D/3; % length of filter at each channel
psize=sqrt(fsize); % square filter

% preprocess image
if scale~=1
    img = imresize(img,scale);
end
img = double(img);
img = img / std(img(:));
height=size(img,1);
width=size(img,2);

% take image patches
N = length(1:height-psize+1)*length(1:width-psize+1);
patches = zeros(D,N);
i = 0;
for r = 1:height-psize+1
    for c = 1:width-psize+1
        i = i+1;
        patches(:,i) = reshape(img(r:r+psize-1,c:c+psize-1,:),D,1);
    end;
end;

% filter responses
S = B1*patches;

% saliency map
smap=zeros(1,size(S,2));
for i=1:d
    smap=smap+(abs(S(i,:))/sigmas(i)).^thetas(i);
end
smap=reshape(smap,[width-psize+1 height-psize+1])';
salMap = imresize(smap, [height, width]);


