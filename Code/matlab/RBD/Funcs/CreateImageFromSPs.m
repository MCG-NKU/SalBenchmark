function [img, spValues] = CreateImageFromSPs(spValues, pixelList, height, width, doNormalize)
% create an image from its superpixels' values
% spValues is all superpixel's values, e.g., saliency
% pixelList is a cell (with the same size as spValues) of pixel index arrays

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

if (~iscell(pixelList))
    error('pixelList should be a cell');
end

if (length(pixelList) ~= length(spValues))
    error('different sizes in spValues and pixelList');
end

if (nargin < 5)
    doNormalize = true;
end

minVal = min(spValues);
maxVal = max(spValues);
if doNormalize
    spValues = (spValues - minVal) / (maxVal - minVal + eps);
else
    if minVal < -1e-6 || maxVal > 1 + 1e-6
        error('feature values do not range from 0 to 1');
    end
end

img = zeros(height, width);
for i=1:length(pixelList)
    img(pixelList{i}) = spValues(i);
end