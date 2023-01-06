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

%% Estimate the factors

t             = nb_calculate_factors.template();
t.data        = data;
t.observables = data.variables;
t.nFactors    = 2;
calculator    = nb_calculate_factors(t);
calculator    = estimate(calculator);
print(calculator)

%% Get the factors

factors = getCalculated(calculator)

%% Test the calculate method

t             = nb_calculate_factors.template();
t.data        = data;
t.observables = data.variables;
t.nFactors    = 2;
calculator    = nb_calculate_factors(t);
factors       = calculate(calculator);
