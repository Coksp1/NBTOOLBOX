function X = nb_spline(X)
% Syntax:
%
% X = nb_spline(X)
%
% Description:
%
% Fill in for in-sample missing values of a time-series using cubic 
% spline.
% 
% Input:
% 
% - X : A T x 1 double storing the data of the time-series.
%
% Output:
% 
% - X : A T x 1 double storing the balanced dataset of the time-series.
%
% See also:
% nb_ts.rebalance
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [T,N] = size(X);
    if N > 1
        error([mfilename ':: This method only handle scalar time-series.'])
    end
    
    % Check for leading and trailing nans
    isNaN = isnan(X);
    if ~any(isNaN)
        return
    end
    firstRealObs = find(~isNaN,1,'first');
    lastRealObs  = find(~isNaN,1,'last');
    if lastRealObs > T
        lastRealObs = T;
    end

    % Spline the missing observations in the middle of the same,
    % e.g. for low frequency variables
    midSample    = firstRealObs:lastRealObs;
    X(midSample) = spline(find(~isNaN),X(~isNaN),midSample');


end
