function options = template(num)
% Syntax:
%
% options = nb_harmonizer.template()
% options = nb_harmonizer.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_harmonizer
% class constructor.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Input:
%
% - num     : Number of models to create.
%
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                = nb_model_generic.templateGeneral(num,'time-series');
    options.algorithm      = 'var';
    options.calibrateR     = {};
    options.data           = nb_ts();
    options.doTests        = false;
    options.condDB         = [];
    options.estim_method   = 'harmonize';
    options.exoProj        = '';
    options.exoProjAR      = nan;
    options.exoProjCalib   = {};
    options.exoProjDiff    = {};
    options.exoProjDummies = {};
    options.exoProjHist    = false;
    options.frequency      = [];
    options.harmonizers    = {};
    options.nFcstSteps     = 0;
    options.nLags          = 5;
    options.optimizer      = 'fmincon';
    options.optimset       = struct;
  
end
