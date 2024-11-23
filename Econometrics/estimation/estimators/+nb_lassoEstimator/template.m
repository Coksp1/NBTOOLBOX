function options = template()
% Syntax:
%
% options = nb_lassoEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_lassoEstimator.estimate function.
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
    options.covidAdj                    = {};
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataTypes                   = {};
    options.dataVariables               = {};
    options.dependent                   = {};
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.estim_types                 = {};
    options.exogenous                   = {};
    options.nLags                       = 0;
    options.nStep                       = 0;
    options.optimset                    = [];
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.regularization              = [];
    options.regularizationMode          = 'normal';
    options.regularizationPerc          = [];
    options.requiredDegreeOfFreedom     = 3;
    options.restrictConstant            = true;
    options.rollingWindow               = [];
    options.seasonalDummy               = '';
    
end
