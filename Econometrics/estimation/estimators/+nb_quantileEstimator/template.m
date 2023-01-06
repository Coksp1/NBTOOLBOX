function options = template()
% Syntax:
%
% options = nb_olsEstimator.template()
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options                             = struct();
    options.addLags                     = 0;
    options.constant                    = 1;
    options.criterion                   = '';
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataTypes                   = {};
    options.dataVariables               = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.estim_types                 = {};
    options.exogenous                   = {};
    options.maxLagLength                = 10;
    options.modelSelection              = '';
    options.modelSelectionAlpha         = 0.05;
    options.modelSelectionFixed         = [];
    options.nLags                       = 0;
    options.nLagsTests                  = 5;
    options.nStep                       = 0;
    options.quantile                    = 0.5;
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.seasonalDummy               = '';
    options.stdType                     = 'sparsity';
    options.time_trend                  = 0;
    options.unbalanced                  = false;
    options.waitbar                     = 1;
    
end
