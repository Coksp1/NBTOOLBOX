function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_manualEstimator.estimate(options)
%
% Description:
%
% Estimate a manually programmed model.
%
% Caution: If you want to forecast with this model you need to provide
%          these during estimation. The forecast should be stored to
%          the results output as the fields forecast and start. The
%          forecast field must be 
% 
% Input:
% 
% - options  : A struct on the format given by nb_manualEstimator.template.
%              See also nb_manualEstimator.help.
% 
% Output:
% 
% - result  : A struct with the estimation results. To make it generic to
%             other estimators of the toolbox you should provide the 
%             fields (These field needs to be provied to get automatic
%             print out of estimation results!);
%             > 'beta'  : A nParam x nEq x iter double.
%             > 'sigma' : A nEq x nEq x iter double.
%
%             Here nParam is the number of estimated parameters of the
%             model. nEq is the number of estimated equations. iter is
%             the number of recursively estimated parameters.
%
%             Other optional fields;
%             > 'residual'             : A T x nEq x iter double with the 
%                                        residuals of the model.
%             > 'predicted'            : A T x nEq double with the 
%                                        predicted left-hand side variables 
%                                        of the model. By providing this 
%                                        you will be able to call the 
%                                        nb_model_generic.getResidualGraph 
%                                        method.
%             > 'includedObservations' : The number of observations used 
%                                        for informative printing of
%                                        estimation results.
%
%             If you want your model to provide forecast you need to
%             provide the following fields;
%             > 'forecast'   : A options.nFcstSteps x nVars x draws + 1 x  
%                              iter double. nVars is the number of  
%                              forecasted variables, draws is the number 
%                              of simulations from a density forecast, if
%                              0 a point forecast is assumed. Even if 	 
%                              density forecast is provided, the mean
%                              forecast should be provided as the last
%                              page. iter is the number of recursive
%                              periods that has been forecasted.
%             > 'start'      : A 1 x iter double with the start index
%                              of the forecast. It should be counted as
%                              the number of periods since the start date 
%                              of the data (startD);  
%                              startD + (start(jj) - 1)), 
%                              where jj is the recursive start ind. For a
%                              model that is not recursivly estimated,
%                              start = options.estim_end_ind + 1!
%             > 'forecasted' : A 1 x nVars cellstr with the names of the 
%                              forecasted variables of the model.
%             See the nb_forecast.fetchForecastFromResults function for
%             more one have these forecast are collected during the call
%             to nb_model_generic.forecast.
%
% - options : The return model options. You should provide the following
%             fields during call to the function you provide to the 
%             estimFunc;
%             > 'coeff'     : A 1 x nParam cellstr with the names of the 
%                             estimated parameters.
%             > 'dependent' : A 1 x nEq cellstr with the names of the 
%                             dependent variables of the model. Used by
%                             nb_manualEstimator.getDependent.
%
% See also:
% nb_manualEstimator.print, nb_manualEstimator.help, 
% nb_manualEstimator.template, nb_manualEstimator.getDependent,
% nb_manualEstimator.print, nb_model_generic.getResidualGraph,
% nb_forecast.fetchForecastFromResults
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tStart = tic;
    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
            
    % Estimate model
    if isempty(options.estimFunc)
        error('You need to provide the estimFunc estimate a manually programmed model.')
    end
    estimFunc         = str2func(options.estimFunc);
    [results,options] = estimFunc(options);

    % Check outputs
    if isempty(options.estim_start_ind)
        error('The estim_start_ind cannot be empty after estimation!')
    end
    if isempty(options.estim_end_ind)
        error('The estim_end_ind cannot be empty after estimation!')
    end
    if options.recursive_estim
        if isempty(options.recursive_estim_start_ind)
            error('The recursive_estim_start_ind cannot be empty after recursive estimation!')
        end
    end
    
    % Assign output
    results.elapsedTime = toc(tStart);
    options.estimator   = 'nb_manualEstimator';
    options.estimType   = 'classic';
           
end
