function d = domain(obj,out)
% Syntax:
%
% d = domain(obj)
%
% Description:
%
% Returns the full domain of the marginal distributions combined by the
% copula.
% 
% Input:
% 
% - obj    : An object of class nb_copula  
% 
% - out    : - 0 : Returns the lower and upper bound of the distribution,
%                  if truncated does limits are returned. Default.
%
%            - 1 : Returns the lower and upper bound of the distribution,
%                  if truncated does limits are not returned.
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
% - domain :  A Nx2 double with the lower and upper limits of the domain.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        out = 0;
    end

    d = domain(obj.distributions,out);
    
end
