function obj = callPowerOnSub(obj,another)
% Syntax:
%
% obj = callPowerOnSub(obj,another)
%
% See also:
% nb_term.power
%
% Written by Kenneth Sæterhagen Paulsen

    if nb_isScalarNumber(obj)
        obj = nb_num(obj);
    end
    if ~isa(obj,'nb_num')
        error([mfilename ':: Unsupported operator for objects of class ' class(obj) ' and ' class(another) '.'])
    end
    if obj == 0
        if isa(another,'nb_num')
            if another < 0
                obj = nb_num(inf);
            end
        end
        return
    elseif obj == 1 || obj == inf || obj == -inf
        return
    end
    if isa(another,'nb_equation') || isa(another,'nb_base')
        if strcmp(another.operator,'^')
            % 2^y^z -> 2^(y*z)
            another.operator = '*';
        end
        obj = nb_equation('^',[obj,another]);
    elseif nb_isScalarNumber(another)
        obj.value = obj.value ^ another;    
    else
        obj.value = obj.value ^ another.value;
    end
    
end
