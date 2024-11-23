function obj = callPowerOnSub(obj,another)
% Syntax:
%
% obj = callPowerOnSub(obj,another)
%
% See also:
% nb_term.power
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isnumeric(obj)
        % Call nb_num.callPowerOnSub
        obj = nb_num(obj);
        obj = callPowerOnSub(obj,another); 
        return
    end
    if isnumeric(another)
        another = nb_num(another);
    end

    if isa(another,'nb_equation')
        if strcmp(another.operator,'^')
            % x^y^z -> x^(y*z)
            another.operator = '*';
        end
        obj = nb_equation('^',[obj,another]);
    elseif isa(another,'nb_num')
        if another == 1
            % x^1 -> x
            return
        elseif another == 0
            % x^0 -> 1
            obj = nb_num(1);
            return
        elseif any(another == [inf,-inf])
            % x*0 -> 0, x*inf -> inf
            obj = another;
            return    
        end
        % x^2
        obj = nb_equation('^',[obj,another]);
    else
        obj = nb_equation('^',[obj,another]);
    end
    
end
