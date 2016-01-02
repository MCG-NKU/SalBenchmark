function salValue = convertRecErrorToSal(recError,regions,r,c,supNum);
%% Output a saliency map by the reconstruction error for each superpixel.

salValue=zeros(r,c);

for i=1:supNum
    salValue(regions{i}.pixelInd)=recError(i);
end

salValue = (salValue - min(salValue(:)))/(max(salValue(:)) - min(salValue(:)));