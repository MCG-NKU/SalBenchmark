function [ salMap ] = GetRBD( imgPath )
%GETRBG 此处显示有关此函数的摘要
%   此处显示详细说明
    noFrameImg = imread(imgPath);
    [h, w, ~] = size(noFrameImg);

    %% 1. Parameter Settings
    %useSP = true;           %You can set useSP = false to use regular grid for speed consideration
    doMAEEval = true;       %Evaluate MAE measure after saliency map calculation
    doPRCEval = true;       %Evaluate PR Curves after saliency map calculation

    %% Segment input rgb image into patches (SP/Grid)
    pixNumInSP = 600;                           %pixels in each superpixel
    spnumber = round( h * w / pixNumInSP );     %super-pixel number for current image
 
    [idxImg, adjcMatrix, pixelList] = SLIC_Split(noFrameImg, spnumber);
    
    
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
    
    salMap = CreateImageFromSPs(optwCtr, pixelList, h, w, true);
end

