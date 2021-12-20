function x = variance(obj)
% Syntax:
%
% x = variance(obj)
%
% Description:
%
% Evaluate the variance of the marginal distributions combined by the 
% copula.
%
% The variance is normalized with T-1
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

    x = variance(obj.distributions);

end
