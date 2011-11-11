%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [gmmInvMix, pcaInvMean, pcaInvBases] = radiometricCalibrationInfo    
%  Loads useful stuff for code for radiometric calibration from a single image.
%   (Lin et al., 2004)
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gmmInvMix, pcaInvMean, pcaInvBases] = radiometricCalibrationInfo    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2009 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
basePath = '/nfs/hn01/jlalonde/results/webcamSequence';

gmmModelsPath = fullfile(basePath, 'cameraResponses', 'gmmModels');
gmmModelsFile = fullfile(gmmModelsPath, 'gmmModels_coeff.mat');

%% Load the database of camera response functions
[brightnessDb, invBrightnessDb] = loadDatabaseOfResponseFunction(basePath);

%% Load GMM
gmmModelsInfo = load(gmmModelsFile, 'gmmInvMix');
gmmInvMix = gmmModelsInfo.gmmInvMix;

%% Run PCA
nbPCABases = 5;
[pcaInvMean, pcaInvBases] = getPCAModelFromDatabaseOfResponseFunctions(invBrightnessDb, nbPCABases);

