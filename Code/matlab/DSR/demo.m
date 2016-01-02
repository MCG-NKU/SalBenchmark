clc;
clear all;
close all;

%% Parameter setting:
%% SLIC scale parameters
seg_paras = [50   10;
         	 100  10;
             150  20;
         	 200  20;
           	 250  25;
           	 300  25;
             350  30;
             400  30;
           	];              
%% feature selection parameters
isLAB = 1;                              %if isLAB = 1, LAB feature is chosen. if isLAB = 0, LAB feature is not chosen.
isRGB = 1;                              
isXY  = 1;                              
featDim = 3*(isLAB+isRGB)+2*isXY;       %The actual feature dimension. featDim = 8 when LAB, RGB and XY are all chosen as features. 
%% Sparse representation parameters
paramSR.lambda2 = 0;                    
paramSR.mode    = 2;
paramSR.lambda  = 0.01;
%% Dense representation parameters
paramPCA.dim  = 3*(isLAB+isRGB)+2*isXY; 
paramPCA.rate = 95;
%% Context-based error propagation parameters
paramPropagate.lamna = 0.5;             
paramPropagate.nclus = 8;
paramPropagate.maxIter=200;             
%% The parameter that controls the window size of the Gaussian model
guassSigmaRatio = 0.25;                 
%% The parameters of Bayesian integration
paramHist.isColorObserver = 0;       	%1: calculate the likelihoods of Bayesian inference by Lab color 
paramHist.isErrorObserver = 1;      	%1: calculate the likelihoods of Bayesian inference by error map 
paramHist.numBin = 60;
paramHist.labFactor = 5;
paramHist.errFactor = 0.02;

%% Read an input image
imName = 'test1.bmp';               % Make sure the input image be .bmp file to execute SLICSuperpixelSegmentation.exe. 
input_im=im2double(imread(imName));
input_imlab = RGB2Lab(input_im);
r=size(input_im,1);
c=size(input_im,2);
    
t1 = zeros(r,c);
t2 = zeros(r,c);
t3 = zeros(r,c);
t4 = zeros(r,c);
t5 = zeros(r,c);

%% Calculate multi-scale saliency maps.
for j=1:size(seg_paras,1)
        
    spnumber = seg_paras(j,1);
    compactness = seg_paras(j,2);
    
    %% SLIC
    sulabel = getSlicLabelMap(imName, compactness, spnumber, r, c);
    supNum = max(sulabel(:));
    regions = calculateRegionProps(supNum,sulabel);
    
    %% Extract superpixel features
    [sup_feat color_weight] = extractSupfeat(input_im,input_imlab,regions,r,c,supNum);
    feat = chooseFeature(sup_feat,isRGB,isLAB,isXY);
    
    %% Extract background templates
    bg_sp = extract_bg_sp(sulabel,r,c);
    bgfeat = feat(bg_sp,:);
    
    t1 = t1 + color_weight;
    
    %% Calculate sparse reconstruction error
    SRRecError = calculateSRError(bgfeat',feat',paramSR);
    SRRecErrorSaliency = convertRecErrorToSal(SRRecError,regions,r,c,supNum);
    t2 = t2 + SRRecErrorSaliency .* color_weight;
    
    %% Propagate sparse reconstruction error
    propSRRecError = descendPropagation(feat,SRRecError,paramPropagate,supNum,featDim);
    propSRRecErrorSaliency = convertRecErrorToSal(propSRRecError,regions,r,c,supNum);  
    t3= t3 + propSRRecErrorSaliency .* color_weight;  

    %% Calculate dense reconstruction error
    PCARecError = calculatePCAError(bgfeat',feat',paramPCA,supNum,featDim);
    PCARecErrorSaliency = convertRecErrorToSal(PCARecError,regions,r,c,supNum);
    t4= t4 + PCARecErrorSaliency .* color_weight;
    
    %% Propagate dense reconstruction error
    propPCARecError = descendPropagation(feat,PCARecError,paramPropagate,supNum,featDim);
    propPCARecErrorSaliency = convertRecErrorToSal(propPCARecError,regions,r,c,supNum);
    t5 = t5 + propPCARecErrorSaliency .* color_weight;
end  
%% Multi-scale integration  
smap = t2 ./ t1;
SRRecErrorSaliency = (smap - min(smap(:))) / (max(smap(:)) - min(smap(:)));
imwrite(SRRecErrorSaliency,strcat(imName(1:end-4),'_MSE.bmp'));
smap = t4 ./ t1;
PCARecErrorSaliency = (smap - min(smap(:))) / (max(smap(:)) - min(smap(:)));
imwrite(PCARecErrorSaliency,strcat(imName(1:end-4),'_MDE.bmp'));
smap = t3 ./ t1;
propSRRecErrorSaliency = (smap - min(smap(:))) / (max(smap(:)) - min(smap(:)));
imwrite(propSRRecErrorSaliency,strcat(imName(1:end-4),'_MSEP.bmp'));
smap = t5 ./ t1;
propPCARecErrorSaliency = (smap - min(smap(:))) / (max(smap(:)) - min(smap(:)));
imwrite(propPCARecErrorSaliency,strcat(imName(1:end-4),'_MDEP.bmp'));
    
%% Object-biased Gaussian Refinement
SRErrorPropGuassSaliency = calculateGuassOptimization(propSRRecErrorSaliency,guassSigmaRatio,r,c);
imwrite(SRErrorPropGuassSaliency,strcat(imName(1:end-4),'_MSEPG.bmp'));
PCAErrorPropGuassSaliency = calculateGuassOptimization(propPCARecErrorSaliency,guassSigmaRatio,r,c);
imwrite(PCAErrorPropGuassSaliency,strcat(imName(1:end-4),'_MDEPG.bmp'));    

%% Bayesian Integration
SRPriorBayes = calculateBayesPosterior(SRErrorPropGuassSaliency,PCAErrorPropGuassSaliency,input_imlab,r,c,paramHist);  
PCAPriorBayes = calculateBayesPosterior(PCAErrorPropGuassSaliency,SRErrorPropGuassSaliency,input_imlab,r,c,paramHist);
salmaps = zeros(r,c,2);
salmaps(:,:,1) = SRPriorBayes(:,:,1);   
salmaps(:,:,2) = PCAPriorBayes(:,:,1);
saliency = combineSalMap(salmaps, '+');
imwrite(saliency,strcat(imName(1:end-4),'_DSR.bmp'));