function mae = CalMeanMAE(SRC, srcSuffix, GT, gtSuffix)
% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014
files = dir(fullfile(SRC, strcat('*', srcSuffix)));
if isempty(files)
    error('No saliency maps are found: %s\n', fullfile(SRC, strcat('*', srcSuffix)));
end

MAE = zeros(length(files), 1);
parfor k = 1:length(files)
    srcName = files(k).name;
    srcImg = imread(fullfile(SRC, srcName));
    
    gtName = strrep(srcName, srcSuffix, gtSuffix);
    gtImg = imread(fullfile(GT, gtName));
    
    MAE(k) = CalMAE(srcImg, gtImg);
end

mae = mean(MAE);
fprintf('MAE for %s: %f\n', srcSuffix, mae);