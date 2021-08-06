%% Simulate from a multivariate truncated normal distribution

mu    = [0.2;1];
sigma = [1,   0.8; 
         0.8, 1];
l     = [-1;-2];
u     = [inf;1];
Xt    = nb_mvtnrand(1000,1,mu,sigma,l,u);

figure;
scatterhist(Xt(:,1),Xt(:,2),'NBins',15);

%% Less correlation

mu    = [0.2;1];
sigma = [1,   0.2; 
         0.2, 1];
l     = [-1;-2];
u     = [inf;1];
Xt    = nb_mvtnrand(1000,1,mu,sigma,l,u);

figure;
scatterhist(Xt(:,1),Xt(:,2),'NBins',15);

%% Another example
% High lower bound


mu    = [0.2;1];
sigma = [1,   0.2; 
         0.2, 1];
l     = [1;-2];
u     = [inf;1];
Xn    = nb_mvtnrand(1000,1,mu,sigma,l,u);

figure;
scatterhist(Xn(:,1),Xn(:,2),'NBins',15);

%% Another example
% Low upper bound


mu    = [0.2;1];
sigma = [1,   0.2; 
         0.2, 1];
l     = [1;-3];
u     = [inf;-2];
Xn    = nb_mvtnrand(1000,1,mu,sigma,l,u);

figure;
scatterhist(Xn(:,1),Xn(:,2),'NBins',15);

%% Condition on a point

mu    = [0.2;1];
sigma = [1,   0.8; 
         0.8, 1];
l     = [-1;-2];
u     = [inf;1];
indC  = [false;true];
a     = 0;

Xnc = nb_mvtncondrand(1000,1,mu,sigma,l,u,indC,a);

figure;
scatterhist(Xnc(:,1),Xnc(:,2),'NBins',15);
