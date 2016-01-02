% Demo script for SIM (Saliency by Induction Mechanisms).
% Run to display saliency map for input image "3.jpg"

filename     = '3.jpg';
img          = double(imread(filename));
[m n p]      = size(img);
window_sizes = [13 26];                          % window sizes for computing center-surround contrast
wlev         = min([7,floor(log2(min([m n])))]); % number of wavelet planes
gamma        = 2.4;                              % gamma value for gamma correction
srgb_flag    = 1;                                % 0 if img is rgb; 1 if img is srgb

% get saliency map:
smap = SIM(img, window_sizes, wlev, gamma, srgb_flag);

% display saliency map:
figure; subplot(1,2,1); imshow(uint8(img));
subplot(1,2,2); imshow(smap,[]);
