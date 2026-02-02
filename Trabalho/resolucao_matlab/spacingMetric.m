function S = spacingMetric(F, varargin)

% Parse
p = inputParser;
addRequired(p,'F',@isnumeric);
addParameter(p,'p',1,@(x)isnumeric(x) && isscalar(x) && x>0);
addParameter(p,'Normalize',false,@islogical);
addParameter(p,'Maximize',false,@(x) islogical(x) || isscalar(x));
parse(p,F,varargin{:});
F = p.Results.F;
pwr = p.Results.p;
doNorm = p.Results.Normalize;
maximize = p.Results.Maximize;

if isempty(F)
    S = NaN; return
end

[n,d] = size(F);

if isscalar(maximize), maximize = repmat(logical(maximize),1,d); else maximize = logical(maximize); end
if numel(maximize) ~= d, error('Maximize must be scalar or length d'); end
if any(maximize)
    F(:,maximize) = -F(:,maximize);
end

if doNorm
    minV = min(F,[],1); maxV = max(F,[],1);
    rangeV = maxV - minV; rangeV(rangeV==0)=1;
    F = (F - minV) ./ rangeV;
end

F = unique(F,'rows','stable');

n = size(F,1);
if n < 2
    S = NaN; return
end

dmin = inf(n,1);
for i = 1:n
    X = abs(bsxfun(@minus, F, F(i,:)));   % n x d
    if pwr == 1
        distVec = sum(X,2);
    elseif pwr == 2
        distVec = sqrt(sum(X.^2,2));
    else
        distVec = sum(X.^pwr,2).^(1/pwr);
    end
    distVec(i) = Inf;          % ignore self
    dmin(i) = min(distVec);
end

dbar = mean(dmin);
S = sqrt( sum((dmin - dbar).^2) / (n-1) );

end