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
dataQ   = convert(data,4,'diffAverage');
dataQM  = convert(dataQ,12,'','interpolateDate','end');
dataQM  = addPrefix(dataQM,'Q_');
data  = [dataQM,data]; 

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
t.observables      = {'Var1','Var3','Var4','Var5','Var6','Var7','Q_Var2'};
t.frequency        = {'Q_Var2',4};
t.estim_method     = 'tvpmfsv';
t.nLags            = 5;
t.estim_start_date = data.startDate;
t.estim_end_date   = data.endDate;
t.transformation   = 'standardize';
t.recursive_estim  = 1;
model              = nb_fmdyn(t);

%% Set prior

prior = nb_fmdyn.priorTemplate();

% -------------------------- TVP and SV -----------------------------------
% To turn off time-varying parameters or stochastic volatility, simply
% manipulate the prior structure:

% - e.g. to turn off time variation in the state equations' VAR paramters:
% prior.l_4 = 1

% - e.g. to turn off stochastic volatility in the factor state equations'
% error variance:
% prior.l_2 = 1

% for more information type "help nb_fmdyn.priorTemplate"
% -------------------------------------------------------------------------

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
plotter.set('startGraph','2005M1');
nb_graphSubPlotGUI(plotter);

%% Recursive forecast

modelF  = forecast(modelS,3,'fcstEval','SE');
plotter = plotForecast(modelF,'hairyplot');
nb_graphSubPlotGUI(plotter);
