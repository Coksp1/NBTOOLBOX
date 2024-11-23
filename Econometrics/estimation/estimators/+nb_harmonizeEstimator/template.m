function options = template()
% Syntax:
%
% options = nb_harmonizeEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_harmonizeEstimator.estimate function.
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
    options.algorithm                 = 'var';
    options.calibrateR                = {};
    options.condDB                    = [];
    options.condDBVariables           = {};
    options.data                      = [];
    options.dataStartDate             = '';
    options.dataVariables             = {};
    options.estim_end_ind             = [];
    options.estim_start_ind           = [];
    options.frequency                 = [];
    options.harmonizers               = {};
    options.nLags                     = 5;
    options.optimizer                 = 'fmincon';
    options.optimset                  = struct;
    options.recursive_estim           = 0;
    options.recursive_estim_start_ind = [];
    options.requiredDegreeOfFreedom   = 3;
    options.rollingWindow             = [];

end
