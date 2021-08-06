function [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = stateSpace(par,nDep,nLags,nExo,restr,restrVal,measErrInd,H,stabilityTest)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G,obs,failed] = nb_mfvar.stateSpace(par,nDep,...
%                              nLags,nExo,restr,restrVal,measErrInd,...
%                              H,stabilityTest)
%
% Description:
%
% Returns a state-space representation of an MF-VARX(nLags) model.
%
% Observation equation:
% y = d + Hx + Tz + v, v ~ N(0,R)
% 
% State equation:
% x = c + Ax_1 + Gz + Bu, u ~ N(0,I)
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
%                   - measurement error std
%
% - nDep          : The number of depedent variables of the model.
%
% - nLags         : The number of lags of the VAR (of the highest 
%                   frequency).
%              
%                   Caution : The state-space representation may be bigger 
%                             due the measurment equation.
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
% - measErrInd    : The index of the measurement error std to estimate.
%                   If empty no measurement errors are allowed.
%
% - H             : The matrix of the measurement equation.  
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
% See also:
% nb_kalmanlikelihood_missing
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 9
        stabilityTest = false;
    end
    failed  = false;
    nStates = size(H,2)/nDep;
    nExtra  = nStates - nLags; 

    % Get the equation x = c + A*x_1 + Gz + B*u for the dynamic system
    %---------------------------------------------------------------
    nMeasErr        = length(measErrInd);
    c               = zeros(nDep*nStates,1);        % No constant in the state equation (included in z!)
    nDepPar         = sum(~restr(:));
    predPar         = nan(nDep,nDep*nLags);
    predPar(~restr) = par(nExo+1:nExo+nDepPar);
    predPar(restr)  = restrVal(restr);
    parExo          = reshape(par(1:nExo),nDep,nExo/nDep);
    parStd          = par(nExo+nDepPar+1:end-nMeasErr);
    parMeasErr      = par(end-nMeasErr+1:end);
    
    % Construct matrices
    predPar = [predPar,zeros(nDep,nExtra*nDep)];
    numRows = (nStates - 1)*nDep;
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
    Q = nb_expandCov(parStd,nDep);
    
    % Get the observation equation y = d + Hx + Tz + v
    nObs          = size(H,1);
    T             = zeros(nObs,nExo/nDep);
    R             = zeros(nObs,1);   
    R(measErrInd) = parMeasErr;
    R             = diag(R);
    d             = zeros(nObs,1);          % No constant in the observation equation
    obs           = [];                     % Observables index
    
    % Initialization of the filter
    s   = size(A,1);
    x0  = zeros(s,1);
    BQB = B*Q*B';
    P0  = nb_lyapunovEquation(A,BQB);
   
end
