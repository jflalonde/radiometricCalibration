%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function corrImg = correctImage(img, camInvResponse, mask)
%   Corrects the image according to the inverse response function
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function corrImg = correctImage(img, camInvResponse, mask)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2008 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 2
    mask = true(size(img,1), size(img,2));
end

% reshape and rescale in the [0,1] interval
imgVec = reshape(img, size(img,1)*size(img,2), size(img,3));
maxVal = max(imgVec(mask,:), [], 1);
imgVec = imgVec ./ repmat(maxVal, size(img,1)*size(img,2), 1);

% clamp in [0,1] interval
imgVec = min(max(imgVec, 0), 1);

% correct
corrImgVec = zeros(size(imgVec));
for i=1:3
     corrImgVec(:,i) = getForwardResponse(camInvResponse(:,i), imgVec(:,i));
end

% rescale and reshape back to original format
corrImgVec = corrImgVec .* repmat(maxVal, size(img,1)*size(img,2), 1);
corrImg = reshape(corrImgVec, size(img,1), size(img,2), size(img,3));
