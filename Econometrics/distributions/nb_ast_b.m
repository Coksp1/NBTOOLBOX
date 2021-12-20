function f = nb_ast_b(c,d,e)
% Syntax:
%
% f = nb_ast_b(x)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    f  = c*nb_ast_k(d) + (1 - c)*nb_ast_k(e);

end
