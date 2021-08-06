%% Get help on the nb_ecm class

nb_ecm.help
help nb_ecm.grouped_decomposition

%% Simulate some data

rng(1) % Set seed

z     = nan(100,1);
scale = 10;
z(1)  = 100 + scale*rand;
for ii = 2:100
    z(ii) = z(ii-1) + scale*rand;
end
x1 = z + randn(100,1);
x2 = z + randn(100,1);
x3 = z + randn(100,1);
w1 = z + rand(100,1)*4;

dy    = nan(100,1);
dy(1) = randn; 
for tt = 2:100
    dy(tt) = 0.7*dy(tt-1) + randn;
end
y  = dy + 0.6*(x1 + x3) + 0.4*x2 + 0.8*w1 + 2*randn(100,1);

data = nb_ts([y,x1,x2,x3,w1],'','1990Q1',{'y','x1','x2','x3','w1'});

% plot(data)

%% Initialize ECM model

t      = nb_ecm.template;
t.data = data;
model  = nb_ecm(t);

%% Do transformations (To store shift/trend)
%
% To decompose the history into the contribution of 'x1' and 'x3' 
% variables you need to use the createVariables method, as this tells 
% the code how to construct the variable 'x4' from these two. 

expressions = {
% Name,  expression,  shift/trend, description                                                                                                                               
'x4',    'x1+x3',     {},          ''
};
model = model.createVariables(expressions,8);

%% Formulate model

model = set(model,'constant',true,'dependent',{'y'},...
                  'endogenous',{'x2','x4'},'nLags',2,...
                  'exogenous',{'w1'}); 

%% Estimate

model = estimate(model);
print(model)

%% Solve model

model = solve(model);

%% Historical decomposition (Model variables)

[dec,p] = grouped_decomposition(model,'transformation','diff',...
                    'nLags',4,'method','shock_decomposition');
nb_graphPagesGUI(p);

%% Historical decomposition (Model variables)

[dec,p] = grouped_decomposition(model,'transformation','diff',...
                    'nLags',4,'method','recursive_forecast',...
                    'seasonalPattern',true);
nb_graphPagesGUI(p);

%% Historical decomposition (Input variables)

[dec,p] = grouped_decomposition(model,'transformation','diff',...
                    'nLags',4,'method','recursive_forecast',...
                    'inputVars',true,'seasonalPattern',true);
nb_graphPagesGUI(p);

