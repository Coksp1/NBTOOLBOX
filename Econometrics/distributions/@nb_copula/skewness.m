function x = skewness(obj)
% Syntax:
%
% x = skewness(obj)
%
% Description:
%
% Evaluate the skewness of the marginal distributions combined by the 
% copula.
%
% The skewness will be adjusted for bias. See the function skewness made
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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    x = skewness(obj.distributions);

end
