%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doRadiometricCalibration
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doRadiometricCalibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Setup
addpath ../;
setPath;

dbPath = fullfile(basePath, 'sequenceDbV3');

outputBasePath = dbPath;

gmmModelsPath = fullfile(basePath, 'cameraResponses', 'gmmModels');
gmmModelsFile = fullfile(gmmModelsPath, 'gmmModels_coeff.mat');

%% User parameters
doDisplay = 0;
recompute = 0;
doSave = 1;

% optimization parameters
% lambdaPrior = 7.5e2;
% lambdaPrior = 7;
lambdaPrior = 0.001;

% clustering parameters
nbPCABases = 5;

useSelectedTriplets = 1;

sequencesToProcess = '';
% sequencesToProcess = getSequenceNames('input', '1207757616');%''; %getSequenceNames('input', '1076244800');%getSequenceNames('HD');

parallelized = 1;
randomized = 1;

%% Load the database of camera response functions
[brightnessDb, invBrightnessDb] = loadDatabaseOfResponseFunction(basePath);

%% Load GMM
load(gmmModelsFile);

%% Run PCA
[pcaInvMean, pcaInvBases] = getPCAModelFromDatabaseOfResponseFunctions(invBrightnessDb, nbPCABases, 'DoDisplay', doDisplay);

%% Process the database
dbFn = @dbFnRadiometricCalibration;
processResultsDatabaseFast(dbPath, sequencesToProcess, '', outputBasePath, dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'Recompute', recompute, 'DoCalibration', 1, ...
    'DoSave', doSave, 'DoDisplay', doDisplay, 'Randomized', randomized, ...
    'PcaInvMean', pcaInvMean, 'PcaInvBases', pcaInvBases, 'GmmInvMix', gmmInvMix, 'LambdaPrior', lambdaPrior, ...
    'UseSelectedTriplets', useSelectedTriplets);
