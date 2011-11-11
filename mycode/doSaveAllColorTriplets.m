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
function doSaveAllColorTriplets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Setup
addpath ../;
setPath;

dbPath = fullfile(basePath, 'subSequenceDb');

outputBasePath = dbPath;

%% User parameters
doSave = 1;
doDisplay = 0;
recompute = 0;

% sequencesToProcess = getSequenceNames('traingood');
sequencesToProcess = '655-1';

parallelized = 0;
randomized = 1;

%% Process the database
dbFn = @dbFnRadiometricCalibration;
processResultsDatabaseFast(dbPath, sequencesToProcess, '', outputBasePath, dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'DoSave', doSave, 'DoDisplay', doDisplay, 'Recompute', recompute, ...
    'DoSaveColorTriplets', 1);
