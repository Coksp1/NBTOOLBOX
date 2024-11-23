function [pval,ci,dist] = testParameters(obj,expression,method,draws,alpha,type)
% Syntax:
%
% dist = testParameters(obj, expression, draws, method)
%
% Description:
%
% Test (non-)linear expression by using bootstrapping (classical) or 
% posterior draws.
%
% Caution (classical only): This method uses that stdBeta is known. 
%                           This is the same as using that the t-statistic
%                           is normally distributed when stdBeta is known.
% 
% Hint                    : The parameter name can be found by 
%                           obj.parameters.name!
%
% Input:
% 
% - obj        : A scalar solved nb_model_generic object. 
% 
% - expression : A MATLAB expression as a string. Use parameter names as
%                variables. See model.parameters.name.
%
% - method     : A string with the method to use. For bootstrap method see
%                nb_bootstrap. For bayesian models 'posterior' is the only 
%                option. Default is 'bootstrap' for classical models, while
%                'posterior' is the default for bayesian models.
%
% - draws      : Number of draws from the parameter distribution. Default 
%                is 1000.
% 
% - alpha      : Confidence level. Default is 0.05.
%
% - type       : Type of test:
%                > '=' : Two sided test. expression == 0 (default)
%                        For two-sided tests it is assumed thath the
%                        distribution is symmetric! Use
%                        confidenc/probabillity intervals instead.
%                > '>' : One sided test. expression > 0
%                > '<' : One sided test. expression < 0
%
% Output:
%
% - pval       : > 'classical' : P-value of test.
%                > 'bayesian'  : Probabilty of test.
%
%                A 1x1 double.
%
% - ci         : A 1 x 2 double with the lower and upper bound of the
%               confidence/probabillty interval of the tested expression.
%
% - dist       : A nb_distribution object storing the distribution of the
%                tested expression.
%
% Example:
%
% dist = obj.testParameters('Parameter1 - Parameter2');
%
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        type = '=';
        if nargin < 5
            alpha = 0.05;
            if nargin < 4
                draws = [];
                if nargin < 3
                    method = '';
                end
            end
        end
    end

    % This has shape nPar x nEq x nDraws
    data = obj.parameterDraws(draws, method);
    data = data.beta;
    
    % nb_eval expects nObs x nParameters
    data     = reshape(data, size(data, 1)*size(data, 2), size(data, 3))';   
    distData = nb_eval(expression, obj.parameters.name, data);
    
    % sim2KernelDist expects nHor x nVar x nDraws
    distData = reshape(distData, 1, 1, length(distData));    
    dist     = nb_distribution.sim2KernelDist(distData);
    dist.set('name', expression);
    
    % P-value
    switch type
        case '='
            pval = 2*cdf(dist,0); % Assumes symmetric distribution!
        case '>'
            pval = cdf(dist,0);
        case '<'
            pval = 1-cdf(dist,0);
        otherwise
            error([mfilename ':: Unsupported test type ' type])
    end
    
    % Confidence/probability interval
    if nargout > 1
        ci = icdf(dist,[alpha/2;1-alpha/2]);  % Does not assume symmetric distribution!
        ci = ci';
    end
    
end
