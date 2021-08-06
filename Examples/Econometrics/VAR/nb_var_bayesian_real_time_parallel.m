%% Test B-VAR with minnesota prior (Gibbs sampling) 
% using real-time data and parallel estimation.

%% Load real-time data

data = nb_ts('realTime');

% QSA_DPY_PCPIJAE : 4-quarter change in norwegian core CPI
% QSA_DPY_YMN     : 4-quarter growth in GDP mainland Norway
% QUA_RNFOLIO     : The Norwegian policy rate.

% The series are de-trended in real time by de-meaning.

%% Priors

p            = nb_var.priorTemplate('minnesota');
p.a_bar_1    = 0.04;    % Hard prior on own lags
p.a_bar_2    = 0.04;    % Hard prior on rest of the dynamic coefficients
p.a_bar_3    = 10;      % Loose prior on exogenous
p.ARcoeff    = 0.9;     % This is used as the default prior on lag 1
p.method     = 'gibbs'; % Gibbs sampler
p.burn       = 1500;    % Burn in when estimating the model
p.thin       = 5;       % Save every X draw. Prevent autocorrelated draws

% This priors overrun the default priors on specific coefficients
p.coeff      = {'QSA_DPY_PCPIJAE_QSA_DPY_PCPIJAE_lag1',   0.5;...
                'QSA_DPY_YMN_QSA_DPY_YMN_lag1',   0.7;...
                'QSA_DPY_YMN_Constant', 0.5};
        
%% B-VAR (Not recursive)

% Options
t                  = nb_var.template();
t.data             = data(:,:,end);
t.constant         = 1;
t.nLags            = 4;
t.recursive_estim  = 0;
t.dependent        = data.variables;
t.prior            = p;
t.parallel         = false;
t.draws            = 1000;

% Create model and estimate in real-time
model = nb_var(t);
model = estimate(model);
print(model)              
  
% Check posterior draws
[~,plotter,pAutocorr] = checkPosteriors(model,'nLags',5);
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);

%% B-VAR (Not real-time, but recursive)

% Options
t                            = nb_var.template();
t.data                       = data(:,:,end); % Last vintage only
t.constant                   = 1;
t.nLags                      = 4;
t.recursive_estim            = 1;
t.dependent                  = data.variables;
t.prior                      = p;
t.parallel                   = false;
t.draws                      = 1000;
t.recursive_estim_start_date = '2014Q1';

% Create model and estimate in real-time
model = nb_var(t);
model = estimate(model);
print(model)              
  
% Check posterior draws
[~,plotter,pAutocorr] = checkPosteriors(model,'nLags',5,'iter','2017Q2');
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);

%% B-VAR (Real-time and recursive)

% This will set the recursive estimation start date
dates  = data.getRealEndDatePages();
recInd = find(strcmpi('2014Q1',dates),1);

% Options
t                 = nb_var.template();
t.data            = data(:,:,recInd+1:end);
t.constant        = 1;
t.nLags           = 4;
t.real_time_estim = 1;
t.dependent       = data.variables;
t.prior           = p;
t.parallel        = false;

% Create model and estimate in real-time
model = nb_var(t);
model = estimate(model);
print(model)   

% Check posterior draws
[~,plotter,pAutocorr] = checkPosteriors(model,'nLags',5,'iter','2017Q2');
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);

%% B-VAR (Real-time and recursive in parallel)
% No waitbar in this case, see progress in the file 
% real_time_estimation_worker.txt in the folder given by the 
% nb_userpath('gui')

% Options
t                 = nb_var.template();
t.data            = data; % Over all periods
t.constant        = 1;
t.nLags           = 4;
t.real_time_estim = 1;
t.dependent       = data.variables;
t.prior           = p;
t.parallel        = true;

% Create model and estimate in real-time
model = nb_var(t);
model = estimate(model);
print(model)   

% Check posterior draws
[~,plotter,pAutocorr] = checkPosteriors(model,'nLags',5,'iter','2017Q2');
nb_graphSubPlotGUI(plotter);
nb_graphSubPlotGUI(pAutocorr);
