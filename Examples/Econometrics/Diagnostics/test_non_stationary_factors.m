%% Simulate dataset

rng(1); % Set seed

T      = 100;
N      = 25;
r1     = 0;
r2     = 2;
r3     = 3;
r      = r1 + r2 + r3;
eps    = 0.01*randn(T,r);
rho    = rand(1,r2);       % [0,1]
alpha  = rand(1,r3)*2 - 1; % [-1,1]
a      = 0;
b      = 0;
C      = min(floor(N/20),10);

F = zeros(T+1,r);
if r1 > 0
    % Simulate factor with linear trend 
    for tt = 1:T
        F(tt+1,1) = 1 + F(tt,1) + 7*eps(tt,1);
    end
    ind = 2;
else
    ind = 1;
end

if r2 > 0
    % Simulate mean 0 I(1) factors
    e    = zeros(T+1,r2);
    ind2 = ind:ind+r2-1;
    for tt = 1:T
        e(tt+1,:)    = rho.*e(tt,:) + eps(tt,ind2);
        F(tt+1,ind2) = F(tt,ind2) + e(tt+1,:);
    end
    ind = ind + r2;
end

if r3 > 0
    % Simulate mean 0 I(0) factors
    ind3 = ind:ind+r3-1;
    for tt = 1:T
        F(tt+1,ind3) = alpha.*F(tt,ind3) + 10*eps(tt,ind3);
    end
end

F = F(2:end,:);

% Simulate factor loadings
X          = randn(100,N);
[~,Lambda] = nb_pca(X,r);
Lambda     = sqrt(N)*Lambda;
Lambda     = Lambda';

% Simulate measurment equation
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

%% Plot factors

figure; plot(F(:,1:r1));
figure; plot(F(:,r1+1:r1+r2));
figure; plot(F(:,r1+r2+1:r));

%% Plot simulated data

figure; plot(X);

%% Do the test

r = nb_trapaniNFactorTest(X)

test = nb_cfsTest(X,'k','1')

%% Levels

data = nb_ts('nemoinput.db','','',{...
    'NTF.QSA_YMN','NTF.QSA_CP','NTF.QSA_XMN','NTF.QSA_MMN',...
    'NTF.QSA_JPMN','NTF.QSA_PCPIJAE','NTF.QUA_QI44','NTF.QUA_RNFOLIO',...
    'NTF.QSA_JG','NTF.QSA_CG','NTF.QSA_JH','NTF.QSA_JC','NTF.QSA_XMNO',...
    'NTF.QSA_PHN','NTF.QSA_JOS','NTF.QUA_POP1674','NTF.QUA_KFC2H',...
    'NTF.QUA_KFC3EMN','NTF.QSA_WANB'});
dataY = nb_ts('histdata.db','','',{'QSA_Y'});
data  = merge(data,dataY);
gData = growth(data);
data  = cutSample(data);
gData = cutSample(gData);

%% Level data

r    = nb_trapaniNFactorTest(double(data))
test = nb_cfsTest(double(data),'k','1')

%% Growth rates

r    = nb_trapaniNFactorTest(double(gData))
test = nb_cfsTest(double(gData),'k','1')





