function test = eq(obj,another)
% Syntax:
%
% test = eq(obj,another)
%
% Description:
%
% Test for equality of to objects. They are only equal if the value
% property is equal.
%
% Inputs:
%
% - obj     : A nb_base object.
%
% - another : A nb_base object.
%
% Output:
%
% - test    : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_base') || ~isa(another,'nb_base')
       test = false;
       return
    end
    test = strcmp(obj.value,another.value);
    
end
