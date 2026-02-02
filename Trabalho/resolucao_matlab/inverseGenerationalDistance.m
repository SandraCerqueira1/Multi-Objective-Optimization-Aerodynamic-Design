function IGD = inverseGenerationalDistance(F_obt, F_true, varargin)

% Parse inputs
p = 2;
doNorm = false;
maximize = [];
for k=1:2:numel(varargin)
    switch lower(varargin{k})
        case 'p', p = varargin{k+1};
        case 'normalize', doNorm = varargin{k+1};
        case 'maximize', maximize = varargin{k+1};
        otherwise, error('Unknown option %s', varargin{k});
    end
end

% Validate
if isempty(F_true)
    IGD = 0;
    return
end
if isempty(F_obt)
    IGD = Inf;
    return
end
[m_true,d] = size(F_true);
if size(F_obt,2) ~= d
    error('Dimension mismatch between F_obt and F_true.');
end

% Handle maximization objectives
if ~isempty(maximize)
    if numel(maximize) ~= d
        error('Maximize must be length d or empty.');
    end
    F_obt(:,maximize) = -F_obt(:,maximize);
    F_true(:,maximize) = -F_true(:,maximize);
end

if doNorm
    minT = min(F_true,[],1);
    maxT = max(F_true,[],1);
    rangeT = maxT - minT;
    rangeT(rangeT==0) = 1;
    F_true = (F_true - minT) ./ rangeT;
    F_obt  = (F_obt  - minT) ./ rangeT;
end

m = m_true;
dists = zeros(m,1);
for j = 1:m
    diff = abs(bsxfun(@minus, F_obt, F_true(j,:))); % n x d
    if p == 2
        dvec = sqrt(sum(diff.^2,2));
    elseif p == 1
        dvec = sum(diff,2);
    else
        dvec = sum(diff.^p,2).^(1/p);
    end
    dists(j) = min(dvec);
end

% IGD: mean of distances
IGD = (sum(dists.^p))^(1/p)/m;

end