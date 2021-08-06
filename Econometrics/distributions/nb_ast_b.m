function f = nb_ast_b(c,d,e)
% Syntax:
%
% f = nb_ast_b(x)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    f  = c*nb_ast_k(d) + (1 - c)*nb_ast_k(e);

end
