function options = template()
% Syntax:
%
% options = nb_fmEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_fmEstimator.estimate
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
    options.constant                    = 1;
    options.contemporaneous             = 0;
    options.criterion                   = 'aic';
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.factorsCriterion            = 7;
    options.factorsLags                 = 1; 
    options.maxLagLength                = 10;
    options.modelSelection              = '';
%     options.modelSelectionAlpha         = 0.05;
    options.modelType                   = 'dynamic';
    options.nFactors                    = [];
    options.nFactorsMax                 = [];
    options.nLags                       = 1;
    options.nLagsTests                  = 5;
    options.nStep                       = 4;
    options.observables                 = {};
    options.observablesFast             = {};
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.seasonalDummy               = '';
    options.stdReplic                   = 1000;
    options.stdType                     = 'none';
    options.time_trend                  = 0;
    options.unbalanced                  = 0;

end
