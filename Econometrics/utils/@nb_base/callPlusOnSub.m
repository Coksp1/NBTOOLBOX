function obj = callPlusOnSub(obj,another)
% Syntax:
%
% obj = callPlusOnSub(obj,another)
%
% See also:
% nb_term.plus
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_base')
        objT    = obj;
        obj     = another;
        another = objT;
    end
    if isnumeric(another)
        another = nb_num(another);
    end
    if isa(another,'nb_equation')
        obj = callPlusOnSub(another,obj);
    elseif isa(another,'nb_num')
        if another == 0
            return
        elseif any(another == [-inf,inf])
            obj = another;
            return
        end
        obj = nb_equation('+',[another,obj]);
    else
        if obj == another
            another = nb_num(2);
            obj     = nb_equation('*',[another,obj]);
        else
            obj = nb_equation('+',[another,obj]);
        end
    end
    
end
