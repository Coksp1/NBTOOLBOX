function expr = removePar(expr)
% Syntax:
%
% expr = removePar(expr)
%
% Description:
%
% Is the expression enclosed with parentheses?
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    match = nb_getMatchingParentheses(expr);
    if match(1) == 1 && match(2) == size(expr,2)
        expr = expr(2:end-1);
    end

end