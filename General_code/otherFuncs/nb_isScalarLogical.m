function ret = nb_isScalarLogical(x)
% Syntax:
%
% ret = nb_isScalarLogical(x)
%
% Description:
%
% Test if x is a scalar logical.
% 
% Input:
% 
% - x   : Any type
% 
% Output:
% 
% - ret : true or false.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    ret = true;
    if ~isscalar(x)
        ret = false;
    else
        if ~islogical(x)
            ret = false;
        end
    end

end
