function dout = nb_diff(din,t)
% Syntax:
%
% dout = nb_diff(din,t)
%
% Description:
%
% Difference operator x(s) - x(s-t). dout will append nan at the start to
% preserve the same size of dout as din.
%
% See also:
% growth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        t = 1;
    end
    [r,c,p] = size(din); %#ok<ASGLU>
    dout    = cat(1,nan(t,c,p),din(t+1:end,:,:)-din(1:end-t,:,:));
    
end
