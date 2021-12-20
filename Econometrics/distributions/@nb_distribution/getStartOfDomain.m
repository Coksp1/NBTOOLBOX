function start = getStartOfDomain(obj)
% Syntax:
%
% start = getStartOfDomain(obj)
%
% Description:
%
% Get the approximate start point of the domain of all the distributions.
% Uses the 1st percentile.
% 
% Input:
% 
% - obj    : A vector of nb_distribution objects
% 
% Output:
% 
% -  start : The start point of the distribution, as 1x1 double
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
    
    lb            = domain(obj);
    lb            = lb(:,1);
    ind           = isfinite(lb);
    padding       = zeros(size(obj));
    padding(~ind) = std(obj(~ind));  
    padding(~isfinite(padding)) = 0;
    
    sd = nan(1,nobj);
    for ii = 1:nobj
        if isfinite(lb(ii)) 
            sd(ii) = lb(ii);
        else
            sd(ii) = icdf(obj(ii),0.02) - padding(ii);
        end
    end
    start = min(sd);

end
