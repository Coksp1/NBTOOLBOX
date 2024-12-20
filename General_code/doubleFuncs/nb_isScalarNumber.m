function ret = nb_isScalarNumber(x,low,upp)
% Syntax:
%
% ret = nb_isScalarNumber(x,low,upp)
%
% Description:
%
% Test if x is a scalar number.
% 
% Input:
% 
% - x   : Any type
%
% - low : If x is a number, it will test if x > low if this input is given.
%
% - upp : If x is a number, it will test if x < upp if this input is given.
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = true;
    if ~isscalar(x)
        ret = false;
    else
        if ~isnumeric(x)
            ret = false;
        end
    end
    
    if nargin > 1 && ret
        ret = x > low;
        if nargin > 2 && ret
            ret = x < upp;
        end
    end

end
