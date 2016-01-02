function regions = calculateRegionProps(sup_num,sulabel_im)
%% Calculate the region pixel index for each superpixel.
for r = 1:sup_num
	indxy = find(sulabel_im==r);
	[indx indy] = find(sulabel_im==r);
	regions{r}.pixelInd = indxy;
    regions{r}.pixelIndxy = [indx indy];
end