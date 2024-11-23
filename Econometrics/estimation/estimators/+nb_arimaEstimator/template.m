function options = template()
% Syntax:
%
% options = nb_arimaEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_arimaEstimator
% class constructor.
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
    options.algorithm                   = 'hr';
    options.alpha                       = 0.05;
    options.AR                          = nan;
    options.constant                    = 1;
    options.covidAdj                    = {};
    options.covrepair                   = false;
    options.criterion                   = '';
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.integration                 = nan;
    options.MA                          = nan;
    options.maxAR                       = 3;
    options.maxMA                       = 3;
    options.nLagsTests                  = 5;
    options.optimizer                   = 'fminunc';
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.removeZeroRegressors        = false;
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.SAR                         = 0;
    options.SMA                         = 0;
    options.stabilityTest               = true;
    options.transition                  = [];
    options.waitbar                     = 1;

end
