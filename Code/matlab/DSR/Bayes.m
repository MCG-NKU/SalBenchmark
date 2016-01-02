function posterior = Bayes(prior, observer, ind, out_ind, nBin, factor, row, col)
%% Calculate the Bayesian posterior probability.

Ndim = size(observer,3);
mat_im = [];
for inputDim = 1:Ndim
    mat_im = [mat_im ; reshape(observer(:,:,inputDim),1,row*col)];
end
maxValO = max(mat_im(:,ind),[],2);
minVal0 = min(mat_im(:,ind),[],2);
maxValB = max(mat_im(:,out_ind),[],2);
minValB = min(mat_im(:,out_ind),[],2);
numBin = nBin*ones(1,Ndim); % Number of bins in histogram
smoothFactor = factor*ones(1,Ndim); % Smoothing factor

PrH1 = 1;
PrH0 = 1;
out_PrH1 =1;
out_PrH0 = 1;

for i = 1:Ndim
    cur_im = observer(:,:,i);
    
    dataMat = cur_im(ind);
    [innerHist,innerBin] = ComputeHistogram_(dataMat,numBin(i),minVal0(i),maxValO(i));
    smoothingKernel=getSmoothKernel_(smoothFactor(i));
    innerHist=filterDistribution_(smoothingKernel,innerHist',numBin(i));
    
    dataMat = cur_im(out_ind);
    [outerHist,outerBin] = ComputeHistogram_(dataMat,numBin(i),minValB(i),maxValB(i));
    smoothingKernel=getSmoothKernel_(smoothFactor(i));
    outerHist=filterDistribution_(smoothingKernel,outerHist',numBin(i));
    
    PrO_H1 = innerHist(innerBin);
    PrO_H0 = outerHist(innerBin);
    PrH1=PrH1.*PrO_H1;
    PrH0=PrH0.*PrO_H0;
       
    PrB_H1 = innerHist(outerBin);
    PrB_H0 = outerHist(outerBin);
    out_PrH1=out_PrH1.*PrB_H1;
    out_PrH0=out_PrH0.*PrB_H0;
end

sal_o_super = prior(ind);
sal_b_super = prior(out_ind);
Pr_0=(PrH1.*sal_o_super)./(PrH1.*sal_o_super+PrH0.*(1 - sal_o_super));
Pr_B=(out_PrH1.*sal_b_super)./(out_PrH1.*sal_b_super+out_PrH0.*(1-sal_b_super));

posterior = zeros(row,col);
posterior(ind) = Pr_0;
posterior(out_ind) = Pr_B;
posterior = (posterior - min(posterior(:)))/(max(posterior(:)) - min(posterior(:)));


function [intHist,binInd]=ComputeHistogram_(dataMat,numBin,minVal,maxVal)
binInd=max( min(ceil(numBin*(double(dataMat-minVal)/(maxVal-minVal))),numBin),1);
intHist=zeros(numBin,1);
for i = 1:length(dataMat)
    intHist(binInd(i))=intHist(binInd(i))+1;
end

function [smKer]=getSmoothKernel_(sigma)
if sigma==0
    smKer=1;
    return;
end
dim=length(sigma); 
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

function dist=filterDistribution_(filterKernel,dist,numBin)
if numel(filterKernel)==1
    dist=dist(:)/sum(dist(:));
    return;
end
numDim=length(numBin);
if numDim==1  
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