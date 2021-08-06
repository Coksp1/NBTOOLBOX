function fval = systemPriorObjective(par,estStruct)
% Syntax:
%
% fval = nb_dsge.systemPriorObjective(par,estStruct)
%
% Description:
%
% The objective to sample from to get the final prior distribution which 
% also takes into account the system priors.
% 
% Input:
% 
% - par         : Current vector of the estimated parameters.
%
% - estStruct   : A struct with at least the following fields;
%
%     > indPar      : Index for where in the full parameter vector to find 
%                     the estimated parameters.
% 
%     > beta        : A vector of the values of all parameters. As a 
%                     nParam x 1.
% 
%     > model       : The obj.parser property of the nb_dsge class.
% 
%     > options     : The obj.estOptions property of the nb_dsge class.
%                     (After calling getEstimationOptions, i.e. calling  
%                     the estimate method.)
% 
%     > y           : A nObservables x nPeriods double with the data to 
%                     estimate the model on. The data may contain missing 
%                     observations. 
% 
%     > z           : Not in use. To make it generic to other classes of 
%                     models.
% 
%     > observables : A logical vector. An element is true if the variable  
%                     is observable.
% 
% 
% Output:
% 
% - fval : Value of minus the log system prior at the given parameters.
%
% See also:
% nb_model_sampling.sampleSystemPrior
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Calculate minus the log likelihood
    if estStruct.filterType == 1
        sol = nb_dsge.stateSpace(par,estStruct);
    elseif estStruct.filterType == 2
        sol = nb_dsge.stateSpaceBreakPoint(par,estStruct);
    else
        sol = nb_dsge.stateSpaceTVP(par,estStruct);
    end
    
    if ~isempty(sol.err)
        % Solving failed
        fval = -1e10;
        return
    end
    
    % Are we doing bayesian?
    if ~nb_isempty(estStruct.options.prior)
    
        % Calculate the prior density
        fval = nb_model_generic.evaluatePrior(estStruct.options.prior,par);

        % Have the user supplied some system priors?
        if ~isempty(estStruct.options.systemPrior)
            % estStruct.options.systemPrior is a function_handle that
            % returns the log of the system prior
            sol  = rmfield(sol,'options'); % Remove the confusion that may occure as options may stores ss and states as well!
            fval = (fval + estStruct.options.systemPrior(estStruct.options.parser,sol));
        end
        
    end
    
end
