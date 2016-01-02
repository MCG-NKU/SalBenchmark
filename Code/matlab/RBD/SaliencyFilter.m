function [cmbVal, Contrast, Distribution] = SaliencyFilter(colDistM, posDistM, meanPos)
% The core function for Saliency Filter:
% F. Perazzi, P. Krahenbuhl, Y. Pritch, and A. Hornung. Saliency filters:
% Contrast based filtering for salient region detection. In CVPR, 2012.
% 
% Note that we didn't implement the last upsampling step, which is very
% slow

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spaSigma = 0.25;        %sigma for spatial weight
colSigma = 20;          %sigma for color weight
k = 6;                  %coefficient for combining contrast and distribution

posWeight = Dist2WeightMatrix(posDistM, spaSigma);
spNum = size(colDistM, 1);

%% Calculate Contrast
Contrast = sum( colDistM .* posWeight, 2 );
Contrast = (Contrast - min(Contrast)) / (max(Contrast) - min(Contrast) + eps);

%% Calculate Distribution
colSimW = Dist2WeightMatrix(colDistM, colSigma);
centerPos = colSimW * meanPos ./ repmat(sum(colSimW, 2), 1, 2);    %mass center
Distribution = zeros(spNum, 2);

for n = 1:spNum
    Distribution(n, :) = colSimW(n,:) * (meanPos - repmat(centerPos(n, :), spNum, 1)).^2;
end
Distribution = sum(Distribution, 2);
Distribution = (Distribution - min(Distribution)) / (max(Distribution) - min(Distribution) + eps);

%% Combine Contrast with Distribution, on SP level
cmbVal = Contrast .* exp(- Distribution * k);