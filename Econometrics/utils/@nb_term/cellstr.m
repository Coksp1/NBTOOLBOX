function cstr = cellstr(obj)
% Syntax:
%
% c = toString(obj)
%
% Description:
%
% Convert array of nb_term objects to cellstr.
%
% Inputs:
%
% - obj : An array of nb_term objects.
%
% Output:
%
% - c   : A cellstr with same size as obj.  
%
% See also:
% toString
%
% Written by Kenneth Sæterhagen Paulsen

    cstr = nb_callMethod(obj,@toString,'cell');
    
end

