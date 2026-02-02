function HV = hypervolume(F, ref, varargin)

p = inputParser;
addRequired(p,'F',@isnumeric);
addRequired(p,'ref',@(x)isnumeric(x) && isvector(x));
addParameter(p,'Maximize',false,@(x) islogical(x) || isscalar(x));
addParameter(p,'Normalize',false,@islogical);
parse(p,F,ref,varargin{:});
F = p.Results.F;
ref = p.Results.ref(:)';
maximize = p.Results.Maximize;
doNorm = p.Results.Normalize;

if isempty(F)
    HV = 0; return
end

[n,d] = size(F);
if numel(ref) ~= d
    error('Reference point must have same dimension as F columns.');
end

% handle maximize flag
if isscalar(maximize), maximize = repmat(logical(maximize),1,d); else maximize = logical(maximize); end
if numel(maximize) ~= d, error('Maximize must be scalar or length d'); end
if any(maximize)
    F(:,maximize) = -F(:,maximize);
    ref(maximize)  = -ref(maximize);
end

if doNorm
    minV = min(F,[],1);
    rangeV = ref - minV;
    rangeV(rangeV==0) = 1;
    F = (F - minV) ./ rangeV;
    ref = (ref - minV) ./ rangeV;
end

% Keep only points that are strictly better than reference in all objectives
mask = all(F < repmat(ref, n, 1), 2);
F = F(mask,:);
if isempty(F)
    HV = 0; return
end

% Remove dominated points
F = unique(F,'rows','stable');
F = filterNonDominated(F);

% Sort points by first objective ascending 
[~, idx] = sortrows(F,1);
F = F(idx,:);

% Call recursive hypervolume 
HV = hv_recursive(F, ref);

end

%% Recursive hypervolume: computes HV for a set of points (minimization)
function hv = hv_recursive(P, ref)

[k,d] = size(P);
if k == 0
    hv = 0; return
end
if d == 1
    x = min(P(:,1));
    hv = ref(1) - x;
    return
end

if k == 1
    hv = prod(ref - P(1,:));
    return
end

dim = d;

[~, order] = sort(P(:,dim),'ascend');
P = P(order,:);

hv = 0;
prev = ref(dim);
i = k;
while i >= 1
    z = P(i,dim);
    j = i;
    slice = P(1:i,1:dim-1);
    slice = removeDominatedForSlice(slice);
    vol = hv_recursive(slice, ref(1:dim-1));
    hv = hv + (prev - z) * vol;
    prev = z;
    i = i - 1;
end

end

%% Helpers

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

function S = removeDominatedForSlice(A)
    if isempty(A), S = A; return; end
    % remove duplicates and dominated points
    A = unique(A,'rows','stable');
    S = filterNonDominated(A);
end