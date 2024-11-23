function [residual,residualStripped] = estimateCovidAdjResidual(options,y,X,beta)
% Syntax:
%
% [residual,residualStripped] = nb_bVarEstimator.estimateCovidAdjResidual(...
%       options,yObs,X,beta)
%
% Description:
%
% Calculate residual when covidAdj options is used to stripp observations
% from the estimation problem.
%
% See also:
% nb_bVarEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    T = size(X,1);
    if options.time_trend
        trend = 1:T;
        X     = [trend', X];
    end
    if options.constant        
        X = [ones(T,1), X];
    end

    indCovid         = nb_estimator.applyCovidFilter(options,y);
    residual         = y - X*beta;
    residualStripped = y(indCovid,:) - X(indCovid,:)*beta;

end
