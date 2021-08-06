%% Generate artificial data
% With one cointegration vector.

rng(10); % Set seed

obs     = 100;
lambda  = [0.7,  0.1,  0.1,;
           0.5, -0.4, -0.2;
           0.6, -0.2,  0.1];
alpha   = [1 -1 -1]; % The cointegration vector.
beta    = [0.2;0.3;.4];
PIE     = beta*alpha;
DY      = zeros(3,obs + 1);
Y       = nan(3,obs + 1);
Y(1,1)  = 100;
Y(2,1)  = 50;
Y(3,1)  = 50;     
for tt = 2:obs+1
    DY(:,tt) = PIE*Y(:,tt-1) + lambda*DY(:,tt-1) + randn(3,1);
    Y(:,tt)  = Y(:,tt-1) + DY(:,tt);
end
DY = nb_ts(DY(:,2:end)','','1990Q1',{'DY1','DY2','DY3'});
Y  = nb_ts(Y(:,2:end)','','1990Q1',{'Y1','Y2','Y3'});

% plot(DY)
% plot(Y)

%% Engle-Granger (adf)

[results,model] = nb_egcoint(Y,'nlags',2)

[results,model] = nb_egcoint(Y,'lagLengthCrit','aic')

%% Johansen

[results,models] = nb_jcoint(Y)

%% nb_cointTest Class (E-G)

test = nb_cointTest(Y,'eg','lagLengthCrit','aic');
print(test)

%% nb_cointTest Class (Johansen)

test = nb_cointTest(Y,'jo','nLags',4);
print(test)

