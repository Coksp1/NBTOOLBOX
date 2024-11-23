function options = template()
% Syntax:
%
% options = nb_manualCalcEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_manualCalcEstimator.estimate function.
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

    options                           = struct();
    options.data                      = [];
    options.dataStartDate             = '';
    options.dataVariables             = {};
    options.dependent                 = {};
    options.estim_end_ind             = [];
    options.estim_start_ind           = [];
    options.calcFunc                  = [];
    options.handleMissing             = false;
    options.path                      = [];
    options.outVariables              = {};
    options.recursive_estim           = 0;
    options.recursive_estim_start_ind = [];
    options.requiredDegreeOfFreedom   = 3;
    options.rollingWindow             = [];

end
