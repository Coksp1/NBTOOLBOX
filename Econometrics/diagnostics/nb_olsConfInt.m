function confInt = nb_olsConfInt(beta,stdBeta,nobs,alpha)
% Syntax:
%
% confInt = nb_olsConfInt(beta,stdBeta,nobs)
%
% Description:
%
% Confidence intervals of estimated parameters.
% 
% Input:
% 
% - beta    : A nvar x 1 double with the estimated parameters.
%
% - stdBeta : A nvar x 1 double with the std of the estimated parameters.
%
% - nobs    : Number of observation of the estimation. As an integer.
%
% - alpha   : The critical value. Default is 0.05.
% 
% Output:
% 
% - confInt  : Confidence intervals. A nvar x 2 matrix. With
%              lower and upper limit.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

% 

    if nargin < 4
        alpha = .05;
    end

    % Confidence intervals
    tcrit   = -nb_distribution.t_icdf(alpha/2,nobs);
    confInt = [beta - tcrit.*stdBeta, beta + tcrit.*stdBeta];

end
