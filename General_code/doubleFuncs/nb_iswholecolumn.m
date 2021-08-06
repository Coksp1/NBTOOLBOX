function ret = nb_iswholecolumn(X)
% Syntax:
%
% ret = nb_iswholecolumn(input)
%
% Description:
%
% True for a column of whole numbers
% For example, 
% nb_iswholecolumn([pi NaN 3 -Inf]') is 0.
% nb_iswholecolumn([4 2 3 1]') is 1.
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
    ret = all(ret,1);
    
end
