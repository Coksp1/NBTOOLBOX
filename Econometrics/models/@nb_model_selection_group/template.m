function options = template()
% Syntax:
%
% options = nb_model_selection_group.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_model_selection_group
% class constructor.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Input:
%
% - num : Number of models to create.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_model_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options = nb_model_generic.templateGeneral(num,'group');

    % Formulation
    options.algorithm          = 'hr';
    options.class              = 'nb_var';
    options.crit               = 10;
    options.maxAR              = 10;
    options.maxMA              = 5;
    options.nHor               = 1;
    options.scoreHor           = '';
    options.nLags              = 4;
    options.nVarMax            = 6;
    options.nVarMin            = 0;
    options.SAR                = false;
    options.SMA                = false;
    options.variables          = {};
    options.varOfInterest      = '';
    options.modelVarOfInterest = '';

    % Estimation
    VARTemplate                         = nb_var.template();
    options.constant                    = VARTemplate.constant;
    options.estim_start_date            = VARTemplate.estim_start_date;
    options.estim_end_date              = VARTemplate.estim_end_date;
    options.missingMethod               = '';
    options.real_time_estim             = false;
    options.recursive_estim             = VARTemplate.recursive_estim;
    options.recursive_estim_start_date  = '';
    options.rollingWindow               = VARTemplate.rollingWindow;
    options.time_trend                  = VARTemplate.time_trend;

    % Forecasting
    options.bins           = [];
    options.draws          = 1;
    options.endDate        = '';
    options.method         = '';
    options.nSteps         = 8;
    options.parameterDraws = 1;
    options.score          = 'RMSE';
    options.parallel       = false;
    options.cores          = [];
    options.stabilityTest  = true;

    % Others
    options.recursiveDetrending = false; 
    options.setUpOnly           = false;

end
