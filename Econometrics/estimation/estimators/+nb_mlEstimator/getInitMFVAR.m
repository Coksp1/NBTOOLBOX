function [betaExo,betaDyn,sigmaPar] = getInitMFVAR(y,X,options,method,H)
% Syntax:
%
% [betaExo,betaDyn,sigmaPar] = nb_mlEstimator.getInitMFVAR(y,X,options,...
%                                   method,H)
%
% Description:
%
% Get initial values for optimization routine when dealing with a MF-VAR
% model.
% 
% See also:
% nb_mlEstimator.mfvarEstimator
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nLags     = options.nLags;
    nExo      = size(X,2) + options.constant + options.time_trend;
    nDep      = size(y,2);
    nCoeffExo = nExo*nDep;
    nCoeffDyn = nDep^2*nLags;
    switch method 
        
        case 'zeros'
            
            % Initialize to zero
            betaExo   = zeros(nCoeffExo,1);
            betaDyn   = zeros(nCoeffDyn,1);

            % Initial covariance matrix
            sigma    = eye(nDep);
            sigmaPar = nb_reduceCov(sigma);
            
        case 'interpolate'
            
            yT   = y';
            yOLS = y;
            XT   = zeros(0,size(yT,2));
            for ii = 1:nDep
                if any(isnan(yT(ii,:)))  
                    [~,ys]     = nb_kalmansmoother_missing(@setUpOneVar,yT(ii,:),XT,ii,H);
                    yOLS(:,ii) = ys(:,1);
                else
                    yOLS(:,ii) = y(:,ii);
                end
            end
            tSample = options.nLags+1:size(yOLS,1);
            yLag    = nb_mlag(yOLS,options.nLags,'varFast');
            yLag    = yLag(tSample,:);
            yTemp   = yOLS(tSample,:);
            Xtemp   = X(tSample,:);

            % OLS initialization
            if isempty(options.restrictions)
                [beta,~,~,~,res] = nb_ols(yTemp,[Xtemp,yLag],options.constant,options.time_trend);
            else
                [beta,~,~,~,res] = nb_olsRestricted(yTemp,[Xtemp,yLag],options.restrictions,options.constant,options.time_trend);
            end
            beta     = beta';
            beta     = beta(:);
            betaExo  = beta(1:nCoeffExo);
            betaDyn  = beta(nCoeffExo+1:nCoeffExo+nCoeffDyn);
            T        = size(res,1);
            numCoeff = size(beta,2);
            sigma    = res'*res/(T - numCoeff);
            sigmaPar = nb_reduceCov(sigma);
            
    end
    
end

function [x0,P0,d,Hi,R,T,c,A,B,Q,G,obs,failed] = setUpOneVar(ii,H)

    % Get the equation x = c + A*x_1 + Gz + B*u for the dynamic system
    nDep    = size(H,1);
    failed  = false;    
    Hi      = H(ii,ii:nDep:end,:);
    if size(Hi,3) > 1
        ind = find(any(Hi ~= 0,3),1,'last');
    else
        ind = find(Hi ~= 0,1,'last');
    end
    Hi      = Hi(:,1:ind,:);
    nStates = size(Hi,2);
    c       = zeros(nStates,1);
    A       = [0.5,zeros(1,nStates-1);eye(nStates-1),zeros(nStates-1,1)];  
    B       = [1;zeros(nStates-1,1)];   
    G       = zeros(size(A,1),0);
    Q       = 0.1;
    
    % Get the observation equation y = d + Hx + Tz + v
    T   = zeros(1,0);
    R   = 0;                           
    d   = 0;                      
    obs = [true,false(1,nStates-1)];       
    
    % Initialization of the filter
    s   = size(A,1);
    x0  = zeros(s,1);
    BQB = B*Q*B';
    P0  = nb_lyapunovEquation(A,BQB);
    
end
