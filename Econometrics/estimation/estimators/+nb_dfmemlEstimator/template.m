function options = template()
% Syntax:
%
% options = nb_dfmemlEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_dfmemlEstimator.estimate function.
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
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.factorRestrictions          = true;
    options.fix_point_maxiter           = 500;
    options.fix_point_TolFun            = 1e-04;
    options.fix_point_verbose           = false;
    options.kf_presample                = 0;
    options.kf_kalmanTol                = eps;
    options.maxLagLength                = 10;
    options.nFactors                    = [];
    options.nLags                       = 1;
    options.nLagsIdiosyncratic          = 1;
    options.nLagsTests                  = 5;
    options.nonStationary               = false;
    options.observables                 = {};
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.seasonalDummy               = '';
    options.set2nan                     = struct();
    options.stdReplic                   = 1000;
    options.stdType                     = 'none';
    options.time_trend                  = 0;
    options.transformation              = 'none';
    
end
