function [SalMap] = GetCA(imgName)
     MOV = saliency({imgName});
     SalMap = MOV{1}.SaliencyMap;
     img = imread(imgName);
     height=size(img,1);
     width=size(img,2);
     SalMap = imresize(SalMap, [height, width]);
end
