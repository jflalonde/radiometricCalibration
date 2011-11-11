%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function brightnesses = getForwardResponse(response, irradiances)
%  Computes the inverse response function
%  
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function brightnesses = getForwardResponse(response, irradiances)

brightnesses = interp1(linspace(0, 1, length(response)), response, irradiances, 'linear');
