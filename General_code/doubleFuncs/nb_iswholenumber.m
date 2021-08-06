function ret = nb_iswholenumber(X)
% Syntax:
%
% ret = nb_iswholenumber(input)
%
% Description:
%
%  True for whole numbers
%  For example, nb_iswholenumber([pi NaN 3 -Inf]) is [0 0 1 0].
% 
% Input:
% 
% - in : Any
% 
% Output:
% 
% - ret : an array that contains 1's where
% the elements of X are whole numbers and 0's where they are not.
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isnumeric(X)
        ret = false(size(X));
    else
        ret = isnumeric(X) & isfinite(X) & (round(X) == X);
    end
    
end
