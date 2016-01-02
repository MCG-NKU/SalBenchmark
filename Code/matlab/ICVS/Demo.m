%---------------------------------------------------------
% Copyright (c) 2010 Radhakrishna Achanta [EPFL]
% Contact: firstname.lastname@epfl.ch
%---------------------------------------------------------
% Citation:
% @InProceedings{Achanta_Saliency_ICVS_2008,
%    author      = {Achanta, Radhakrishna and Extrada, Francisco and Süsstrunk, Sabine},
%    booktitle   = {{I}nternational {C}onference on {C}omputer
%                  {V}ision {S}ystems},
%    year        = 2008
% }
%---------------------------------------------------------
%
%
%---------------------------------------------------------
% Read image
%---------------------------------------------------------
img = imread('input_image.jpg');%Provide input image path
dim = size(img);
width = dim(2);height = dim(1);
md = min(width, height);%minimum dimension
%---------------------------------------------------------
% Perform sRGB to CIE Lab color space conversion (using D65)
%---------------------------------------------------------
cform = makecform('srgb2lab', 'whitepoint', whitepoint('d65'));
lab = applycform(img,cform);
l = double(lab(:,:,1));
a = double(lab(:,:,2));
b = double(lab(:,:,3));
%If you have your own RGB2Lab function...
%[l a b] = RGB2Lab(gfrgb(:,:,1),gfrgb(:,:,2), gfrgb(:,:,3));
%---------------------------------------------------------
%Saliency map computation
%---------------------------------------------------------
sm = zeros(height, width);
off1 = int32(md/2); off2 = int32(md/4); off3 = int32(md/8);
for j = 1:height
    y11 = max(1,j-off1); y12 = min(j+off1,height);
    y21 = max(1,j-off2); y22 = min(j+off2,height);
    y31 = max(1,j-off3); y32 = min(j+off3,height);
    for k = 1:width
        x11 = max(1,k-off1); x12 = min(k+off1,width);
        x21 = max(1,k-off2); x22 = min(k+off2,width);
        x31 = max(1,k-off3); x32 = min(k+off3,width);
        lm1 = mean2(l(y11:y12,x11:x12));am1 = mean2(a(y11:y12,x11:x12));bm1 = mean2(b(y11:y12,x11:x12));
        lm2 = mean2(l(y21:y22,x21:x22));am2 = mean2(a(y21:y22,x21:x22));bm2 = mean2(b(y21:y22,x21:x22));
        lm3 = mean2(l(y31:y32,x31:x32));am3 = mean2(a(y31:y32,x31:x32));bm3 = mean2(b(y31:y32,x31:x32));
        %---------------------------------------------------------
        % Compute conspicuity values and add to get saliency value.
        %---------------------------------------------------------
        cv1 = (l(j,k)-lm1).^2 + (a(j,k)-am1).^2 + (b(j,k)-bm1).^2;
        cv2 = (l(j,k)-lm2).^2 + (a(j,k)-am2).^2 + (b(j,k)-bm2).^2;
        cv3 = (l(j,k)-lm3).^2 + (a(j,k)-am3).^2 + (b(j,k)-bm3).^2;
        sm(j,k) = cv1 + cv2 + cv3;
    end
end

imshow(sm,[]);
%---------------------------------------------------------
