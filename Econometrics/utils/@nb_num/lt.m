function test = lt(obj,another)
% Syntax:
%
% test = lt(obj,another)
%
% Description:
%
% Test if one object is less than another.
%
% Inputs:
%
% - obj     : A nb_num object or a scalar number.
%
% - another : A nb_num object or a scalar number.
%
% Output:
%
% - test    : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

    if isnumeric(obj)
        test = obj < another.value;
    elseif isnumeric(another)
        test = obj.value < another;
    elseif ~isa(obj,'nb_num') || ~isa(another,'nb_num')
        error([mfilename ':: Cannot call lt (<) on objects of class ' class(obj) ' and ' class(another) '.'])
    else
        test = obj.value < another.value;
    end
    
end
