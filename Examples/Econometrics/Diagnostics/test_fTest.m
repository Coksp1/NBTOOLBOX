%% Test F-test

% Simulate data
beta = 0.8;
zeta = 0.4;
x    = randn(100,1);
z    = randn(100,1);
e    = randn(100,1)*0.1;
y    = beta*x + zeta*z + e;

% Estimate model
[betaHat,~,~,~,residual,X] = nb_ols(y,[x,z],true,false);

% Do F-test
A             = [1,0,0];
c             = zeros(3,1);
[fTest,fProb] = nb_restrictedFTest(A,c,X,betaHat,residual)
