function [options,results] = wrapUpEstimation(options,results,estimator,estimType,y,tStart)
% Syntax:
%
% [options,results] = wrapUpEstimation(options,results,estimator,...
%   estimType,y,tStart)
%
% Description:
%
% Wrap up estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Correct estimation results for unbalanced nb_sa models
    if options.unbalanced 
        [results,options] = nb_estimator.correctResultsGivenUnbalanced(options,results);
    end
    
    % Secure that all lags of the solution is in the data!
    if isempty(options.estim_types) && strcmpi(options.class,'nb_singleEq') % Time-series
        options = nb_olsEstimator.secureAllLags(options);
    end
    
    % Assign generic results
    results.includedObservations = size(y,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign metadata
    options.estimator = estimator;
    options.estimType = estimType;

end
