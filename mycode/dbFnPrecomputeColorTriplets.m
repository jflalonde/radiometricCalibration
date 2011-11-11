%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function r = dbFnPrecomputeColorTriplets(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnPrecomputeColorTriplets(outputBasePath, annotation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;
global colorTriplets processDatabaseImgNumber;

% parse arguments
defaultArgs = struct('Recompute', 0, 'DoSave', 0, 'DoDisplay', 0, ...
    'ImagesPath', [], 'DbPath', [], 'SeqInfo', [], 'GlobalSave', 0, ...
    'PatchSize', [10 10], 'VarianceThreshold', 30/255, 'ColorDiffThreshold', 20/255, ...
    'AreaDiffThreshold', 0.1, 'MinVarStraight', 2, 'SceneMask', [], 'MaxNbEdges', 0);
args = parseargs(defaultArgs, varargin{:});

outputFile = fullfile(outputBasePath, strrep(annotation.image.filename, '.jpg', '.mat'));
if ~args.Recompute && exist(outputFile, 'file')
    fprintf('Already computed! Skipping...\n');
    return;
end

%% Read the image
fprintf('Loading the image...'); tic;
imgPath = fullfile(args.ImagesPath, args.SeqInfo.sequence.origName, annotation.image.filename);
img = imreadSafe(imgPath);

if isempty(img)
    % skip this image
    return;
end

%% Compute the color triplets
[triplets, edgeCoords, colorDiffs, maxVariances, tripletToEdgeInd] = findColorTriplets(img, args.PatchSize, ...
    args.ColorDiffThreshold, args.VarianceThreshold, args.AreaDiffThreshold, args.MinVarStraight, ...
    'DoDisplay', args.DoDisplay, 'Verbose', 0, 'SceneMask', args.SceneMask, 'MaxNbEdges', args.MaxNbEdges); %#ok

fprintf('Found %d edges in %.2fs...', length(triplets), toc);

if args.GlobalSave
    colorTriplets{processDatabaseImgNumber} = triplets;
end

%% Save results
if args.DoSave
    [m,m,m] = mkdir(fileparts(outputFile)); %#ok
    save(outputFile, 'triplets', 'edgeCoords', 'colorDiffs', 'maxVariances', 'tripletToEdgeInd');
end
