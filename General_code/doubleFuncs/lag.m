function xout = lag(xin,t,d) 
% Syntax:
%
% xout = lag(xin,t) 
% xout = lag(xin,t,d)
%
% Input:
%
% - xin  : The series to lag, as a nObs x nVar x nPage double.
%
% - t    : The number of periods to lag the series.
%
% - d    : The number to fill in for the first t periods. Default is nan.
%
% Output:
%
% - xout : The series lagged.
%
% See also:
% lead
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        t = 1;
    end
    
    t                 = round(t);
    [r,c,p]           = size(xin); 
    xout              = nan(r,c,p);
    xout(t+1:end,:,:) = xin(1:end-t,:,:);
    if nargin == 3
        xout(1:t,:,:) = d;
    end
    
end

