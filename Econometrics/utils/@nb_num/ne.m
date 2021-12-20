function test = ne(obj,another)
% Syntax:
%
% test = ne(obj,another)
%
% Description:
%
% Test for not equality (~=) of two objects. They are only not equal if  
% the value property is not equal.
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
        test = obj ~= [another.value];
    elseif isnumeric(another)
        test = [obj.value] ~= another;
    elseif ~isa(obj,'nb_num') || ~isa(another,'nb_num')
        test = false;
    else
        test = [obj.value] ~= [another.value];
    end
    
end
