function [meanMin1, meanTop, meanMin2] = GetMeanMinAndMeanTop(adjcMatrix, colDistM, topRate)
% Do statistics analysis on color distances between neighbor patches

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spNum = size(adjcMatrix, 1);

% 1. Min distance analysis (between neighbor patches)
adjcMatrix(1:spNum+1:end) = 0;  %patches do not link with itself for min distance analysis
minDist = zeros(spNum, 1);      %minDist(i) means the min distance from sp_i to its neighbors
for id = 1:spNum
    isNeighbor = adjcMatrix(id,:) > 0;
    minDist(id) = min(colDistM(id, isNeighbor));
end
meanMin1 = mean(minDist);

% 2. Largest distance analysis (this measure can reflect image contrast level)
tmp = sort(colDistM(tril(adjcMatrix, -1) > 0), 'descend');
meanTop = mean(tmp(1:round(topRate * length(tmp))));

% 3. Min distance analysis (between 2 layer neighbors)
adjcMatrix = double( (adjcMatrix * adjcMatrix + adjcMatrix) > 0 );  %Reachability matrix
adjcMatrix(1:spNum+1:end) = 0;
minDist = zeros(spNum, 1);      %minDist(i) means the min distance from sp_i to its neighbors
for id = 1:spNum
    isNeighbor = adjcMatrix(id,:) > 0;
    minDist(id) = min(colDistM(id, isNeighbor));
end
meanMin2 = mean(minDist);

if meanMin2 > meanMin1  %as meanMin2 considered more neighbors, its min value should be no larger than meanMin1
    error('meanMin2 should <= meanMin1');
end