function [yPlus,xPlus] = setUpPriorSC(prior,y,x,lags,constant,timeTrend)
% Syntax:
%
% [yPlus,XPlus] = nb_bVarEstimator.setUpPriorSC(prior,y,x,lags,...
%                       constant,timeTrend)
%
% Description:
%
% Set up artificial series when using a sum-of-coefficients prior by 
% Doan, Litterman, and Sims (1984).
% 
% See also:
% nb_bVarEstimator.applyDummyPrior
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if timeTrend
        error(['If you apply the sum-of-coefficients prior you cannot ',...
            'include a time trend.'])
    end
    if isfield(prior,'mu')
        mu = prior.mu;
    else
        error(['If you apply the sum-of-coefficients prior you need to ',...
            'specify the mu option.'])
    end
    if isempty(mu)
        error(['If you apply the sum-of-coefficients prior you need to ',...
            'set the mu option to a number.'])
    elseif ~nb_isScalarNumber(mu,0)
        error(['If you apply the sum-of-coefficients prior you need to ',...
            'set the mu option to a number greater than 0.'])
    end
    
    % Remove missing observations at the start
    y(any(isnan(y),2),:) = [];
    if isempty(x)
        x(any(isnan(x),2),:) = [];
    end
    
    % Form the artificial data
    n     = size(y,2);
    y0    = mean(y(1:lags,:),1);
    yPlus = diag(y0/mu);
    xPlus = repmat(yPlus,[1,lags]);
    if ~isempty(x)
        xPlus = [repmat(mean(x(1:lags,:),1),[n,1]),xPlus];
    end
    if constant
        xPlus = [zeros(n,1),xPlus];
    end

end
