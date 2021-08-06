%%
nb_clearall

%% Identify model with zero and sign restrictions

data = nb_ts('Smets_Wouters_data');

% Options
t                  = nb_var.template();
t.data             = data;
t.prior            = nb_var.priorTemplate('jeffrey');
t.dependent        = {'dw','dy','labobs','pinfobs','robs'};
t.nLags            = 3;
t.block_exogenous  = {'dc','dinve'};
t.estim_start_date = data.startDate + t.nLags;
t.estim_end_date   = '';
t.constant         = 1;
t.time_trend       = 0;
t.recursive_estim  = 0;
t.draws            = 1;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print_estimation_results(model)


restriction ={
    'dy',       'mp',inf,   0,  []
%     'dy',       'ad',inf,   0,  []
%     'dy',       'as',inf,   0,  []
%     'dy',       'ls',inf,   0,  []
    'robs',     'mp',0,     '+',[]
%     'robs',     'ad',0,     '+',[]
%     'robs',     'as',0,     '-',[]
%     'robs',     'ls',0,     '-',[]
    'dy',       'mp',0,     '-',[]
%     'dy',       'ad',0,     '+',[]
%     'dy',       'as',0,     '+',[]
%     'dy',       'ls',0,     '+',[]
%     'labobs',   'ls',0,     '+',[]
%     'pinfobs',  'mp',0,     '-',[]
%     'pinfobs',  'ad',0,     '+',[]
%     'pinfobs',  'as',0,     '-',[]
%     'pinfobs',  'ls',0,     '-',[]
%     'dw',       'ls',0,     '-',[]
%     'dw',       'ls',0,     '<',0
};

model = set_identification(model,'combination',...
                                 'restrictions',restriction,...
                                 'maxDraws',100000);
                             
notSolved = true;                             
while notSolved
    try 
        model     = solve(model);
        notSolved = false;
    catch Err
        disp(Err.message)
    end
end

%% Produce irfs
% Go to the folder returned by nb_userpath('gui') using window explorer.
% In this folder you can find files with name irf_worker_X, where X is
% the worker id.
%
% Another file called input_file_YYYYMMDDHHNNSS is made in the same folder.
% Type in cancel to cancel the process, type in pause to pause
% the process. In the last case you can continue using the next section

[~,~,plotter,modelT] = irf(model,'perc',0.68,'shocks',{},'replic',1000,...
                                 'parallelL',true);
if ~isempty(plotter)                
    nb_graphInfoStructGUI(plotter);
end

%% Continue from paused run

if ~isempty(modelT) % If empty it has not been paused
    [~,~,plotter,modelTT] = irf(modelT,'continue',true);
    if ~isempty(plotter)                
        nb_graphInfoStructGUI(plotter);
    end
end
