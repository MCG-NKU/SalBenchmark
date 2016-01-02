function recError = calculatePCAError(trainData,DataAll_ori,paramPCA,dataNum,featDim)
%% Calculate the dense reconstruction errors by PCA.

Base = PCA( trainData , paramPCA.dim , paramPCA.rate );

Mean = zeros( featDim ,1 );
for Num = 1 : dataNum
	Mean = Mean + DataAll_ori( : , Num );                 
end
Mean = Mean / dataNum;                               
DataAll = DataAll_ori - repmat(Mean,1,dataNum);

recCoff = Base' * DataAll;	
RecData = zeros(featDim,dataNum); 
for k = 1:dataNum
	RecData(:,k) = Mean + Base * recCoff(:,k);  
	recError(1,k) = norm(DataAll_ori(:,k) - RecData(:,k));
end
recError = (recError -   min(recError(:)))/(max(recError(:)) - min(recError(:)));