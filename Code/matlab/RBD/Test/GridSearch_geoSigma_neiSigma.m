clear, clc,
close all
addpath('..\Funcs');

%% 1. Parameter Settings
doFrameRemoving = true;
useSP = true;           %You can set useSP = false to use regular grid for speed consideration
doMAEEval = true;       %Evaluate MAE measure after saliency map calculation
doPRCEval = true;       %Evaluate PR Curves after saliency map calculation

dataset = 'ASD';
SRC = fullfile('\\MSRA-VC12\SaliencyDatasets', dataset);                %Path of input images
BDCON = 'Data\BDCON';   %Path for saving bdCon feature image
SP = fullfile('\\MSRA-VC12\Project_NewSaliency\SPs_3_25_2014', dataset);                      %Path for saving superpixel's index image and mean color image
RES = fullfile('\\MSRA-VC12\Project_NewSaliency\GridSearch_3_25_2014', dataset);                   %Path for saving different saliency maps
srcSuffix = '.jpg';     %suffix for your input image
GT = SRC;

if ~exist(SP, 'dir')
    mkdir(SP);
end
if ~exist(BDCON, 'dir')
    mkdir(BDCON);
end
if ~exist(RES, 'dir')
    mkdir(RES);
end
GEOSIGMAS = [5;7;10];
NEISIGMAS = [7;10;15];
%% 2. Saliency Map Calculation
files = dir(fullfile(SRC, strcat('*', srcSuffix)));
if matlabpool('size') <= 0
    matlabpool('open', 'local', 8);
end
parfor k=1:length(files)
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
    
    if useSP
        [idxImg, adjcMatrix, pixelList] = SLIC_Split(noFrameImg, spnumber, SP, srcName);
    else
        [idxImg, adjcMatrix, pixelList] = Grid_Split(noFrameImg, spnumber);
    end
    %% Get super-pixel properties
    spNum = size(adjcMatrix, 1);
    meanRgbCol = GetMeanColor(noFrameImg, pixelList);
    meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
    meanPos = GetNormedMeanPos(pixelList, h, w);
    bdIds = GetBndPatchIds(idxImg);
    colDistM = GetDistanceMatrix(meanLabCol);
    posDistM = GetDistanceMatrix(meanPos);
    [clipVal, ~, ~] = EstimateDynamicParas(adjcMatrix, colDistM);
    
    %% Saliency Optimization
    for g = 1:length(GEOSIGMAS)
        for n = 1:length(NEISIGMAS)
            geoSigma = GEOSIGMAS(g);
            neiSigma = NEISIGMAS(n);
            [bgProb, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
            wCtr = CalWeightedContrast(colDistM, posDistM, bgProb);
            optwCtr = SaliencyOptimization(adjcMatrix, bdIds, colDistM, neiSigma, bgWeight, wCtr);
            
            smapName=fullfile(RES, strcat(noSuffixName, sprintf('_wCtr_Opt_g_%d_n_%d.png', geoSigma, neiSigma)));
            SaveSaliencyMap(optwCtr, pixelList, frameRecord, smapName, true);
        end
    end
end

%% 3. Evaluate MAE
if doMAEEval
    gtSuffix = '.bmp';
    for g = 1:length(GEOSIGMAS)
        for n = 1:length(NEISIGMAS)
            geoSigma = GEOSIGMAS(g);
            neiSigma = NEISIGMAS(n);
            CalMAE_foldInput(RES, sprintf('_wCtr_Opt_g_%d_n_%d.png', geoSigma, neiSigma), GT, gtSuffix);
        end
    end
end

%% 4. Evaluate PR Curve
lineProps = {
    {'r', 'g', 'b'}
    {'r--', 'g--', 'b--'}
    {'r:', 'g:', 'b:'}
    };
if doPRCEval
    gtSuffix = '.bmp';
    figure, hold on;
    LGS = cell(0,1);
    for g = 1:length(GEOSIGMAS)
        for n = 1:length(NEISIGMAS)
            geoSigma = GEOSIGMAS(g);
            neiSigma = NEISIGMAS(n);
            DrawPRCurve(RES, sprintf('_wCtr_Opt_g_%d_n_%d.png', geoSigma, neiSigma), GT, gtSuffix, true, true, lineProps{g}{n});
            LGS{end+1} = sprintf('g_%d_n_%d.png', geoSigma, neiSigma);
        end
    end
    hold off;
    grid on;
    lg = legend(LGS);
    set(lg, 'location', 'southwest');
end