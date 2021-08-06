function [distr,paramNames] = getPosteriorDistributions(obj)
% Syntax:
%
% [distr,paramNames] = getPosteriorDistributions(obj)
%
% Description:
%
% Get posterior distributions of model.
% 
% Input:
% 
% - obj        : An object of class nb_model_generic. 
% 
% Output:
% 
% - distr      : A 1 x numCoeff nb_distribution object.
%
% - paramNames : A 1 x numCoeff cellstr with the names of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if ~isestimated(obj)
        error([mfilename ':: Model must be estimated.']) 
    end
       
    if ~isbayesian(obj)
        error([mfilename ':: Model must be estimated with bayesian methods.'])
    end
    
    estOpt    = obj.estOptions;
    posterior = nb_loadDraws(estOpt.pathToSave);
    distr     = nb_distribution.sim2KernelDist(posterior.betaD);%,posterior.options.lb,posterior.options.ub
    distr     = distr(:)';
    
    % Get the names of the parameters
    options = obj.estOptions;
    if strcmpi(options.estim_method,'bvar')
        func = @(x)nb_bVarEstimator.getCoeff(x);
    else
        func = str2func(['nb_' lower(options.estim_method) 'Estimator.getCoeff']);
    end
    paramNames = func(options);
    if size(posterior.betaD,2) > 1
        % Robustify for multiple equation models
        dep         = options.dependent;
        paramNamesT = {};
        for ii = 1:length(dep)
            paramNamesT = [paramNamesT, strcat(dep{ii},'_',paramNames)]; %#ok<AGROW>
        end
        paramNames = paramNamesT;
    end
              
end
