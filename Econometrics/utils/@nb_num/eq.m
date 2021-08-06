function test = eq(obj,another)
% Syntax:
%
% test = eq(obj,another)
%
% Description:
%
% Test for equality of two objects. They are only equal if the value
% property is equal.
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

    if isnumeric(obj)
        test = abs(obj - [another.value]) < 1e-10;
    elseif isnumeric(another)
        test = abs([obj.value] - another) < 1e-10;
    elseif ~isa(obj,'nb_num') || ~isa(another,'nb_num')
        test = false;
    else
        test = abs([obj.value] - [another.value]) < 1e-10;
    end
    
end
