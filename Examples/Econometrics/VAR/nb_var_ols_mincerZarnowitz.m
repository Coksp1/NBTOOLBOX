%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);

%% Get help on the nb_var class

nb_var.help
help nb_var.mincerZarnowitzTest

%% Recursive estimation of VAR

% Options
t                 = nb_var.template();
t.data            = sim;
t.estim_method    = 'ols';
t.dependent       = sim.variables;
t.constant        = false;
t.nLags           = 2;
t.recursive_estim = 1;
% t.rollingWindow   = 20; % Include to estimate with rolling window!
t.recursive_estim_start_date = '2013M12';

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Recursive point forecast (Out-of-sample)

modelS = solve(model);
modelF = forecast(modelS,8,'fcstEval', 'SE','startDate', '2014M1');

%% Mincer-Zarnowitz test
        
[test,pval,printed] = mincerZarnowitzTest(modelF)
