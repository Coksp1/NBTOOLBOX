function obj = callTimesOnSub(obj,another)
% Syntax:
%
% obj = callTimesOnSub(obj,another)
%
% See also:
% nb_term.times
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_base')
        objT    = obj;
        obj     = another;
        another = objT;
    end
    if isnumeric(another)
        another = nb_num(another);
    end

    if isa(another,'nb_equation')
        obj = callTimesOnSub(another,obj);
    elseif isa(another,'nb_num')
        if another == 1
            % x*1 -> x
            return
        elseif any(another == [0,inf,-inf])
            % x*0 -> 0, x*inf -> inf
            obj = another;
            return
        end
        % x*2 = 2*x
        obj = nb_equation('*',[another,obj]);
    else
        if obj == another
            % x*x -> x^2
            another = nb_num(2);
            obj     = nb_equation('^',[obj,another]);
        else
            obj = nb_equation('*',[obj,another]);
        end
    end
    
end
