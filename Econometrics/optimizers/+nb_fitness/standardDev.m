function fit = standardDev(fVal,fMin,Q)
% Syntax:
%
% fit = nb_fitness.standardDev(fVal,fMin,Q)
%
% Description:
%
% Calculates the fitness function
%
% fit = 1/(Q + fVal - fMin) 
% 
% Input:
% 
% - fVal : Value of function. As a N x M double.
%
% - fMin : Minimum value of function optained until now. As a scalar 
%          double.
% 
% - Q    : Scaling parameter.
% 
% Output:
% 
% - fit : Fitness score. As a N x M double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    fit = 1/(Q + fVal - fMin);

end
