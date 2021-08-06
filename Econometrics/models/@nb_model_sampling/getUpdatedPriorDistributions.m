function [distr,paramNames] = getUpdatedPriorDistributions(obj)
% Syntax:
%
% [distr,paramNames] = getUpdatedPriorDistributions(obj)
%
% Description:
%
% Get the updated prior distributions of model. Only from the first chain.
% 
% Input:
% 
% - obj        : An object of class nb_model_sampling. 
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
    
    if ~isbayesian(obj)
        error([mfilename ':: The selected object is not using bayesian methods, so no updated priors to fetch.'])
    end
    
    if isempty(obj.systemPriorPath)
        error([mfilename ':: Error no sampling of the updated priors has been done.'])
    end
    output  = nb_loadDraws(obj.systemPriorPath);
    randInd = ceil(output(1).draws*rand(1000,1)); 
    beta    = output(1).beta(randInd,:); % Only keep 1000 of the draws
    distr   = nb_distribution.sim2KernelDist(permute(beta,[2,3,1]));%,posterior.options.lb,posterior.options.ub
    
    % Get the names of the parameters
    paramNames = obj.options.prior(:,1)';
    
end
