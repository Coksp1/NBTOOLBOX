function logLikelihood = nb_olsLikelihood(residual,method,numCoeff)
% Syntax:
%
% logLikelihood = nb_olsLikelihood(residual)
% logLikelihood = nb_olsLikelihood(residual,method,numCoeff)
%
% Description:
%
% Calculate the log likelihood of an ols regression based on the
% residuals.
% 
% Input:
% 
% - residual : The residuals from the ols regression. As a 
%              nobs x neqs double. The equations must be unrelated
%              or have the same regressors.
%
% - method   : Either 'full' (full likelihood of the system) or 
%              'single' (individually likelihood calculations).
%
%              - 'single' : Uses the equation (24.9) in EViews 6 User's
%                           Guide 2
%
%              - 'full'   : Uses the equation (34.4) in EViews 6 User's
%                           Guide 2
% 
% Output:
% 
% - logLikelihood : The log likelihood of the ols regression. 
%                   As a 1 x neqs double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        numCoeff = 0;
        if nargin < 2
            method = 'single';
        end
    end

    T = size(residual,1);
    if strcmpi(method,'full')
        
        nvar          = size(residual,2);
        resSquared    = residual'*residual;
        SIGMA         = resSquared/(T-numCoeff);
        detSIGMA      = det(SIGMA);
        logLikelihood = -0.5*T*(nvar*(1 + log(2*pi)) + log(detSIGMA));
        
    else
        var           = (diag(residual'*residual)')./T;
        logLikelihood = -0.5*T*(1 + log(2*pi) + log(var));
    end
    
end
