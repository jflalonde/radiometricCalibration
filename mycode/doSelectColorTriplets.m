%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doSelectColorTriplets
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doSelectColorTriplets
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
doDisplay = 0;
recompute = 0;

nbSelectedTriplets = 50000;
sequencesToProcess = '';
% sequencesToProcess = getSequenceNames('input', '1207757616');
% sequencesToProcess = getSequenceNames('input', '1076244800');%getSequenceNames('HD');
% sequencesToProcess = getSequenceNames('input', 'SanJose');

parallelized = 1;
randomized = 1;

%% Process the database
dbFn = @dbFnRadiometricCalibration;
processResultsDatabaseFast(dbPath, sequencesToProcess, '', outputBasePath, dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'DoSave', doSave, 'DoDisplay', doDisplay, 'Recompute', recompute, ...
    'DoSelectColorTriplets', 1, 'NbSelectedTriplets', nbSelectedTriplets);

