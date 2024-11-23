function options = template()
% Syntax:
%
% options = nb_bVarEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_bVarEstimator.estimate
% function.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Output:
% 
% - options : A struct.
%
% See also:
% nb_bVarEstimator.priorTemplate
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options                             = struct();
    options.constant                    = 1;
    options.criterion                   = '';
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.draws                       = 1000;
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.frequency                   = {};
    options.mapping                     = {};
    options.maxLagLength                = 10;
    options.mixing                      = {};
    options.modelSelection              = '';
    options.modelSelectionFixed         = [];
    options.nLags                       = 0;
    options.nLagsTests                  = 5;
    options.prior                       = nb_bVarEstimator.priorTemplate('jeffrey');
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.rollingWindow               = [];
    options.requiredDegreeOfFreedom     = 3;
    options.saveDraws                   = true;
    options.seasonalDummy               = '';
    options.time_trend                  = 0;
    options.waitbar                     = 1;

end
