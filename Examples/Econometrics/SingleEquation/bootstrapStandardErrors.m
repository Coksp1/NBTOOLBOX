%% Get help on this example

nb_singleEq.help
help nb_singleEq.calculateStandardError

%% Generate artificial data

x1 = randn(50,1);
x2 = randn(50,1);
e  = 0.5*randn(50,1);
y  = 0.5*x1 + 0.2*x2 + e;

data = nb_ts([y,x1,x2],'','1990Q1',{'y','x1','x2'});

%% Estimate

options           = nb_singleEq.template();
options.dependent = {'y'};
options.exogenous = {'x1','x2'};
options.data      = data;
options.constant  = false;
model             = nb_singleEq(options);

% Estimate model
model = estimate(model);
print(model)

%% Confidence intervals

cit = parameterIntervals(model,0.05)

%% Bootstrap standard errors and confidence intervals

model       = solve(model);
[modelB,ci] = calculateStandardError(model,'bootstrap',1000,0.05);
print(modelB)

%% Test expression

model = solve(model);  

% Null: 0. Alternativ: Two-sided. I.e higher or lower than 0.
[pval,ci]  = testParameters(model,'y_x1')

% Null: 0. Alternative: One-sided higher than 0.
[pvalH,ci] = testParameters(model,'y_x1','bootstrap',1000,0.1,'>')

% Null: 0. Alternative: One-sided lower than 0.
[pvalL,ci] = testParameters(model,'y_x1','bootstrap',1000,0.1,'<')
