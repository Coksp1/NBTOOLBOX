function obj = callPlusOnSub(obj,another)
% Syntax:
%
% obj = callPlusOnSub(obj,another)
%
% See also:
% nb_term.plus
%
% Written by Kenneth Sæterhagen Paulsen

    if nb_isScalarNumber(obj)
        obj = nb_num(obj);
    end
    if ~isa(obj,'nb_num')
        error([mfilename ':: Unsupported operator for objects of class ' class(obj) ' and ' class(another) '.'])
    end
    if obj == 0
        obj = another;
        return
    end
    if isa(another,'nb_equation')
        obj = callPlusOnSub(another,obj);
    elseif isa(another,'nb_base')
        if obj == 0
            obj = another;
            return
        end
        obj = nb_equation('+',[obj,another]);
    elseif nb_isScalarNumber(another)
        obj.value = obj.value + another; 
    elseif ~isa(obj,'nb_num')
        obj = callPlusOnSub(another,obj);
    else
        obj.value = obj.value + another.value;
    end
    
end
