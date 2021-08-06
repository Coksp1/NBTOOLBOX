%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if isoctave || matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Save empty dates and dseries objects in memory.
dates('initialize');
dseries('initialize');
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'cgg_rule';
M_.dynare_version = '4.5.0';
oo_.dynare_version = '4.5.0';
options_.dynare_version = '4.5.0';
%
% Some global variables initialization
%
global_initialization;
diary off;
diary('cgg_rule.log');
M_.exo_names = 'e_eta';
M_.exo_names_tex = 'e\_eta';
M_.exo_names_long = 'e_eta';
M_.exo_names = char(M_.exo_names, 'e_eps');
M_.exo_names_tex = char(M_.exo_names_tex, 'e\_eps');
M_.exo_names_long = char(M_.exo_names_long, 'e_eps');
M_.exo_names = char(M_.exo_names, 'e_em');
M_.exo_names_tex = char(M_.exo_names_tex, 'e\_em');
M_.exo_names_long = char(M_.exo_names_long, 'e_em');
M_.endo_names = 'y';
M_.endo_names_tex = 'y';
M_.endo_names_long = 'y';
M_.endo_names = char(M_.endo_names, 'pie');
M_.endo_names_tex = char(M_.endo_names_tex, 'pie');
M_.endo_names_long = char(M_.endo_names_long, 'pie');
M_.endo_names = char(M_.endo_names, 'i');
M_.endo_names_tex = char(M_.endo_names_tex, 'i');
M_.endo_names_long = char(M_.endo_names_long, 'i');
M_.endo_names = char(M_.endo_names, 'is');
M_.endo_names_tex = char(M_.endo_names_tex, 'is');
M_.endo_names_long = char(M_.endo_names_long, 'is');
M_.endo_names = char(M_.endo_names, 'eta');
M_.endo_names_tex = char(M_.endo_names_tex, 'eta');
M_.endo_names_long = char(M_.endo_names_long, 'eta');
M_.endo_names = char(M_.endo_names, 'eps');
M_.endo_names_tex = char(M_.endo_names_tex, 'eps');
M_.endo_names_long = char(M_.endo_names_long, 'eps');
M_.endo_names = char(M_.endo_names, 'em');
M_.endo_names_tex = char(M_.endo_names_tex, 'em');
M_.endo_names_long = char(M_.endo_names_long, 'em');
M_.endo_partitions = struct();
M_.param_names = 'alpha';
M_.param_names_tex = 'alpha';
M_.param_names_long = 'alpha';
M_.param_names = char(M_.param_names, 'beta');
M_.param_names_tex = char(M_.param_names_tex, 'beta');
M_.param_names_long = char(M_.param_names_long, 'beta');
M_.param_names = char(M_.param_names, 'gamma_i');
M_.param_names_tex = char(M_.param_names_tex, 'gamma\_i');
M_.param_names_long = char(M_.param_names_long, 'gamma_i');
M_.param_names = char(M_.param_names, 'gamma_pie');
M_.param_names_tex = char(M_.param_names_tex, 'gamma\_pie');
M_.param_names_long = char(M_.param_names_long, 'gamma_pie');
M_.param_names = char(M_.param_names, 'gamma_y');
M_.param_names_tex = char(M_.param_names_tex, 'gamma\_y');
M_.param_names_long = char(M_.param_names_long, 'gamma_y');
M_.param_names = char(M_.param_names, 'lambda_eps');
M_.param_names_tex = char(M_.param_names_tex, 'lambda\_eps');
M_.param_names_long = char(M_.param_names_long, 'lambda_eps');
M_.param_names = char(M_.param_names, 'lambda_eta');
M_.param_names_tex = char(M_.param_names_tex, 'lambda\_eta');
M_.param_names_long = char(M_.param_names_long, 'lambda_eta');
M_.param_names = char(M_.param_names, 'lambda_em');
M_.param_names_tex = char(M_.param_names_tex, 'lambda\_em');
M_.param_names_long = char(M_.param_names_long, 'lambda_em');
M_.param_names = char(M_.param_names, 'phi');
M_.param_names_tex = char(M_.param_names_tex, 'phi');
M_.param_names_long = char(M_.param_names_long, 'phi');
M_.param_names = char(M_.param_names, 'theta');
M_.param_names_tex = char(M_.param_names_tex, 'theta');
M_.param_names_long = char(M_.param_names_long, 'theta');
M_.param_names = char(M_.param_names, 'varphi');
M_.param_names_tex = char(M_.param_names_tex, 'varphi');
M_.param_names_long = char(M_.param_names_long, 'varphi');
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 3;
M_.endo_nbr = 7;
M_.param_nbr = 11;
M_.orig_endo_nbr = 7;
M_.aux_vars = [];
M_.Sigma_e = zeros(3, 3);
M_.Correlation_matrix = eye(3, 3);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = 1;
M_.det_shocks = [];
options_.block=0;
options_.bytecode=0;
options_.use_dll=0;
M_.hessian_eq_zero = 1;
erase_compiled_function('cgg_rule_static');
erase_compiled_function('cgg_rule_dynamic');
M_.orig_eq_nbr = 7;
M_.eq_nbr = 7;
M_.ramsey_eq_nbr = 0;
M_.lead_lag_incidence = [
 1 8 15;
 2 9 16;
 3 10 0;
 4 11 0;
 5 12 0;
 6 13 0;
 7 14 0;]';
M_.nstatic = 0;
M_.nfwrd   = 0;
M_.npred   = 5;
M_.nboth   = 2;
M_.nsfwrd   = 2;
M_.nspred   = 7;
M_.ndynamic   = 7;
M_.equations_tags = {
};
M_.static_and_dynamic_models_differ = 0;
M_.exo_names_orig_ord = [1:3];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(7, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(3, 1);
M_.params = NaN(11, 1);
M_.NNZDerivatives = [29; 0; -1];
M_.params( 1 ) = 0.1;
alpha = M_.params( 1 );
M_.params( 2 ) = 1;
beta = M_.params( 2 );
M_.params( 3 ) = 0;
gamma_i = M_.params( 3 );
M_.params( 4 ) = 1.2;
gamma_pie = M_.params( 4 );
M_.params( 5 ) = 0.338;
gamma_y = M_.params( 5 );
M_.params( 6 ) = 0.7;
lambda_eps = M_.params( 6 );
M_.params( 7 ) = 0.7;
lambda_eta = M_.params( 7 );
M_.params( 8 ) = 0.7;
lambda_em = M_.params( 8 );
M_.params( 9 ) = 0.5;
phi = M_.params( 9 );
M_.params( 10 ) = 0.5;
theta = M_.params( 10 );
M_.params( 11 ) = 0.8;
varphi = M_.params( 11 );
%
% SHOCKS instructions
%
M_.det_shocks = [ M_.det_shocks;
struct('exo_det',0,'exo_id',2,'multiplicative',0,'periods',1:1,'value',(-0.1)) ];
M_.exo_det_length = 0;
options_.periods = 80;
perfect_foresight_setup;
perfect_foresight_solver;
save('cgg_rule_results.mat', 'oo_', 'M_', 'options_');
if exist('estim_params_', 'var') == 1
  save('cgg_rule_results.mat', 'estim_params_', '-append');
end
if exist('bayestopt_', 'var') == 1
  save('cgg_rule_results.mat', 'bayestopt_', '-append');
end
if exist('dataset_', 'var') == 1
  save('cgg_rule_results.mat', 'dataset_', '-append');
end
if exist('estimation_info', 'var') == 1
  save('cgg_rule_results.mat', 'estimation_info', '-append');
end
if exist('dataset_info', 'var') == 1
  save('cgg_rule_results.mat', 'dataset_info', '-append');
end
if exist('oo_recursive_', 'var') == 1
  save('cgg_rule_results.mat', 'oo_recursive_', '-append');
end


disp(['Total computing time : ' dynsec2hms(toc(tic0)) ]);
if ~isempty(lastwarn)
  disp('Note: warning(s) encountered in MATLAB/Octave code')
end
diary off
