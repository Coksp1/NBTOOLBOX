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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = mean(obj.distributions);

end
