function ret = nb_iswholerow(X)
% Syntax:
%
% ret = nb_iswholerow(input)
%
% Description:
%
% True for a row of whole numbers
% For example, 
% nb_iswholerow([pi NaN 3 -Inf]) is 0.
% nb_iswholerow([4 2 3 1]) is 1.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(X)
        ret = false;
        return
    end
    if ~isnumeric(X)
        ret = false(size(X));
    else
        ret = isnumeric(X) & isfinite(X) & (round(X) == X);
    end
    ret = all(ret,2);
    
end
