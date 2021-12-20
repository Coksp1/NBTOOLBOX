function obj = callPowerOnSub(obj,another)
% Syntax:
%
% obj = callPowerOnSub(obj,another)
%
% See also:
% nb_term.power
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isnumeric(obj)
        % Call nb_num.callPowerOnSub
        obj = nb_num(obj);
        obj = callPowerOnSub(obj,another); 
        return
    end
    if isnumeric(another)
        another = nb_num(another);
    end

    if strcmp(obj.operator,'*')
        terms = obj.terms;
        for ii = 1:obj.numberOfTerms
            terms(ii) = callPowerOnSub(obj.terms(ii),another);
        end
        obj.terms = terms;
    elseif strcmp(obj.operator,'^')
        % x^2^3 -> x^(2*3)
        obj.terms(end) = callTimesOnSub(obj.terms(end),another);
        if obj.numberOfTerms == 1
            obj = obj.terms(1);
        end
    else
        obj = nb_equation('^',[obj,another]);
    end
    
end
