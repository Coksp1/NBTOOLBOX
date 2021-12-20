function obj = callTimesOnSub(obj,another)
% Syntax:
%
% obj = callTimesOnSub(obj,another)
%
% See also:
% nb_term.times
%
% Written by Kenneth Sæterhagen Paulsen

    if nb_isScalarNumber(obj)
        obj = nb_num(obj);
    end
    if ~isa(obj,'nb_num')
        error([mfilename ':: Unsupported operator for objects of class ' class(obj) ' and ' class(another) '.'])
    end
    if any(obj == [0,inf,-inf])
        % 0*x -> 0, inf*x -> inf
        return
    end
    if isa(another,'nb_equation')
        obj = callTimesOnSub(another,obj);
    elseif isa(another,'nb_base')
        if obj == 1
            % 1*x -> x
            obj = another;
            return   
        end
        obj = nb_equation('*',[obj,another]);
    elseif nb_isScalarNumber(another)
        obj.value = obj.value * another;
    else
        obj.value = obj.value * another.value;
    end
    
end
