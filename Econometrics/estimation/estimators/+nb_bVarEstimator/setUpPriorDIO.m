function [yPlus,xPlus] = setUpPriorDIO(prior,y,x,lags,constant,timeTrend)
% Syntax:
%
% [yPlus,XPlus] = nb_bVarEstimator.setUpPriorDIO(prior,y,x,lags,...
%                       constant,timeTrend)
%
% Description:
%
% Set up artificial series when using a dummy-initial-observation prior by 
% Sims (1993).
% 
% See also:
% nb_bVarEstimator.applyDummyPrior
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if timeTrend
        error(['If you apply the dummy-initial-observation prior you ',...
            'cannot include a time trend.'])
    end
    if isfield(prior,'delta')
        delta = prior.delta;
    else
        error(['If you apply the dummy-initial-observation prior you ',...
            'need to specify the delta option.'])
    end
    if isempty(delta)
        error(['If you apply the dummy-initial-observation prior you ',...
            'need to set the delta option to a number.'])
    elseif ~nb_isScalarNumber(delta,0)
        error(['If you apply the dummy-initial-observation prior you ',...
            'need to set the delta option to a number greater than 0.'])
    end
    
    % Remove missing observations at the start
    y(any(isnan(y),2),:) = [];
    if isempty(x)
        x(any(isnan(x),2),:) = [];
    end
    
    % Form the artificial data
    y0    = mean(y(1:lags,:),1);
    yPlus = y0/delta;
    xPlus = repmat(yPlus,[1,lags]);
    if ~isempty(x)
        xPlus = [mean(x(1:lags,:),1),xPlus];
    end
    if constant
        xPlus = [1/delta,xPlus];
    end

end
