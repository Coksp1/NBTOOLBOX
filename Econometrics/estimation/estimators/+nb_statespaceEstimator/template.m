function options = template()
% Syntax:
%
% options = nb_statespaceEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_olsEstimator.estimate
% function.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options                             = struct();
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.doTests                     = 1;
    options.getObjectiveFunc            = [];
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
%     options.kf_init_variance            = 1;
    options.kf_presample                = 0;
    options.optimizer                   = 'bee_gate';
    options.optimset                    = struct('MaxTime',24*60*60,'MaxFunEvals',inf,'MaxIter',inf);
    options.prior                       = [];
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.sampler_options             = nb_mcmc.optimset('log',true,'waitbar',true);

end
