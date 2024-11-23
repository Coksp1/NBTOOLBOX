function options = template(num)
% Syntax:
%
% options = nb_manualModel.template()
% options = nb_manualModel.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_manualModel
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

    options                         = nb_model_generic.templateGeneral(num,'time-series');
    options.constant                = false;
    options.condDB                  = [];
    options.drawParamFunc           = [];
    options.handleCondInfo          = false;
    options.handleMissing           = false;
    options.estim_method            = 'manual';
    options.estimFunc               = [];
    options.exoProj                 = '';
    options.exoProjAR               = nan;
    options.exoProjCalib            = {};
    options.exoProjDiff             = {};
    options.exoProjDummies          = {};
    options.exoProjHist             = false;
    options.nFcstSteps              = 0;
    options.predict                 = false;
    options.removeZeroRegressors    = false;
    options.requiredDegreeOfFreedom = 0;
    options.solveFunc               = [];
    options.time_trend              = false;
    
end
