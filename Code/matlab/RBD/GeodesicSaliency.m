function geoDist = GeodesicSaliency(adjcMatrix, bdIds, colDistM, posDistM, clip_value)
% The core function for Geodesic Saliency Algorithm:
% Y.Wei, F.Wen,W. Zhu, and J. Sun. Geodesic saliency using background
% priors. In ECCV, 2012.

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spNum = size(adjcMatrix, 1);
% Set background super-pixels
bgIds = BoundaryAnalysis(colDistM, posDistM, bdIds);

% Calculate pair-wise geodesic distance
adjcMatrix_lb = LinkBoundarySPs(adjcMatrix, bdIds); %adjacent matrix with boundary SPs linked
[row,col] = find(adjcMatrix_lb);

% Here we add a virtual background node which is linked to all background
% super-pixels with 0-cost. To do this, we padding an extra row and column 
% to adjcMatrix_lb, and get adjcMatrix_virtual.
adjcMatrix_virtual = sparse([row; repmat(spNum + 1, [length(bgIds), 1]); bgIds], ...
    [col; bgIds; repmat(spNum + 1, [length(bgIds), 1])], 1, spNum + 1, spNum + 1);

% Specify edge weights for the new graph
colDistM_virtual = zeros(spNum+1);
colDistM_virtual(1:spNum, 1:spNum) = colDistM;

adjcMatrix_virtual = tril(adjcMatrix_virtual, -1);
edgeWeight = colDistM_virtual(adjcMatrix_virtual > 0);
edgeWeight = max(0, edgeWeight - clip_value);
geoDist = graphshortestpath(sparse(adjcMatrix_virtual), spNum + 1, 'directed', false, 'Weights', edgeWeight);
geoDist = geoDist(1:end-1); % exclude the virtual background node

doRenorm = true;    %re-normalize saliency map, normalize saliency value of the top 2% pixels to 1
topRate = 0.02;
if doRenorm
    tmp = sort(geoDist, 'descend');
    pos = round(topRate * length(tmp));
    maxVal = tmp(pos);
    geoDist = geoDist / maxVal; %minVal = 0
    geoDist(geoDist > 1) = 1;
end


function backgroundIds = BoundaryAnalysis(colDistM, posDistM, bdIds)
% 1-D saliency analysis for boundary SPs, using  method in the CVPR10
% paper: S.Goferman, L.manor, and A.Tal. Context-aware saliency
% detection. In CVPR, 2010.

spNum = size(colDistM, 1);
neighborNum = round(spNum / 200 * 5);
c = 3;

colDist_bnd = colDistM(bdIds, bdIds);
colDist_bnd(1:length(bdIds) + 1:end) = inf;
posDist_bnd = posDistM(bdIds, bdIds);
cmbDist_bnd = colDist_bnd ./ (1 + c * posDist_bnd);
cmbDist_bnd = sort(cmbDist_bnd, 2, 'ascend');
meanDist_bnd = mean(cmbDist_bnd(:, 1:neighborNum), 2);
minDist_bnd = min(meanDist_bnd);
maxDist_bnd = max(meanDist_bnd);

if (maxDist_bnd - minDist_bnd > 1)
    meanDist_bnd = ( meanDist_bnd - minDist_bnd ) / (maxDist_bnd - minDist_bnd);
    backgroundIds = bdIds(meanDist_bnd <= 0.5);
else
    backgroundIds = bdIds;
end