function [sup_feat,color_weight] = extractSupfeat(input_im,input_imlab,regions,row,col,sup_num)
%% Extract superpixel features.

color_weight = zeros(row, col);
R = input_im(:,:,1);
G = input_im(:,:,2);
B1 = input_im(:,:,3);
    
L = input_imlab(:,:,1);
A = input_imlab(:,:,2);
B2 = input_imlab(:,:,3);
    
% normalize the LAB color feature
L = (L-min(L(:)))/(max(L(:))-min(L(:)));
A = (A-min(A(:)))/(max(A(:))-min(A(:)));
B2 = (B2-min(B2(:)))/(max(B2(:))-min(B2(:)));
    
sup_feat = [];
for r = 1:sup_num
	ind = regions{r}.pixelInd;
	indxy = regions{r}.pixelIndxy;
	meanall = [mean(R(ind)),mean(G(ind)),mean(B1(ind)),mean(L(ind)),mean(A(ind)),mean(B2(ind)),mean(indxy(:,2))/col,mean(indxy(:,1))/row];
	color_weight(ind) = computeColorDist([R(ind) G(ind) B1(ind) L(ind) A(ind) B2(ind) indxy],repmat(meanall, [length(ind), 1]));
 	sup_feat = [sup_feat;mean(R(ind)),mean(G(ind)),mean(B1(ind)),mean(L(ind)),mean(A(ind)),mean(B2(ind)),mean(indxy(:,2))/col,mean(indxy(:,1))/row];
end
color_weight = 1 ./ (color_weight + eps);


function color_dist = computeColorDist(c1, c2)
color_dist = sqrt(sum((c1 - c2).^2, 2));