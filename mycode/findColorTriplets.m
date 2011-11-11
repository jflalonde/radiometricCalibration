%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function colorTriplets = findColorTriplets(img, edgeMap, patchSize, ...
%     colorDiffThreshold, varianceThreshold)
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [colorTriplets, edgeCoords, colorDiffs, maxVariances, tripletToEdgeInd, edgeMap] = findColorTriplets(img, patchSize, ...
    colorDiffThreshold, varianceThreshold, areaDiffThreshold, minVarStraight, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse optional arguments
defaultArgs = struct('DoDisplay', 0, 'Verbose', 0, 'SceneMask', [], 'MaxNbEdges', 0);
args = parseargs(defaultArgs, varargin{:});

%% Normalize the image in the [0,1] interval (wrt maximum value)
img = im2double(img);
img = img ./ repmat(max(max(img)), [size(img,1) size(img,2)]);

%% Compute edges
grayImg = rgb2gray(img);
[dummy, thresh] = edge(grayImg, 'canny'); % find automatic threshold
edgeMap = edge(grayImg, 'canny', min(thresh.*4, 0.9)); % use more agressive threshold

if ~isempty(args.SceneMask)
    edgeMap = edgeMap.*args.SceneMask;
end

% remove the edges at the borders of the image
borderWidth = floor(patchSize./2);
edgeMap(1:borderWidth(1), :) = 0; edgeMap(end-borderWidth(1)+1:end, :) = 0; 
edgeMap(:, 1:borderWidth(1)) = 0; edgeMap(:, end-borderWidth(1)+1:end) = 0;

if args.DoDisplay
    figure(10), imshow(edgeMap);
end

%% Find color triplets
colorTriplets = {};
edgeCoords = {};
colorDiffs = [];
maxVariances = [];
tripletToEdgeInd = [];

remainingEdgeMap = edgeMap;

patchHalfSize = floor(patchSize./2);
centerPatchHalfSize = floor(patchSize./4);

if args.MaxNbEdges == 0
    args.MaxNbEdges = nnz(edgeMap);
end

nbCheckedEdges = 0;
while nnz(remainingEdgeMap) && nbCheckedEdges < args.MaxNbEdges
    nbCheckedEdges = nbCheckedEdges + 1;
    
    [patchR, patchC] = find(remainingEdgeMap);
    
    % randomly take another patch
    if args.MaxNbEdges > 0
        curInd = round(rand*(numel(patchR)-1))+1;
    else
        curInd = 1;
    end
    remainingEdgeMap(patchR(curInd), patchC(curInd)) = 0;
    
    patchRowRange = patchR(curInd)-patchHalfSize(1):patchR(curInd)+patchHalfSize(1);
    patchColRange = patchC(curInd)-patchHalfSize(2):patchC(curInd)+patchHalfSize(2);

    sqColorPatch = img(patchRowRange, patchColRange, :);
    edgePatch = edgeMap(patchRowRange, patchColRange);
    
    colorPatch = permute(sqColorPatch, [3 1 2]);
    
    % edge must be straight: fit a line and get minimum variance
    [y,x] = find(edgePatch);
    E = [x y]; E = E - repmat(mean(E, 1), length(x), 1);
    s = svd(E'*E);
    if min(s) > minVarStraight
        myfprintf(args.Verbose, 'Edge not straight: %.2f!\n', min(s));
        continue;
    end

    dilEdgePatch = imdilate(edgePatch, strel('square', 3));

    % find the 2 regions
    regionLabels = bwlabel(~dilEdgePatch);
    uniqueRegions = unique(regionLabels);

    % must have exactly 3 regions (region 0 is the edge)
    if length(uniqueRegions) ~= 3
        myfprintf(args.Verbose, 'Patch does not contain 3 regions\n');
        continue;
    end
    
    % the 2 regions must be of similar areas
    if abs(nnz(regionLabels == 1) - nnz(regionLabels == 2)) / numel(dilEdgePatch) > areaDiffThreshold
        myfprintf(args.Verbose, 'Regions of dissimilar areas\n');
        continue;
    end

    meanRegionColor = zeros(3, 2);
    varRegionColor = zeros(3, 2);

    % compute the mean and variance of the regions
    for i=1:2
        indRegion = find(regionLabels == i);
        meanRegionColor(:, i) = mean(colorPatch(:, indRegion), 2);
        varRegionColor(:, i) = var(colorPatch(:, indRegion), [], 2);
    end

    % check for variance (maximum variance in any channel)
    maxVariance = max(varRegionColor(:));
    if maxVariance > varianceThreshold
        myfprintf(args.Verbose, 'Variance test failed\n');
        continue;
    end

    % check the color difference
    colorDiff = sum((meanRegionColor(:,1) - meanRegionColor(:,2)).^2);  
    if colorDiff < colorDiffThreshold^2
        myfprintf(args.Verbose, 'Color difference test failed\n');
        continue;
    end
    
    % NEW: create triplets from all pixels within a sub-window centered at the current
    % edge location
    centerPatchRowRange = patchR(curInd)-centerPatchHalfSize(1):patchR(curInd)+centerPatchHalfSize(1);
    centerPatchColRange = patchC(curInd)-centerPatchHalfSize(2):patchC(curInd)+centerPatchHalfSize(2);

    centerSqColorPatch = img(centerPatchRowRange, centerPatchColRange, :);
    centerEdgeColor = reshape(centerSqColorPatch, size(centerSqColorPatch,3), size(centerSqColorPatch,1)*size(centerSqColorPatch,2));
    nbCenterEdges = size(centerEdgeColor, 2);
    
    % check for monotonicity: if the edge color lies within the bounding
    % box defined by the two regions color
    
    indGoodEdge = ~any(centerEdgeColor < repmat(min(meanRegionColor, [], 2), 1, nbCenterEdges) | ...
        centerEdgeColor > repmat(max(meanRegionColor, [], 2), 1, nbCenterEdges), 1);

    if ~any(indGoodEdge)
        % there isn't any good triplet around that edge.        
        continue;
    end
        
    % We've passed all the tests. Save triplets
    centerEdgeColor = centerEdgeColor(:,indGoodEdge);
    newTriplets = arrayfun(@(i) cat(2, meanRegionColor, centerEdgeColor(:,i)), 1:size(centerEdgeColor, 2), 'UniformOutput', 0);
    colorTriplets = cat(1, colorTriplets, newTriplets{:});
    
    % Save edge and additional stats
    edgeCoords = cat(1, edgeCoords, [patchR(curInd) patchC(curInd)]');
    
    % save additional stats
    colorDiffs = cat(1, colorDiffs, colorDiff);
    maxVariances = cat(1, maxVariances, maxVariance);
    
    % save triplets -> edge index
    tripletToEdgeInd = cat(1, tripletToEdgeInd, repmat(length(edgeCoords), length(newTriplets), 1));

    % Remove the current edge from the edge map
    overlapRowRange = min(max(patchR(curInd)-patchSize(1)+1:patchR(curInd)+patchSize(1)-1, 1), size(edgeMap, 1));
    overlapColRange = min(max(patchC(curInd)-patchSize(2)+1:patchC(curInd)+patchSize(2)-1, 1), size(edgeMap, 2));
    remainingEdgeMap(overlapRowRange, overlapColRange) = 0;
    
    if args.DoDisplay
        figure(20), 
        subplot(2,3,1:3), imagesc(remainingEdgeMap); axis image;
        subplot(2,3,4), imagesc(sqColorPatch), axis square;
        subplot(2,3,5), imagesc(edgePatch), axis square;
        subplot(2,3,6), hold off, imagesc(sqColorPatch .* repmat(~dilEdgePatch, [1 1 3])), axis square, hold on;
        
        regionCenters = regionprops(regionLabels, 'Centroid');
        plot([regionCenters(1).Centroid(1) regionCenters(2).Centroid(1)], [regionCenters(1).Centroid(2) regionCenters(2).Centroid(2)], '-ob', 'LineWidth', 3)

        drawnow;
    end
end

