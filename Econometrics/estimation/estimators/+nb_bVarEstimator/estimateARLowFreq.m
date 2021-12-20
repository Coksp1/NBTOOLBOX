function [AR,sigma,ys,us] = estimateARLowFreq(y,H)
% Syntax:
%
% [AR,sigma,ys,us] = nb_bVarEstimator.estimateARLowFreq(y,H)
%
% Description:
%
% Estimate AR(1) model of a series with higher frequency than the observed
% data using a kalman filter approach.
% 
% See also:
% nb_mlEstimator.minnesotaMF
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % No exogenous
    X = zeros(0,size(y,1));

    % Get initialization and bounds
    par = [0.9;0.1];
    UB  = inf(2,1);
    LB  = [-inf;0];
    
    % Optimization options
    opt             = optimset('fmincon');
    opt.Display     = 'off';
    opt.MaxFunEvals = 2000;
    opt.MaxIter     = 500;
    opt.TolFun      = sqrt(eps);
    opt.TolX        = sqrt(eps);
    opt.LargeScale  = 'off';
    
    % Do the estimation
    [estPar,~,flag] = fmincon(@nb_kalmanlikelihood_missing,par,[],[],[],[],LB,UB,[],opt,@setUpAR,y',X,1,H);
    message = nb_interpretExitFlag(flag,'fmincon',' Setting up the Minnesota prior failed due to error during estimation of the prior variance of the coefficients. ');
    if ~isempty(message)
        error([mfilename ':: ' message])
    end
    AR    = estPar(1);
    sigma = estPar(2);
    
    if nargout > 2
        % Returned smoothed estimate of the series given the AR(1)
        % spesifikation
        [~,ys,us] = nb_kalmansmoother_missing(@setUpAR,y',X,estPar,H);
        ys        = ys(:,1);
    end
    
end

function [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = setUpAR(par,H)

    % Get the equation x = c + A*x_1 + Gz + B*u for the dynamic system
    failed  = false;    
    nStates = size(H,2);
    c       = zeros(nStates,1);
    A       = [par(1),zeros(1,nStates-1);eye(nStates-1),zeros(nStates-1,1)];  
    B       = [1;zeros(nStates-1,1)];   
    G       = zeros(size(A,1),0);
    Q       = par(2);
    
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
