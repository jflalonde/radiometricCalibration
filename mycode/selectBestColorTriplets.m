%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function bestTriplets = selectBestColorTriplets(triplets, colorDiffs, maxVariances, nbTriplets)
%  Selects the best triplets based on a simulated annealing optimization. 
% 
% Input parameters:
%  - triplets: (3x3xN) input triplets to choose from. 
%  - colorDiffs: (1xN) color differences for each triplet (want to maximize)
%  - maxVariances: (1xN) max variances for each triplet (want to minimize)
%  - nbTripletsToKeep: number of triplets that we want in our final solution
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bestTriplets, bestTripletsInd, initTripletsInd] = selectBestColorTriplets(triplets, colorDiffs, maxVariances, nbTripletsToKeep)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define weights (should be passed as input?)
weightCoverage = 1;
weightColor = 1;
weightVariance = prctile(colorDiffs, 95) ./ prctile(maxVariances, 95);

% number of bins for coverage computation
nbBins = 20;

% do not try the same triplet twice
visitedStates = false(1, size(triplets, 3));

% pre-compute uniform histogram
uniformHistogram = ones(nbBins, nbBins, nbBins);

% find an initial state, use random state
initState = getInitState;
visitedStates = visitedStates | initState;

% specify options for the optimization
options.Generator = @selectNeighboringState;
options.CoolSched = @coolingSchedule;
options.Verbosity = 2;
options.InitTemp = 1e6;

% run simulated annealing
optState = anneal(@optBestTriplets, initState, options);

bestTripletsInd = find(optState);
initTripletsInd = find(initState);
bestTriplets = triplets(:,:,optState);

    % this is the function we're trying to optimize
    function d = optBestTriplets(state)
        % compute coverage distance
        coverageDist = computeCoverageDist(state);
        
        % color and variance distances are simply the sum of the individual
        % values for the selected triplets
        colorDist = sum(colorDiffs(state)) ./ nnz(state);
        varianceDist = sum(maxVariances(state)) ./ nnz(state);
        
        d = weightCoverage*coverageDist - weightColor*colorDist + weightVariance*varianceDist;
    end

    % Helper function: compute the coverage distance. Based on chi-square
    % distance of histogram of color points with respect to a uniform
    % distribution over the entire RGB cube. 
    function d = computeCoverageDist(state)
        % compute the coverage histogram of the current state
        coverageHistogram = computeTripletHistogram(triplets(:,:,state));
        
        % chi-square distance wrt a uniform histogram
        d = chisq(coverageHistogram, uniformHistogram);
    end

    % Helper function: compute the coverage histogram of triplets
    function hist = computeTripletHistogram(triplets)
        curTriplets = permute(triplets, [2 1 3]);
        tripletsVec = [reshape(curTriplets(:,1,:), 3*size(curTriplets,3), 1), reshape(curTriplets(:,2,:), 3*size(curTriplets,3), 1), reshape(curTriplets(:,3,:), 3*size(curTriplets,3), 1)];

        % histogram the current triplets (RGB cube: [0,1] interval)
        hist = myHistoND(tripletsVec, nbBins, [0 0 0], [1 1 1]);
    end

    % Helper function: select an initial set of triplets
    function initState = getInitState
        % option 1: random set of states
%         nbTriplets = size(triplets, 3);
%         initState = randperm(nbTriplets) <= nbTripletsToKeep;
        
        % option 2: select those that are furthest away from the r=g=b line
        % point-to-line distance: |cross(x2-x1, x1-x0)| / |(x2-x1)|
        p2 = ones(size(triplets));
        p1 = zeros(size(triplets));
        
        dist = zeros(size(triplets, 2), size(triplets, 3));
        for i=1:size(triplets, 2)
            num = cross(p2(:,i,:)-p1(:,i,:), p1(:,i,:)-triplets(:,i,:), 1);
            denum = p2(:,i,:)-p1(:,i,:);
            dist(i,:) = squeeze(dot(num, num, 1) ./ dot(denum, denum, 1));
        end
        dist = min(dist, [], 1);
        
        [s, sInd] = sort(dist, 'descend');
        initState = false(1, size(triplets, 3));
        initState(sInd(1:nbTripletsToKeep)) = true;
        
%         % option 3: pick best triplets based on contrast and variance
%         dist = weightVariance.*maxVariances - weightColor.*colorDiffs;
%         [s, sInd] = sort(dist);
%         initState = false(1, size(triplets, 3));
%         initState(sInd(1:nbTripletsToKeep)) = true;
    end

    % this selects a new state based on the input state
    function outState = selectNeighboringState(state)
        % randomly pick a triplet to swap
        tripletToSwapInd = find(state);
        tripletToSwapInd = tripletToSwapInd(ceil(rand*length(tripletToSwapInd)));
        
        % swap it with a randomly selected, triplet that hasn't been visited yet
        newTripletInd = find(~visitedStates);
        newTripletInd = newTripletInd(ceil(rand*length(newTripletInd)));
        
        outState = state;
        outState(tripletToSwapInd) = 0;
        outState(newTripletInd) = 1;
        visitedStates(newTripletInd) = 1;
    end

    function newT = coolingSchedule(T)
        newT = 0.95*T;
    end
end