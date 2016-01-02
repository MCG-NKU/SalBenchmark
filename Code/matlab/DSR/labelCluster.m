function [ featLabel ] = labelCluster( centers, allfeat, N_sample, nclus )
%% Label each superpixel according to the cluster centers.

distance = zeros(nclus,N_sample);

for i=1:nclus
    for j=1:N_sample
        distance(i,j) = norm(allfeat(:,j)-centers(:,i));
    end
end

[minval , featLabel] = min(distance);