%% Simulate dataset

rng(2); % Set seed

T      = 100;
N      = 25;
r1     = 0;
r2     = 2;
r3     = 2;
r      = r1 + r2 + r3;
eps    = 0.01*randn(T,r);
rho    = rand(1,r2);       % [0,1]
alpha  = rand(1,r3)*2 - 1; % [-1,1]
a      = 0;
b      = 0;
C      = min(floor(N/20),10);

F = zeros(T+1,r);
if r1 > 0
    % Simulate factor with linear trend 
    for tt = 1:T
        F(tt+1,1) = 1 + F(tt,1) + 7*eps(tt,1);
    end
    ind = 2;
else
    ind = 1;
end

if r2 > 0
    % Simulate mean 0 I(1) factors
    e    = zeros(T+1,r2);
    ind2 = ind:ind+r2-1;
    for tt = 1:T
        e(tt+1,:)    = rho.*e(tt,:) + eps(tt,ind2);
        F(tt+1,ind2) = F(tt,ind2) + e(tt+1,:);
    end
    ind = ind + r2;
end

if r3 > 0
    % Simulate mean 0 I(0) factors
    ind3 = ind:ind+r3-1;
    for tt = 1:T
        F(tt+1,ind3) = alpha.*F(tt,ind3) + 10*eps(tt,ind3);
    end
end

F = F(2:end,:);

% Simulate factor loadings
X          = randn(100,N);
[~,Lambda] = nb_pca(X,r);
Lambda     = sqrt(N)*Lambda;
Lambda     = Lambda';

% Simulate measurment equation
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

plotter = nb_graph_ts(data);
plotter.set('subPlotSize',[3,3]);
nb_graphSubPlotGUI(plotter);

plotter = nb_graph_ts(factors);
if r > 4
    if r > 6
        plotter.set('subPlotSize',[3,3]);
    else
        plotter.set('subPlotSize',[3,2]);
    end
end
nb_graphSubPlotGUI(plotter);

%% Formulate dynamic factor model

t                  = nb_fmdyn.template();
t.data             = data;
t.nLags            = 1;
t.nonStationary    = nb_conditional(r2 > 0,true,false);
t.observables      = data.variables;
t.estim_start_date = data.startDate;
t.estim_end_date   = data.endDate;
t.transformation   = 'standardize';
model              = nb_fmdyn(t);

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

model = estimate(model,'fix_point_verbose',true,'initDiff',0);
print(model)

%% Plot factors with error bands
% The error bands are conditional on the parameters are the true 
% parameters!

plotter = plotFactors(model,true);
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

% help nb_fmdyn.solution

%% Decompose the variables and factors into trend, cycle and noise

O = trendAndCycle(model,'q',r2,'m',r3);
p = nb_graph_ts(O);
p.set('plotType','dec','lineWidth',1,'startGraph','2006M1');
nb_graphSubPlotGUI(p);

%% Forecast

modelF  = forecast(modelS,8);
plotter = plotForecast(modelF);
plotter.set('startGraph','2005M1');
nb_graphSubPlotGUI(plotter);
