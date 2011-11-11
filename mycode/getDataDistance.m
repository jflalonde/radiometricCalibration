%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function optimizeInvCameraResponse
%   Gets the distance function for each data point
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [d, dist] = getDataDistance(g, brightnessTriplets)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% compute the irradiances
irradianceTriplets = zeros(size(brightnessTriplets));
for i=1:3
    % apply input inverse response to get the irradiance
    irradianceTriplets(i,:,:) = getForwardResponse(g(:,i), brightnessTriplets(i,:,:));
end

% point-to-line distances
num = cross(irradianceTriplets(:,1,:) - irradianceTriplets(:,2,:), irradianceTriplets(:,1,:) - irradianceTriplets(:,3,:));
num = dot(num, num);
denom = irradianceTriplets(:,1,:) - irradianceTriplets(:,2,:);
denom = dot(denom, denom);

dist = num./denom;

% sum across all instances
d = mean(dist);
