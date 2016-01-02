function [ salMap ] = GetCOV( imageName )

    % options for saliency estiomation
    options.size = 512;                     % size of rescaled image
    options.quantile = 1/10;                % parameter specifying the most similar regions in the neighborhood
    options.centerBias = 1;                 % 1 for center bias and 0 for no center bias
    options.modeltype = 'CovariancesOnly';  % 'CovariancesOnly' and 'SigmaPoints' 
                                            % to denote whether first-order statistics
                                            % will be incorporated or not

    % Visual saliency estimation with covariances only                                    
    salMap = saliencymap(imageName, options);
   
    salMap = mat2gray(salMap);
end

