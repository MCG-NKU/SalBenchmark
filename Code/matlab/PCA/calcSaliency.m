function calcSaliency(inputLocation,outputDir,startIdx)

if (~exist('startIdx','var'))
    startIdx=1;
end

if (~isdir(outputDir) || ~exist(outputDir,'dir'))
    error('outputDir is not a directory or does not exist');
end
if (isdir(inputLocation))
    fileList=dir([inputLocation '/*.png']);
    fileList= [fileList; dir([inputLocation '/*.jpg'])];
    IN_DIR=inputLocation;
    NumOfFiles=size(fileList,1);
else
    [IN_DIR,base_name,ext] = fileparts(inputLocation);
    fileList.name = [base_name ext];
    NumOfFiles=1;
end

fprintf('\n');
for imIndx=startIdx:NumOfFiles
    [~,base_name,ext] = fileparts(fileList(imIndx).name);
    frameCurrent = imread([IN_DIR '/' base_name ext]);
    if (size(frameCurrent,3)==1)
        fprintf('\nNote: Grayscale image treated as colored\n');
        frameCurrent=repmat(frameCurrent,[1 1 3]);
    end
    fprintf('\n');
    strng = sprintf('%i/%i',imIndx,NumOfFiles);
    fprintf(strng);
    
    frameSaliencyMap  = PCA_Saliency(frameCurrent);

    imwrite(frameSaliencyMap, [outputDir '/' base_name '.png'],'png');
end
end