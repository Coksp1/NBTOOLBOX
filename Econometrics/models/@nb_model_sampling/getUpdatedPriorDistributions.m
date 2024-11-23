function [distr,paramNames] = getUpdatedPriorDistributions(obj,varargin)
% Syntax:
%
% distr              = getUpdatedPriorDistributions(obj)
% [distr,paramNames] = getUpdatedPriorDistributions(obj,'draws',1000)
%
% Description:
%
% Get the updated prior distributions of model. Only from the first chain.
% 
% Input:
% 
% - obj        : An object of class nb_model_sampling. 
% 
% Optitonal input:
%
% - 'draws'    : The number of draws to sample from the updated prior to  
%                base the kernel estimation on, if empty or not provided 
%                all draws are used for estimation.
%
% Output:
% 
% - distr      : A 1 x numCoeff nb_distribution object.
%
% - paramNames : A 1 x numCoeff cellstr with the names of the parameters.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
       error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if ~isbayesian(obj)
        error([mfilename ':: The selected object is not using bayesian methods, so no updated priors to fetch.'])
    end
    
    if isempty(obj.systemPriorPath)
        error([mfilename ':: Error no sampling of the updated priors has been done.'])
    end
    draws  = nb_parseOneOptional('draws',[],varargin{:});
    output = nb_loadDraws(obj.systemPriorPath);
    beta   = permute(output(1).beta,[2,3,1]);
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
    
    % Get the names of the parameters
    paramNames = obj.options.prior(:,1)';
    
end
