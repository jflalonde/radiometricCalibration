%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function pcaBases = getPCAModelFromDatabaseOfResponseFunctions(brightnessDb, nbBases, varargin)
%  Gets the PCA bases of the database of response functions
%  
% Input parameters:
%  - brightnessDb: brightnesses of the database
%  - nbBases: number of bases to keep
%  - varargin: optional arguments:
%    - 'DoDisplay': [0] or 1, whether to display stuff or not
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pcaMean, pcaBases, coeffDb] = getPCAModelFromDatabaseOfResponseFunctions(brightnessDb, nbBases, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse optional arguments
defaultArgs = struct('DoDisplay', 0);
args = parseargs(defaultArgs, varargin{:});

%% Computing PCA 
myfprintf(args.DoDisplay, 'Computing PCA...'); tic;
pcaMean = mean(brightnessDb, 2);
D = brightnessDb - repmat(pcaMean, 1, size(brightnessDb, 2));
[U,S,V] = svd(D*D'); %#ok

% keep 5 bases as in the paper
pcaBases = U(:, 1:nbBases);

myfprintf(args.DoDisplay, 'done in %.2fs.\n', toc);

%% Get the coefficients for all the data points
coeffDb = brightnessDb - repmat(pcaMean, 1, size(brightnessDb, 2));
coeffDb = pcaBases'*coeffDb;

