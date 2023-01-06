function options = template()
% Syntax:
%
% options = nb_shorteningEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_shorteningEstimator.estimate function.
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
    options.func                      = [];
    options.handleMissing             = false;
    options.lambda                    = 1600;
    options.oneSided                  = false;
    options.outVariables              = {};
    options.recursive_estim           = 0;
    options.recursive_estim_start_ind = [];
    options.requiredDegreeOfFreedom   = 3;
    options.rollingWindow             = [];
    options.type                      = 'gap';

end
