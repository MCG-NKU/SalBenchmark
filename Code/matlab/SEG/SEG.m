function [salMat,salMatInd]=SEG(dataCell)
% function [salMat,salMatInd]=saliencyMeasure(dataCell) computes saliency measure values for given image.
% 
% Inputs:
% dataCell = Cell array containing the input information channels. With current configuration four choices are supported
%            dataCell={L}, dataCell={L,absFlow}, dataCell={L,a,b}, and dataCell={L,a,b,absFlow}, where L,a,b correspond to
%            Lab-color channels and absFlow is an absolute value of optical flow. For other choices you must change configuration.
%            In addition 2D-distributions are also supported (need change in config e.g. numBins). Then input is e.g. dataCell={L,ab}, where 
%            ab=cat(3,a,b); 
%
% Outputs:
% salMat    =  Matrix containing saliency measure values for each pixel
% salMatInd =  Cell array containin saliency measure values per each individual information channel. 
%              (Computed automatically if two output arguments defined, otherwise not computed (faster))
%
% Example usage:
% >>img=imread('exampleImage.jpg');
% >>[L,a,b]=RGB2Lab(img); % You need some function RGB2Lab to perform the conversion
% >>salMat=saliencyMeasure({L,a,b});
% or
% >>[salMat,salMatInd]=saliencyMeasure({L,a,b});
%
% Copyright 2010 Esa Rahtu
% Matlab implementation for illustrative purposes.

%% Default parameters
% General config
% Window parameters (relative to max(imRow,imCol))
config.windowRows=[0.25 0.3 0.5 0.7]; % Window row size relative to image size max(imRow,imCol))
config.windowCols=[0.1 0.3 0.5 0.4]; % Window column size relative to image size max(imRow,imCol))
config.sampleStep=[0.01 0.015 0.03 0.04]; % Window sampling step relative to image size max(imRow,imCol)) (one for each window size) 
    
% Saliency detector parameters (borders relative to max(imRow,imCol))
config.verticalBorder=0.1; % Vertical border size relative to image size
config.horizontalBorder=0.1; % Horizontal border size relative to image size
config.pH1=0.2; % pH1 parameter (pH0=1-pH1)

% Feature related config (assumes input {L,a,b,absFlow}}
% L channel
featConf(1).numBin=60; % Number of bins in histogram (if 2D histogram are used, numBin=[numBin1, numBin2];)
featConf(1).minVal=0;  % Minimum feature value
featConf(1).maxVal=255; % Maximum feature value
featConf(1).smoothFactor=5; % Smoothing factor
% a and b channels    
featConf(2).numBin=60;
featConf(2).minVal=-20;
featConf(2).maxVal=20;
featConf(2).smoothFactor=5;
featConf(3)=featConf(2);
% Motion flow channel
featConf(4).numBin=15;
featConf(4).minVal=0;
featConf(4).maxVal=15;
featConf(4).smoothFactor=1;

% Other
config.verbose=2; %0->show nothing, 1->display processing msgs, 2->display also result images
config.flipBox=0; % Turn window according to image aspect ratio
%config.compIndSal=0; % Compute also saliency maps for individual feature channels (1 if 2 output arguments defined, 0 otherwise)
config.fullImage=[0 0 0 2]; % 0-> whole window inside image, 1-> kernel inside image, 2->full image. Corresponds to each feature in dataCell 
    
%% Assume following automatic configuration settings
% length(dataCell==4) % Assume input {L,a,b,absFlow}
% length(dataCell==3) % Assume input {L,a,b}
% length(dataCell==2) % Assume input {L,absFlow}
% length(dataCell==1) % Assume input {L}
if length(dataCell)==2
    featConf(2)=featConf(4);
    config.fullImage=[0 2];
end


%% Initialize
config.numRow=size(dataCell{1},1);
config.numCol=size(dataCell{1},2);
config.numFeat=length(dataCell);
if config.numCol>config.numRow && config.flipBox==1
    tmp=config.windowRows; config.windowRows=config.windowCols; config.windowCols=tmp;
end   
config=parseConfiguration_(config);
numFeat=length(dataCell);
numRow=size(dataCell{1},1);
numCol=size(dataCell{1},2);
salMat=zeros(numRow,numCol,length(config.windowRows));
intHist=cell(1,numFeat);
smoothingKernel=cell(1,numFeat);
salMatInd=cell(1,numFeat);
if nargout<2
    config.compIndSal=0;
else
    config.compIndSal=1;
end


%% Compute integral histogram image
for i=1:numFeat
    [intHist{i},dataCell{i}]=formIntegralHistogram_(dataCell{i},featConf(i).numBin,featConf(i).minVal,featConf(i).maxVal);
    smoothingKernel{i}=getSmoothKernel_(featConf(i).smoothFactor);
    if config.compIndSal>0
        salMatInd{i}=zeros(numRow,numCol);
    end
end

%% Run trough image using all sliding windows sizes
for winSizeId=1:length(config.windowRows)
        
    if config.verbose>=1
        fprintf('Kernel %i x %i, borders %i x %i, step %i.\n',config.windowRows(winSizeId)-2*config.verticalBorder(winSizeId),config.windowCols(winSizeId)-2*config.horizontalBorder(winSizeId),config.verticalBorder(winSizeId),config.horizontalBorder(winSizeId),config.sampleStep(winSizeId));
    end
        
    % Initialize window parameters
    halfWinRow=floor(config.windowRows(winSizeId)/2);
    halfWinCol=floor(config.windowCols(winSizeId)/2);
    halfKerRow=halfWinRow-config.verticalBorder(winSizeId);
    halfKerCol=halfWinCol-config.horizontalBorder(winSizeId);
    kernelRowIdx=-halfKerRow:halfKerRow;
    kernelColIdx=-halfKerCol:halfKerCol;
    
    % Initialize window positions
    if sum(config.fullImage(1:numFeat))>0
        rowCent=(config.sampleStep(winSizeId)+1):config.sampleStep(winSizeId):numRow;
        colCent=(config.sampleStep(winSizeId)+1):config.sampleStep(winSizeId):numCol;
        rowCent(rowCent>(numRow))=[];
        colCent(colCent>(numCol))=[];
        numWindow=length(rowCent)*length(colCent);
    else
        rowCent=(halfWinRow+1):config.sampleStep(winSizeId):numRow;
        colCent=(halfWinCol+1):config.sampleStep(winSizeId):numCol;
        rowCent(rowCent>(numRow-halfWinRow))=[];
        colCent(colCent>(numCol-halfWinCol))=[];
        numWindow=length(rowCent)*length(colCent);
    end

    % Initialize a priori probabilities
    pH1=config.pH1;
    pH0=1-pH1;

    % Loop trough all windows and calculate saliency
    cnt=1;
    for winRowPos=rowCent
        for winColPos=colCent
            
            % Display info if needed
            if (cnt>1 && config.verbose>=1)
                fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bWindow %0.6i of %0.6i',cnt,numWindow);
            elseif(config.verbose>=1)
                fprintf('Window %0.6i of %0.6i',cnt,numWindow);
            end
            cnt=cnt+1;
            
            % Initialize critical points
            k11=[winRowPos-halfKerRow-1,winColPos-halfKerCol-1]+1; 
            k12=[winRowPos-halfKerRow-1,winColPos+halfKerCol]+1;
            k21=[winRowPos+halfKerRow,winColPos-halfKerCol-1]+1;
            k22=[winRowPos+halfKerRow,winColPos+halfKerCol]+1;
            w11=[winRowPos-halfWinRow-1,winColPos-halfWinCol-1]+1;
            w12=[winRowPos-halfWinRow-1,winColPos+halfWinCol]+1;
            w21=[winRowPos+halfWinRow,winColPos-halfWinCol-1]+1;
            w22=[winRowPos+halfWinRow,winColPos+halfWinCol]+1;
            
            if sum([k11<1 k12(1)<1 k12(2)>(numCol+1) k21(1)>(numRow+1) k21(2)<1 k22(1)>(numRow+1) k22(2)>(numCol+1)])>0
                innerWindowFlag=2;
            elseif sum([w11<1 w12(1)<1 w12(2)>(numCol+1) w21(1)>(numRow+1) w21(2)<1 w22(1)>(numRow+1) w22(2)>(numCol+1)])>0
                innerWindowFlag=1;
            else
                innerWindowFlag=0;
            end
            
            k11=min(max(k11,[1,1]),[numRow+1,numCol+1]);
            k12=min(max(k12,[1,1]),[numRow+1,numCol+1]);
            k21=min(max(k21,[1,1]),[numRow+1,numCol+1]);
            k22=min(max(k22,[1,1]),[numRow+1,numCol+1]);
            
            w11=min(max(w11,[1,1]),[numRow+1,numCol+1]);
            w12=min(max(w12,[1,1]),[numRow+1,numCol+1]);
            w21=min(max(w21,[1,1]),[numRow+1,numCol+1]);
            w22=min(max(w22,[1,1]),[numRow+1,numCol+1]);
            
            featureRowIndex=kernelRowIdx+winRowPos;
            featureRowIndex(featureRowIndex<1 | featureRowIndex>numRow)=[];
            featureColIndex=kernelColIdx+winColPos;
            featureColIndex(featureColIndex<1 | featureColIndex>numCol)=[];
            
            % Calculate histograms
            PrH1=pH1;
            PrH0=pH0;
            for i=1:numFeat
                if innerWindowFlag==0 || config.fullImage(i)>=innerWindowFlag
                    pX_H1=double(intHist{i}(k22(1),k22(2),:)+intHist{i}(k11(1),k11(2),:)-intHist{i}(k12(1),k12(2),:)-intHist{i}(k21(1),k21(2),:));
                    pX_H0=double(intHist{i}(w22(1),w22(2),:)+intHist{i}(w11(1),w11(2),:)-intHist{i}(w12(1),w12(2),:)-intHist{i}(w21(1),w21(2),:))-pX_H1;
                
                    pX_H1=filterDistribution_(smoothingKernel{i},pX_H1(:)',featConf(i).numBin);
                    pX_H0=filterDistribution_(smoothingKernel{i},pX_H0(:)',featConf(i).numBin);
                
                    PrX_H1=pX_H1(dataCell{i}(featureRowIndex,featureColIndex));
                    PrX_H0=pX_H0(dataCell{i}(featureRowIndex,featureColIndex));
                    
                    PrH1=PrH1.*PrX_H1;
                    PrH0=PrH0.*PrX_H0;
                
                    if config.compIndSal>0
                        PrH1_X_perFeat=(PrX_H1*pH1)./(PrX_H1*pH1+PrX_H0*pH0);
                        salMatInd{i}(featureRowIndex,featureColIndex)=max(PrH1_X_perFeat,salMatInd{i}(featureRowIndex,featureColIndex));
                    end
                end
            end
            
            PrH1_X=PrH1./(PrH1+PrH0);
            
            % Read saliency values for datapoints
            salMat(featureRowIndex,featureColIndex,winSizeId)=max(PrH1_X,salMat(featureRowIndex,featureColIndex,winSizeId));

        end
    end
    if(config.verbose>=1)
        fprintf('\n');
    end
end


% Concatenate saliency images with different resolutions
salMat=max(salMat,[],3);

% %% Display result
% if(config.verbose>=2)
%     
%     if config.compIndSal>0
%         visImg=[];
%         for i=1:numFeat
%             dataMat=double(dataCell{i})/max(dataCell{i}(:));
%             visImg=[visImg,[dataMat;salMatInd{i}]];
%         end
%         visImg=[visImg,[double(salMat>0.7);salMat]];
%     else
%         visImg=[];
%         for i=1:numFeat
%             dataMat=double(dataCell{i})/max(dataCell{i}(:));
%             visImg=[visImg,dataMat];
%         end
%         visImg=[visImg,salMat];
%     end
%     
%     figure; imshow(visImg,[]);
%     if config.compIndSal==0
%         title('Left to right: Each feature channel and rightmost is resulting saliency map.');
%     else
%         title('Top row left to right: Each feature channel and rightmost is thresholded (>0.7) saliency map. Bottom row corresponding feature channel saliency maps and rightmost is combined map.');
%     end
%     
% end














%%%%%%%%%%%%%%%%%%%%%%%%
% Additional functions %
%%%%%%%%%%%%%%%%%%%%%%%%

%% Make integral histogram image
function [intHist,binInd]=formIntegralHistogram_(dataMat,numBin,minVal,maxVal)
% currently only 1 histograms

% Compute bin indices
%binInd=ceil(numBin*(double(dataMat)+1e-5)/maxVal);
%binInd(binInd>numBin)=numBin;

if isempty(dataMat)
    error('Datamatrix is empty');
end

% If only one numBin/minVal/maxVal is given, but dataMat has more feature, use same numBin/minVal/maxVal for all dimensions.
if(length(numBin)<size(dataMat,3))
    numBin=repmat(numBin(1),[1,size(dataMat,3)]);
end
if(length(minVal)<size(dataMat,3))
    minVal=repmat(minVal(1),[1,size(dataMat,3)]);
end
if(length(maxVal)<size(dataMat,3))
    maxVal=repmat(maxVal(1),[1,size(dataMat,3)]);
end

% Compute bin indices
binInd=ones(size(dataMat,1),size(dataMat,2));
binOffset=[1 numBin];
for i=1:size(dataMat,3)
    tempInd=max(min(ceil(numBin(i)*(double(dataMat(:,:,i))-minVal(i))/(maxVal(i)-minVal(i))),numBin(i)),1);
    binInd=binInd+prod(binOffset(1:i))*(tempInd-1);
end

%% Matlab version
r=size(binInd,1); c=size(binInd,2);
intHist=zeros(r+1,c+1,prod(numBin),'int32');

intHist(2,2,binInd(1,1))=1;
for i=2:c
    intHist(2,i+1,:)=intHist(2,i,:);
    intHist(2,i+1,binInd(1,i))=intHist(2,i+1,binInd(1,i))+1;
end
for j=2:r
    intHist(j+1,2,:)=intHist(j,2,:);
    intHist(j+1,2,binInd(j,1))=intHist(j+1,2,binInd(j,1))+1;
end

for i=2:c
    for j=2:r
        intHist(j+1,i+1,:)=intHist(j,i+1,:)+intHist(j+1,i,:)-intHist(j,i,:);   
        intHist(j+1,i+1,binInd(j,i))=intHist(j+1,i+1,binInd(j,i))+1;
    end
end



%% Get smoothing filter
function [smKer]=getSmoothKernel_(sigma)

if sigma==0
    smKer=1;
    return;
end

dim=length(sigma); % row, column, third dimension
sz=max(ceil(sigma*2),1);
sigma=2*sigma.^2;

if dim==1
    d1=-sz(1):sz(1);
    
    smKer=exp(-((d1.^2)/sigma));
    
elseif dim==2
    [d2,d1]=meshgrid(-sz(2):sz(2),-sz(1):sz(1));
    
    smKer=exp(-((d1.^2)/sigma(1)+(d2.^2)/sigma(2)));
    
elseif dim==3
    [d2,d1,d3]=meshgrid(-sz(2):sz(2),-sz(1):sz(1),-sz(3):sz(3));
    
    smKer=exp(-((d1.^2)/sigma(1)+(d2.^2)/sigma(2)+(d3.^2)/sigma(3)));
    
else
    error('Not implemented');
end

smKer=smKer/sum(smKer(:));





%% Smooth distribution
function dist=filterDistribution_(filterKernel,dist,numBin)

if numel(filterKernel)==1
    dist=dist(:)/sum(dist(:));
    return;
end

numDim=length(numBin);

if numDim==1
    %smoothDist=conv(dist,filterKernel,'same');
    
    lenDist=length(dist);
    hlenKernel=(length(filterKernel)-1)/2;

    dist=[dist(1)*ones(1,hlenKernel),dist,dist(end)*ones(1,hlenKernel)];
    dist=conv(dist,filterKernel);
    lenSmoothDist=length(dist);
    offset=(lenSmoothDist-lenDist)/2;
    dist=dist((offset+1):(lenSmoothDist-offset));
    
elseif numDim==2
    dist=reshape(dist,numBin);
    
    dist=conv2(filterKernel,filterKernel,dist,'same');
    
else
    dist=reshape(dist,numBin);
    
    for i=1:numDim
        fker=ones(1,numDim);
        fker(i)=length(filterKernel);
        fker=zeros(fker);
        fker(:)=filterKernel(:);
        
        dist=convn(dist,fker,'same');
        
    end
    
end

dist=dist(:)/sum(dist(:));







%% Parse config
function config=parseConfiguration_(config)

numWindow=length(config.windowRows);

% Window rows and columns
config.windowRows=round(config.windowRows*max(config.numRow,config.numCol));
config.windowCols=round(config.windowCols*max(config.numRow,config.numCol));

% Window step size
if(length(config.sampleStep)<numWindow)
    config.sampleStep=repmat(config.sampleStep,1,numWindow);
end
config.sampleStep=ceil(config.sampleStep*max(config.numRow,config.numCol));

% Border lengths
if(length(config.verticalBorder)<numWindow)
    config.verticalBorder=repmat(config.verticalBorder,1,numWindow);
end
if(length(config.horizontalBorder)<numWindow)
    config.horizontalBorder=repmat(config.horizontalBorder,1,numWindow);
end
config.verticalBorder=round(config.verticalBorder.*max(config.windowRows,config.windowCols));
config.horizontalBorder=round(config.horizontalBorder.*max(config.windowRows,config.windowCols));

% Increase window sizes by border sizes
config.windowRows=config.windowRows+2*config.verticalBorder;
config.windowCols=config.windowCols+2*config.horizontalBorder;

% Full image flag
if(length(config.fullImage)<numWindow)
    config.fullImage=repmat(config.fullImage(1),[1,numWindow]);
end
