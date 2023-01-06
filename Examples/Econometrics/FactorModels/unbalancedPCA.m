%% Simulate dataset

rng(2); % Set seed

T      = 100;
N      = 25;
r      = 1;
eps    = 0.01*randn(T,r);
alpha  = rand(1,r)*2 - 1; % [-1,1]
a      = 0;
b      = 0;
C      = min(floor(N/20),10);

% Simulate mean 0 I(0) factors
F = zeros(T+1,r);
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
LAct    = nb_cs(Lambda','Lambda',nb_appendIndexes('Factor',1:r)',...
                nb_appendIndexes('Var',1:N)');

%% PCA balanced dataset

[Fest,L,R,varF,expl,c,sigma,e,dataNorm] = pca(data,1);

%% Plot estimated factor

FestD = addPrefix(Fest,'Est_');
plotD = merge(FestD,factors);
p     = nb_graph_ts(plotD);
p.set('legends',{'Estimated','Actual'},....
      'variablesToPlot',{'Est_Factor1'},...
      'variablesToPlotRight',{'Factor1'},...
      'yDir','reverse');
nb_graphPagesGUI(p);

%% Decompose

decomp  = -dataNorm.*L;
plotter = nb_graph_ts(decomp);
plotter.set('plotType','dec');
nb_graphPagesGUI(plotter);

%% PCA unbalanced 

dataUn = setToNaN(data,data.startDate,data.startDate+10,'Var1');
dataUn = setToNaN(dataUn,data.startDate,data.startDate+20,'Var2');
% dataUn = setToNaN(dataUn,data.startDate,data.startDate);
[FestUn,LUn,RUn,varFUn,explUn,cUn,sigmaUn,eUn] = ...
    pca(dataUn,1,'','unbalanced',true);

%% Plot estimated factor (PCA balanced and PCA unbalanced)

FestD   = addPrefix(Fest,'Est_');
FestDUn = addPrefix(FestUn,'Est_unbalanced_');
plotD   = [FestDUn,FestD,factors];
p       = nb_graph_ts(plotD);
p.set('legends',{'Estimated','Estimated(unbalanced)','Actual'},....
      'variablesToPlot',{'Est_Factor1','Est_unbalanced_Factor1'},...
      'variablesToPlotRight',{'Factor1'},...
      'yDir','reverse');
nb_graphPagesGUI(p);

%% Formulate dynamic factor model

dataUn = setToNaN(data,data.startDate,data.startDate+10,'Var1');
dataUn = setToNaN(dataUn,data.startDate,data.startDate+20,'Var2');

t                    = nb_fmdyn.template();
t.data               = dataUn;
t.nLags              = 1; % Assume a AR(1) for the factor.
t.observables        = data.variables;
t.estim_start_date   = data.startDate;
t.estim_end_date     = data.endDate;
t.nFactors           = 1;
t.transformation     = 'standardize';
t.nLagsIdiosyncratic = 0; % No serial correlation in the idiosyncartic components
model                = nb_fmdyn(t);

% Estimate model
model = estimate(model,'fix_point_verbose',true,'initDiff',0);
% print(model)

%% Plot estimated factor (all metods)

Fdyn    = getFactors(model);
Fdyn    = addPrefix(Fdyn,'Dyn_');
FestD   = addPrefix(Fest,'Est_');
FestDUn = addPrefix(FestUn,'Est_unbalanced_');
plotD   = [Fdyn,FestDUn,FestD,factors];
p       = nb_graph_ts(plotD);
p.set('legends',{'Dynamic(unbalanced)','Estimated','Estimated(unbalanced)','Actual'},....
      'variablesToPlot',{'Dyn_Factor1','Est_Factor1','Est_unbalanced_Factor1'},...
      'variablesToPlotRight',{'Factor1'},...
      'yDir','reverse');
nb_graphPagesGUI(p);
