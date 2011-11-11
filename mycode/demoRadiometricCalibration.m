function demoRadiometricCalibration
% Main demo function for the radiometric calibration project.
%
% ----------
% Jean-Francois Lalonde

%% Preliminaries

% Paths
imgPath = fullfile('data', 'test.bmp');
dbPath = fullfile('data', 'dorfCurves.txt');
gmmPath = fullfile('data', 'gmmModels_coeff.mat');

% Set edge detection parameters
patchSize = [20 20];
colorDiffThresh = 20/255;
varianceThresh = 10/255;
areaDiffThresh = 0.4;
minVarStraight = 2; % straight-ness of edges

% Optimization parameters
nbPCABases = 5;
lambdaPrior = 0.001;

% Read the image
img = im2double(imread(imgPath));

%% Extract the color triplets (this could take a while, depending on the parameters)
[colorTriplets, edgeCoords, colorDiffs, maxVariances, tripletToEdgeInd, edgeMap] = ...
    findColorTriplets(img, patchSize, colorDiffThresh, varianceThresh, areaDiffThresh, minVarStraight);

%% Prepare prior
% Load the database of response functions
[brightnessDb, invBrightnessDb] = loadDatabaseOfResponseFunction(dbPath);

% Load pre-computed GMM model
load(gmmPath);

% Run PCA
[pcaInvMean, pcaInvBases] = getPCAModelFromDatabaseOfResponseFunctions(invBrightnessDb, nbPCABases);

%% Optimize
invCamResponseEst = optimizeInvCameraResponse(gmmInvMix, pcaInvMean, pcaInvBases, ...
    colorTriplets, lambdaPrior, 'DoDisplay', args.DoDisplay);

%% Display
plot(invCamResponseEst); grid on; axis equal;
figure('Estimated inverse response function');