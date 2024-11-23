function expr = removePar(expr)
% Syntax:
%
% expr = removePar(expr)
%
% Description:
%
% Is the expression enclosed with parentheses?
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    match = nb_getMatchingParentheses(expr);
    if match(1) == 1 && match(2) == size(expr,2)
        expr = expr(2:end-1);
    end

end
