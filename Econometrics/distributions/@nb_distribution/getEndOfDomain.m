function finish = getEndOfDomain(obj)
% Syntax:
%
% start = getEndOfDomain(obj)
%
% Description:
%
% Get the approximate end point of the domain of all the distributions.
% Uses the 99th percentile.
% 
% Input:
% 
% - obj    : A vector of nb_distribution objects
% 
% Output:
% 
% - finish : The start point of the distribution, as 1x1 double
%
% See also:
% nb_distribution.domain
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nobj1 = size(obj,1);
    nobj  = size(obj,2);
    if nobj1 ~= 1
        if nobj == 1
            obj  = obj(:);
            nobj = nobj1;
        else
            error([mfilename ':: The obj input must be a nb_distribution vector.'])
        end
    end
    
    ub            = domain(obj);
    ub            = ub(:,2);
    ind           = isfinite(ub);
    padding       = zeros(size(obj));
    padding(~ind) = std(obj(~ind));  
    padding(~isfinite(padding)) = 0;

    fd = nan(1,nobj);
    for ii = 1:nobj
        if isfinite(ub(ii)) 
            fd(ii) = ub(ii);
        else
            fd(ii) = icdf(obj(ii),0.98) + padding(ii);
        end
    end
    finish = max(fd);

end
