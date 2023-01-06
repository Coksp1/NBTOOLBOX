function par = nb_reduceCov(C)
% Syntax:
%
% par = nb_reduceCov(C)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    n   = size(C,1);
    par = nan(sum(1:n),1);
    kk  = 1;
    for ii = 1:n
        par(kk:kk + (n - ii)) = C(ii:end,ii);
        kk = kk + (n - ii + 1);
    end
    
end
