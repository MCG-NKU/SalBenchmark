function [stage2, stage1, bsalt, bsalb, bsall, bsalr] = ManifoldRanking(adjcMatrix, idxImg, bdIds, colDistM)
% The core function for Manifold Ranking Saliency: 
% C. Yang, L. Zhang, H. Lu, X. Ruan, and M.-H. Yang. Saliency
% detection via graph-based manifold ranking. In CVPR, 2013.

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

alpha=0.99;
theta=10;
spNum = size(adjcMatrix, 1);

%% Construct Super-Pixel Graph
adjcMatrix_nn = LinkNNAndBoundary2(adjcMatrix, bdIds); 
% This super-pixels linking method is from the author's code, but is 
% slightly different from that in our Saliency Optimization

W = SetSmoothnessMatrix(colDistM, adjcMatrix_nn, theta);
% The smoothness setting is also different from that in Saliency
% Optimization, where exp(-d^2/(2*sigma^2)) is used
D = diag(sum(W));
optAff =(D-alpha*W)\eye(spNum);
optAff(1:spNum+1:end) = 0;  %set diagonal elements to be zero

%% Stage 1
% top
Yt=zeros(spNum,1);
bst=unique(idxImg(1, :));
Yt(bst)=1;
bsalt=optAff*Yt;
bsalt=(bsalt-min(bsalt(:)))/(max(bsalt(:))-min(bsalt(:)));
bsalt=1-bsalt;
% bottom
Yb=zeros(spNum,1);
bsb=unique(idxImg(end, :));
Yb(bsb)=1;
bsalb=optAff*Yb;
bsalb=(bsalb-min(bsalb(:)))/(max(bsalb(:))-min(bsalb(:)));
bsalb=1-bsalb;
% left
Yl=zeros(spNum,1);
bsl=unique(idxImg(:, 1));
Yl(bsl)=1;
bsall=optAff*Yl;
bsall=(bsall-min(bsall(:)))/(max(bsall(:))-min(bsall(:)));
bsall=1-bsall;
% right
Yr=zeros(spNum,1);
bsr=unique(idxImg(:, end));
Yr(bsr)=1;
bsalr=optAff*Yr;
bsalr=(bsalr-min(bsalr(:)))/(max(bsalr(:))-min(bsalr(:)));
bsalr=1-bsalr;
% combine
stage1=(bsalt.*bsalb.*bsall.*bsalr);
stage1=(stage1-min(stage1(:)))/(max(stage1(:))-min(stage1(:)));

%% Stage 2
th=mean(stage1);
stage2=optAff*(stage1 >= th);

function W = SetSmoothnessMatrix(colDistM, adjcMatrix_nn, theta)
allDists = colDistM(adjcMatrix_nn > 0);
maxVal = max(allDists);
minVal = min(allDists);

colDistM(adjcMatrix_nn == 0) = Inf;
colDistM = (colDistM - minVal) / (maxVal - minVal + eps);
W = exp(-colDistM * theta);

function adjcMatrix = LinkNNAndBoundary2(adjcMatrix, bdIds)
%link boundary SPs
adjcMatrix(bdIds, bdIds) = 1;

%link neighbor's neighbor
adjcMatrix = (adjcMatrix * adjcMatrix + adjcMatrix) > 0;
adjcMatrix = double(adjcMatrix);

spNum = size(adjcMatrix, 1);
adjcMatrix(1:spNum+1:end) = 0;  %diagnal elements set to be zero