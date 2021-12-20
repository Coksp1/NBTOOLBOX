%% Test Wald test

q  = [0.5,0.8];
nq = size(q,2);
nc = 3;
d  = [1,-1, 0;
     0, 1,-1];
s  = eye(nc);
A  = kron(d,s);
A  = A(1:nc,1:nq*nc);
c  = zeros(nc,1);

% Simulate data
beta = 0.8;
zeta = 0.4;
x    = randn(100,1);
z    = randn(100,1);
e    = randn(100,1)*0.1;
y    = beta*x + zeta*z + e;

% Estimate model
[betaHat,~,~,~,residual,X] = nb_qreg(q,y,[x,z],true,false);

% Do test
betaHatStacked = betaHat(:);
[wTest,wProb]  = nb_quantileWaldTest(A,c,X,betaHatStacked,permute(residual,[1,3,2]),q) 
