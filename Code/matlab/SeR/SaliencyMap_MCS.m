function FinalS = ComputeSaliencyMap(RGB,s)

% Compute Saliency Map

% [RETURNS]
% FinalS   : Saliency Map
%
% [PARAMETERS]
% RGB   : the input image
% s     : resize factor

% [HISTORY]
% Jan 19 2010 : created by Hae Jong

FinalS = zeros(size(RGB,1),size(RGB,2));
Lab = im2double(colorspace('Lab<-RGB',RGB));

for c = 1:3
    img = Lab(:,:,c);
    img = imresize(img, s, 'bilinear');    
    img = img - min(img(:));
    img = img/max(img(:));
%     LSK{c} = Compute_LSK(img,3,0.008,1);
       LSK{c} = Compute_LARK(img,3,0.42,0.2); %0.43 0.6 --> 0.6828 %0.43 0.4 --> 0.6842 %0.42, 0.2 --> 0.6914
end
S = Compute_SelfRemblance_Apr17(img,3,LSK,7);
FinalS = imresize(mat2gray(S),[size(RGB,1), size(RGB,2)],'bilinear');

end
