function dout = nb_diff(din,t)
% Syntax:
%
% dout = nb_diff(din,t)
%
% Description:
%
% Same as MATLAB built in, but preserve size by adding nan at the start.
%
% See also:
% growth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        t = 1;
    end
    [r,c,p] = size(din); %#ok<ASGLU>
    dout    = cat(1,nan(t,c,p),din(t+1:end,:,:)-din(1:end-t,:,:));
    
end
