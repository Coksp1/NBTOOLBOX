function ret = nb_isAxes(value)
% Syntax:
%
% ret = nb_isAxes(value)
%
% Description:
%
% Test if an object is of class axes.
% 
% Input:
% 
% - value : Any
% 
% Output:
% 
% - ret   : True if value is a handle to a axes.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ret = false;
    if ishandle(value)
        type = get(value,'type');
        if strcmpi(type,'axes')
            ret = true;
        end
    end

end
