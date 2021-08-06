function trend = exptrend(series,weight,numInitialisationAvg)
% Syntax:
%
% trend = exptrend(series)
% trend = exptrend(series,weight,numInitialisationAvg)
%
% Description:
%
% Exponential smoothing.
%
% Translated from Gauss code originally produced by Anne-Sofie Jore.
%
% Input:
%
% - series               : The series to be smoothed (each column is 
%                          smoothed using the parameter weight). A double 
%                          with size T x N x P.
% - weight               : The amount of weight attached to the immediately
%                          lagged value or (1-weight) attached to last 
%                          period's trend value. Default is 0.5. 
% - numInitialisationAvg : The number of observations to average across at 
%                          the beginning of the sample
%
% Output:
%
% - trend                : The trend. A double with size T x N x P.
%
% See also: 
% hpfilter
%
% Written by Christie Smith
% Edited by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        numInitialisationAvg = 20;
        if nargin < 2
            weight = 0.5;
        end
    end

    % Initialize trend with average of first numInitialisationAvg observations
    qq  = series((1:numInitialisationAvg)',:,:); 
    qqq = mean(qq);

    % Preallocate trend
    trend = nan(size(series));

    % Compute first element of the trend
    trend(1,:,:) = weight*series(1,:,:) + (1-weight)*qqq;
    jj           = 2; 
    while jj <= size(series,1)
        trend(jj,:,:) = weight*series(jj,:,:) + (1-weight)*trend(jj-1,:,:);
        jj            = jj + 1;
    end
    
end
