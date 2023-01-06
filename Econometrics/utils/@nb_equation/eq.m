function test = eq(obj,another)
% Syntax:
%
% test = eq(obj,another)
%
% Description:
%
% Test for equality of two objects. They are only equal if they represents 
% the same equation.
%
% Inputs:
%
% - obj     : A nb_equation object.
%
% - another : A nb_equation object.
%
% Output:
%
% - test    : true or false.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_equation') || ~isa(another,'nb_equation')
       test = false;
       return
    end
    if obj.numberOfTerms ~= another.numberOfTerms
        test = false;
        return
    end
    test = strcmp(toString(obj),toString(another));
  
end
