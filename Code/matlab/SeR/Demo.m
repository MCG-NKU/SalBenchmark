% Saliency detection Demo
% [HISTORY]
% Apr 25, 2011 : created by Hae Jong Seo

close all;
clear all;
clc;

param.P = 3; % LARK window size
param.alpha = 0.42; % LARK sensitivity parameter
param.h = 0.2; % smoothing parameter for LARK
param.L = 7; % # of LARK in the feature matrix 
param.N = 3; % size of a center + surrounding region for computing self-resemblance
param.sigma = 0.07; % fall-off parameter for self-resemblamnce

mkdir('SaliencyMaps');
for k = 7
    FN = ['./images/' num2str(k) '.jpg'];
    RGB = imread(FN);
    tic;
    smap = ComputeSaliencyMap(RGB,[64 64],param); % Resize input images to [64 64]
    disp(['image' num2str(k) ': ' num2str(toc) 'sec']); 
    save(['SaliencyMaps/SM_' num2str(k) '.mat'],'smap');
    % Plot saliency maps 
    figure(1)
    subplot(1,3,1),sc(RGB);
    subplot(1,3,2),sc(smap);
    subplot(1,3,3),sc(cat(3,smap,double(RGB(:,:,1))),'prob_jet');
end
