function propagatedData = descendPropagation(feat,initData,paramPropagate,Nsample,featDim)
%% Calculate the propagated reconstruction errors.
%% Input:    
% feat: superpixel feature matrix, the size of which is Nsample * featDim.
% initData: the initial reconstruction errors.
% paramPropagate: propagation parameters.
%% Output:
% propagatedData: the propagated reconstruction errors.     

%% calculate the cluster centers 
centers = form_codebook(feat', paramPropagate.nclus,paramPropagate.maxIter);
%% label each superpixel
[ featLabel ] = labelCluster( centers, feat', Nsample, paramPropagate.nclus );

meanfeat = mean(feat,1);
sig2 = zeros(1,featDim);
for k=1:featDim
    sig2(k) = norm(feat(:,k) - meanfeat(:,k))^2/Nsample;
end
sigma2 = mean(sig2);

%% Calculate the Euclidean distance matrix
distMatrix = zeros(Nsample, Nsample);
for i=1:Nsample
    for j=i+1:Nsample
        distMatrix(i,j) = exp(-norm(feat(i,:)-feat(j,:))^2/(2*sigma2));
        distMatrix(j,i) = distMatrix(i,j);
    end
end

%% Propagation
[desData desInd] = sort(initData);
for i=Nsample:-1:1
    dataLabel = desInd(i);
    clusterlabel = featLabel(dataLabel);
    clusterbgsup = find(featLabel==clusterlabel);
    nInnerCluster = length(clusterbgsup);

	sumdist = 0;
	sumA = 0;
	for m=1:nInnerCluster
        M = clusterbgsup(m);
        sumdist = sumdist + distMatrix(dataLabel,M)*initData(M);
        sumA = sumA + distMatrix(dataLabel,M);
	end
    
    if sumA==0
        sumA = sumA+eps;
    end
	initData(dataLabel)=(1-paramPropagate.lamna)*initData(dataLabel) + paramPropagate.lamna/sumA*sumdist;
end
propagatedData = initData;
propagatedData = (propagatedData - min(propagatedData(:)))/(max(propagatedData(:)) - min(propagatedData(:)));