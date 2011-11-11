%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doVisualizeCalibration
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doVisualizeCalibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Setup
addpath ../;
setPath;

dbPath = fullfile(basePath, 'subSequenceDbHD');
outputBasePath = dbPath;

%% User parameters
sequencesToProcess = getSequenceNames('input', '1076244800');%{'569-1'};
% sequencesToProcess = getSequenceNames('skyall-quant-prob');
useSelectedTriplets = 1;

%% Process the database
dbFn = @dbFnRadiometricCalibration;
processResultsDatabaseFast(dbPath, sequencesToProcess, '', outputBasePath, dbFn, 0, 0, ...
    'DbPath', dbPath, 'DoVisualization', 1, 'UseSelectedTriplets', useSelectedTriplets);
