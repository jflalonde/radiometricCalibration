%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function displayInvRespFunctionFromCoeff(pcaMean, pcaCoeff, c, axesHandle, displayAxisLegend)
%   Helper function to display a camera response function from its
%   coefficients
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayInvRespFunctionFromCoeff(pcaMean, pcaCoeff, c, axesHandle, displayAxisLegend)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 4
    displayAxisLegend = 0;
end

g = getResponseFromCoefficients(pcaMean, pcaCoeff, c);
set(get(axesHandle, 'Parent'), 'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1])
plot(linspace(0,1,max(size(g,1),size(g,2))), g, 'LineWidth', 3);

axis([0 1 0 1]); grid on;

if displayAxisLegend
    legend('R', 'G', 'B', 'Location', 'NorthWest'); title('Estimated inverse response function');
    xlabel('Normalized intensity'), ylabel('Normalized irradiance');
end

