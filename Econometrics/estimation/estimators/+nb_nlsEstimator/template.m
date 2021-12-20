function options = template()
% Syntax:
%
% options = nb_olsEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_nlsEstimator.estimate
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options                 = nb_estimator.template('time-series');
    options.constraints     = [];
    options.covrepair       = false;
    options.dependent       = {};
    options.doTests         = 1;
    options.equations       = {};
    options.estim_method    = 'nls';
    options.exogenous       = {};
    options.init            = struct();
    options.lb              = struct();
    options.nLagsTests      = 5;
    options.optimizer       = 'fmincon';
    options.optimset        = struct;
    options.parameters      = {};
    options.parser          = struct();
    options.silent          = false;
    options.ub              = struct();

end
