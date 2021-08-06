function f = nb_ast_k(x)
% Syntax:
%
% f = nb_ast_k(x)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    f1 = gamma((x + 1)./2);
    f2 = sqrt(pi.*x).*gamma(x./2);
    if any(~isfinite([f1,f2]))
        f = 0.4; % Asymptotic value
    else
        f  = f1./f2;
    end
    
end
