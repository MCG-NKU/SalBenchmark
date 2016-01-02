function distM = GetDistanceMatrix(feature)
% Get pair-wise distance matrix between each rows in feature
% Each row of feature correspond to a sample

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spNum = size(feature, 1);
DistM2 = zeros(spNum, spNum);

for n = 1:size(feature, 2)
    DistM2 = DistM2 + ( repmat(feature(:,n), [1, spNum]) - repmat(feature(:,n)', [spNum, 1]) ).^2;
end
distM = sqrt(DistM2);