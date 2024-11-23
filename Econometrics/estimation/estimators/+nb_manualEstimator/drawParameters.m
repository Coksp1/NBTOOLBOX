function [betaDraws,sigmaDraws,yD,pD] = drawParameters(results,options,draws,iter)
% Syntax:
%
% [betaDraws,sigmaDraws,yD,pD] = nb_manualEstimator.drawParameters(results,...
%       options,draws,iter)
%
% Description:
%
% Draw parameters using a manually provided function. For an example of the
% use of this function see nb_forecast.densityPosterior.
%
% The output yD and pD need only be provided if the option is set to true.
% In this case these are provided to the 
% nb_forecast.drawNowcastFromKalmanFilter function.
%
% Input:
%
% - results    : The results output provided by nb_manualEstimator.estimate
%
% - options    : The options output provided by nb_manualEstimator.estimate
%
% - draws      : The number of draws to make from the parameter
%                distribution.
%
% - iter       : The recursive index, i.e. when model is estimated
%                recursivly, this input tells you which iteration of
%                recursive estimation to use. Default is 'end', i.e.
%                last recursion.
%
% Output:
%
% - betaDraws  : A nParam x nEq x draws double with the posterior/
%                boostrapped draws from the distribution of parameters.         
%
% - sigmaDraws : A nEq x nEq x draws double with the posterior/
%                boostrapped draws from the distribution of residual
%                covariance matrix.
%
% - yD         : A T x nEq x draws double with the posterior/
%                boostrapped draws from the distribution of the models
%                dependent variables. E.g. in the case you have a model 
%                with missing observations. Return empty if model does not
%                handle missing observations.
%
% - pD         : nEq x nEq x nNow x draws. nNow is the number of periods
%                missing at the end of the same for any of the variables
%                with missing observations. Return empty if model does not
%                handle missing observations.
%
% Examples:
% nb_mlEstimator.drawParameters, nb_arimaEstimator.drawParameters
%
% See also:
% nb_forecast.densityPosterior, nb_forecast.drawNowcastFromKalmanFilter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        iter = 'end';
    end
    if isempty(options.drawParamFunc)
        error(['You need to provide the drawParamFunc options to draw from ',...
            'the distribution of the parameters for a manually programmed model.'])
    end
    drawFunc                     = str2func(options.drawParamFunc);
    [betaDraws,sigmaDraws,yD,pD] = drawFunc(results,options,draws,iter);
 
end
