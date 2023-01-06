function value = nb_conditional(condition, trueValue, falseValue)
% Syntax:
%
% value = nb_conditional(condition, trueValue, falseValue)
%
% Description:
%
% If condition is true return trueValue, or else return falseValue.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isscalar(condition)
        if condition
            value = trueValue;
        else
            value = falseValue;
        end
    else
        try
            siz               = size(condition);
            condition         = condition(:);
            trueValue         = trueValue(:);
            falseValue        = falseValue(:);
            num               = prod(siz);
            value             = nan(num,1);
            if isscalar(trueValue)
                value(condition) = trueValue;
            else
                value(condition) = trueValue(condition);
            end
            if isscalar(falseValue)
                value(~condition) = falseValue;
            else
                value(~condition) = falseValue(~condition);
            end
            value = reshape(value,siz);
        catch
            error([mfilename ': If condition is not scalar, trueValue and falseValue must either be scalar or match the size of condition.'])
        end
    end
    
end
