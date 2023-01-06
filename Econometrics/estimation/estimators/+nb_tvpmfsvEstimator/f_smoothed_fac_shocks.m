function [eps_f_sm] = f_smoothed_fac_shocks(priors, f_sm, beta_sm)
% Syntax:
%
% [eps_f_sm] = nb_tvpmfsvEstimator.f_smoothed_fac_shocks(priors, f_sm, beta_sm)
%
% Description:
%
% This function backs out the residuals of the factor state equation based
% on the smoothed factors and smoothed beta (factor VAR) coeffcients. 
% 
% Input:
% 
% - priors  : A struct, see the nb_tvpmfsvEstimator.getPriors function.
% - f_sm    : The smoothed factor estimates
% - beta_am : the reordered smoothed estimates of the VAR
%             coefficients (Companion form)
% 
% Output:
% 
% - eps_f_sm : A matrix containing the "smoothed" residuals of the factor
%              state equation. The rows identify the factors, the columns
%              identify the time dimension. 
%
%
% See also:
% nb_tvpmfsvEstimator.print, nb_tvpmfsvEstimator.help, 
% nb_tvpmfsvEstimator.template
%
% Written by Maximilian Schröder

% Copyright (c)  2021, Norges Bank
    
    % compute the dimensions of the system 
    lags_f = priors.nLags;
    n_f    = size(beta_sm,2)/lags_f;
    T = size(f_sm, 2);
    k = size(f_sm, 1);

    % initialize the matrix of factor predictions
    f_hat = zeros(k,T);

    % for each time period compute the prediction of the smoothed factors
    for t=2:T
       f_hat(:,t) =  beta_sm(:,:,t-1)*f_sm(:,t-1);
    end
    
    % compute the residual/prediction error
    eps_f_sm = f_sm(1:n_f,:)-f_hat(1:n_f,:);

end

