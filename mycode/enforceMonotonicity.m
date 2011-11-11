%% Force the function to be monotonic
function cMon = enforceMonotonicity(c, pcaMean, pcaBases)
% from [Grossberg and Nayar, 2003]

% cMon = argmin ||Hc - f - f0||^2
% subject to D H cMon <= f0

cMon = zeros(size(c));

%% Build the discrete derivative matrix
D = zeros(size(pcaBases,1)-1, size(pcaBases, 1));
for i=1:size(D,1)
    D(i,:) = circshift([-1 1 zeros(1, size(D,2)-2)], [0 i-1]);
end

%% Optimize each channel independently
for i=1:3
    f0 = pcaMean(:,i);
    H = pcaBases;
    
    % "true" response function
    f = getResponseFromCoefficients(f0, H, c(:,i));
    
    % find fMon that's closest to f, but monotonic
    cMon(:,i) = fmincon(@monotonicityMin, c(:,i), -D*H, D*f0);
end

%% Monotonicity equation
    function m = monotonicityMin(c)
        m = sum((H*c - f + f0).^2);
    end
end
