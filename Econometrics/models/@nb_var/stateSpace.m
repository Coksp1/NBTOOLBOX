function [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = stateSpace(par,nDep,nLags,nExo,restr,restrVal,stabilityTest)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = nb_var.stateSpace(par,nDep,...
%                                nLags,nExo,restr,restrVal,stabilityTest)
%
% Description:
%
% Returns a state-space representation of an VARX(nLags) model.
%
% Observation equation:
% y = d + Hx + Tz + v
% 
% State equation:
% x = c + Ax_1 + Gz + Bu
% 
% Input:
% 
% - par           : The parameter vector of the VARX model.
%
%                   Order:
%                   - constant
%                   - exogenous
%                   - lagged endogenous
%                   - residual std
%
% - nDep          : The number of depedent variables of the model.
%
% - nLags         : the number of lags of the VAR.
%
% - constant      : Include constant or not. true or false. 
% 
% - nExo          : Number of exogenous variables included in the model.
%
% - restr         : A nDep x nDep*nLags logical matrix. true fro the
%                   non-restricted parameters.
%
% - restrVal      : Values of the restricted parameters.
%
% - stabilityTest : Check stability of system. Sets failed to true if model
%                   is not stationary. Default is false.
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
% - failed : See stabilityTest input.
%
% Examples:
%
% See also:
% nb_kalmanlikelihood, nb_kalmanlikelihood_missing
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        stabilityTest = false;
    end
    failed = false;

    % Get the equation x = c + A*x_1 + F z + B*u for the dynamic system
    %---------------------------------------------------------------
    c               = zeros(nDep*nLags,1);            % No constant in the state equation (included in z!)
    nDepPar         = sum(~restr(:));
    predPar         = nan(nDep,nDep*nLags);
    predPar(~restr) = par(nExo+1:nExo+nDepPar);
    predPar(restr)  = restrVal(restr);
    parExo          = reshape(par(1:nExo),nDep,nExo/nDep);
    par             = par(nExo+nDepPar+1:end);
    
    % Construct matrices
    numRows = (nLags - 1)*nDep;
    A       = [predPar;eye(numRows),zeros(numRows,nDep)]; % Transition matrix
    if stabilityTest
        [~,~,modulus] = nb_calcRoots(A);
        if any(modulus >= 1)
            failed = true;
        end
    end
    if nExo == 0
        G = zeros(size(A,1),0);   
    else
        G = [parExo;zeros(numRows,nExo/nDep)];
    end
    B = [eye(nDep);zeros(numRows,nDep)];      % One residual for each equation
    Q = nb_expandCov(par,nDep);
    
    % Get the observation equation y = d + Hx + Tz + v
    H   = [eye(nDep),zeros(nDep,numRows)];       % Observation matrix
    T   = zeros(nDep,nExo/nDep);
    R   = zeros(nDep);                           % No measurement error
    d   = zeros(nDep,1);                         % No constant in the observation equation
    obs = [true(1,nDep),false(1,numRows)];       % Observables index
    
    % Initialization of the filter
    s   = size(A,1);
    x0  = zeros(s,1);
    BQB = B*Q*B';
    P0  = nb_lyapunovEquation(A,BQB);
   
end
