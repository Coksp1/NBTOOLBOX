function options = template(num)
% Syntax:
%
% options = nb_dsge.template()
% options = nb_dsge.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_dsge
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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    opt         = optimset('fmincon');
    opt.Display = 'iter';
    
    options                             = nb_model_generic.templateGeneral(num,'time-series');  
    options.blockDecompose              = false;
    options.blockTol                    = 1e-10;
    options.derivativeMethod            = 'automatic';
    options.discount                    = [];
    options.doTests                     = 1;
    options.draws                       = 0;
    options.check                       = false;
    options.covrepair                   = false;
    options.estim_steady_state_solve    = true;
    options.estim_verbose               = false;
    options.fix_point_dampening         = 1;  
    options.fix_point_maxiter           = 1500;
    options.fix_point_TolFun            = 1e-05;
    options.fix_point_verbose           = false;
    options.getObjectiveFunc            = 'nb_dsge.getObjectiveForEstimation';
    options.growth_basis_tol            = 1e-04;
    options.homotopyAlgorithm           = 0;
    options.homotopySetup               = {};
    options.homotopySteps               = 10;
    options.kf_init_variance            = 1;
    options.kf_kalmanTol                = eps;
    options.kf_method                   = 'normal';
    options.kf_presample                = 0;
    options.kf_riccatiTol               = eps^(0.5);
    options.kf_warning                  = false;
    options.lc_commitment               = 0;
    options.lc_discount                 = 0.99;
    options.lc_reconvexify              = false;
    options.macroWriteFile              = '';
    options.macroProcessor              = false;
    options.macroVars                   = nb_macro.empty();
    options.M_                          = struct;
    options.numAntSteps                 = [];
    options.oo_                         = struct;
    options.optimal_algorithm           = '';
    options.optimizer                   = 'fmincon';
    options.optimset                    = struct;
    options.options_                    = struct;
    options.osr_type                    = 'commitment';
    options.prior                       = [];
    options.rcondTol                    = eps;
    options.report                      = 0;
    options.riseObject                  = [];
    options.sampler_options             = nb_mcmc.optimset('log',true,'waitbar',true);
    options.shockProperties             = [];
    options.silent                      = false;
    options.solve_check_stability       = true;
    options.solve_initialization        = '';
    options.solve_order                 = 1;
    options.solve_parallel              = false;
    options.solver                      = 'fsolve';
    options.steady_state_block          = false;
    options.steady_state_change         = {};
    options.steady_state_default        = @zeros;
    options.steady_state_debug          = false;
    options.steady_state_exo            = '';
    options.steady_state_file           = '';
    options.steady_state_fixed          = struct();
    options.steady_state_imposed        = false;
    options.steady_state_init           = struct();
    options.steady_state_optimset       = struct();
    options.steady_state_solve          = false;
    options.steady_state_tol            = 1e-05;
    options.steady_state_unique         = false;
    options.stochasticTrend             = false;
    options.stochasticTrendInit         = struct();
    options.systemPrior                 = [];
    options.tempParametersVerbose       = false;
    options.timeVarying                 = {};
    options.uncertain_draws             = 500;
    
    options = orderfields(options);
    
end
