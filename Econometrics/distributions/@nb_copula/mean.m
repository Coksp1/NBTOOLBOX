function x = mean(obj)
% Syntax:
%
% x = mean(obj)
%
% Description:
%
% Evaluate the mean of the marginal distributions combined by the copula.
% 
% Input:
% 
% - obj : An object of class nb_copula
% 
% Output:
% 
%- x   : A double with size 1xN, where N is the number of marginal
%         distributions combined with the copula.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x = mean(obj.distributions);

end
