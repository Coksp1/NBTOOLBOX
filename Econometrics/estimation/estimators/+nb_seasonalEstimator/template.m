function options = template()
% Syntax:
%
% options = nb_seasonalEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_seasonalEstimator.estimate function.
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

    options                           = struct();
    options.data                      = [];
    options.dataStartDate             = '';
    options.dataVariables             = {};
    options.dependent                 = {};
    options.estim_end_ind             = [];
    options.estim_start_ind           = [];
    options.exogenous                 = {};
    options.maxIter                   = 2500;
    options.missing                   = '';
    options.recursive_estim           = 0;
    options.recursive_estim_start_ind = [];
    options.removeZeroRegressors      = false;
    options.requiredDegreeOfFreedom   = 3;
    options.rollingWindow             = [];
    options.tolerance                 = 1e-5;

end
