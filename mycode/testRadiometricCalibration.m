%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function testRadiometricCalibration
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup
addpath ../;
setPath;

imgBasePath = fullfile(dataBasePath, 'cameraResponse', '4');
gmmModelsPath = fullfile(basePath, 'cameraResponse', 'gmmModels');
gmmModelsFile = fullfile(gmmModelsPath, 'gmmModels.mat');

%% User parameters
doDisplay = 1;

% edge parameters
patchSize = [10 10];
colorDiffThreshold = 20/255;
varianceThreshold = 40/255;
areaDiffThreshold = 0.3;
minVarStraight = 2; % straight-ness of edges

% database clustering and PCA
nbGMMCenters = 5;
nbPCABases = 5;

% Weight on prior
lambdaPrior = 1;

%% Load image
img = imread(fullfile(imgBasePath, 'test.bmp'));
img = im2double(imresize(img, [600 800], 'bilinear'));

%% Load the database of camera response functions
myfprintf(doDisplay, 'Loading database...'); tic;
[brightnessDb, invBrightnessDb] = loadDatabaseOfResponseFunction(basePath);
myfprintf(doDisplay, 'done in %.2fs\n', toc);

%% Compute PCA on inverse response function
[pcaInvMean, pcaInvBases] = getPCAModelFromDatabaseOfResponseFunctions(invBrightnessDb, nbPCABases, 'DoDisplay', doDisplay);

%% Compute GMM on the PCA coefficients
gmmInvMix = getGmmModelFromDatabaseOfResponseFunctions(pcaInvBases', nbGMMCenters);

%% Extract the edge triplets
[colorTriplets, edgeCoords, colorDiffs, maxVariances, tripletToEdgeInd, edgeMap] = findColorTriplets(img, patchSize, colorDiffThreshold, varianceThreshold, ...
    areaDiffThreshold, minVarStraight, 'DoDisplay', doDisplay);

%% Draw them
if doDisplay
    drawColorTriplets(figure(1), img, edgeMap, patchSize, edgeCoords);
end

%% Save them to file in the C++ code format
saveTripletsToTxtFile(colorTriplets, 'matlab_patch.dat');

%% Try loading previously computed triplets
colorTripletsNew = loadTripletsFromTxtFile('/Users/jflalonde/Documents/phd/data/cameraResponse/4/test_patch.dat');

%% Calibrate the camera from a single image
lambdaPrior = 1e-3;
invCamResponse = optimizeInvCameraResponse(gmmInvMix, pcaInvMean, pcaInvBases, colorTriplets, lambdaPrior, 'DoDisplay', doDisplay, 'Verbose', 1);

%% Visualize triplets
if 0%doDisplay
    figure;
    for i=1:length(colorTriplets)
        hold off;
        plot3(colorTriplets{i}(1, [1 3 2]), colorTriplets{i}(2, [1 3 2]), colorTriplets{i}(3, [1 3 2]), '-ob', 'LineWidth', 3);
        hold on;
        irrTriplet = zeros(3, 3);
        for c=1:3
            irrTriplet(c,:) = getForwardResponse(invCamResponse(:,c), colorTriplets{i}(c,:));
        end
        plot3(irrTriplet(1, [1 3 2]), irrTriplet(2, [1 3 2]), irrTriplet(3, [1 3 2]), '-or', 'LineWidth', 3);
        drawnow;
        pause;
    end
end

%% Correct the image
corrImg = correctImage(img, invCamResponse);

figure(30);
subplot(1,2,1), imshow(img); title('Original image');
subplot(1,2,2), imshow(corrImg), title('Corrected image');

