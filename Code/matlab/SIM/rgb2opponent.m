function opp_img = rgb2opponent(img, gamma, srgb_flag)
% Converts rgb values into opponent color values.
%
% outputs:
%   opp_img: opponent image
% 
% inputs:
%   img: s/rgb image with values between 0 and 255 or between 0 and 1
%   gamma: gamma value for gamma correction
%   srgb_flag: 0 if img is rgb; 1 if img is srgb

img = double(img);

% normalise RGB values if necessary:
if max(img(:)) > 1
    img = img/255;
end

if srgb_flag
    % perform gamma correction:
    img_sRGB_temp1 = (img/12.92).*(img <= 0.04045);
    img_sRGB_temp2 = (((img + 0.055)/1.055).^gamma).*(img > 0.04045);
    img_sRGB       = img_sRGB_temp1 + img_sRGB_temp2;

    R = img_sRGB(:,:,1);
    G = img_sRGB(:,:,2);
    B = img_sRGB(:,:,3);
else
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);    
end

% We assume white light. Therefore, we use the simplified version of
% opponent color transform
O1 = R-G;
O2 = R+G-2*B;
O3 = R+G+B;

O13 = O1./O3;
O23 = O2./O3;

O13(isnan(O13)) = 0;
O23(isnan(O23)) = 0;

opp_img(:,:,1) = O13;
opp_img(:,:,2) = O23;
opp_img(:,:,3) = O3;
