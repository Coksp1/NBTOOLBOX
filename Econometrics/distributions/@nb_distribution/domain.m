function d = domain(obj,out)
% Syntax:
%
% d = domain(obj)
%
% Description:
%
% Returns the full domain of the distribution represented by a
% nb_distribution object.
% 
% Input:
% 
% - obj    : An object of class nb_distribution  
% 
% - out    : - 0 : Returns the lower and upper bound of the distribution,
%                  if truncated those limits are returned. Default.
%
%            - 1 : Returns the lower and upper bound of the distribution,
%                  if truncated those limits are not returned.
%
%            - 2 : Returns the lower and upper bound of the distribution,
%                  if truncated it will only return the lower truncation
%                  limit.
%
%            - 3 : Returns the lower and upper bound of the distribution,
%                  if truncated it will only return the upper truncation
%                  limit.
%
% Output:
% 
% - domain :  A nobjx2 double with the lower and upper limits of the 
%             domain.
%
% Examples:
%
% See also:
% nb_distribution.getEndOfDomain, nb_distribution.getStartOfDomain
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        out = 0;
    end

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
    
    d = nan(nobj,2);
    for ii = 1:nobj
    
        func    = str2func(['nb_distribution.' obj(ii).type '_domain']);
        d(ii,:) = func(obj(ii).parameters{:});

        if ~isempty(obj(ii).meanShift)
            d(ii,:) = d(ii,:) + obj(ii).meanShift;
        end
        
        if ~isempty(obj(ii).upperBound) && or(out == 0,out == 3)
            d(ii,2) = obj(ii).upperBound;
        end

        if ~isempty(obj(ii).lowerBound) && or(out == 0,out == 2)
            d(ii,1) = obj(ii).lowerBound;
        end
         
    end
    
end
