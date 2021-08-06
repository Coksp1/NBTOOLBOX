function test = gt(obj,another)
% Syntax:
%
% test = gt(obj,another)
%
% Description:
%
% Test if one object is greater than another.
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
% Written by Kenneth S�terhagen Paulsen

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
