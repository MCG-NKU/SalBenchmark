clear, clc, 
close all
addpath('..\Funcs');

%% 1. Parameter Settings
doFrameRemoving = false;
useSP = true;           %You can set useSP = false to use regular grid for speed consideration
doMAEEval = true;       %Evaluate MAE measure after saliency map calculation
doPRCEval = true;       %Evaluate PR Curves after saliency map calculation

SRC = 'E:\Data\Saliency_TestTime';       %Path of input images
BDCON = 'Data\BDCON';   %Path for saving bdCon feature image
SP = 'Data\SP';         %Path for saving superpixel index image and mean color image
RES = 'E:\Project_NewSaliency\Data\ASD_SalOpt';       %Path for saving saliency maps
srcSuffix = '.jpg';     %suffix for your input image

if ~exist(SP, 'dir')
    mkdir(SP);
end
if ~exist(BDCON, 'dir')
    mkdir(BDCON);
end
if ~exist(RES, 'dir')
    mkdir(RES);
end
%% 2. Saliency Map Calculation
time_slic = 0;
time_bdCon = 0;
time_opt = 0;

files = dir(fullfile(SRC, strcat('*', srcSuffix)));
t1 = tic;
T_seg = 0;
for k=1:length(files)
    disp(k);
    srcName = files(k).name;
    noSuffixName = srcName(1:end-length(srcSuffix));
    %% Pre-Processing: Remove Image Frames
    srcImg = imread(fullfile(SRC, srcName));
    if doFrameRemoving
        [noFrameImg, frameRecord] = removeframe(srcImg, 'sobel');
        [h, w, chn] = size(noFrameImg);
    else
        noFrameImg = srcImg;
        [h, w, chn] = size(noFrameImg);
        frameRecord = [h, w, 1, h, 1, w];
    end
    
    %% Segment input rgb image into patches (SP/Grid)
    pixNumInSP = 600;                           %pixels in each superpixel
    spnumber = round( h * w / pixNumInSP );     %super-pixel number for current image
    
    t2 = tic;
    if useSP
        [idxImg, adjcMatrix, pixelList] = SLIC_Split(noFrameImg, spnumber);
    else
        [idxImg, adjcMatrix, pixelList] = Grid_Split(noFrameImg, spnumber);        
    end
    T_seg = T_seg + toc(t2);
    %% Get super-pixel properties
    spNum = size(adjcMatrix, 1);
    meanRgbCol = GetMeanColor(noFrameImg, pixelList);
    meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
    meanPos = GetNormedMeanPos(pixelList, h, w);
    bdIds = GetBndPatchIds(idxImg);
    colDistM = GetDistanceMatrix(meanLabCol);
    posDistM = GetDistanceMatrix(meanPos);
    [clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);
    
    %% Saliency Optimization
    [bgProb, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    wCtr = CalWeightedContrast(colDistM, posDistM, bgProb);
    optwCtr = SaliencyOptimization(adjcMatrix, bdIds, colDistM, neiSigma, bgWeight, wCtr);
    
%     smapName=fullfile(RES, strcat(noSuffixName, '_wCtr_Optimized.png'));
%     SaveSaliencyMap(optwCtr, pixelList, frameRecord, smapName, true);
end

T = toc(t1);
fprintf('Average time: %.4f\n', T/length(files));
fprintf('Segmentation time: %.4f\n', T_seg/length(files));