function [obj,ci,dist] = calculateStandardError(obj,method,draws,alpha)
% Syntax:
%
% obj = calculateStandardError(obj,method,draws)
%
% Description:
%
% Calculate standrard errors by bootstrap (classical) or posterior draws 
% (bayesian).
% 
% Caution (classical only): This method uses that stdBeta is known. 
%                           This is the same as using that the t-statistic
%                           is normally distributed when stdBeta is known.                         
%
% Input:
% 
% - obj    : A scalar nb_model_generic object
%
% - method : A string with the method to use. For bootstrap method see
%            nb_bootstrap. For bayesian models 'posterior' is the only 
%            option. Default is 'bootstrap' for classical models, while
%            'posterior' is the default for bayesian models.
%
% - draws  : Number of draws from the parameter distribution. Default is
%            1000.
% 
% - alpha  : Confidence level. Default is 0.05.
%
% Output:
% 
% - obj    : A scalar nb_model_generic object, where the results property
%            is updated with the bootstraped standrard errors.
%
%            Extra outputs (all based on bootstrapped draws):
%
%            - stdBeta     : Standard deviation of coefficient of the
%                            main equation.
%
%            - tStatBeta   : T-statistic for the coefficient of the
%                            main equation.
%
%            - pValBeta    : Calculated P-value based on a kernel
%                            density estimator of the paramter 
%                            distribution. Two-sided test against the 
%                            null hypothesis of the parameters being 0.
%
%            - stdLambda   : Standard deviation of coefficient of the
%                            observation equation.
%
%            - tStatLambda : T-statistic for the coefficient of the
%                            observation equation.
%
%            - pValLambda  : Calculated P-value based on a kernel
%                            density estimator of the paramter 
%                            distribution. Two-sided test against the 
%                            null hypothesis of the parameters being 0.
%
% - ci     : Confidence interval/probability interval calculated based on 
%            a kernel density estimation instead of assuming asymptotic  
%            normal distribution. Only for the parameter in beta! As a 
%            (nCoeff * nEq) + 1 x 3 cell array. 
%
% - dist   : Estimated distribution of the coefficients of the main
%            equation. As a (nCoeff * nEq) x 1 nb_distribution object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        alpha = 0.05;
        if nargin < 3
            draws = [];
            if nargin < 2
                method = '';
            end
        end
    end

    if numel(obj) > 1
        error([mfilename ':: This function only support scalar nb_model_generic object'])
    end
    
    if ~isestimated(obj)
        error([mfilename ':: The model must be estimated.'])
    end
    
    if obj.estOptions.recursive_estim
        error([mfilename ':: This function is not supported for recursivly estimated models'])
    end
    
    % This has shape nPar x nEq x nDraws
    out  = obj.parameterDraws(draws, method);
    beta = out.beta;
    if isa(obj,'nb_factor_model_generic')
        lambda = out.lambda;
    end
      
    % Calculate confidence/probabilty intervals
    betaDist = nb_distribution.sim2KernelDist(beta);
    betaDist = betaDist(:);
    dist     = betaDist;
    
    % Calculate standard errors of estimated parameters
    [N,E,~]             = size(beta);
    obj.results.stdBeta = std(beta,0,3);

    % T-statistics
    betaStacked           = obj.results.beta(:);
    stdBetaStacked        = obj.results.stdBeta(:);
    tStatBetaStacked      = betaStacked./stdBetaStacked;
    obj.results.tStatBeta = reshape(tStatBetaStacked,N,E);

    % P-value
    pValBetaStacked = tStatBetaStacked;
    for ii = 1:length(pValBetaStacked)
        pValBetaStacked(ii) = 2*cdf(betaDist(ii),0);
    end
    obj.results.pValBeta = reshape(pValBetaStacked,N,E);
    
    % Calculate standard errors of estimated parameters of the observation
    % equation
    if isa(obj,'nb_factor_model_generic')
        
        [N,E,~]                 = size(lambda);
        obj.results.stdLambda   = std(lambda,3);
        lambdaStacked           = obj.results.beta(:);
        stdLambdaStacked        = obj.results.stdBeta(:);
        tStatLambdaStacked      = lambdaStacked./stdLambdaStacked;
        obj.results.tStatLambda = reshape(tStatLambdaStacked,N,E);
        
        % Calculate confidence/probabilty intervals
        lambdaDist        = nb_distribution.sim2KernelDist(lambda);
        lambdaDist        = lambdaDist(:);
        pValLambdaStacked = tStatLambdaStacked;
        for ii = 1:length(pValLambdaStacked)
            pValLambdaStacked(ii) = 2*cdf(lambdaDist(ii),0);
        end
        obj.results.pValLambda = reshape(pValLambdaStacked,N,E);
        
    end
    
    obj.results.standardErrorMethod = method;
    
    if nargout > 1
        
        parNames = obj.parameters.name;
        ci       = icdf(betaDist,[alpha/2;1-alpha/2]);
        ci       = ci';
        ci       = [parNames(1:N*E),num2cell(ci)];
        ci       = [{'Coefficient','Lower','Upper'};ci];
        
    end

end
