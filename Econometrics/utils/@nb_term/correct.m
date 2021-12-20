function expr = correct(expr)
% Syntax:
%
% expr = nb_term.correct(expr)
%
% Description:
%
% Correct term for .*, ./ and .^ operators.
% 
% Input:
% 
% - expr : A one line char with a mathematical expression.
% 
% Output:
% 
% - expr : Corrected version of the input.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
    
    expr = strrep(expr,'.*','*');
    expr = strrep(expr,'./','/');
    expr = strrep(expr,'.^','^');
    expr = regexprep(expr,'\s','');

end
