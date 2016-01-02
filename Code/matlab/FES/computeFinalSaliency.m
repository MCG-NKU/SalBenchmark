
function saliency = computeFinalSaliency(img, pScale, sScale, alpha, sigma0, sigma1, p1)
% function saliency = computeFinalSaliency(image, pScale, sScale, alpha, sigma0, sigma1, p1)
%
% compute multi scale saliency over an image 
%
% @input
%   img - a given image to process
%   pScale - precission scale (number of samples) [1xn vector]
%   sScale - size scale (sampling raduis) [1xn vector]
%   alpha - attenuation factor [1x1 variable]
%   sigma0 : standard deviation of kernels in surround [1x1 variable]
%   sigma1 : standard deviation of kernel in center [1x1 variable]
%   p1 - P(1|x) [128x171 matrix]
% @output
%   saliency - saliency of inputed image
% 
% please refer to the following paper for details
% Rezazadegan Tavakoli H, Rahtu E & Heikkil? J, 
% "Fast and efficient saliency detection using sparse sampling and kernel density estimation."
% Proc. Scandinavian Conference on Image Analysis (SCIA 2011), 2011, Ystad, Sweden.
%
% The code has been tested on Matlab 2010a (32-bit) running windows. 
% This code is publicly available for demonstration and educational
% purposes, any commercial use without permission is strictly prohibited.  
%
% Please contact the author in case of any questions, comments, or Bug
% reports
%
% @CopyRight: Hamed Rezazadegan Tavakoli
% @Contact Email: hrezazad@ee.oulu.fi
% @date  : 2010
% @version: 0.1


% normalize the size of image to 128x171
img = imresize(img, [128, 171]);

[r c d] = size(p1);
if (r ~=128 || c~=171 || d~=1)
    error('p1 should be of size 128x171');
end

% compute saliency over each scale
n = numel(pScale);
saliency = zeros([128, 171, n]);

for i = 1:n
    saliency(:,:,i) = calculateImageSaliency(img, pScale(i), sScale(i), sigma0, sigma1, p1);
end

% merge saliency over scales
for i = 1:n
    saliency(:,:,i) = imfilter(saliency(:,:,i), fspecial('Gaussian', 26, 0.2*26));
end
saliency = saliency.^alpha;

saliency = mean(saliency, 3);
saliency = (saliency - min(saliency(:))) / (max(saliency(:)) - min(saliency(:)));


