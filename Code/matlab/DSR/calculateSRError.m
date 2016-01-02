function recError = calculateSRError(dictionary,allfeats,paramSR)
%% Calculate the sparse reconstruction errors.
allfeats = normVector(allfeats);
dictionary = normVector(dictionary);

paramSR.L = length(allfeats(:,1));                                

beta = mexLasso(allfeats, dictionary, paramSR);
beta = full(beta);

recError = sum((allfeats - dictionary*beta(1:size(dictionary,2),:)).^2); 

recError = (recError -   min(recError(:)))/(max(recError(:)) - min(recError(:)));