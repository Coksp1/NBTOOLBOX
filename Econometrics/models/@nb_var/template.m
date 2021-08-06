function options = template(num)
% Syntax:
%
% options = nb_var.template()
% options = nb_var.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_var
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
% nb_var, nb_var.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    options                             = nb_model_generic.templateGeneral(num,'time-series');
    options.block_exogenous             = {};
    options.blockLags                   = [];
    options.constant                    = 1;
    options.cores                       = [];
    options.covrepair                   = false;
    options.criterion                   = '';
    options.dependent                   = {};
    options.doTests                     = 1;
    options.draws                       = 1000;
    options.empirical                   = false;
    options.estim_method                = 'ols';
    options.exogenous                   = {};
    options.factors                     = {};
    options.hyperprior                  = false;
    options.kf_presample                = 0;
    options.maxLagLength                = 10;
    options.missingMethod               = '';
    options.modelSelection              = '';
    options.nLags                       = 1;
    options.nLagsTests                  = 5;
    options.optimizer                   = 'fmincon';
    options.optimset                    = struct('MaxTime',[],'MaxFunEvals',inf,'MaxIter',10000,'Display','iter','TolFun',[],'TolX',[]);
    options.parallel                    = false;
    options.prior                       = [];
    options.removeZeroRegressors        = false;
    options.seasonalDummy               = '';
    options.saveDraws                   = true;
    options.stabilityTest               = true;
    options.stdType                     = 'h';
    options.time_trend                  = 0; 

end
