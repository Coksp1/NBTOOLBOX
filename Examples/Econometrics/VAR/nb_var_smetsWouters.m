%% Load data

data = nb_ts('Smets_Wouters_data');

%% Estimate model with jeffrey prior

% Options
t                  = nb_var.template();
t.data             = data;
t.prior            = nb_var.priorTemplate('jeffrey');
t.dependent        = {'dw','dy','labobs','pinfobs','robs'};
t.nLags            = 3;
t.block_exogenous  = {'dc','dinve'};
t.constant         = 1;
t.draws            = 1000;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print_estimation_results(model)

%% Set zero and sign restriction and find one accepted draw

restriction ={
    'dy',       'mp',inf,   0,  []
    'dy',       'ad',inf,   0,  []
    'dy',       'as',inf,   0,  []
    'dy',       'ls',inf,   0,  []
    'robs',     'mp',0,     '+',[]
    'robs',     'ad',0,     '+',[]
    'robs',     'as',0,     '-',[]
    'robs',     'ls',0,     '-',[]
    'dy',       'mp',0,     '-',[]
    'dy',       'ad',0,     '+',[]
    'dy',       'as',0,     '+',[]
    'dy',       'ls',0,     '+',[]
    'labobs',   'ls',0,     '+',[]
    'pinfobs',  'mp',0,     '-',[]
    'pinfobs',  'ad',0,     '+',[]
    'pinfobs',  'as',0,     '-',[]
    'pinfobs',  'ls',0,     '-',[]
    'dw',       'ls',0,     '-',[]
};

model = set_identification(model,'combination',...
                                 'restrictions',restriction,...
                                 'maxDraws',100000);
                             
%% Identify model with zero and sign restrictions and produce irfs                             
                             
model         = solve(model);
[~,~,plotter] = irf(model,'perc',0.68,'shocks',{},'replic',100);
nb_graphInfoStructGUI(plotter);

%% Test in parallel (low level) (Parallel Toolbox needed)

[irfs,irfsBand,plotter] = irf(model,'perc',0.68,...
                            'replic',100,'stabilityTest',true,...
                            'parallelL',true,'cores',[]);
nb_graphInfoStructGUI(plotter);
