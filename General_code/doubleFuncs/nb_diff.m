function dout = nb_diff(din,t,skipNaN)
% Syntax:
%
% dout = nb_diff(din,t)
% dout = nb_diff(din,t,skipNaN)
%
% Description:
%
% Difference operator x(s) - x(s-t). dout will append nan at the start to
% preserve the same size of dout as din.
%
% See also:
% growth, nb_undiff
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        skipNaN = 0;
        if nargin < 2
            t = 1;
        end
    end
    if skipNaN
        dout = din;
        for ii = 1:size(din,3) 
            for jj = 1:size(din,2)
                dataTT              = din(:,jj,ii);
                isNaN               = isnan(dataTT);
                y                   = dataTT(~isNaN);
                dout(~isNaN,jj,ii) = y - nb_lag(y,t);
            end
        end
    else
        [r,c,p] = size(din); %#ok<ASGLU>
        dout    = cat(1,nan(t,c,p),din(t+1:end,:,:)-din(1:end-t,:,:));
    end
    
end
