function options = template()
% Syntax:
%
% options = nb_ecmEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_ecmEstimator.estimate
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options                             = struct();
    options.constant                    = 1;
    options.criterion                   = '';
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.exoLags                     = 0;
    options.maxLagLength                = 10;
    options.method                      = 'oneStep';
    options.modelSelection              = '';
    options.modelSelectionAlpha         = 0.05;
    options.nLags                       = 0;
    options.nLagsTests                  = 5;
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.seasonalDummy               = '';
    options.stdType                     = 'h';
    options.time_trend                  = 0;

end
