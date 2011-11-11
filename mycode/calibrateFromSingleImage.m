%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function camResponseEst = calibrateFromSingleImage(img)
%  Recovers the camera response function of a camera from a single image, 
%  based on edges.
% 
%  Implements the paper:
%  S. Lin, J. Gu, S. Yamazaki, and H.-Y. Shum. Radiometric calibration from a single image. 
%  In IEEE Conference on Computer Vision and Pattern Recognition, 2004.
% 
% Input parameters:
%  - img: input image
%  - patchSize: size of the patch used to detect edges
%
% Output parameters:
%  - camResponseEst: response function
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [colorTriplets, edgeCoords, invCamResponseEst] = calibrateFromSingleImage(img, patchSize, ...
    gmmInvMix, pcaInvMean, pcaInvBases, colorDiffThresh, varianceThresh, areaDiffThresh, minVarStraight, lambdaPrior, varargin)

%% Parse optional arguments
defaultArgs = struct('DoDisplay', 0);
args = parseargs(defaultArgs, varargin{:});

%% Find good patches, non-overlapping patches
[colorTriplets, edgeCoords] = findColorTriplets(img, patchSize, ...
    colorDiffThresh, varianceThresh, areaDiffThresh, minVarStraight, 'DoDisplay', args.DoDisplay);

%% Get the response function by optimization
if nargout > 2
    invCamResponseEst = optimizeInvCameraResponse(gmmInvMix, pcaInvMean, pcaInvBases, colorTriplets, lambdaPrior, 'DoDisplay', args.DoDisplay);
end


