function [clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM)
% Estimate dynamic paras can slightly improve overall performance, but in
% fact, influence of those paras is very small, you can just use fixed
% paras, and we suggest you to set geoSigma = 7, neiSigma = 10.

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

[meanMin1, meanTop, meanMin2] = GetMeanMinAndMeanTop(adjcMatrix, colDistM, 0.01);
clipVal = meanMin2;

% Emperically choose adaptive sigma for converting geodesic distance to
% weight
geoSigma = min([10, meanMin1 * 3, meanTop / 10]);
geoSigma = max(geoSigma, 5);

% Emperically choose adaptive sigma for smoothness term in Equa(9) of our
% paper.
neiSigma = min([3 * meanMin1, 0.2 * meanTop, 20]);