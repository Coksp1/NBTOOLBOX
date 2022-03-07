function dout=egrowth(din,t)
% Syntax:
%
% dout = egrowth(din,t)
%
% Description:
%
% This function uses the standard growth formula as opposed to the log
% growth economist typically use.
%
% See also: 
% growth, iegrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<2
        t=1;
    end
    [r,c,p] = size(din); %#ok<ASGLU>
    dout    = cat(1,nan(t,c,p),(din(t+1:end,:,:) - din(1:end-t,:,:))./din(1:end-t,:,:));

end
