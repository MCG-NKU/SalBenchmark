function chosedFeat = chooseFeature(feature,isRGB,isLAB,isXY)
chosedFeat = [];
if isRGB==1
	chosedFeat = [chosedFeat feature(:,1:3)];
end
if isLAB==1
	chosedFeat = [chosedFeat feature(:,4:6)];
end
if isXY==1
	chosedFeat = [chosedFeat feature(:,7:8)];
end