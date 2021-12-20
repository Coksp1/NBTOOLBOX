function x = median(obj)
% Syntax:
%
% x = median(obj)
%
% Description:
%
% Evaluate the median of the marginal distributions combined by the 
% copula.
% 
% Input:
% 
% - obj : An object of class nb_copula
% 
% Output:
% 
% - x   : A double with size 1xN, where N is the number of marginal
%         distributions combined with the copula.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    x = median(obj.distributions);

end
