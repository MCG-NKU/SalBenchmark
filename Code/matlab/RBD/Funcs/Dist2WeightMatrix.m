function weightMatrix = Dist2WeightMatrix(distMatrix, distSigma)
% Transform pair-wise distance to pair-wise weight using
% exp(-d^2/(2*sigma^2));

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spNum = size(distMatrix, 1);

distMatrix(distMatrix > 3 * distSigma) = Inf;   %cut off > 3 * sigma distances
weightMatrix = exp(-distMatrix.^2 ./ (2 * distSigma * distSigma));

if any(1 ~= weightMatrix(1:spNum+1:end))
    error('Diagonal elements in the weight matrix should be 1');
end