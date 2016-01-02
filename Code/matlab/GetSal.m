function [  ] = GetSal(WkDir, ImgNameNE, MethodName)
    fileName = sprintf('%sImgs/%s.jpg', WkDir, ImgNameNE);    
    outName = sprintf('%sSaliency/%s_%s.png', WkDir, ImgNameNE, MethodName);
    fprintf('%sSaliency/%s_%s.png\r', WkDir, ImgNameNE, MethodName);    
    sMap = 0;
    
    if (exist(outName, 'file'))
       return;
    end
    
    switch MethodName
        case 'SEG' 
            sMap = GetSEG(imread(fileName));
        case 'IT'
            sMap = GetIT(fileName);
        case 'AIM'
            sMap = AIM(fileName)/255;
        case 'SIM'
            sMap = GetSIM(fileName)/255;
        case 'SUN'
            sMap = GetSUN(imread(fileName), 1)/255;
        case 'SeR'
            sMap = GetSeR(imread(fileName));
        case 'GB'
            tmp = gbvs(imread(fileName));
            sMap = tmp.master_map_resized;
        case 'SWD'
            sMap = GetSWD(fileName);
        case 'SS'
            sMap = signatureSal(fileName);
        case 'CA'
            sMap = GetCA(fileName);
        case 'CB'
            sMap = CBSaliency(imread(fileName));
        case 'DRFI'
            sMap = drfiGetSaliencyMap(imread(fileName), makeDefaultParameters);
        case 'SR'
            sMap = GetSR(fileName);
        case 'GR'
            sMap = GetGR(fileName);
        case 'LMLC'
            sMap = GetLMLC(fileName);
        case 'MC'
            sMap = GetMC(fileName);
        case 'BMS'
            sMap = GetBMS(fileName);
        case 'MNP'
            sMap = GetMNP(fileName);
        case 'COV'
            sMap = GetCOV(fileName);
        case 'FES'
            sMap = GetFES(fileName);
        case 'DSR'
            sMap = GetDSR(fileName);
        case 'ICVS'
            sMap = GetICVS(fileName);
        case 'PCA'
            sMap = PCA_Saliency_Core(imread(fileName));
        case 'OBJ'
            sMap = GetOBJ(fileName);
        case 'SVO'
            sMap = GetSVO(fileName);
        case 'CHM'
            sMap = GetCHM(fileName);
        case 'RBD'
            sMap = GetRBD(fileName);
        otherwise
            warning('Unexpected type. No plot created.');
    end
    
    %imwrite(mat2gray(sMap), outName); 
    imwrite(sMap, outName);                 
end

function [SalMap] = GetSWD(imgName)
     SalMap = Wu_ImageSaliencyComputing(imgName, 14, 11, 3);
end

function [SalMap] = GetSIM(filename)
    img          = double(imread(filename));
    [m, n, p]      = size(img);
    window_sizes = [13 26];                          % window sizes for computing center-surround contrast
    wlev         = min([7,floor(log2(min([m n])))]); % number of wavelet planes
    gamma        = 2.4;                              % gamma value for gamma correction
    srgb_flag    = 1;                                % 0 if img is rgb; 1 if img is srgb

    % get saliency map:
    SalMap = SIM(img, window_sizes, wlev, gamma, srgb_flag);
end

function [SalMap] = GetSEG(img)
    [L,a,b]=RGB2Lab(img); % You need some function RGB2Lab to perform the conversion
    SalMap = SEG({L, a, b});
end

function [SalMap] = GetSeR(RGB)
    param.P = 3; % LARK window size
    param.alpha = 0.42; % LARK sensitivity parameter
    param.h = 0.2; % smoothing parameter for LARK
    param.L = 7; % # of LARK in the feature matrix 
    param.N = 3; % size of a center + surrounding region for computing self-resemblance
    param.sigma = 0.07; % fall-off parameter for self-resemblamnce

    SalMap = ComputeSaliencyMap(RGB,[64 64],param); % Resize input images to [64 64]
end

function [SalMap] = GetIT(fileName)
    [imgStruct,err] = initializeImage(fileName);
    if isempty(err)
        myParams = defaultSaliencyParams;
        if (imgStruct.dims == 2)
            myParams = removeColorFeatures(myParams);
        end
        imgSize = imgStruct.size(1:2);
        if (min(imgSize) < 256) % size smaller than 256 will make the code crash
            newSize = round(imgSize * (256/min(imgSize)));
            imgStruct.size(1:2) = newSize;
            imgStruct.data = imresize(imgStruct.data, newSize);
        end
        SalMap = makeSaliencyMap(imgStruct,myParams);
        SalMap = imresize(SalMap.data, imgSize);
    end
end