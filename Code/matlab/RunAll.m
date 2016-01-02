clear; close all; clc;
RootDir = '../../../Data/';
SubNames = {'DataSet1/' , 'DataSet2/'};

% MethodNames = {'CA', 'COV', 'DSR', 'FES', 'GR', 'ICVS', 'MC', 'PCA', 'RBD', 'SEG', 'SeR', 'SIM', 'SR', 'SUN', 'SWD'};
% You can chose these methods to produce SaliencyMap as follow.

MethodNames = {'PCA','SWD'};

RunDatasets(SubNames, MethodNames, RootDir);
