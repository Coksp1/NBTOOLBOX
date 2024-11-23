function [test,obj] = equalToThePower(obj,another)
% Syntax:
%
% [test,obj] = equalToThePower(obj,another)
%
% Description:
%
% Test for equality of two objects ignoring powers.
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
% - obj     : A nb_equation object representing the simplified object. E.g:
%             eq*(eq)^-1 -> 1, eq^2*eq^1 -> eq^3
%             eq/(eq + eq*x) -> 1/(1 + x)
%
%             But not yet:
%             eq^2/(eq^2 + eq*x) -> eq/(eq + x)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_equation') || ~isa(another,'nb_equation')
       test = false;
       return
    end
    if strcmpi(obj.operator,'^') && obj.numberOfTerms == 2
        base1 = obj.terms(1);
        pow1  = obj.terms(2);
    else
        base1 = obj;
        pow1  = nb_num(1);
    end
    if strcmpi(another.operator,'^') && another.numberOfTerms == 2
        base2 = another.terms(1);
        pow2  = another.terms(2);
    else
        base2 = another;
        pow2  = nb_num(1);
    end
  
    if base1 == base2
        % eq*(eq)^-1 -> 1, eq^2*eq^1 -> eq^3
        pow = pow1 + pow2;
        if pow == 1
            obj = base1;
        elseif pow == 0
            obj = nb_num(1);
        else
            obj = power([base1,pow]);
        end
        test = true;
        return
    elseif base1 == -1*base2
        % -eq*(eq)^-1 -> -1, (-eq)^2*eq^1 -> -eq^3
        pow = pow1 + pow2;
        if pow == 1
            obj = base1;
        elseif pow == 0
            obj = nb_num(1);
        else
            obj = nb_equation('^',[base1,pow]);
        end
        obj  = -1*obj;
        test = true;
        return
    end
    
    [common,base1,base2] = findCommonTerms(base1,base2,pow1,pow2);
    if size(common,1) == 0
        test = false;
    else
        % eq^2/(eq^2 + eq*x) -> eq/(eq + x)
        obj  = collectCommon(common,base1,base2,pow1,pow2);
        test = true;
    end
    
end

%==========================================================================
function obj = collectCommon(common,base1,base2,pow1,pow2)

    pow = pow1 + pow2;
    if pow == 0
        common = nb_num.empty();
    else
        common = nb_equation('^',[common,pow]);
    end
    
    if pow1 ~= 1
        base1 = power([base1,pow1]);
    end
    if pow2 ~= 1
        base2 = power([base2,pow2]);
    end
    obj = times([common,base1,base2]);
    
end
