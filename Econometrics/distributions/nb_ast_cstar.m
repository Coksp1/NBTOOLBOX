function cstar = nb_ast_cstar(c,d,e)
% Syntax:
%
% cstar = nb_ast_cstar(c,d,e)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    cstar = c*nb_ast_k(d)/nb_ast_b(c,d,e);

end
