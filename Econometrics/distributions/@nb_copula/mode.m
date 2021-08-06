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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = mode(obj.distributions);

end
