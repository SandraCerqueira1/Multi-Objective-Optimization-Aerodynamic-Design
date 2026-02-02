function Delta = Spread(F_obt, F_true, varargin)

% parse
p = inputParser;
addRequired(p,'F_obt',@isnumeric);
addOptional(p,'F_true',[],@(x) isempty(x) || isnumeric(x));
addParameter(p,'Normalize',false,@islogical);
addParameter(p,'Maximize',false,@(x)islogical(x) || isscalar(x));
parse(p,F_obt,F_true,varargin{:});
F_obt = p.Results.F_obt;
F_true = p.Results.F_true;
doNorm = p.Results.Normalize;
maximize = p.Results.Maximize;

% basic checks
if isempty(F_obt)
    Delta = NaN; return
end
[n,d] = size(F_obt);
if ~isempty(F_true) && size(F_true,2) ~= d
    error('F_obt and F_true must have same number of columns (objectives).');
end

% handle maximize flag
if isscalar(maximize)
    maximize = repmat(logical(maximize),1,d);
else
    maximize = logical(maximize);
end
if numel(maximize) ~= d
    error('Maximize must be logical scalar or vector of length d.');
end
if any(maximize)
    F_obt(:,maximize) = -F_obt(:,maximize);
    if ~isempty(F_true), F_true(:,maximize) = -F_true(:,maximize); end
end

% normalization
if doNorm
    if ~isempty(F_true)
        ref = F_true;
    else
        ref = F_obt;
    end
    minV = min(ref,[],1); maxV = max(ref,[],1);
    rangeV = maxV - minV; rangeV(rangeV==0) = 1;
    F_obt = (F_obt - minV) ./ rangeV;
    if ~isempty(F_true), F_true = (F_true - minV) ./ rangeV; end
end

F_obt = unique(F_obt,'rows','stable');
F_obt = filterNonDominated(F_obt);

if size(F_obt,1) < 2
    Delta = Inf; return
end


[~,ord] = sortrows(F_obt,1);
P = F_obt(ord,:);

k = size(P,1);
difs = inf(k,1);
for i = 1:k
    D = sqrt(sum((P - P(i,:)).^2, 2)); % kx1
    D(i) = Inf;
    difs(i) = min(D);
end
d_bar = mean(difs);


if ~isempty(F_true)
    [~,i_min] = min(F_true(:,1));
    [~,i_max] = max(F_true(:,1));
    T_low = F_true(i_min,:);
    T_high = F_true(i_max,:);
else
    T_low = P(1,:);
    T_high = P(end,:);
end
df = norm(P(1,:) - T_low);
dl = norm(P(end,:) - T_high);

numer = df + dl + sum(abs(difs - d_bar));
denom = df + dl + numel(difs) * d_bar;
if denom == 0
    Delta = 0;
else
    Delta = numer / denom;
end

end


function Fnd = filterNonDominated(F)
    n = size(F,1);
    keep = true(n,1);
    for i = 1:n
        if ~keep(i), continue; end
        dom = all(F <= F(i,:),2) & any(F < F(i,:),2);
        if any(dom)
            keep(i) = false;
        end
    end
    Fnd = F(keep,:);
end