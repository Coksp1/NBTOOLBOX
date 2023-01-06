function ret = nb_isScalarInteger(x,low,upp)
% Syntax:
%
% ret = nb_isScalarInteger(x,low,upp)
%
% Description:
%
% Test if x is a scalar integer.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(x)
        ret = false;
    else
        if nb_iswholenumber(x)
            ret = true;
            if nargin > 1 && ret
                ret = x > low;
                if nargin > 2 && ret
                    ret = x < upp;
                end
            end
            return
        end
        if isnumeric(x)
            if ~isfinite(x)
                ret = true;
            else
                ret = false;
            end
            if nargin > 1 && ret
                ret = x > low;
                if nargin > 2 && ret
                    ret = x < upp;
                end
            end
        else
            ret = false;
        end
    end

end
