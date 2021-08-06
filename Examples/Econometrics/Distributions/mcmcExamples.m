%% Get help on this example

help nb_mcmc.mhSampler
help nb_mcmc.nutSampler

%% Test of Metropolis-Hastings algorithm (univariate)

sigma     = 0.5;
objective = @(x)exp(-0.5*(x./sigma).^2); % Proportional to the normal distribution
beta      = 0;

%% Use standard method to simulate (univariate)

betaSim       = randn(1000,1)*sigma;
sigmaStandard = std(betaSim)

%% Use random walk M-H sampler to draw from the distribution (univariate)

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma^2,'draws',draws,...
                'thin',thin,'burn',burn);

sigmaOut = std(output.beta)

toc

%% Use adaptive random walk M-H sampler to draw from the distribution
% Update the covariance matrix at each iteration (univariate)

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma^2,'draws',draws,...
                'thin',thin,'burn',burn,'qFunction','arw');

sigmaOut = std(output.beta)

toc

%% Use adaptive random walk M-H sampler to draw from the distribution
% Target an acceptance ratio (univariate)

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma^2,'draws',draws,...
                'thin',thin,'burn',burn,'qFunction','arw',...
                'accTarget',0.44,'adaptive','target');

sigmaOut = std(output.beta)

toc

%% Use adaptive random walk M-H sampler to draw from the distribution
% Update the covariance matrix at each iteration and target an 
% acceptance ratio. (univariate)

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma^2,'draws',draws,...
                'thin',thin,'burn',burn,'qFunction','arw',...
                'accTarget',0.44,'adaptive','recTarget');

sigmaOut = std(output.beta)

figure;
plot(output.beta)

toc

%% Use NUT sampler to draw from the distribution (univariate)
% The gradient is calculated numerically using nb_gradient

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.nutSampler(objective,beta,[],'draws',draws,...
                'thin',thin,'burn',burn,'accTarget',0.8,...
                'parallel',false,'chains',1,'waitbar',false);

sigmaOut = std(output(1).beta)

figure;
plot(output(1).beta)

toc


%% Test of Metropolis-Hastings algorithm

sigma     = [0.5, 0.3; 0.3, 0.8];
objective = @(x)mvnpdf(x,0,sigma);
beta      = nb_mvnrand(1,1,0,sigma);

%% Use standard method to simulate

betaSim       = nb_mvnrand(1000,1,0,sigma);
sigmaStandard = cov(betaSim)

%% Use random walk M-H sampler to draw from the distribution

tic

draws  = 2000;
thin   = 50;
burn   = 10000;
output = nb_mcmc.mhSampler(objective,beta,sigma,'draws',draws,...
                'thin',thin,'burn',burn,'waitbar',true,...
                'parallel',false,'chains',4);

sigmaOut = cov(vertcat(output(:).beta))

toc


% Check autocorrelation
[acf,lb,ub] = nb_autocorr(output(1).beta,5)

% Check convergence
[z,p] = nb_mcmc.geweke(output(1).beta)

% Plot
figure
plot(output(1).beta(:,1))
figure
plot(output(1).beta(:,2))

% Plot mean
mBeta1 = cumsum(output(1).beta(:,1))./(1:draws)';
figure;
plot(1:draws,mBeta1)

mBeta2 = cumsum(output(1).beta(:,2))./(1:draws)';
figure;
plot(1:draws,mBeta2)

% Gelman-Rubin test
R = nb_mcmc.gelmanRubin(output(:).beta);

% Plot recursive Gelman-Rubin test
Rrec = nb_mcmc.gelmanRubinRecursive(output(:).beta);
figure;
plot(Rrec(:,1))
figure;
plot(Rrec(:,2))

%% Use adaptive random walk M-H sampler to draw from the distribution
% Update the covariance matrix at each iteration

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma,'draws',draws,...
                'thin',thin,'burn',burn,'qFunction','arw');

sigmaOut = cov(vertcat(output(:).beta))

toc

%% Use adaptive random walk M-H sampler to draw from the distribution
% Target an acceptance ratio 

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma,'draws',draws,...
                'thin',thin,'burn',burn,'qFunction','arw',...
                'accTarget',0.44,'adaptive','target');

sigmaOut = cov(vertcat(output(:).beta))

toc

%% Use adaptive random walk M-H sampler to draw from the distribution
% Update the covariance matrix at each iteration and target an 
% acceptance ratio

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.mhSampler(objective,beta,sigma,'draws',draws,...
                'thin',thin,'burn',burn,'qFunction','arw',...
                'accTarget',0.44,'adaptive','recTarget');

sigmaOut = cov(vertcat(output(:).beta))

toc

%% Use NUT sampler to draw from the distribution (univariate)
% The gradient is calculated numerically using nb_gradient

tic

draws  = 1000;
thin   = 10;
burn   = 4000;
output = nb_mcmc.nutSampler(objective,beta,[],'draws',draws,...
                'thin',thin,'burn',burn,'accTarget',0.8,...
                'parallel',false,'chains',1,'waitbar',false);

sigmaOut = cov(vertcat(output(:).beta))

figure;
plot(output(1).beta)

toc
