function options = template()
% Syntax:
%
% options = nb_tvpmfsvEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_tvpmfsvEstimator.estimate function.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options                             = struct();
    options.blocks                      = [];
    options.constant                    = 1;
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.kf_presample                = 0;
    options.kf_kalmanTol                = eps;
    options.nFactors                    = [];
    options.nLags                       = 1;
    options.observables                 = {};
    options.prior                       = struct();
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.set2nan                     = struct();
    options.smoothParam                 = false;
    options.smoothShocks                = true;
    options.time_trend                  = 0;
    options.transformation              = 'none';
    
end
