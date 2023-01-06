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
% - obj        : An object of class nb_model_recursive_detrending. 
% 
% Output:
% 
% - distr      : A nPeriods x numCoeff nb_distribution object.
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
    nParam = size(obj.modelIter(1).results.beta,2);
    
    distr(length(obj.modelIter),nParam) = nb_distribution;
    for tt = 1:length(obj.modelIter)
        [distr(tt,:),paramNames] = getPosteriorDistributions(obj.modelIter(tt));
    end
                  
end
