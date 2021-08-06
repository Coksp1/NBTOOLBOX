%% Get help on the nb_ecm class

nb_ecm.help
help nb_ecm.forecast

%% Simulate some data

rng(1) % Set seed

z     = nan(100,1);
scale = 10;
z(1)  = scale*rand;
for ii = 2:100
    z(ii) = z(ii-1) + scale*rand;
end
x1 = z + randn(100,1);
x2 = z + randn(100,1);
y  = 0.2 + 0.6*x1 + 0.4*x2 + 2*randn(100,1);
w1 = randn(100,1);
w2 = randn(100,1);

% plot(z)
% plot([x1,x2,y])

data = nb_ts([y,x1,x2,w1,w2],'','1990Q1',{'y','x1','x2','w1','w2'});

%% Estimate ECM model 
% Two step method. This model can only be estimated!

t = nb_ecm.template;
t.data       = data;
t.dependent  = {'y'};
t.endogenous = {'x1','x2'};
t.method     = 'twoStep';
t.constant   = 1;

model = nb_ecm(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate ECM model
% Two step method. This model can only be estimated!

t = nb_ecm.template;
t.data       = data;
t.dependent  = {'y'};
t.endogenous = {'x1','x2'};
t.method     = 'twoStep';
t.constant   = 1;
t.nLags      = [2,2,1]; % Set lags of each variable

model = nb_ecm(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate ECM model
% Two step method. This model can only be estimated!

t = nb_ecm.template;
t.data       = data;
t.dependent  = {'y'};
t.endogenous = {'x1','x2'};
t.method     = 'twoStep';
t.constant   = 1;
t.nLags      = {[1,2],[1,2],2}; % Set lags of each variable

model = nb_ecm(t);
model = estimate(model);
print(model)

% Solve
model = solve(model);

%% Estimate ECM model. Model selection
% Two step method. This model can only be estimated!

t = nb_ecm.template;
t.data            = data;
t.dependent       = {'y'};
t.endogenous      = {'x1','x2'};
t.modelSelection  = 'autometrics';
t.method          = 'twoStep';
t.constant        = 1;

model = nb_ecm(t);
model = estimate(model);
print(model)
