function [objective,beta,sigma,lb,ub] = getObjective(obj)
% Syntax:
%
% [objective,beta,sigma,lb,ub] = getObjective(obj)
%
% Description:
%
% Get objective for doing sampling from the posterior distribution of an
% estimated DSGE model. This is what is being minimized.
% 
% Input:
% 
% - obj : An object of class nb_dsge.
% 
% Output:
% 
% - objective : A function handle calculating the objective function that
%               where maximized.
%
% - beta      : A nParam x 1 double with the values of all the parameters
%               of the model.
%
% - sigma     : Covariance matrix of the estimated parameters at the mode.
%
% - lb        : Lower bound of the support of the estimated parameters, as
%               a nEst x 1 double. 
%
% - lb        : Upper bound of the support of the estimated parameters, as
%               a nEst x 1 double. 
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method is only supported for a scalar nb_dsge object.'])
    end
    if ~isNB(obj)
        error([mfilename ':: The model must be solved with the NB Toolbox to be able to get the objective.'])
    end
    if nb_isempty(obj.results)
        error([mfilename ':: The model is not estimated.'])
    end
    if isempty(obj.results.omega)
        error([mfilename ':: The model is not estimated.'])
    end
    [fh,estStruct,lb,ub] = nb_dsge.getObjectiveForEstimation(obj.estOptions);
    beta                 = estStruct.beta;
    objective            = @(x)fh(x,estStruct);
    sigma                = obj.results.omega;
    
end
