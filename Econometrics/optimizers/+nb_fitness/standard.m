function fit = standard(fVal,~,~)
% Syntax:
%
% fit = nb_fitness.standard(fVal,fMin,Q)
%
% Description:
%
% Calculates the fitness function
%
% fit = 1/(1 + fVal) if fVal >= 0
%
% fit = 1 + abs(fVal) if fVal < 0
% 
% Input:
% 
% - fVal : Value of function. As a N x M double.
%
% - fMin : Minimum value of function optained until now. As a scalar 
%          double. Not in use.
% 
% - Q    : Scaling parameter. Not in use.
% 
% Output:
% 
% - fit : Fitness score. As a N x M double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    pos      = fVal >= 0;
    neg      = ~pos;
    fit      = fVal;
    fit(pos) = 1./(1 + fVal(pos));
    fit(neg) = 1 + abs(fVal(neg));

end
