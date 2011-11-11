%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function r = dbFnPreloadColorTriplets(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnPreloadColorTriplets(outputBasePath, annotation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;
global allTriplets allColorDiffs allMaxVariances totNbTriplets processDatabaseImgNumber;

% parse arguments
defaultArgs = struct('DbPath', [], 'SeqInfo', [], 'MaxNbTriplets', 0);
args = parseargs(defaultArgs, varargin{:});

filePath = fullfile(args.DbPath, args.SeqInfo.invRespFunction.colorTriplets.folder, strrep(annotation.image.filename, '.jpg', '.mat'));

if exist(filePath, 'file')
    tripletsData = load(filePath);
    allTriplets{processDatabaseImgNumber} = tripletsData.triplets;
    allColorDiffs{processDatabaseImgNumber} = tripletsData.colorDiffs(tripletsData.tripletToEdgeInd);
    allMaxVariances{processDatabaseImgNumber} = tripletsData.maxVariances(tripletsData.tripletToEdgeInd);
    
    % count how many triplets we have so far, stop if we have exceeded the maximum
    if args.MaxNbTriplets > 0
        totNbTriplets = totNbTriplets + size(tripletsData.triplets, 1);
        if totNbTriplets > args.MaxNbTriplets
            fprintf('Reached maximum number of triplets allowed: %d\n', totNbTriplets);
            r = 1;
        end
    end
end