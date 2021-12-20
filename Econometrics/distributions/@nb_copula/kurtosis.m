function x = kurtosis(obj)
% Syntax:
%
% x = kurtosis(obj)
%
% Description:
%
% Evaluate the kurtosis of the marginal distributions combined by the 
% copula.
%
% The kurtosis will be adjusted for bias. See the function kurtosis made
% by MATLAB inc.
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

    x = kurtosis(obj.distributions);

end
