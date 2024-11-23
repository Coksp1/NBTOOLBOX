function expr = simplify(expr,waitbar)
% Syntax:
%
% expr = nb_term.simplify(expr)
% expr = nb_term.simplify(expr,waitbar)
%
% Description:
%
% Simplify the mathematical expressions.
% 
% Input:
% 
% - expr    : A one line char with a mathematical expression or a cellstr
%             with the mathematical expressions.
% 
% - waitbar : A nb_waitbar5 object. It will use the next available waitbar
%             of the given object. If empty no waitbar is added.
%
% Output:
% 
% - obj  : A cellstr with the simplified mathematical expressions.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    if nargin < 2
        waitbar = [];
    end
    terms = nb_term.split(expr,waitbar);
    expr  = cellstr(terms);
    
end
