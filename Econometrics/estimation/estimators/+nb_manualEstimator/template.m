function options = template()
% Syntax:
%
% options = nb_manualEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_manualEstimator
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options                             = struct();
    options.condDB                      = [];
    options.constant                    = 1;
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.drawParamFunc               = [];
    options.estimFunc                   = [];
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.handleCondInfo              = false;
    options.handleMissing               = false;
    options.nFcstSteps                  = 0;
    options.predict                     = false;
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.removeZeroRegressors        = false;
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.solveFunc                   = [];
    options.time_trend                  = 0;

end
