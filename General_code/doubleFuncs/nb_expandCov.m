function C = nb_expandCov(par,n)
% Syntax:
%
% C = nb_expandCov(par,n)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    C  = zeros(n,n);
    kk = 1;
    for ii = 1:n
        C(end-n+ii:end,ii) = par(kk:kk+n-ii);
        kk = kk + n - ii + 1;
    end
    D = diag(diag(C));
    C = C + (C' - D);
    
end
