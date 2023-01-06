%% Simulate dataset

rng(2); % Set seed

T     = 100;
N     = 25;
r     = 2;
eps   = 0.01*randn(T,r);
alpha = [0.7,0.4]; % [-1,1]
a     = 0;
b     = 0;
C     = min(floor(N/20),10);

F = zeros(T+1,r);

% Simulate mean 0 I(0) factors
for tt = 1:T
    F(tt+1,:) = alpha.*F(tt,:) + 10*eps(tt,:);
end

F = F(2:end,:);

% Simulate factor loadings
X          = randn(100,N);
[~,Lambda] = nb_pca(X,r);
Lambda     = sqrt(N)*Lambda;
Lambda     = Lambda';

% Simulate measurement equation
nu = randn(T,N);
u  = zeros(T+1,N);
for tt = 1:T
    for ii = 1:N
        k          = [max(ii-C,1):ii-1,ii+1:min(ii+C,N)];
        u(tt+1,ii) = a*u(tt,ii) + nu(tt,ii) + b*sum(nu(tt,k));
    end
end
u = u(2:end,:);

theta = 0.5*sum(sum((Lambda*F').^2,2),1)/sum(sum(u.^2,1),2);
X     = F*Lambda' + sqrt(theta).*u;

%% Construct time-series

date    = '2000M1';
data    = nb_ts(X,'',date,nb_appendIndexes('Var',1:N)');
factors = nb_ts(F,'Simulated',date,nb_appendIndexes('Factor',1:r)'); 

%% Plot simulated data

% plotter = nb_graph_ts(data);
% plotter.set('subPlotSize',[3,3]);
% nb_graphSubPlotGUI(plotter);
% 
% plotter = nb_graph_ts(factors);
% if r > 4
%     if r > 6
%         plotter.set('subPlotSize',[3,3]);
%     else
%         plotter.set('subPlotSize',[3,2]);
%     end
% end
% nb_graphSubPlotGUI(plotter);

%% Formulate dynamic factor model

data(end,25)       = nan;
t                  = nb_fmdyn.template();
t.data             = data;
t.estim_method     = 'tvpmfsv';
t.nLags            = 2;
t.observables      = data.variables;
t.estim_start_date = data.startDate;
t.estim_end_date   = data.endDate;
t.transformation   = 'standardize';
t.recursive_estim  = 1;
model              = nb_fmdyn(t);

%% Set prior

prior = nb_fmdyn.priorTemplate();

% -------------------------- TVP and SV -----------------------------------
% Here we set l_X_endo_update to true to update the forgetting factors 
% endogenously during estimation of the model
%
% prior.l_X are in this case the starting values of the forgetting factors
%
% for more information type "help nb_var.priorTemplate"
% -------------------------------------------------------------------------

prior.l_1m            = 1;
prior.l_1q            = 1;
prior.l_2             = 1;
prior.l_3             = 1;
prior.l_4             = 1;
prior.l_1_endo_update = 1;
prior.l_2_endo_update = 1;
prior.l_3_endo_update = 1;
prior.l_4_endo_update = 1;

model = setPrior(model,prior);

%% Determin the number of factors

R = nan; % Use actual
% R = detNumFactors(model,'horn');
% R = detNumFactors(model,'scree'); % Use figure to decide number of factors
% R = detNumFactors(model,'expl');
% R = detNumFactors(model,'bn');
% R = detNumFactors(model,'trapani');

%% Assign number of factors

if isnan(R)
    R = r; 
end
model = set(model,'nFactors',R);

%% Estimate model

tic
model = estimate(model);
toc
print(model)

%% Plot factors

plotter = plotFactors(model,false);
if r > 4
    if r > 6
        plotter.set('subPlotSize',[3,3]);
    else
        plotter.set('subPlotSize',[3,2]);
    end
end
nb_graphSubPlotGUI(plotter);

%% Solve model

modelS = solve(model);
modelS.solution

%% Forecast

modelF  = forecast(modelS,3);
plotter = plotForecast(modelF);
plotter.set('startGraph','2007M1');
nb_graphSubPlotGUI(plotter);

%% Recursive forecast

modelF  = forecast(modelS,3,'fcstEval','SE');
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);
