%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function irradiances = getInverseResponse(response, brightnesses)
%  Computes the inverse response function
%  
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function irradiances = getInverseResponse(response, brightnesses)

if size(response,2) > 1
    irradiances = zeros(length(brightnesses), size(response,2));
    for i=1:size(response,2)
        irradiances(:,i) = interp1(response(:,i), linspace(0, 1, length(response(:,i))), brightnesses, 'linear');
    end
else
    irradiances = interp1(response, linspace(0, 1, length(response)), brightnesses, 'linear');
end
