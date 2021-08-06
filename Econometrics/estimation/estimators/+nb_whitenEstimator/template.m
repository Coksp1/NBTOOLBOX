function options = template()
% Syntax:
%
% options = nb_whitenEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the 
% nb_whitenEstimator.estimate function.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Output:
% 
% - options : A struct.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    options                             = struct();
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.missing                     = '';
    options.nFactors                    = [];
    options.observables                 = {};
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.seasonalDummy               = '';

end
