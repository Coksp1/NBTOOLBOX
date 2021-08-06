%% Get help on this example

nb_var.help
help nb_var.parameterDraws

% See also the documentation of the 'foundReplic' input to
help nb_var.irf
help nb_var.variance_decomposition
help nb_var.forecast

%% Generate artificial data

rng(1); % Set seed

obs     = 100;
lambda  = [0.5, 0.1,0.3, 0.2,0.2,-0.1;
           0.5,-0.1,-0.2,0,  0.1,-0.2;
           0.6,-0.2,0.1, 0,  0.4,-0.1];
rho     = [1;1;1];  
sim     = nb_ts.simulate('2012M1',obs,{'VAR1','VAR2','VAR3'},1,lambda,rho);

%nb_graphSubPlotGUI(sim);
  

%% Set up VAR 

% Options
t           = nb_var.template();
t.data      = sim;
t.dependent = {'VAR1','VAR2','VAR3'};
t.constant  = false;
t.nLags     = 2;

% Create model and estimate
model = nb_var(t);
model = estimate(model);
print(model)

%% Identify VAR model and solve

model    = set_identification(model,'cholesky',...
                'ordering',model.dependent.name);
model    = solve(model);

%% Draw parameters
% Instead of drawing the parameters inside irf, variance_decomposition
% and forecast, you can draw them once and for all using the
% parameterDraws method. 
%
% This also applies to bayesian model. Just set the 3rd input to 
% 'posterior' instead.

mDraws = parameterDraws(model,4000,'bootstrap','solution',true,...
            'parallel',false);

%% IRFs

[~,~,plotter] = irf(model,'foundReplic',mDraws,'perc',0.68);
nb_graphInfoStructGUI(plotter);

%% FEVD

[~,~,plotter,plotterBands] = variance_decomposition(model,...
                                'foundReplic',mDraws,...
                                'perc',0.68,'horizon',[1,8]);
                            
nb_graphPagesGUI(plotter);
nb_graphSubPlotGUI(plotterBands.Model1(1));
                            
%% Forecast

model = forecast(model,8,...
        'foundReplic',      mDraws,...
        'draws',            2,...
        'parameterDraws',   2000);
plotter = plotForecast(model);
nb_graphSubPlotGUI(plotter);
        
