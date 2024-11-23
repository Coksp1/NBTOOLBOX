function x = mode(obj)
% Syntax:
%
% x = mode(obj)
%
% Description:
%
% Evaluate the mode of the marginal distributions combined by the 
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    x = mode(obj.distributions);

end
