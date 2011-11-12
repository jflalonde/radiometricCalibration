function drawColorTriplets(figHandle, img, edgeMap, patchSize, edgeCoords)
% Draws the color triplets found on the image
%
% See also:
%   findColorTriplets
%
% ----------
% Jean-Francois Lalonde

figure(figHandle); imshow(img); hold on;
patchHalfSize = floor(patchSize ./ 2);

edgeMap = imdilate(edgeMap, strel('disk', 3));

for i=1:length(edgeCoords)
    curCoords = edgeCoords{i};
    
    % draw the corresponding edge points
    patchRowRange = curCoords(1)-patchHalfSize(1):curCoords(1)+patchHalfSize(1);
    patchColRange = curCoords(2)-patchHalfSize(2):curCoords(2)+patchHalfSize(2);
    edgePatch = edgeMap(patchRowRange, patchColRange);
    
    [edgeR, edgeC] = find(edgePatch);
    
    plot(patchColRange(edgeC), patchRowRange(edgeR), '.b', 'LineWidth', 2, 'MarkerSize', 4);
        
    % draw a rectangle
    rectangle('Position', [curCoords(2)-patchHalfSize(2), curCoords(1)-patchHalfSize(1), patchSize(2), patchSize(1)], 'LineWidth', 1);
end