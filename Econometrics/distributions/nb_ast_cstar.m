function cstar = nb_ast_cstar(c,d,e)
% Syntax:
%
% cstar = nb_ast_cstar(c,d,e)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    cstar = c*nb_ast_k(d)/nb_ast_b(c,d,e);

end
