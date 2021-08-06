%% Help on this example

help nb_ts.extrapolate

%% Create data

dist(1,4) = nb_distribution(); % Marginal normals
sigma     = [4 3 2 1;3 5 2 1;2 2 4 2;1 1 2 5];
stds      = sqrt(diag(sigma));
stds      = stds*stds';
sigma     = sigma./stds; % Correlation matrix
cop       = nb_copula(dist,'sigma',sigma);
E         = random(cop,100,1);

Y      = E;
lambda = [0.5,0.2,1,0.9];
for ii = 1:4
    lam = lambda(ii);
    for tt = 2:100
        Y(tt,ii) = lam*Y(tt-1,ii) + E(tt,ii);
    end
end

% Make some observation blank
Yb              = Y;
Yb(end-3:end,2) = nan;

% Convert to nb_ts
data = nb_ts(Yb,'','1',{'Var1','Var2','Var3','Var4'});

%% Fill blanks and forecast using autocorrelation and a copula

dataExt = extrapolate(data,{},'103','method','copula','nLags',5,...
                                    'check',true);
dataExt.dataNames = {'Copula'};    
                                
%% Fill blanks with AR model

dataExtAR = extrapolate(data,{},'103','method','ar');
dataExtAR.dataNames = {'AR'}; 

%% Plot

dataP   = addPages(dataExt,dataExtAR);
plotter = nb_graph_ts(dataP);
nb_graphSubPlotGUI(plotter)

