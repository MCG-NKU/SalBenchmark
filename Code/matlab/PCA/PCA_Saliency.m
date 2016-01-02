function result = PCA_Saliency(I_RGB)

if (~exist('vl_slic.m','file'))
    fprintf('\nConfiguring vl_slic & IM2COLSTEP\n');
    bindir = mexext;
    if (~strcmp(mexext,'mexw64'))
        fprintf('Note: You are not using Windows 64 bit: Fast im2colstep diabled\n');
    end;
    if strcmp(bindir, 'dll'), bindir = 'mexw32' ; end
    addpath(fullfile(pwd,'EXT','vl_slic')) ;
    addpath(fullfile(pwd,'EXT','vl_slic',bindir)) ;
    addpath(fullfile(pwd,'EXT','IM2COLSTEP')) ;
end


result = PCA_Saliency_Core(I_RGB);
end