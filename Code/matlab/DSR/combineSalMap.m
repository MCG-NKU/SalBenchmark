function [ combinedMap ] = combineSalMap( allmap, strategyTemp)
%% Combine multiple saliency maps.
%% Input:
%   allmap: the size of 'allmap' is [row, column, number of maps]
%   strategyTemp: '+' means averaging the maps, while '*' means
%   multiplying the maps.
%% Output:
%   combinedMap: the combined map, the size of which is row * column

[r c mapN] = size(allmap);

if strategyTemp == '+'
    sumMap = zeros(r,c);
    for i=1:mapN
        sumMap = sumMap + allmap(:,:,i);
    end
    combinedMap = sumMap/mapN;
end

if strategyTemp == '*'
    combinedMap = ones(r,c);
    for i=1:mapN
        combinedMap = combinedMap .* allmap(:,:,i);
    end
end

combinedMap = (combinedMap - min(combinedMap(:)))/(max(combinedMap(:)) - min(combinedMap(:)));

end