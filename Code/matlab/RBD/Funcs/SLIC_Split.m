function [idxImg, adjcMatrix, pixelList] = SLIC_Split(noFrameImg, spnumber_input)
% Segment rgb image into super-pixels using SLIC algorithm:

% R.Achanta, A.Shaji, K.Smith, A.Lucchi, P.Fua, and S.Susstrunk. Slic 
% superpixels compared to state-of-the-art superpixel methods. IEEE
% Transactions on Pattern Analysis and Machine Intelligence, 2012.

% Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

%% Segment using SLIC:
compactness = 20; %the larger, the more regular patches will get
[idxImg, spNum] = SLIC_mex(noFrameImg, spnumber_input, compactness);

%%
adjcMatrix = GetAdjMatrix(idxImg, spNum);

%%
pixelList = cell(spNum, 1);
for n = 1:spNum
    pixelList{n} = find(idxImg == n);
end
