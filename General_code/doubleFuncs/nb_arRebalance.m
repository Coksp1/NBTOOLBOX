function X = nb_arRebalance(X)
% Syntax:
%
% X = nb_arRebalance(X)
%
% Description:
%
% Fill in for leading and trailing nan values using a AR(1) with automatic
% selection of the level of integration of the series.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [~,N] = size(X);
    if N > 1
        error([mfilename ':: This method only handle scalar time-series.'])
    end

    isNaN= isnan(X);
    if ~any(isNaN)
        return
    end
    firstRealObs = find(~isNaN,1,'first');
    lastRealObs  = find(~isNaN,1,'last');
    if lastRealObs > size(X,1)
        lastRealObs = size(X,1);
    end 
    X = backAndForcastMissing(X,firstRealObs,lastRealObs);
        
end

%==========================================================================
function xi = backAndForcastMissing(xi,firstRealObs,lastRealObs)

    % Estimate ARIMA model
    xMid = xi(firstRealObs:lastRealObs);
    if any(~isnan(xMid)) && firstRealObs ==  1 && lastRealObs == size(xi,1)
        % No missing values to fill in
        return
    end
    try
        res = nb_arimaFunc(xMid,1,nan,0,0,0,'criterion','aic');
    catch
        res = nb_arimaFunc(xMid,1,1,0,0,0,'criterion','aic');
    end
    
    % Get the companion form
    if res.AR > 0
        A   = [res.beta(2:end)';
               eye(res.AR-1),zeros(res.AR-1,1)];
    else
        A = 0;
    end
    
    % Difference the data
    xiTemp = xMid(:,ones(1,res.i+1));
    for ii = 1:res.i
        xiTemp(2:end,ii+1) = diff(xiTemp(:,ii));
        xiTemp(1,ii+1)     = nan;
    end
    
    % Backcast leading nans
    if firstRealObs > 1
        nBcst    = firstRealObs - 1;
        backcast = nan(nBcst,1);
        x0       = xiTemp(res.i + 1:res.i + res.AR,end);
        for ii = nBcst:-1:1
           x0           = A*x0;
           backcast(ii) = x0(1);
        end
    else
        nBcst    = 0;
        backcast = nan(0,1);
    end
    
    % Forecast trailing nans
    if lastRealObs < size(xi,1)
        nFcst    = size(xi,1) - lastRealObs;
        forecast = nan(nFcst,1);
        x0       = xiTemp(end:-1:end - res.AR + 1,end);
        for ii = 1:nFcst
           x0           = A*x0;
           forecast(ii) = x0(1);
        end
    else
        nFcst    = 0;
        forecast = nan(0,1);
    end
    
    if res.i > 0
        
        for ii = 1:res.i
        
            % Put backcast into level
            bactL      = nan(nBcst+1,1);
            bactL(end) = xiTemp(res.i,res.i + 1 - ii);
            for ll = nBcst:-1:1
                bactL(ll) = bactL(ll+1) - backcast(ll);
            end
            backcast = bactL(1:end-1);

            % Put forecast into level
            fcstL    = nan(nFcst+1,1);
            fcstL(1) = xiTemp(end,res.i + 1 - ii);
            for hh = 2:nFcst+1
                fcstL(hh) = fcstL(hh-1) + forecast(hh-1);
            end
            forecast = fcstL(2:end);
            
        end
    
    end
    
    % Fill in for leading and trailing missing observations
    xi(1:firstRealObs-1)  = backcast;
    xi(lastRealObs+1:end) = forecast;
    
end
