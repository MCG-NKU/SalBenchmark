function adjcMatrix = LinkBoundarySPs(adjcMatrix, bdIds)
% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

adjcMatrix(bdIds, bdIds) = 1;