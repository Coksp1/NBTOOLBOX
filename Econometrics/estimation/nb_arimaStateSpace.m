function [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = nb_arimaStateSpace(par,p,q,sp,sq,constant,nExoT,stabilityTest)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = nb_arimaStateSpace(par,p,q,sp,...
%      sq,constant,nExoT,stabilityTest)
%
% Description:
%
% Returns a state-space representation of an ARIMA(p,0,q,sq,sq) model
% with seasonal autoregressive and seasonal moving average terms.
%
% Observation equation:
% y = d + Hx + Tz + v
% 
% State equation:
% x = c + Ax_1 + Gz + Bu
% 
% Where u ~ N(0,Q) meaning u is gaussian noise with covariance Q
%       v ~ N(0,R) meaning v is gaussian noise with covariance R
%
% Input:
% 
% - par           : The parameter vector of the ARIMA model. Order:
%                   - constant
%                   - AR terms
%                   - MA terms
%                   - SAR terms
%                   - SMA terms
%                   - Exogenous regressors
%                   - Std of residual
%
% - p             : The number of AR terms.
%
% - q             : the number of MA terms.
%
% - constant      : Include constant or not. true or false.
% 
% - stabilityTest : Check stability of system. Sets failed to true if model
%                   is not stationary. Default is false.
%
% - nExoT         : Number of exogenous variables included in the
%                   state equation.
%
% Output:
% 
% - x0     : Initial state vector.
%
% - P0     : Initial variance.
%
% - See equation above
%
% - obs    : Index of observables in the state vector.
%
% - failed : See stabilityTest input. true if model fail test.
%
% See also:
% nb_kalmanlikelihood
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        stabilityTest = false;
    end
    failed = false;

    % Get the AR(p) and MA(q) initial values
    s     = max([p,q + 1]);
    w     = constant + p + q;
    r     = w + double(sp > 0) + double(sq > 0);
    rho   = par(constant + 1:constant + p);
    theta = [ones; par(constant + p + 1:w)];
    sigma = par(end);
    exo   = par(r+1:end-1);
    nExo  = length(exo);
    
    % Expand solution given seasonal terms
    if sp > 0
        rhoSAR       = par(w + 1);
        rhoInit      = rho;
        rhoSAR       = rhoSAR.*[ones;-rhoInit];
        rho          = zeros(p + sp,1);
        rho(1:p)     = rhoInit;
        rho(sp:sp+p) = rho(sp:sp+p) + rhoSAR;
        p            = p + sp;
        s            = max([p,q + 1]);
    end
    if sq > 0
        thetaSMA       = par(w + 1 + double(sp > 0));
        thetaInit      = theta;
        thetaSMA       = thetaSMA.*thetaInit;
        theta          = zeros(q  + 1 + sq,1);
        theta(1:q+1)   = thetaInit;
        theta(sq:sq+q) = theta(sq:sq+q) + thetaSMA;
        q              = q + sq;
        s              = max([p,q + 1]);
    end
    
    % Set up the state-space. See for example 
    % http://www.etsii.upm.es/ingor/estadistica/Carol/TSAtema9petten.pdf
    %--------------------------------------------------------------
    if constant
        d = par(1); % Constant in the observation equation
    else
        d = 0; % No constant in the observation equation
    end
    H                = [ones,zeros(1,s - 1)]; % Observation matrix
    R                = 0; % No measurement error
    obs              = [true,false(1,s - 1)]; % Observables index
    T                = zeros(1,nExo);
    T(nExoT+1:end)   = exo(nExoT+1:end);
    
    c = 0; % No constant in the state equation
    A = [[rho;zeros(s - p,1)],[eye(s - 1); zeros(1,s - 1)]]; % Transition matrix 
    if stabilityTest
        [~,~,modulus] = nb_calcRoots(A);
        if any(modulus >= 1)
            failed = true;
        end
    end
    B            = [theta;zeros(s - q - 1,1)]; % MA terms contribution to the error term in the state eq.
    Q            = sigma; % Error of the state equation
    G            = zeros(size(A,1),nExo);
    G(1,1:nExoT) = exo(1:nExoT);
    
    % Get initalial values of the kalman filter
    x0    = zeros(s,1);
    BQB   = B*Q*B';
    vecP0 = (eye(s*s) - kron(A,A))\BQB(:);
    P0    = reshape(vecP0,[s,s]);
     
end
