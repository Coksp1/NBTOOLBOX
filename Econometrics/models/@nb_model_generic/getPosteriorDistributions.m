function [distr,paramNames] = getPosteriorDistributions(obj,varargin)
% Syntax:
%
% distr              = getPosteriorDistributions(obj)
% [distr,paramNames] = getPosteriorDistributions(obj,'draws',1000)
%
% Description:
%
% Get posterior distributions of model.
% 
% Input:
% 
% - obj        : An object of class nb_model_generic. 
% 
% Optitonal input:
%
% - 'draws'    : The number of draws to sample from the posterior to base 
%                the kernel estimation on, if empty all draws are used for 
%                estimation.
%
% Output:
% 
% - distr      : A 1 x numCoeff nb_distribution object.
%
% - paramNames : A 1 x numCoeff cellstr with the names of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if ~isestimated(obj)
        error([mfilename ':: Model must be estimated.']) 
    end
       
    if ~isbayesian(obj)
        error([mfilename ':: Model must be estimated with bayesian methods.'])
    end
    
    draws     = nb_parseOneOptional('draws',[],varargin{:}); 
    estOpt    = obj.estOptions;
    posterior = nb_loadDraws(estOpt.pathToSave);
    beta      = posterior.betaD;
    if ~isempty(draws) && draws < size(beta,3)
        
        defaultStream = RandStream.getGlobalStream;
        savedState    = defaultStream.State;
        s             = RandStream.create('mt19937ar','seed',1);
        RandStream.setGlobalStream(s);
        
        ind  = randperm(size(beta,3));
        ind  = ind(1:draws);
        beta = beta(:,:,ind);
        
        defaultStream.State = savedState;
        RandStream.setGlobalStream(defaultStream);
        
    end
    distr = nb_distribution.sim2KernelDist(beta);%,posterior.options.lb,posterior.options.ub
    distr = distr(:)';
    
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
