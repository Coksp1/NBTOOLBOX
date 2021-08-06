%% Create a artificial series

rng(1) % Set seed

% Observed time-varying parameter
lambda_d = nb_distribution('type','uniform','parameters',{0.7,0.9});
lambda_c = random(lambda_d,100);

% Cyclical component
rng(1) % Set seed

drawsC   = randn(100,1);
yc       = zeros(101,1);
breakP   = 50;
for ii = 2:101
    yc(ii) = lambda_c(ii-1)*yc(ii-1) + drawsC(ii-1);
end
yc = yc(2:end);

% Trend component
drawsT = randn(100,1);
ytd    = filter(1,[1,-0.5],drawsT); % ARIMA(1,0,0)
yt     = nb_undiff(ytd,1);

% Noise component
yn     = 0.1*randn(100,1);

% Level series
y = yc + yt + yn;

% Convert to nb_ts object
date = nb_quarter('1990Q1');
vars = {'y','yc','yt','yn','lambda_c'};
data = nb_ts([y,yc,yt,yn,lambda_c],'','1990Q1',vars);

%% Parse model

model = nb_dsge('nb_file','model.nb');

%% Assign parameters and solve

param.lambda_c = 0.7;
param.lambda_t = 0.5;
param.std_ec   = 1;
param.std_en   = 0.1;
param.std_et   = 1;
model          = assignParameters(model,param);
model          = solve(model);

%% Filter

model = set(model,'data',data,'timeVarying',{'lambda_c'});
model = filter(model,...
    'kf_method','diffuse');

filt  = getFiltered(model);
filt  = keepVariables(filt,vars);

%% Plot

dataC    = deleteVariables(data,{'lambda_c'});
plotData = addPages(dataC,filt);
plotter  = nb_graph_ts(plotData);
plotter.set('legends',{'Simulated','Filtered'});
nb_graphSubPlotGUI(plotter);

%% Estimate

% Set priors
priors          = struct();
priors.lambda_t = {0.5,0.5,0.2,'beta'};
priors.std_ec   = {0.9,1,10,'invgamma'};
priors.std_en   = {0.05,0.1,10,'invgamma'};
priors.std_et   = {0.7,1,10,'invgamma'};

% Estimate the model
mest = estimate(model,'prior',priors,'data',data,...
    'kf_init_variance',1,'kf_presample',4,...
    'kf_method','diffuse');
print(mest)

% Run the kalman filter
mest = filter(mest,'kf_method','diffuse');
filt = getFiltered(mest);
filt = keepVariables(filt,vars);

%% Plot

dataC    = deleteVariables(data,{'lambda_c'});
plotData = addPages(dataC,filt);
plotter  = nb_graph_ts(plotData);
plotter.set('legends',{'Simulated','Estimated'});
nb_graphSubPlotGUI(plotter);
