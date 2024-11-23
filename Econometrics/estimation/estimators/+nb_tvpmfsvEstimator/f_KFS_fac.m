function [f_sm,H_t,ef_t,var_f_sm] = f_KFS_fac(options,priors,XY,lambda_sm,beta_sm,Q_t_sm,V_t_sm)
% Syntax:
%
% [f_sm,H_t,ef_t,var_f_sm] = nb_tvpmfsvEstimator.f_KFS_fac(prior,XY,...
%                   lambda_sm,beta_sm,Q_t_sm,V_t_sm)
%
% Description:
%
% This function is greatly inspired by Koop and Korobilis (2014) and 
% adapted to the TVP-MF-DFM framework as described in the paper by 
% Schroder and Eraslan (2021), "Nowcasting GDP with a large factor model 
% space".
%
% The purpose of this function is to estimate the factors conditional on
% the parameter estimates obtained from 
% nb_tvpmfsvEstimator.f_KFS_params. 
% 
% Input:
% 
% - priors    : A struct, see the nb_tvpmfsvEstimator.getPriors function.
% - XY        : The data on the observed variables.
% - lambda_sm : The smoothed factor loadings estimates
% - beta_sm   : The smmothed VAR parameter estimates  
% - Q_t_sm    : The smoothed Q_t estimates
% - V_t_sm    : The smoothed V_t estimates
% 
% Output:
% 
% - f_sm     : The smoothed factor estimates
% - H_t      : The state-space matrix "H_t" containing all loadings (with 
%              aggregation scheme) 
% - ef_t     : Measurement error.
% - var_f_sm : Smoothed estimates of the one-step-ahead forecast error 
%              variance.
%
% See also:
% nb_tvpmfsvEstimator.normalEstimation, 
% nb_tvpmfsvEstimator.recursiveEstimation
%
% Written by Maximilian Schröder
% Edited by Kenneth Sæterhagen Paulsen
% - Formated the documentation to fit NB toolbox
% - Changed inputs. Many of them are now calculated inside function
%   instead.
% - Returned the smoothed estimates of the one-step-ahead forecast error 
%   variance.

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    lags_f = priors.nLags;
    T      = size(XY,1);
    n_f    = size(beta_sm,2)/lags_f;
    n      = size(XY,2);
    k      = lags_f*n_f;
    
    % Get the priors
    %====================
    f_0 = priors.f_0;
    agg = priors.agg;
    n_m = priors.n_m;
    n_q = priors.n_q;

    % Initialize the State Space and the Kalman Filter
    %=================================================

    % Initialize matrices
    f_t       = zeros(k,T);
    f_tt      = zeros(k,T);
    var_f_t   = zeros(k,k,T);
    var_f_tt  = zeros(k,k,T);
    y_t_predf = zeros(T,n);
    ef_t      = zeros(n,T);
     
    % display warnings in case the of dimension mismatch and compose the
    % state-space loadings matrix
    if n_q == 0
        H_t = [lambda_sm, zeros(n_m,(lags_f-1)*n_f,T)]; 
    else
        if lags_f >= size(agg,2)
            as = size(agg,2)*n_f;
            if options.class == "nb_mfvar"
                % need to adjust the "loadings matrix in the MF-VAR case"
                H_t                = zeros(n,lags_f*n_f,T);
                H_t(1:n_m,1:n_f,:) = lambda_sm(1:n_m,:,:);
                if any(options.indObservedOnly) && ~isempty(options.mixing)
                    % MF-VAR with mixing
                    indObsCtr = 1;
                    for ii = 1:n_q
                        ind = zeros(1,n-sum(options.indObservedOnly));
                        if options.indObservedOnly(n_m + ii)
                            ind(options.mixingSettings.loc(indObsCtr)) = 1;
                            indObsCtr = indObsCtr + 1;
                        else
                            ind(n_m + ii) = 1;
                        end
                        map                = kron(agg(ii,:),ind);
                        H_t(n_m+ii,1:as,:) = map(:,:,ones(1,T));
                    end
                else
                    % MF-VAR without mixing
                    for ii = 1:n_q
                        ind                = zeros(1,n);
                        ind(n_m + ii)      = 1;
                        map                = kron(agg(ii,:),ind);
                        H_t(n_m+ii,1:as,:) = map(:,:,ones(1,T)); 
                    end 
                end
            else
                H_t                = zeros(n,lags_f*n_f,T);
                H_t(1:n_m,1:n_f,:) = lambda_sm(1:n_m,:,:);
                for ii = 1:n_q
                    for t = 1:T 
                        H_t(n_m+ii,1:as,t) = kron(agg(ii,:),lambda_sm(n_m+ii,:,t));
                    end
                end 
            end
        else
            error(['Given the aggregation scheme, at least four lags of the factors are required! Set "nLags" >= ' int2str(size(agg,2))])
        end
    end

    % find the index of non-missing values
    idx = ~isnan(XY(:,:)'); 

    % build auxilliary selection matrices that set the elements of V_t and H_t
    % equal to zero in case of missing observations.
    V_t_miss = V_t_sm;
    H_t_miss = H_t;
    for t = 1:T
        V_t_aux         = diag(V_t_sm(:,:,t));
        id_v            = idx(:,t) == 0;
        V_t_aux(id_v)   = 1;
        V_t_miss(:,:,t) = diag(V_t_aux); 
        id_ht           = kron(ones(1,size(f_t+1,1)),idx(:,t));
        H_t_miss(:,:,t) = H_t(:,:,t).*id_ht; 
    end

    % set the missing observations in all series at time t equal to zero.
    % Together with the respective elements in V_t and H_t being set equal to
    % zero, this will induce the Kalman filter to disregard the information of 
    % the missing series. Then they no longer contribute to the new estimate of 
    % the factors and their variance. 
    XY_miss            = XY;
    XY_miss(isnan(XY)) = 0;

    % Run the Kalman Filter
    %======================

    for t = 1:T
        % Update the factors conditional on the parameter estimates 

        % Kalman predict step for f
        if t==1
            f_t(:,t)       = f_0.mean;         
            var_f_t(:,:,t) = f_0.var;
        elseif t>1
            f_t(:,t)       = beta_sm(:,:,t-1)*f_tt(:,t-1);
            var_f_t(:,:,t) = beta_sm(:,:,t-1)*var_f_tt(:,:,t-1)*beta_sm(:,:,t-1)' + [Q_t_sm(:,:,t) zeros(n_f,n_f*(lags_f-1)); zeros(n_f*(lags_f-1),n_f*lags_f)];
        end

        % One step ahead prediction based on Kalman factor
        y_t_predf(t,:) = H_t_miss(:,:,t)*f_t(1:k,t);
        
        % Prediction error
        ef_t(:,t) = XY_miss(t,:)' - y_t_predf(t,:)';

        % Kalman update step for f
        % Update the factors conditional on the estimate of lambda_t and beta_t
        KV_f                = V_t_miss(:,:,t) + H_t_miss(:,:,t)*var_f_t(1:k,1:k,t)*H_t_miss(:,:,t)';
        KG                  = (var_f_t(1:k,1:k,t)*H_t_miss(:,:,t)')/KV_f;
        f_tt(1:k,t)         = f_t(1:k,t) + KG*ef_t(:,t);
        var_f_tt(1:k,1:k,t) = var_f_t(1:k,1:k,t) - KG*(H_t_miss(:,:,t)*var_f_t(1:k,1:k,t)); 

    end   

    % Run the Kalman Smoother
    %========================

    % Kalman smoother
    % Smooth the factor estimates using the Rauch–Tung–Striebel fixed-interval 
    % smoother for the factors  
    f_sm            = zeros(size(f_tt));         
    var_f_sm        = zeros(size(var_f_tt));
    f_sm(:,T)       = f_tt(:,T);  
    var_f_sm(:,:,T) = var_f_tt(:,:,T);
    for t = T-1:-1:1
        Z_t                 = (var_f_tt(:,:,t)*beta_sm(:,:,t)');
        U_t                 = squeeze(Z_t(1:k,1:k)/var_f_t(1:k,1:k,t+1));   
        f_sm(1:k,t)         = f_tt(1:k,t) + U_t*(f_sm(1:k,t+1) - f_t(1:k,t+1));
        var_f_sm(1:k,1:k,t) = var_f_tt(1:k,1:k,t) + U_t*(var_f_sm(1:k,1:k,t+1) - var_f_t(1:k,1:k,t+1))*U_t'; 
    end 

end

