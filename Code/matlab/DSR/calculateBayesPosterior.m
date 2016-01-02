function BayesPosterior = calculateBayesPosterior(prior,observer,input_imlab,r,c,paramHist)
%% Calculate the Bayesian posterior probability.

BayesPosterior = zeros(r,c,3);
BW = im2bw(prior,mean(prior(:)));
ind = find(BW==1);
out_ind = find(BW==0);

%% calculate the likelihoods of Bayesian inference by Lab color 
if paramHist.isColorObserver   
    smoothFactor = paramHist.labFactor;
	BayesPosterior(:,:,2)=Bayes(prior, input_imlab, ind, out_ind, paramHist.numBin, smoothFactor, r, c);
end
%% calculate the likelihoods of Bayesian inference by error map 
if paramHist.isErrorObserver
    smoothFactor = paramHist.errFactor;
    BayesPosterior(:,:,1)=Bayes(prior, observer, ind, out_ind, paramHist.numBin, smoothFactor, r, c);
end