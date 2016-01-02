function FinalS = ComputeSaliencyMap(RGB,s,param)

% Compute Saliency Map

% [RETURNS]
% FinalS   : Saliency Map
%
% [PARAMETERS]
% RGB   : the input image
% s     : resize factor
% param : parameters

% [HISTORY]
% Apr 25, 2011 : created by Hae Jong

FinalS = zeros(size(RGB,1),size(RGB,2));
% Convert RGB to Lab CIE color channel
Lab = im2double(colorspace('Lab<-RGB',RGB));

for c = 1:3
    img = Lab(:,:,c);
    img = imresize(img, s, 'bilinear');    
    img = img - min(img(:));
    img = img/max(img(:));
    % Compute LARKs at every pixel points
    LARK{c} = ComputeLARK(img,param.P,param.alpha,param.h); %0.43 0.6 --> 0.6828 %0.43 0.4 --> 0.6842 %0.42, 0.2 --> 0.6914
end
% Generate self-resemblance map
S = ComputeSelfRemblance(img,LARK,param);
FinalS = imresize(mat2gray(S),[size(RGB,1), size(RGB,2)],'bilinear');

end
