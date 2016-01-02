function param = default_signature_param()

%
% most important parameter. determines channels to use
% there are 3 options: LAB, DKL, RGB
%
param.colorChannels = 'LAB';

%
% signature output must be blurred
% (expressed as fraction of image width)
%
param.blurSigma = .045; 

%
% size of the underlying saliency map
%
param.mapWidth = 64;

% 
% resize saliency map to image input 
% note: can be slow; turn off for faster performance.
%
param.resizeToInput = 1; 

%
% for normalization
%
param.subtractMin = 1; 
