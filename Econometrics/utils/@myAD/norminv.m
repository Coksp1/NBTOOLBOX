function x = norminv(x,m,k)
% Syntax:
%
% x = norminv(x,m,k)
%
% Description:
%
% Inverse normal cdf.
%
% Written by SeHyoun Ahn, May 2022
% Edited by Kenneth S. Paulsen
% - Added the m and k inputs

    if nargin < 3
        k = 1;
        if nargin < 2
            m = 0;
        end
    end
    x.values      = norminv(x.values,m,k);
    x.derivatives = valXder(1./normpdf(x.values,m,k), x.derivatives);

end
