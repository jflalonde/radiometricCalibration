%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeColorTriplets
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeColorTriplets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Setup
addpath ../;
setPath;

dbPath = fullfile(basePath, 'sequenceDbV3');
imagesPath = fullfile(dataBasePath, 'webcamsDownloadDb', 'imagesDb');
skyMaskPath = fullfile(basePath, 'skyMasks');

outputBasePath = dbPath;

%% User parameters
doDisplay = 0;
recompute = 0;
doSave = 1;
globalSave = 0;

% edge parameters
patchSize = [10 10];
colorDiffThresh = 20/255;
varianceThresh = 10/255;
areaDiffThresh = 0.4;
minVarStraight = 2; % straight-ness of edges

% sequencesToProcess = getSequenceNames('train');
% sequencesToProcess = getSequenceNames('skyall');
% sequencesToProcess = getSequenceNames('HD');
% sequencesToProcess = getSequenceNames('input', '1076244800');%'Brocken';
sequencesToProcess = '';

% number of images to use 
nbImages = 2000; % all images 

% maximum number of candidate edges to try per image
maxNbEdges = 1000;

parallelized = 1;
randomized = 1;

%% Process the database
dbFn = @dbFnRadiometricCalibration;
processResultsDatabaseFast(dbPath, sequencesToProcess, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', imagesPath, 'DbPath', dbPath, ...
    'Recompute', recompute, 'DoSave', doSave, 'DoDisplay', doDisplay, 'Parallelized', 0, 'Randomized', randomized, ...
    'PatchSize', patchSize, 'VarianceThreshold', varianceThresh, 'ColorDiffThreshold', colorDiffThresh, ...
    'AreaDiffThreshold', areaDiffThresh, 'MinVarStraight', minVarStraight, ...
    'DoColorTriplets', 1, 'NbImages', nbImages, 'GlobalSave', globalSave, ...
    'SkyMaskPath', skyMaskPath, 'MaxNbEdges', maxNbEdges);
