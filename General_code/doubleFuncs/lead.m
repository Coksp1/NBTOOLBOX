function xout = lead(xin,t) 
% Syntax:
%
% xout = lead(xin,t) 
%
% Input:
%
% - xin  : The series to lead, as a nObs x nVar x nPage double.
%
% - t    : The number of periods to lead the series.
%
% Output:
%
% - xout : The series leaded.
%
% See also:
% lag
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        t = 1;
    end
    
    t                 = round(t);
    [r,c,p]           = size(xin); 
    xout              = nan(r,c,p);
    xout(1:end-t,:,:) = xin(t+1:end,:,:);
    
end

