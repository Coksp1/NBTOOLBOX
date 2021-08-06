
nb_clearall

%% Simulate som artificial data

b0 = 0;
b1 = 0.5;

w = nan(13,1);
for ii = 1:15
    w(ii) = 16-ii;
end
w = w/sum(w);

pie = [randn;zeros(99,1)];
for tt = 2:100
    pie(tt) = 0.7*pie(tt-1) + randn;
end
cai = nan(size(pie));
eps = randn(100,1)*0.5;
for tt = 13:100 
    term = 0;
    for lag = 0:12
        term = term + w(lag+1)*pie(tt-lag);
    end
    cai(tt) = b0 + b1*(term) + eps(tt);
end
data = nb_ts([cai,pie,eps],'','1990Q1',{'CAI','PIE','EPS'});
plot(data)

%% Estimate non-linear model with parameter constraints

% Optimizer options
opt             = nb_getDefaultOptimset([],'fmincon');
opt.MaxIter     = 1000;
opt.MaxFunEvals = inf;

% Lower bounds (Does that are not set will be given a lower bound of -inf)
lb = struct();
for ii = 0:12
    lb.(['w' int2str(ii)]) = 0;
end

% Upper bounds (Does that are not set will be given a upper bound of inf)
ub = struct();
for ii = 0:12
    ub.(['w' int2str(ii)]) = 1;
end

% Initial value (Does that are not set will be given 0 as initial value)
init = struct('w0',1);

% Parse model file
model = nb_nonLinearEq.parse('model.nb','macroProcessor',true,...
                             'macroWriteFile','model');

% Assign the data
model = set(model,'data',data,'optimset',opt,'ub',ub,'lb',lb,'init',init);

% Estimate
model = estimate(model);
print(model)

%% 

plotter = getResidualGraph(model);
nb_graphInfoStructGUI(plotter);

plot(data('EPS'))
