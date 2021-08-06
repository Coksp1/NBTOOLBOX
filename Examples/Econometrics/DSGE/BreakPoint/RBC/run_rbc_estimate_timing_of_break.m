%% Help on this example

help nb_dsge.addBreakPoint
help nb_dsge.simulate
help nb_dsge.estimate

%% Parse model 

m = nb_dsge('nb_file','rbc_stoch2.nb','silent',false,...
            'steady_state_file','rbc_steadystate');

%% Assign baseline calibration

p       = struct();
p.alpha = 0.17;
p.beta  = 0.999;
p.delta = 0.1;
p.rho_a = 0.5;
p.rho_i = 0.7;
p.rho_y = 0.2;
p.std_a = 0.1;
p.std_i = 0.15;
p.std_y = 0.05;
m       = assignParameters(m,p);

%% Assign new parameter value
% Actual break take place at 2000Q2

mBP = addBreakPoint(m,{'alpha'},0.2,'2000Q2');

%% Solve model in both regimes

mBP = solve(mBP);

%% Simulate the break-point model

sim = simulate(mBP,80,'startDate','1990Q1','draws',1);
sim = sim.Model1;
p   = plot(sim,'graphSubPlots');
nb_graphSubPlotGUI(p);

%% Assign new parameter value
% Assume break take place at 2000Q1

mBP = addBreakPoint(m,{'alpha'},0.2,'2000Q1');

%% Estimate the magnitude and timing of the break-point

% Priors
priors              = struct();
priors.alpha_2000Q1 = {0.17, 0.1,0.3,'uniform'};

% The syntax of a prior of the timing of a break point is 
% special. Only a uniform prior is supported, the bound must
% be given (as dates). The inital point will be given by the
% given date of the postulated break, i.e. 2000Q1 in this case.
priors.break_2000Q1 = {'1999Q1','2001Q1'}; 
mBPTEst             = set(mBP,'prior',priors);

% Filtering options
mBPTEst = set(mBPTEst,...
'kf_init_variance', [],...
'kf_presample',     5);

% Plot prior
plotter = plotPriors(mBPTEst);
nb_graphMultiGUI(plotter);

%% Mode estimatation
% Must use a derivative free optimizer in this case, as the timing of
% the break is discrete uniformly distributed, which means that the 
% likelihood will be a step function. So either the derivative is 0 or 
% +/-inf.  
%
% Caution: If the break-point is estimated to be something else than the
%          inital value, we update the parameter names of the breaks and  
%          the domain of the priors of the timing of the breaks 
%          accordingly.
opt         = nb_getDefaultOptimset('nb_abc');
opt.maxTime = 60; 

mBPTEst = set(mBPTEst,'data',sim);
mBPTEst = estimate(mBPTEst,'optimizer','nb_abc','optimset',opt);
mBPTEst.print 

%% Get curvature of objective 

mBPTEst = solve(mBPTEst);
plotter = curvature(mBPTEst,[0.2;0],'numEvalPoints',20);
nb_graphMultiGUI(plotter)
