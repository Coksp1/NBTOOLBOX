function fval = objective(par,estStruct)
% Syntax:
%
% fval = nb_dsge.objective(par,estStruct)
%
% Description:
%
% The objective to minimize when doing estimation
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
% - fval : Value of the objective at the given parameters.
%
% See also:
% nb_model_generic.estimate, nb_dsge.likelihood
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Calculate minus the log likelihood
    [fval,sol] = nb_dsge.likelihood(par,estStruct);
    if fval > 9.9e9
        % Kalman filter or solving failed
        if estStruct.estim_verbose
           disp('Failed to evaluate the likelihood.') 
        end
        return
    end
    
    % Are we doing bayesian?
    if ~nb_isempty(estStruct.options.prior)
    
        % Calculate the prior density
        logPriorDensity = nb_model_generic.evaluatePrior(estStruct.options.prior,par);
        if logPriorDensity < -9.9e9
            fval = -logPriorDensity;
            if estStruct.estim_verbose
                disp('Failed to evaluate the prior.') 
            end
            return
        end

        % Criteria to minimize
        fval = (fval - logPriorDensity);
        
        % Have the user supplied some system priors?
        if ~isempty(estStruct.options.systemPrior)
            % estStruct.options.systemPrior is a function_handle that
            % returns the log of the system prior
            sol                   = rmfield(sol,'options'); % Remove the confusion that may occure as options may stores ss and states as well!
            logSystemPriorDensity = estStruct.options.systemPrior(estStruct.options.parser,sol);
            if logSystemPriorDensity < -9.9e9
                fval = -logSystemPriorDensity;
                if estStruct.estim_verbose
                    disp('Failed to evaluate the system prior.') 
                end
                return
            end
            fval = (fval - logSystemPriorDensity);
        end
        
    end
    
end
