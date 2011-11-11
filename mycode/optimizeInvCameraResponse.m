%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function optimizeInvCameraResponse
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gOpt = optimizeInvCameraResponse(gmmMix, pcaMean, pcaBases, brightnessTriplets, lambda, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse optional arguments
defaultArgs = struct('DoDisplay', 0, 'Verbose', 0);
args = parseargs(defaultArgs, varargin{:});

% 3 color channels
pcaMean = repmat(pcaMean, 1, 3);

% stack the color triplets into one big matrix
if iscell(brightnessTriplets)
    brightnessTriplets = permute(reshape(cell2mat(brightnessTriplets)', 3, 3, length(brightnessTriplets)), [2 1 3]);
end

%% Optimize the coefficients
dispOptions = {'final', 'iter', 'off'};
options = optimset('Display', dispOptions{args.Verbose+1}, 'MaxFunEvals', 1e9, 'MaxIter', 1e4, 'LargeScale', 'off');

c0 = zeros(size(pcaBases, 2), 3);
cOpt = fminsearch(@optColorDistance, c0, options);
% cOpt = fminunc(@optColorDistance, c0, options);

%% Enforce monotonicity
cOptMon = enforceMonotonicity(cOpt, pcaMean, pcaBases);

%% Prepare output
gOpt = getResponseFromCoefficients(pcaMean, pcaBases, cOptMon);

% make sure it's strictly increasing
gOpt = gOpt + repmat((1:size(gOpt))'.*eps, 1, 3);

%% Display results?
if args.DoDisplay
    figure(1); hold off;
    set(get(gca, 'Parent'), 'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])
    plot(linspace(0,1,max(size(g,1),size(g,2))), gOpt, 'LineWidth', 3);

    axis([0 1 0 1]); grid on;

    displayInvRespFunctionFromCoeff(pcaMean, pcaBases, cOpt, figure);
    title('Final estimate');
    pause;
end

    %% Distance function to optimize
    function dist = optColorDistance(c)
        % get the response function
        g = getResponseFromCoefficients(pcaMean, pcaBases, c);
        
        % compute the data distance function
        dataDist = getDataDistance(g, brightnessTriplets);
        priorDist = getPriorDistance(c, gmmMix);
        
%         plot(g); axis([0 100 0 1]); drawnow;
        
%         dist = lambda*dataDist + priorDist;
        dist = dataDist + lambda*priorDist;
    end
end

