function [bdCon, Len_bnd, Area] = BoundaryConnectivity(adjcMatrix, weightMatrix, bdIds, clipVal, geo_sigma, link_boundary)
% Compute boundary connecity values for all superpixels

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014
if (nargin < 6)
    link_boundary = true;    
end
if (link_boundary)
    adjcMatrix = LinkBoundarySPs(adjcMatrix, bdIds);
end

adjcMatrix = tril(adjcMatrix, -1);
edgeWeight = weightMatrix(adjcMatrix > 0);
edgeWeight = max(0, edgeWeight - clipVal);

% Cal pair-wise shortest path cost (geodesic distance)
geoDistMatrix = graphallshortestpaths(sparse(adjcMatrix), 'directed', false, 'Weights', edgeWeight);

Wgeo = Dist2WeightMatrix(geoDistMatrix, geo_sigma);
Len_bnd = sum( Wgeo(:, bdIds), 2); %length of perimeters on boundary
Area = sum(Wgeo, 2);    %soft area
bdCon = Len_bnd ./ sqrt(Area);