function ret = nb_isScalarPositiveNumber(x)
% Syntax:
%
% ret = nb_isScalarPositiveNumber(x)
%
% Description:
%
% Test if x is a scalar positive number.
% 
% Input:
% 
% - x : Any type
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if ~isscalar(x)
        ret = false;
    else
        if ~isnumeric(x)
            ret = false;
        else
            ret = x > 0;
        end
    end

end
