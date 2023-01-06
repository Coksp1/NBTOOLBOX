function fval = objective(par,~,~,~,options,y,z,~)
% Syntax:
%
% fval = nb_mfvar.objective(par,indPar,beta,modelInfo,options,y,...
%                           observables)
%
% Description:
%
% The objective to minimize when doing estimation of a mixed frequency
% VAR.
% 
% Input:
% 
% - par         : Current vector of the estimated parameters.
%
% - indPar      : Not needed. Just for generics.
%
% - beta        : Not needed. Just for generics.
%
% - model       : Not needed. Just for generics.
%
% - options     : The obj.estOptions property of the nb_dsge class.
%                 (After calling getEstimationOptions, i.e. calling the 
%                 estimate method.)
%
% - y           : A nObservables x nPeriods double with the data to 
%                 estimate the model on. The data may contain missing 
%                 observations. 
%
% - z           : A nExo x nPeriods double with the data of the exogenous
%                 variables of the model.
%
% - observables : Not needed. Just for generics.
% 
% 
% Output:
% 
% - fval : Value of the objective at the given parameters.
%
% See also:
% nb_mfvar.stateSpace, nb_kalmanlikelihood_missing, 
% nb_model_generic.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    error('Depricated method')
    
end
