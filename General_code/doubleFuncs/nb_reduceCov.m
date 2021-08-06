function par = nb_reduceCov(C)
% Syntax:
%
% par = nb_reduceCov(C)
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    n   = size(C,1);
    par = nan(sum(1:n),1);
    kk  = 1;
    for ii = 1:n
        par(kk:kk + (n - ii)) = C(ii:end,ii);
        kk = kk + (n - ii + 1);
    end
    
end
