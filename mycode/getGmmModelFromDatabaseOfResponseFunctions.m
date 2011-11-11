%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function mix = getGmmModelFromDatabaseOfResponseFunctions(brightnessDb, nbCenters)
%  Fits a gaussian mixture model on the database of response functions data
%  
% 
% Input parameters:
%  - brightnessDb: brightnesses of the database
%  - nbCenters: number of GMM mixtures to use
%  - varargin: optional arguments:
%    - 'DoDisplay': [0] or 1, whether to display stuff or not
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mix = getGmmModelFromDatabaseOfResponseFunctions(brightnessDb, nbCenters, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse optional arguments
defaultArgs = struct('DoDisplay', 0);
args = parseargs(defaultArgs, varargin{:});

%% Set up mixture model
mix = gmm(size(brightnessDb, 1), nbCenters, 'spherical'); % 'spherical'

% Initialize the model parameters from the data using k-means
options = zeros(1, 18);
options(1) = 0; % verbose 
options(2) = 1e-2; options(6) = 1e-6; options(14) = 1000;
mix = gmminit(mix, brightnessDb', options);

%% Fit mixtures

% Options for EM
options = zeros(1, 18);
options(1) = 1; % verbose
options(2) = 1e-10; options(3) = 1e-10;
options(14) = 1000;	% Use 1000 iterations for EM

% Run EM and fit mixtures
warning('off', 'MATLAB:netlabmsg');
mix = gmmem(mix, brightnessDb', options);

%% Display
if args.DoDisplay
    figure; plot(mix.centres'); title('5 GMM clusters');
end
