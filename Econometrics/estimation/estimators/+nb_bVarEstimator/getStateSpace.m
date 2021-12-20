function [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = getStateSpace(alpha,sigma,nDep,nLags,nExo,restrictions,H,R)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = nb_bVarEstimator.getStateSpace(...
%               alpha,sigma,nDep,nLags,nExo,restr,H,R)
%
% Description:
%
% Go from draws from the posterior to state-space representation of the
% model. Used by the Kalman filter iteration when dealing with missinge
% observations or mixed frequency VARs.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    failed   = false;
    nStates  = size(H,2)/nDep;
    nExtra   = nStates - nLags;
    numCoeff = nLags*nDep + nExo;
    
    % Fill in block exogenous restrictions
    if ~isempty(restrictions)
        restr          = [restrictions{:}];
        alphaSub       = alpha;
        alpha          = zeros(length(restr),1);
        alpha(restr,:) = alphaSub;
    end
    ALPHA   = reshape(alpha,[numCoeff,nDep])';
    predPar = ALPHA(:,nExo+1:end);
    parExo  = ALPHA(:,1:nExo);
    
    % Get the equation x = c + A*x_1 + Gz + B*u for the dynamic system
    %---------------------------------------------------------------
    c       = zeros(nDep*nStates,1);        % No constant in the state equation (included in z!)
    predPar = [predPar,zeros(nDep,nExtra*nDep)];
    numRows = (nStates - 1)*nDep;
    A       = [predPar;eye(numRows),zeros(numRows,nDep)]; % Transition matrix
    if nExo == 0
        G = zeros(size(A,1),0);
    else
        G = [parExo;zeros(numRows,nExo)];  
    end   
    B = [eye(nDep);zeros(numRows,nDep)];      % One residual for each equation
    Q = sigma;
    
    % Get the observation equation y = d + Hx + Tz + v, v ~ N(0,R)
    nObs = size(H,1);
    T   = zeros(nObs,nExo);
    if nargin < 8
        R   = zeros(nObs); % No measurement error
    else
        if isvector(R)
            R = diag(R);
        end
        if size(R,1) ~= nObs
            failed = true;
        end
    end
    d   = zeros(nObs,1);                         % No constant in the observation equation
    obs = [true(1,nObs),false(1,numRows)];       % Observables index
    
    % Initialization of the filter
    s   = size(A,1);
    x0  = zeros(s,1);
    BQB = B*Q*B';
    P0  = nb_lyapunovEquation(A,BQB);

end
