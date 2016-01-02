function [idxImg, adjcMatrix, pixelList] = Grid_Split(inputImg, spnumber)
% Segment rgb image into regular grid patches

% Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

[h, w, chn] = size(inputImg);
pixInEachGrid = h * w / spnumber;
gridSize = round( sqrt(pixInEachGrid) );

xSplitPt = 1:gridSize:w;
if w - xSplitPt(end) + 1 < gridSize / 3
    xSplitPt(end) = [];
end
xNum = length(xSplitPt);

ySplitPt = 1:gridSize:h;
if h - ySplitPt(end) + 1 < gridSize / 3
    ySplitPt(end) = [];
end
yNum = length(ySplitPt);

% horizontal direction
cnt = zeros(1, w);
cnt(xSplitPt) = 1;
ind_h = cumsum(cnt);

% vertical direction
cnt = zeros(h, 1);
cnt(ySplitPt) = 1;
ind_v = cumsum(cnt) - 1;

idxImg = repmat(ind_h, [h, 1]) + repmat(ind_v, [1, w]) * xNum;
spNum = idxImg(end);

%Method 1 to get adjacent matrix
%adjcMatrix = GetAdjMatrix(idxImg, spNum);

%Method 2 to get adjacent matrix, this one is faster
adjcMatrix = diag(ones(spNum-1, 1), 1) + diag(ones(spNum-1, 1), -1) + ...
    diag(ones(spNum-xNum, 1), xNum) + diag(ones(spNum-xNum, 1), -xNum) + ...
    eye(spNum);
adjcMatrix = sparse(adjcMatrix);

%Get pixel list in each super-pixel
pixelList = cell(spNum, 1);
ySplitPt(end+1) = h+1;
xSplitPt(end+1) = w+1;
for y = 1:yNum
    for x = 1:xNum
        id = (y-1) * xNum + x;
        s_x = xSplitPt(x+1) - xSplitPt(x);
        s_y = ySplitPt(y+1) - ySplitPt(y);
        
        %Method 1 to get pixelList:  28ms
        %pixelList{id} = reshape( repmat( (ySplitPt(y):ySplitPt(y+1)-1)', [1, s_x] ) + h * (repmat( xSplitPt(x):xSplitPt(x+1)-1, [s_y, 1]) - 1), [], 1);
        
        %Method 2 to get pixelList, this one is faster:  15ms
        list = zeros(s_x*s_y, 1);
        tmpId = (ySplitPt(y):ySplitPt(y+1)-1)' + (xSplitPt(x) - 1) * h;
        pos = 1;
        for n = 1:s_x
            list(pos:pos+s_y-1) = tmpId;
            tmpId = tmpId + h;
            pos = pos + s_y;
        end
        pixelList{id} = list;
    end
end