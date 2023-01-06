function priors = getPriors(options)
% Syntax:
%
% priors = nb_tvpmfsvEstimator.getPriors(options)
%
% Description:
%
% Get the priors and a few other settings needed for estimation. 
% 
% Input:
% 
% - options : A struct on the format returned by
%             nb_tvpmfsvEstimator.template.
% 
% Output:
% 
% - priors : A struct with fields;
%
%     > f_0      : the prior distribution of the factors (structure)
%     > lambda_0 : the prior distribution of the factor loadings
%                  (structure)
%     > beta_0   : the prior distribution of the VAR coefficients 
%                  (structure)
%     > V_0      : the prior of the obervation equation's variance 
%     > Q_0      : the prior of the factor state equation's variance
%     > agg      : the aggregation scheme
%     > l_1m     : the decay factor for V_t^M
%     > l1_q     : the decay factor for V_t^Q
%     > l_2      : the decay factor for Q_t
%     > l_3      : the forgetting factor for W_t
%     > l_4      : the forgetting factor for R_t
%     > nLags    : the number of factor lags in the VAR
%     > n_m      : the number of indicators at monthly frequency
%     > n_q      : the number of indicators at quarterly frequency
%
% See also:
% nb_tvpmfsvEstimator.normalEstimation, 
% nb_tvpmfsvEstimator.recursiveEstimation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    n_f = options.nFactors;
    k   = options.nFactors*options.nLags;
    n_m = options.nMonth;
    n_q = options.nQuarter;
    if n_q > 0 && n_m == 0
        % Here we are only dealing with quarterly data, so we just set
        % n_m == n_q to not deal with mixed frequency stuff in the
        % algorithm
        n_m = n_q;
        n_q = 0;
    end

    % Set the prior of the factors
    f_0.mean = zeros(k,1);
    f_0.var  = options.prior.f0VarScale*eye(k);

    % Set the prior for the factor loadings 
    if isfield(options, 'class') && options.class == "nb_var"
        lambda_0.mean_m              = zeros(n_m,n_f);
        lambda_0.mean_m(1:n_m,1:n_m) = eye(n_m);
        lambda_0.mean_q              = zeros(n_q,n_f); % +1 for Y variable
        lambda_0.mean_q(end-n_q+1:end, end-n_q+1:end) = eye(n_q);
        lambda_0.var_m                                = 0*eye(n_f);
    elseif isfield(options, 'class') && options.class == "nb_mfvar"
        lambda_0.mean_m              = zeros(n_m,n_f);
        lambda_0.mean_m(1:n_m,1:n_m) = eye(n_m);
        lambda_0.mean_q              = zeros(n_q,n_f); % +1 for Y variable
        lambda_0.mean_q(end-n_q+1:end, end-n_q+1:end) = eye(n_q);
        lambda_0.var_m                                = 0*eye(n_f);
    else
        lambda_0.mean_m = zeros(n_m,n_f);
        lambda_0.mean_q = zeros(n_q,n_f); % +1 for Y variable 
        lambda_0.var_m  = options.prior.lambda0VarScale*eye(n_f);
    end
    
    lambda_0.var_q  = options.prior.lambda0VarScale*eye(n_f);

    % set the prior for the VAR coefficients coefficients beta_t
    [beta_0.mean,beta_0.var] = minnesotaKK(options);

    % set the prior of the observation equation's variance
    if any(options.indObservedOnly) && ~isempty(options.mixing)
        [~,indY] = ismember(options.observables,options.dataVariables);
        y        = options.data(:,indY);
        V_0      = options.prior.V0VarScale.*ones(options.n,1);      
        if isscalar(options.prior.R_scale)
            V_0(options.mixingSettings.loc) = nanvar(y(:,options.mixingSettings.loc))/options.prior.R_scale;
        else
            varDep = nanvar(y(:,options.prior.R_scale(:,1)))';
            V_0(options.prior.R_scale(:,1)) = varDep./options.prior.R_scale(:,2);
        end
        V_0 = diag(V_0);
    else
        V_0 = options.prior.V0VarScale.*eye(options.n);
    end

    % set the prior of the state equation's variance
    Q_0 = options.prior.Q0VarScale*eye(n_f);

    % Get the aggregation scheme
    agg = nan(n_q,5);
    for ii = 1:n_q
        agg(ii,:) = nb_tvpmfsvEstimator.getAggregationScheme(options,n_m + ii);
    end

    options.prior = nb_defaultField(options.prior,'l_1_endo_update',0);
    options.prior = nb_defaultField(options.prior,'l_2_endo_update',0);
    options.prior = nb_defaultField(options.prior,'l_3_endo_update',0);
    options.prior = nb_defaultField(options.prior,'l_4_endo_update',0);
    options.prior = nb_defaultField(options.prior,'l_1_lower_bound',0);
    options.prior = nb_defaultField(options.prior,'l_2_lower_bound',0);
    options.prior = nb_defaultField(options.prior,'l_3_lower_bound',0);
    options.prior = nb_defaultField(options.prior,'l_4_lower_bound',0);
    priors = struct(...
        'f_0',              f_0,...
        'lambda_0',         lambda_0,...
        'beta_0',           beta_0,...
        'V_0',              V_0,...
        'Q_0',              Q_0,...
        'l_1m',             options.prior.l_1m,...
        'l_1q',             options.prior.l_1q,...
        'l_2',              options.prior.l_2,... 
        'l_3',              options.prior.l_3,...
        'l_4',              options.prior.l_4,...
        'agg',              agg,...
        'n_m',              n_m,...
        'n_q',              n_q,...
        'nLags',            options.nLags,...
        'l_1_endo_update',  options.prior.l_1_endo_update,...
        'l_2_endo_update',  options.prior.l_2_endo_update,...
        'l_3_endo_update',  options.prior.l_3_endo_update,...
        'l_4_endo_update',  options.prior.l_4_endo_update,...
        'l_1_lower_bound',  options.prior.l_1_lower_bound,...
        'l_2_lower_bound',  options.prior.l_2_lower_bound,...
        'l_3_lower_bound',  options.prior.l_3_lower_bound,...
        'l_4_lower_bound',  options.prior.l_4_lower_bound...
        );

end

%==========================================================================
function [M,V] = minnesotaKK(options)

    gamma = options.prior.gamma;
    p     = options.nLags*options.nFactors;

    % for the mean vector a stationary AR(1) is assumed. In the vectorized mean
    % vector, the coefficients are treated accroding to lags. Thus all coefficients
    % for the first factor lag come first in order of the factor (all coeffiecients on
    % the first lagged factor, then all coefficients on the second lagged factor etc). 

    % Mean vector
    M = [0.9*eye(options.nFactors), zeros(options.nFactors,options.nFactors*(options.nLags-1))];
    M = M(:);

    % When specifying the minnesota variance, it is important to preserve the
    % structure of the above mean matrix/the state equation, such that each row
    % /column stores the prior variance of the corresponding VAR-coefficient

    V = zeros(options.nFactors,p);
    for i = 1:options.nFactors
        for j = 1:p
            V(i,j) = gamma./(ceil(j/options.nFactors).^2);
        end
    end
    V = diag(V(:));

end
