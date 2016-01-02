function meanPos = GetNormedMeanPos(pixelList, height, width)
% averaged x(y) coordinates of each superpixel, normalized with respect to
% image dimension
% return N*2 vector, row i is superpixel i's coordinate [y x]

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spNum = length(pixelList);
meanPos = zeros(spNum, 2);

for n = 1 : spNum
    [rows, cols] = ind2sub([height, width], pixelList{n});    
    meanPos(n,1) = mean(rows) / height;
    meanPos(n,2) = mean(cols) / width;
end