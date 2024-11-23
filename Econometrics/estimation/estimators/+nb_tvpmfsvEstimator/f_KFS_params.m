function [lambda_sm,beta_sm,beta_t_sm,Q_t_sm,V_t_sm,endo_ff] = f_KFS_params(options,priors,f,XY)
% Syntax:
%
% [lambda_sm,beta_sm,beta_t_sm,Q_t_sm,V_t_sm] = 
% nb_tvpmfsvEstimator.f_KFS_params(priors,f,XY)
%
% Description:
%
% This function is greatly inspired by Koop and Korobilis (2014) and 
% adapted to the TVP-MF-DFM framework as described in the paper by 
% Schroder and Eraslan (2021), "Nowcasting GDP with a large factor model 
% space".
% 
% This function estimates the model parameters conditional on the
% preliminary factor estimates.
%
% Input:
% 
% - priors : A struct, see the nb_tvpmfsvEstimator.getPriors function.
% - f      : the preliminary factor estimates 
% - XY     : the data on the observed variables.
% 
% Output:
% 
% - lambda_sm   : the array of smoothed factor loadings estimates
% - beta_sm     : the reordered smoothed estimates of the VAR
%                 coefficients
% - beta_t_sm   : the matrix of smoothed estimate of the VAR 
%                 coefficients
% - Q_t_sm      : the array of smoothed Q_t estimates
% - V_t_sm      : the array of smoothed V_t estimates
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    warning('off','MATLAB:nearlySingularMatrix');

    lags_f = priors.nLags;
    T      = size(XY,1);
    n_f    = size(f,2);
    n      = size(XY,2);
    p      = lags_f*n_f^2;
    k      = lags_f*n_f;
    if options.class == "nb_var" || options.class == "nb_mfvar"
        skipUpdateOfLambda_q = true; 
    else
        skipUpdateOfLambda_q = false; 
    end
    
    % Get the priors
    %====================
    lambda_0 = priors.lambda_0;
    beta_0   = priors.beta_0;
    V_0      = priors.V_0;
    Q_0      = priors.Q_0;
    l_1m     = priors.l_1m;
    l_1q     = priors.l_1q;
    l_2      = priors.l_2; 
    l_3      = priors.l_3;
    l_4      = priors.l_4;
    agg      = priors.agg;
    n_m      = priors.n_m;
    n_q      = priors.n_q;

    % Initialize the endogenous forgetting factors
    % =================================================
    
    l_1min = priors.l_1_lower_bound;
    l_1m = l_1m*ones(1,T);
    l_1q = l_1q*ones(1,T);

    l_2 = l_2*ones(1,T);
    l_2min = priors.l_2_lower_bound;
    q_t = zeros(n_f,T);

    l_3 = l_3*ones(1,T);
    l_3min = priors.l_3_lower_bound;

    l_4 = l_4*ones(1,T);
    l_4min = priors.l_4_lower_bound;
    
    
    % Initialize the State Space and the Kalman Filter
    %=================================================

    % initialize loadings matrices for prediction and update step for monthly
    % indicators
    lambda_t_m  = zeros(n_m,n_f,T);
    lambda_tt_m = zeros(n_m,n_f,T);

    % initialize quarterly loadings, (q+1 for y)
    lambda_t_q  = zeros(n_q,n_f,T);
    lambda_tt_q = zeros(n_q,n_f,T);

    % initialize VAR-coefficients in a vector
    beta_t  = zeros(p,T); 
    beta_tt = zeros(p,T);

    % initialize lamda_it covariance matrices (keep in mind that lambda_i,t is a
    % vector of loadings on the respective factors for time t and variable y
    var_lambda_t_m  = zeros(n_f,n_f,n_m,T);
    var_lambda_tt_m = zeros(n_f,n_f,n_m,T);

    var_lambda_t_q  = zeros(n_f,n_f,n_q,T);
    var_lambda_tt_q = zeros(n_f,n_f,n_q,T);

    % initialize beta_t covariance matrices, which need to match the dimensions of
    % the minnesota prior
    var_beta_t  = zeros(p,p,T);
    var_beta_tt = zeros(p,p,T);

    % Initialize prediction error matrices
    y_hat = zeros(T,n);
    e_t = zeros(n,T);

    % Initialize Covariance matrices
    Q_t = zeros(n_f,n_f,T);                 % constitutes the upper block of the factor
                                            % state equations covariance matrix.
    V_t = zeros(n,n,T);                     % stores the observation equations residual variance

    % Initialize vectors of lagged factors for observation and state equation
    % equation. (1:n_f is f_t n_f+1:end stores the f_lags lags)
    f_lag = nb_lagmatrix(f,0:lags_f);          % stores all lags of the presampled factors
    F_y   = f_lag(lags_f+1:end,1:n_f);        % stores the contemporaneous factor
    F_x   = f_lag(lags_f+1:end,n_f+1:end);    % stores the necessary factor lags

    % create a matrix of variables that acckowledges the structure of the
    % minnesota prior. The matrix reorders the factors' lags similarly to the SUR
    % case
    f_aux = F_x;
    F_aux = nb_tvpmfsvEstimator.f_factor_minnesotastruc(f_aux,lags_f,n_f,T,k,p);

    lambda = zeros(n,n_f,T);    % stores the loadings of all variables (time-varying for monthly data, static for quarterly data)
    beta   = zeros(k,k,T);        % beta is k x k due to companion form

    % Start Kalman Filter recursions
    %===============================
    still_missing_m = true(1,n_m);
    for t = 1:T

        %if t>=60
        %    print('test')
        %end
        % ############### Update & Prediction Equations ###################

        % Update the state equations variance-covariance matrix
        %------------------------------------------------------

        if t == 1 % initialize the prior
            Q_t(:,:,t) = Q_0;
        elseif t > 1

            if t <= lags_f + 1
                % compute the residual variance for first observations given
                % the lag structure
                rvf_t = 0.1*(f(t,:)'*f(t,:));  
            else
                if t>60 
                    l_2(t) = (1-priors.l_2_endo_update)*l_2(t) + priors.l_2_endo_update*min( 1, l_2min + (1-l_2min)*exp(-0.5*(mean(mahal(q_t(:,t-59:t)',q_t(:,t-59:t)').^2)-n_f*(n_f+2))));
                end
                % compute the residual variance of the factor state equation
                q_t(:,t) = (F_y(t-lags_f,:)-F_x(t-lags_f,:)*B(1:n_f,1:k)')';
                rvf_t    = q_t(:,t)*q_t(:,t)';
            end
            
            % Update the EWMA specification for the residual variance with
            % time-varying forgetting factor
            Q_t(:,:,t) = l_2(t)*Q_t(:,:,t-1) + (1-l_2(t)).*rvf_t(1:n_f,1:n_f);

        end
        
        % Predict the loadings matrices
        %------------------------------        
        
        %  Prediction step for the monthly loadings
        if t == 1
            lambda_t_m(:,:,t) = lambda_0.mean_m;
            for i = 1:n_m
                var_lambda_t_m(:,:,i,t) = lambda_0.var_m;
            end
        elseif t > 1
            % Do not apply forgetting factor if you still have not had any
            % observation on a variable!
            lambda_t_m(:,:,t)                      = lambda_tt_m(:,:,t-1);
            var_lambda_t_m(:,:,~still_missing_m,t) = (1./l_3(t-1))*var_lambda_tt_m(:,:,~still_missing_m,t-1);  
            var_lambda_t_m(:,:,still_missing_m,t)  = var_lambda_tt_m(:,:,still_missing_m,t-1);
            still_missing_m                        = still_missing_m & isnan(XY(t,1:n_m));
        end
    
        % Prediction step for the quarterly loadings
        if t == 1
            lambda_t_q(:,:,t) = lambda_0.mean_q;
            for i = 1:n_q 
                var_lambda_t_q(:,:,i,t) = lambda_0.var_q;
            end
        elseif t>1
            lambda_t_q(:,:,t)       = lambda_tt_q(:,:,t-1);
            var_lambda_t_q(:,:,:,t) = var_lambda_tt_q(:,:,:,t-1); 
            % Where the forgetting factor is specified such that the loadings
            % are static, as is demanded by construction. The Kalman Filter is
            % hence comparable to recursive least squares.
        end


        % Predict the beta coefficients
        %------------------------------

        if t <= lags_f + 1
            beta_t(:,t)       = beta_0.mean;
            beta_tt(:,t)      = beta_t(:,t);
            var_beta_t(:,:,t) = beta_0.var;
        elseif t > lags_f + 1
            beta_t(:,t)       = beta_tt(:,t-1);
            var_beta_t(:,:,t) = (1./l_4(t-1))*var_beta_tt(:,:,t-1);
        end

        % Calculate the Prediction Error
        %-------------------------------

        % One step ahead prediction conditional on the preliminary factor
        % estiamte
        y_hat(t,1:n_m) = lambda_t_m(:,:,t)*f(t,:)';

        % for missings in the beginning of the sample lambda will be 0 and thus
        % the prediction remains at zero until data arrives. For the quarterly
        % variables with sequentially missing data, we need to alter the
        % procedure accordingly.
        if n_q > 0 && n_m > 0
            aggMatrix = nan(size(agg,1),size(agg,2)*size(lambda_t_q,2));
            for ii = 1:size(agg,1)
                aggMatrix(ii,:) = kron(agg(ii,:),lambda_t_q(ii,:,t));
            end
            y_hat(t,n_m+1:n) = (aggMatrix*f_lag(t,1:n_f*5)')';
        end
        
        % Prediction error
        e_t(:,t) = XY(t,:)' - y_hat(t,:)';
        % missing observations in the quarterly variables result in NaN

        % Calculate measurement error variance
        %-------------------------------------
        rvo_t = e_t(1:end,t)*e_t(1:end,t)';
        
        % update the hyperparameter for EWMA of V
        if t > 60 && priors.l_1_endo_update == 1 && max(sum(isnan(e_t),2))+1<t
            eaux    = fillmissing(fillmissing(e_t','previous'),'next')';%fillmissing(e_t','previous')';%fillmissing(e_t(:,t-49:t)','constant',0)';
            l_1m(t) = (1-priors.l_1_endo_update)*l_1m(1) + priors.l_1_endo_update * min( 1 , l_1min + (1-l_1min)*exp(-0.5*(mean(mahal(eaux(1:n_m,t-59:t)',eaux(1:n_m,t-59:t)').^2)-n_m*(n_m+2))));
            if n_q > 0
                l_1q(t) = (1-priors.l_1_endo_update)*l_1q(1) + priors.l_1_endo_update * min( 1 , l_1min + (1-l_1min)*exp(-0.5*(mean(mahal(eaux(n_m+1:end,t-59:t)',eaux(n_m+1:end,t-59:t)').^2)-(n_q+1)*(n_q+1+2))));
            end
        end

        if t==1
            V_t(:,:,t) = diag(diag(V_0));
        else
            L_1                 = ~isnan(diag(rvo_t));                      % use NaN to find the missings 
            L_1                 = [L_1(1:n_m)*l_1m(t); L_1(n_m+1:end)*l_1q(t)]; %L_1.*l_1mq(:,t);
            L_1(L_1==0)         = 1;                                % assure that no update occurs for missing obsservations (l_1 = 1)
            L_1                 = diag(L_1);
            rvo_t(isnan(rvo_t)) = 0;                        % set missings to zero such that no update occurs
            V_t(1:end,1:end,t)  = L_1.*V_t(1:end,1:end,t-1) + (eye(size(L_1))-L_1).*diag(diag(rvo_t));
        end
        
        % ############### Update the loadings and beta coefficients ###########   

        % Update the monthly loadings (Kalman filter)  
        %--------------------------------------------

        
        laux = 0;
        KVL  = zeros(n_m,1);
        for i = 1:n_m
            if isnan(XY(t,i))
               lambda_tt_m(i,1:n_f,t)           = lambda_t_m(i,1:n_f,t);
               var_lambda_tt_m(1:n_f,1:n_f,i,t) = var_lambda_t_m(1:n_f,1:n_f,i,t);
            else
                Rx   = var_lambda_t_m(1:n_f,1:n_f,i,t)*f(t,1:n_f)';
                KV_l = V_t(i,i,t) + f(t,1:n_f)*Rx;
                KG   = Rx/KV_l;
                lambda_tt_m(i,1:n_f,t)           = lambda_t_m(i,1:n_f,t) + (KG*(XY(t,i)'-lambda_t_m(i,1:n_f,t)*f(t,1:n_f)'))';
                var_lambda_tt_m(1:n_f,1:n_f,i,t) = var_lambda_t_m(1:n_f,1:n_f,i,t) - KG*(f(t,1:n_f)*var_lambda_t_m(1:n_f,1:n_f,i,t));

                laux   = laux + e_t(i,t).^2/KV_l;
                KVL(i) = KV_l;

            end
        end
        
        % Update the forgetting factor for the monthly loadings
        %----------------------------------------------
        if priors.l_3_endo_update == 1
            l_3(t) = (1-priors.l_3_endo_update)*l_3(1) + priors.l_3_endo_update*(l_3min + (1-l_3min)*exp(-0.5*1/n_m*e_t(~isnan(e_t(1:n_m,t)),t)'/(diag(KVL(~isnan(e_t(1:n_m,t)))))*e_t(~isnan(e_t(1:n_m,t)),t)));
        end

        % Update the quarterly loadings (Kalman filter) 
        %----------------------------------------------

        for i = 1:n_q
            % account for the missing values in the quarterly variables
            if isnan(XY(t,n_m+i))|| t <= lags_f || skipUpdateOfLambda_q
               lambda_tt_q(i,1:n_f,t)           = lambda_t_q(i,1:n_f,t);
               var_lambda_tt_q(1:n_f,1:n_f,i,t) = var_lambda_t_q(1:n_f,1:n_f,i,t);
            else
                % Apply aggregation scheme for this variable.
                % create auxilliary matrix that contains the factors acknowledging
                % the aggregation scheme. Keep in mind that only the first five elements of
                % the state vector matter for the quarterly loadings, irrespective of the
                % lags of F that will be included in the state equation
                agg   = priors.agg(i,:);
                F_agg = agg(1)*f_lag(t,1:n_f);
                for ii = 2:size(agg,2)
                    F_agg = F_agg + agg(ii)*f_lag(t,n_f*(ii-1)+1:ii*n_f);
                end
                Rx   = var_lambda_t_q(1:n_f,1:n_f,i,t)*F_agg';
                KV_l = V_t(n_m+i,n_m+i,t) + F_agg*Rx;
                KG   = Rx/KV_l;
                lambda_tt_q(i,1:n_f,t)           = lambda_t_q(i,1:n_f,t) + (KG*(XY(t,n_m+i)' - lambda_t_q(i,1:n_f,t)*F_agg'))';
                var_lambda_tt_q(1:n_f,1:n_f,i,t) = var_lambda_t_q(1:n_f,1:n_f,i,t) - KG*(F_agg*var_lambda_t_q(1:n_f,1:n_f,i,t));
            end
        end

        % Update the beta coefficients (Kalman filter)
        %---------------------------------------------
        
        % -for beta
        if t >= lags_f+1
            Rx                 = var_beta_t(:,:,t)*F_aux((t-1)*n_f+1:t*n_f,:)';
            KV_b               = Q_t(:,:,t) + F_aux((t-1)*n_f+1:t*n_f,:)*Rx;
            KG                 = Rx/KV_b;
            beta_tt(:,t)       = beta_t(:,t) + (KG*(f(t,:)'-F_aux((t-1)*n_f+1:t*n_f,:)*beta_t(:,t)));
            var_beta_tt(:,:,t) = var_beta_t(:,:,t) - KG*(F_aux((t-1)*n_f+1:t*n_f,:)*var_beta_t(:,:,t)); 
            l_4(t)             = (1-priors.l_4_endo_update)*l_4(1,t) + priors.l_4_endo_update...
                                 *(l_4min + (1-l_4min)*exp(-0.5*1/n_f*q_t(:,t)'/KV_b*q_t(:,t)));
        end   
        
        % Reorder the Beta coefficients and check for non-explosiveness
        bb     = beta_tt(:,t);
        splace = 0; 
        biga   = nan(n_f,n_f*lags_f);
        for ii = 1:lags_f                                          
            for iii = 1:n_f           
                biga(iii,(ii-1)*n_f+1:ii*n_f) = bb(splace+1:splace+n_f,1)';
                splace                        = splace + n_f;
            end        
        end

        % B gives the matrix as defined in the state space model
        B             = [biga ; eye(n_f*(lags_f-1)) zeros(n_f*(lags_f-1),n_f)];
        lambda(:,:,t) = [lambda_tt_m(:,:,t); lambda_tt_q(:,:,t)];
        if max(abs(eig(B))) < 0.9999
             beta(:,:,t) = B;
        else
            % if beta is explosive, use the previous update * 0.95
            beta(:,:,t)  = beta(:,:,t-1);
            beta_tt(:,t) = 0.95*beta_tt(:,t-1);
        end

    end

    % Start Kalman Smoother recursions    
    %=================================

    % initialize the matrices
    lambda_m_sm        = zeros(size(lambda_tt_m)); 
    lambda_m_sm(:,:,T) = lambda_tt_m(:,:,T);    
    lambda_q_sm        = zeros(size(lambda_tt_q)); 
    lambda_q_sm(:,:,T) = lambda_tt_q(:,:,T);  

    beta_t_sm      = zeros(size(beta_tt));
    beta_t_sm(:,T) = beta_tt(:,T);

    Q_t_sm        = zeros(size(Q_t)); 
    Q_t_sm(:,:,T) = Q_t(:,:,T);

    V_t_sm        = zeros(size(V_t)); 
    V_t_sm(:,:,T) = V_t(:,:,T);

    lambda_sm = zeros(size(lambda));
    beta_sm   = zeros(size(beta));

    % Start the backward recursions of the Kalman Smoother
    for t = T-1:-1:1

        % Smooth the monthly loadings (fixed interval smoother)
        for i = 1:n_m
            if options.class == "nb_var" || options.class == "nb_mfvar"
                Ul_t = 0;  
            else
                if rcond(var_lambda_t_m(1:n_f,1:n_f,i,t+1)) < eps 
                    warning('nb_tvpmfsvEstimator:f_KFS_params',['Covariance ',...
                        'matrix of lambda for monthly variable number ' int2str(i),...
                        ' at time ', int2str(t) ,' is badly conditioned. Fingers ',...
                        'crossed! You should check your data! Do you have weird ',...
                        'observations or very few variables with data. In the ',...
                        'latter case you may want to set estim_start_date!'])
                end
                Ul_t = var_lambda_tt_m(1:n_f,1:n_f,i,t)/var_lambda_t_m(1:n_f,1:n_f,i,t+1); 
            end
            lambda_m_sm(i,1:n_f,t) = lambda_tt_m(i,1:n_f,t) + (lambda_m_sm(i,1:n_f,t+1) - lambda_t_m(i,1:n_f,t+1))*Ul_t';
        end

        % Restore the quarterly loadings 
        % recall that the quarterly loadings are static and thus do not have to be
        % smoothed. The last filter estimate of the loading is the static estimate.
        for i = 1:n_q
           lambda_q_sm(i,1:n_f,t) = lambda_tt_q(i,1:n_f,T);   
        end        

        % Smooth Beta coefficients (fixed interval smoother)   
        if sum(sum(var_beta_t(:,:,t+1))) == 0
            beta_t_sm(:,t) = beta_tt(:,t);
        else
            if rcond(var_beta_t(:,:,t+1)) < eps 
                warning('nb_tvpmfsvEstimator:f_KFS_params',['Covariance ',...
                    'matrix of beta at time ' int2str(t+1),...
                    ' is badly conditioned. Fingers crossed! You should check ',...
                    'your data! Do you have weird observations or very few ',...
                    'variables with data. In the latter case you may want to ',...
                    'set estim_start_date!'])
            end
            Ub_t           = var_beta_tt(:,:,t)/var_beta_t(:,:,t+1);
            beta_t_sm(:,t) = beta_tt(:,t) + Ub_t*(beta_t_sm(:,t+1) - beta_t(:,t+1));
        end


        % Smooth Variance-Covariance Matrices       
        % This smoothing step follows Koop and Korobilis (2014)

        % Smooth Q_t
        Q_t_sm(:,:,t) = 0.9*Q_t(:,:,t) + 0.1*Q_t_sm(:,:,t+1);

        % Smooth V_t 
        V_t_sm(1:end,1:end,t) = 0.9*V_t(1:end,1:end,t) + 0.1*V_t_sm(1:end,1:end,t+1);      

    end    

    % Reassign/reorder Coefficients
    for t = 1:T

        bb     = beta_t_sm(:,t);
        splace = 0; 
        biga   = zeros(n_f,n_f*lags_f);
        for ii = 1:lags_f                                          
            for iii = 1:n_f           
                biga(iii,(ii-1)*n_f+1:ii*n_f) = bb(splace+1:splace+n_f,1)';
                splace                        = splace + n_f;
            end        
        end

        % construct matrix of coefficients (as defined in state-space model)
        B                = [biga ; eye(n_f*(lags_f-1)) zeros(n_f*(lags_f-1),n_f)];
        lambda_sm(:,:,t) = [lambda_m_sm(:,:,t); lambda_q_sm(:,:,t)];
        beta_sm(:,:,t)   = B;
        
    end
    
    endo_ff      = NaN(5,T);
    endo_ff(1,:) = priors.l_1_endo_update*l_1m;
    endo_ff(2,:) = priors.l_1_endo_update*l_1q;
    endo_ff(3,:) = priors.l_2_endo_update*l_2;
    endo_ff(4,:) = priors.l_3_endo_update*l_3;
    endo_ff(5,:) = priors.l_4_endo_update*l_4;
    
    warning('on','MATLAB:nearlySingularMatrix');
    
end

