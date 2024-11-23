function f = nb_ast_k(x)
% Syntax:
%
% f = nb_ast_k(x)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f1 = gamma((x + 1)./2);
    f2 = sqrt(pi.*x).*gamma(x./2);
    if any(~isfinite([f1,f2]))
        f = 0.4; % Asymptotic value
    else
        f  = f1./f2;
    end
    
end
