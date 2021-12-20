function test = ge(obj,another)
% Syntax:
%
% test = ge(obj,another)
%
% Description:
%
% Test if one object is greater than or equal to another.
%
% Inputs:
%
% - obj     : A nb_num object or a number.
%
% - another : A nb_num object or a number.
%
% Output:
%
% - test    : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

    if nb_isScalarNumber(obj)
        test = obj > another.value;
    elseif nb_isScalarNumber(another)
        test = obj.value > another;
    elseif ~isa(obj,'nb_num') || ~isa(another,'nb_num')
        error([mfilename ':: Cannot call gt (>) on objects of class ' class(obj) ' and ' class(another) '.'])
    else
        test = obj.value > another.value;
    end
    
end
