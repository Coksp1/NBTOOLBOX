function options = template()
% Syntax:
%
% options = nb_midasEstimator.template()
%
% Description:
%
% Construct a struct which must be provided to the nb_midasEstimator.estimate
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

    options                             = struct();
    options.AR                          = false;
    options.algorithm                   = 'unrestricted';
    options.constant                    = 1;
    options.covrepair                   = false;
    options.data                        = [];
    options.dataStartDate               = '';
    options.dataVariables               = {};
    options.dependent                   = {};
    options.doTests                     = 1;
    options.draws                       = 1000;
    options.estim_end_ind               = [];
    options.estim_start_ind             = [];
    options.exogenous                   = {};
    options.frequency                   = 4;
    options.nLags                       = 1;
    options.nLagsTests                  = 5;
    options.nStep                       = 1;
    options.optimizer                   = 'fmincon';
    options.optimset                    = struct('MaxTime',[],'MaxFunEvals',inf,'MaxIter',10000,'Display','iter','TolFun',[],'TolX',[]);
    options.polyLags                    = [];
    options.recursive_estim             = 0;
    options.recursive_estim_start_ind   = [];
    options.requiredDegreeOfFreedom     = 3;
    options.rollingWindow               = [];
    options.stdType                     = 'h';
    options.unbalanced                  = false;
    
end
