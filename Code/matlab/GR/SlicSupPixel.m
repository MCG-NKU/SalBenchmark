function [ superpixels ] = SlicSupPixel(img3u, imgPath)
    supdir='./superpixels200/';%% the superpixels files saving dir
    if ~exist(supdir, 'dir')
        mkdir(supdir);
    end
    [~,fileName,~] = fileparts(imgPath);
    outname=[supdir fileName '.bmp'];
    imwrite(img3u, outname);
    [m,n,~] = size(img3u);
        
%% generate superpixels
    spnumber=200;%% superpixels number
    comm=['SLICSuperpixelSegmentation' ' ' outname ' ' int2str(20) ' ' int2str(spnumber) ' ' supdir];
    system(comm);    
    spname=[supdir fileName  '.dat'];
    superpixels=ReadDAT([m,n],spname);
    
    delete([supdir fileName '.bmp']);
    delete([supdir fileName '.dat']);
    delete([supdir fileName '_SLIC.bmp']);
end

