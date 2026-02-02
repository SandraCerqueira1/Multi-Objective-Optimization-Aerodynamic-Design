function GD = generationalDistance(F_obt, F_true, varargin)

% Parse inputs
p = 2;
doNorm = false;
maximize = [];
if ~isempty(varargin)
    for k=1:2:numel(varargin)
        switch lower(varargin{k})
            case 'p', p = varargin{k+1};
            case 'normalize', doNorm = varargin{k+1};
            case 'maximize', maximize = varargin{k+1};
            otherwise, error('Unknown option %s', varargin{k});
        end
    end
end

% Validate
if isempty(F_obt) || isempty(F_true)
    GD = 0;
    return
end
[n,d] = size(F_obt);
if size(F_true,2) ~= d
    error('Dimension mismatch between F_obt and F_true.');
end
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
    F_obt = (F_obt - minT) ./ rangeT;
    F_true = (F_true - minT) ./ rangeT;
end

dists_sq = zeros(n, size(F_true,1));
for i = 1:n
    diff = F_true - F_obt(i,:);          % m x d
    dists_sq(i,:) = sum(diff.^2, 2)';    % 1 x m
end
d_i = sqrt(min(dists_sq,[],2));         % n x 1

GD = (sum(d_i.^p)^(1/p)) / n;

end