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
function doPreloadColorTriplets
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

%% User parameters
doSave = 1;
recompute = 0;

% sequencesToProcess = getSequenceNames('input', '1076244800');%getSequenceNames('input', 'Tokyo');
% sequencesToProcess = getSequenceNames('input', '1207757616');
sequencesToProcess = '';

parallelized = 1;
randomized = 1;

%% Process the database
dbFn = @dbFnRadiometricCalibration;
processResultsDatabaseFast(dbPath, sequencesToProcess, '', outputBasePath, dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'DoSave', doSave, 'Recompute', recompute, 'DoPreloadColorTriplets', 1);
