function [post,lik,prior,sPrior] = curvatureEvaluator(par,estStruct,tol)
% Syntax:
%
% [post,lik,prior,sPrior] = nb_dsge.curvatureEvaluator(par,estStruct,tol)
%
% Description:
%
% Evaluate each part of the posterior.
% 
% Inputs:
%
% - par       : See nb_dsge.objective
%
% - estStruct : See nb_dsge.objective
%
% - tol       : See the 'tolerance' of the nb_dsge.curvature method.
%
% Output:
%
% - post   : Value of minus the log posterior at the given parameters.
%
% - lik    : Value of minus the log likelihood at the given parameters.
%            Will be nan if lik >= tol.
%
% - prior  : Value of minus the log prior at the given parameters. If
%            maximum likelihood estimation is done, this will be 0.
%            Will be nan if prior <= -tol.
%
% - sPrior : Value of minus the log system prior at the given parameters. 
%            If no system priors are used this will be 0. Will be nan if 
%            sPrior <= -tol.
%
% See also:
% nb_dsge.curvature
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Calculate minus the log likelihood
    [lik,sol] = nb_dsge.likelihood(par,estStruct);
    if lik >= tol || imag(lik) > 0
        lik = nan;
    end
    
    % Are we doing bayesian?
    prior  = 0;
    sPrior = 0;
    if ~nb_isempty(estStruct.options.prior)
    
        % Calculate the prior density
        prior = nb_model_generic.evaluatePrior(estStruct.options.prior,par);
        if prior <= -tol || imag(prior) > 0
            prior = nan;
        end

        % Have the user supplied some system priors?
        if ~isempty(estStruct.options.systemPrior)
            % estStruct.options.systemPrior is a function_handle that
            % returns the log of the system prior
            sol = nb_rmfield(sol,'options'); % Remove the confusion that may occure as options may stores ss and states as well!
            if isempty(sol.err)
                sPrior = estStruct.options.systemPrior(estStruct.options.parser,sol);
                if sPrior <= -tol || imag(sPrior) > 0
                    sPrior = nan;
                end
            else
                % If the model is solved with an error return nan
                sPrior = nan;
            end
        end
        
    end
    post = lik - prior - sPrior;

end
