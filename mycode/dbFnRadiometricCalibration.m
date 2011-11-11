%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function r = dbFnRadiometricCalibration(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnRadiometricCalibration(outputBasePath, annotation, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r=0;

global allTriplets allColorDiffs allMaxVariances colorTriplets totNbTriplets;

% parse arguments
defaultArgs = struct('Recompute', 0, 'Parallelized', 0, 'Randomized', 0, 'DoSave', 0, 'DoDisplay', 0, ...
    'ImagesPath', [], 'DbPath', [], 'SingleDay', 0, ...
    'PatchSize', [], 'VarianceThreshold', 0, 'ColorDiffThreshold', 0, 'SkyMaskPath', [], 'MaxNbEdges', 0, ...
    'AreaDiffThreshold', 0, 'MinVarStraight', 0, 'LambdaPrior', 0, 'NbImages', 0, ...
    'PcaInvMean', [], 'PcaInvBases', [], 'GmmInvMix', [], ...
    'DoColorTriplets', 0, 'DoCalibration', 0, 'DoPreloadColorTriplets', 0, 'DoSelectColorTriplets', 0, 'DoVisualization', 0, 'DoSaveColorTriplets', 0, ...
    'GlobalSave', 0, 'NbSelectedTriplets', 0, 'UseSelectedTriplets', 0, ...
    'DoCalibrationC', 0, 'MeanCurveFile', [], 'GmmFile', [], 'BinFile', []);
args = parseargs(defaultArgs, varargin{:});

% load the output xml structure
outputXmlFile = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
if exist(outputXmlFile, 'file'), seqInfo = load_xml(outputXmlFile); seqInfo = seqInfo.document; else seqInfo = annotation; end

%% Select the right files
load(fullfile(args.DbPath, seqInfo.sequence.files.filename)); seqFiles = subSeqImgList;
load(fullfile(args.DbPath, seqInfo.sequence.dates.filename));
load(fullfile(args.DbPath, seqInfo.dayIndices.filename));

%% Prepare output
if args.DoColorTriplets
    % log
    seqInfo.invRespFunction.colorTriplets.folder = fullfile('invRespFunction', 'colorTriplets', seqInfo.sequence.name);
    seqInfo.invRespFunction.colorTriplets.filename = sprintf('%s_allTriplets.mat', seqInfo.sequence.name);
    outputColorTripletsPath = fullfile(outputBasePath, seqInfo.invRespFunction.colorTriplets.folder);
    [m,m,m] = mkdir(outputColorTripletsPath); %#ok
    
    % parameters
    seqInfo.invRespFunction.colorTriplets.params.ColorDiffThreshold = args.ColorDiffThreshold;
    seqInfo.invRespFunction.colorTriplets.params.VarianceThreshold = args.VarianceThreshold;
    seqInfo.invRespFunction.colorTriplets.params.AreaDiffThreshold = args.AreaDiffThreshold;
    seqInfo.invRespFunction.colorTriplets.params.MinVarStraight = args.MinVarStraight;
    
    % scene mask
    skyMask = loadSceneSkyMasks('', seqInfo, 'Automatic', 1, 'DbPath', args.DbPath);
    sceneMask = ~skyMask;
%     [skyMask, sceneMask] = loadSceneSkyMasks(args.SkyMaskPath, seqInfo);
end

if args.DoPreloadColorTriplets
    seqInfo.invRespFunction.allColorTriplets.folder = fullfile('invRespFunction', 'allColorTriplets', seqInfo.sequence.name);
    seqInfo.invRespFunction.allColorTriplets.filename = sprintf('%s_allTriplets.mat', seqInfo.sequence.name);
    outputAllColorTripletsPath = fullfile(outputBasePath, seqInfo.invRespFunction.allColorTriplets.folder);
    [m,m,m] = mkdir(outputAllColorTripletsPath); %#ok
    
    if ~args.Recompute && exist(fullfile(outputAllColorTripletsPath, seqInfo.invRespFunction.allColorTriplets.filename), 'file')
        fprintf('Already pre-loaded! Skipping...\n');
        return;
    end
end

if args.DoSelectColorTriplets
    seqInfo.invRespFunction.selectedColorTriplets.folder = fullfile('invRespFunction', 'selectedColorTriplets', seqInfo.sequence.name);
    seqInfo.invRespFunction.selectedColorTriplets.filename = sprintf('%s_selectedTriplets.mat', seqInfo.sequence.name);
    outputSelectedColorTripletsPath = fullfile(outputBasePath, seqInfo.invRespFunction.selectedColorTriplets.folder);
    [m,m,m] = mkdir(outputSelectedColorTripletsPath); %#ok
    
    if ~args.Recompute && exist(fullfile(outputSelectedColorTripletsPath, seqInfo.invRespFunction.selectedColorTriplets.filename), 'file')
        fprintf('Already computed! Skipping...\n');
        return;
    end
end

if args.DoSaveColorTriplets    
    seqInfo.invRespFunction.saveColorTriplets.folder = fullfile('invRespFunction', 'saveColorTriplets', seqInfo.sequence.name);
    seqInfo.invRespFunction.saveColorTriplets.filename = sprintf('%s_saveTriplets.dat', seqInfo.sequence.name);
    outputSaveColorTripletsPath = fullfile(outputBasePath, seqInfo.invRespFunction.saveColorTriplets.folder);
    [m,m,m] = mkdir(outputSaveColorTripletsPath);
end

if args.DoCalibration
    if args.UseSelectedTriplets
        type = 'selected';
    else
        type = 'random';
    end
    
    seqInfo.invRespFunction.calib.(type).filename = fullfile('invRespFunction', 'calib', type, sprintf('%s_invRespFunction.mat', seqInfo.sequence.name));
    outputCalibrationFile = fullfile(outputBasePath, seqInfo.invRespFunction.calib.(type).filename);
    [m,m,m] = mkdir(fileparts(outputCalibrationFile)); %#ok
    
    % parameters
    seqInfo.invRespFunction.calib.(type).params.LambdaPrior = args.LambdaPrior;
    
    if ~args.Recompute && exist(outputCalibrationFile, 'file')
        fprintf('Already computed! Skipping...\n');
        return;
    end
end

if args.DoCalibrationC
    seqInfo.invRespFunction.calibC.filename = fullfile('invRespFunction', 'calibC', sprintf('%s_invRespFunction.mat', seqInfo.sequence.name));
    outputCalibrationFile = fullfile(outputBasePath, seqInfo.invRespFunction.calibC.filename);
    
    if ~args.Recompute && exist(outputCalibrationFile, 'file')
        fprintf('Already computed! Skipping...\n');
        return;
    end
    [m,m,m] = mkdir(fileparts(outputCalibrationFile)); %#ok
end

%% Compute color triplets
if args.DoColorTriplets
    indFiles = dayIndConcat;
    if args.SingleDay
        indFiles = dayIndConcat(years(dayIndConcat).*10000 + months(dayIndConcat).*100 +  days(dayIndConcat) == args.SingleDay);
    end

    if args.Randomized
        indFiles = indFiles(randperm(length(indFiles)));
    end
    
    nbImages = min(args.NbImages, length(indFiles));
    if args.GlobalSave == 1 || nbImages == 0
        nbImages = length(indFiles);
    end
    
    files = seqFiles(indFiles(1:nbImages));
    
    colorTriplets = cell(1, args.NbImages);
    processImageDatabaseFiles(fullfile(args.ImagesPath, seqInfo.sequence.origName), files, outputColorTripletsPath, ...
        @dbFnPrecomputeColorTriplets, args.Parallelized, args.Randomized, ...
        'ImagesPath', args.ImagesPath, 'SeqInfo', seqInfo, 'Recompute', args.Recompute, 'DoSave', args.DoSave, 'DoDisplay', args.DoDisplay, ...
        'PatchSize', args.PatchSize, 'VarianceThreshold', args.VarianceThreshold, 'ColorDiffThreshold', args.ColorDiffThreshold, ...
        'AreaDiffThreshold', args.AreaDiffThreshold, 'MinVarStraight', args.MinVarStraight, 'GlobalSave', args.GlobalSave, 'SceneMask', sceneMask, 'MaxNbEdges', args.MaxNbEdges);

    if args.GlobalSave
        % concatenate all the color triplets
        allTriplets = cellfun(@(x) x', colorTriplets, 'UniformOutput', 0);
        allTriplets = [allTriplets{:}];
        allTriplets = reshape(cell2mat(allTriplets), 3, 3, length(allTriplets)); %#ok

        if args.DoSave
            % save all triplets to file
            outputFile = fullfile(outputColorTripletsPath, seqInfo.invRespFunction.colorTriplets.filename);
            save(outputFile, 'allTriplets');
        end
    end
end

%% Preload the color triplets
if args.DoPreloadColorTriplets
    files = seqFiles(dayIndConcat);
    allTriplets = cell(1, length(files));
    allColorDiffs = cell(1, length(files)); 
    allMaxVariances = cell(1, length(files)); 
    
    % impose hard maximum on gathered triplets
    maxNbTriplets = 1e6;
    totNbTriplets = 0;
    processImageDatabaseFiles(fullfile(args.ImagesPath, seqInfo.sequence.name), files, outputAllColorTripletsPath, ...
        @dbFnPreloadColorTriplets, 0, 1, 'SeqInfo', seqInfo, 'DbPath', args.DbPath, 'MaxNbTriplets', maxNbTriplets);
    
    if args.DoSave
        outputFile = fullfile(outputAllColorTripletsPath, seqInfo.invRespFunction.allColorTriplets.filename);
        save(outputFile, 'allTriplets', 'allColorDiffs', 'allMaxVariances');
    end
end

%% Select the color triplets
if args.DoSelectColorTriplets
    % load the pre-loaded color triplets
    fprintf('Loading color triplets...'); tic;
    allTripletsPath = fullfile(args.DbPath, seqInfo.invRespFunction.allColorTriplets.folder, seqInfo.invRespFunction.allColorTriplets.filename);
    allTripletsData = load(allTripletsPath);
    
    % concatenate the triplets into one huge matrix
    indValid = cellfun(@(x) ~isempty(x), allTripletsData.allTriplets);
    triplets = cellfun(@(x) reshape([x{:}], 3, 3, length(x)), allTripletsData.allTriplets(indValid), 'UniformOutput', 0);
    triplets = cat(3, triplets{:});
    
    colorDiffs = cat(1, allTripletsData.allColorDiffs{:});
    maxVariances = cat(1, allTripletsData.allMaxVariances{:});
    
    % run optimization
    if args.NbSelectedTriplets <= size(triplets, 3)
        fprintf('Running optimization...');
        [bestTriplets, bestTripletsInd, initTripletsInd] = selectBestColorTriplets(triplets, colorDiffs, maxVariances, args.NbSelectedTriplets);
        fprintf('Done in %.2fs\n', toc);
    else
        fprintf('Not enough triplets!\n');
        bestTriplets = triplets; %#ok
        bestTripletsInd = 1:size(triplets, 3);
        initTripletsInd = bestTripletsInd; %#ok
    end
    
    if args.DoDisplay
        figure(41);
        divsColor = linspace(0, max([colorDiffs(bestTripletsInd); colorDiffs(initTripletsInd)]), 20);
        divsVariance = linspace(0, max([maxVariances(bestTripletsInd); maxVariances(initTripletsInd)]), 20);
        subplot(2,2,1), bar(divsColor+divsColor(2)/2, histc(colorDiffs(initTripletsInd), divsColor)./nnz(bestTripletsInd)); axis([0 max(divsColor) 0 1]); title('Original color distance distribution');
        subplot(2,2,2), bar(divsColor+divsColor(2)/2, histc(colorDiffs(bestTripletsInd), divsColor)./nnz(bestTripletsInd)); axis([0 max(divsColor) 0 1]); title('Optimized color distance distribution');
        subplot(2,2,3), bar(divsVariance+divsVariance(2)/2, histc(maxVariances(initTripletsInd), divsVariance)./nnz(bestTripletsInd)); axis([0 max(divsVariance) 0 1]); title('Original variance distribution');
        subplot(2,2,4), bar(divsVariance+divsVariance(2)/2, histc(maxVariances(bestTripletsInd), divsVariance)./nnz(bestTripletsInd)); axis([0 max(divsVariance) 0 1]); title('Optimized variance distribution');
    end
    
    % save results to file
    if args.DoSave
        outputFile = fullfile(outputSelectedColorTripletsPath, seqInfo.invRespFunction.selectedColorTriplets.filename);
        save(outputFile, 'bestTriplets', 'bestTripletsInd', 'initTripletsInd');
    end
end

%% Save color triplets to txt file
if args.DoSaveColorTriplets
    outputFile = fullfile(outputSaveColorTripletsPath, seqInfo.invRespFunction.saveColorTriplets.filename);
    fprintf('Loading color triplets...');
    colorTripletsFile = fullfile(args.DbPath, seqInfo.invRespFunction.allColorTriplets.folder, seqInfo.invRespFunction.allColorTriplets.filename);
    allTripletsData = load(colorTripletsFile);
    triplets = cellfun(@(x) reshape([x{:}], 3, 3, length(x)), allTripletsData.allTriplets, 'UniformOutput', 0);
    triplets = cat(3, triplets{:});

    fprintf('Saving to %s...', outputFile);
    saveTripletsToTxtFile(triplets, outputFile);
    fprintf('done.\n');
end

%% Run radiometric calibration
if args.DoCalibration
    tic;
    lambda = args.LambdaPrior;
    if args.UseSelectedTriplets
        fprintf('Using selected triplets...');
        % load the pre-computed triplets
        colorTripletsFile = fullfile(args.DbPath, seqInfo.invRespFunction.selectedColorTriplets.folder, seqInfo.invRespFunction.selectedColorTriplets.filename);
        load(colorTripletsFile);
        fprintf('found %d triplets...', size(bestTriplets, 3));
        
%         lambda = lambda*(size(bestTriplets,3)/5000)^3;
%         lambda = lambda*(size(bestTriplets,3)/5000);
    else
        fprintf('Using random triplets...');
        % use random triplets -> reload all triplets
        colorTripletsFile = fullfile(args.DbPath, seqInfo.invRespFunction.allColorTriplets.folder, seqInfo.invRespFunction.allColorTriplets.filename);
        allTripletsData = load(colorTripletsFile);

        triplets = cellfun(@(x) reshape([x{:}], 3, 3, length(x)), allTripletsData.allTriplets, 'UniformOutput', 0);
        triplets = cat(3, triplets{:});
        randInd = randperm(size(triplets, 3)) <= 5000;
        bestTriplets = triplets(:,:,randInd);
    end
    
    % calibrate the camera
    invCamResponse = optimizeInvCameraResponse(args.GmmInvMix, args.PcaInvMean, args.PcaInvBases, bestTriplets, lambda, 'DoDisplay', args.DoDisplay, 'Verbose', 1); %#ok
    
    fprintf('done in %.2fs\n', toc);
    
    if args.DoSave
        invCamResponse = invCamResponse;
        % save the inverse response to file
        save(outputCalibrationFile, 'invCamResponse');
    end
end
 
%% Run radiometric calibration with original C code
if args.DoCalibrationC
    % need the precomputed triplets
    try
        tripletsPath = fullfile(args.DbPath, seqInfo.invRespFunction.saveColorTriplets.folder, seqInfo.invRespFunction.saveColorTriplets.filename);

        % prepare command
        outputTxtFile = strrep(outputCalibrationFile, '.mat', '.rcc');
        cmd = sprintf('%s %s %s %s %s\n', args.BinFile, tripletsPath, args.MeanCurveFile, args.GmmFile, outputTxtFile);

        % calibrate the camera (this will also save the results to a text file)
        system(cmd);
        
        % load txt file
        invCamResponse = loadResponseFromTxtFile(outputTxtFile, args.MeanCurveFile); %#ok
        
        % save in matlab format
        save(outputCalibrationFile, 'invCamResponse');
        
    catch
        sprintf('No triplets available. Run doSaveAllColorTriplets first.\n');
    end
end

%% Visualize the results
if args.DoVisualization
    if args.UseSelectedTriplets
        tagName = 'selected';
    else
        tagName = 'random';
    end
    invCamResponseData = load(fullfile(args.DbPath, seqInfo.invRespFunction.calib.(tagName).filename));
    
    pHandle = figure(1);
    set(pHandle, 'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])
    plot(linspace(0,1,100), invCamResponseData.invCamResponse, 'LineWidth', 3);
    legend('R', 'G', 'B', 'Location', 'NorthWest'); 
    title(sprintf('Estimated inverse response function, sequence %s', seqInfo.sequence.name));
    xlabel('Normalized intensity'), ylabel('Normalized irradiance');
    axis([0 1 0 1]); grid on;
    pause;
end


%% Save the file
if args.DoSave
    fprintf('Saving xml file: %s\n', outputXmlFile);
    write_xml(outputXmlFile, seqInfo);
end

