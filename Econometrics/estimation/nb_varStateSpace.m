function [d,H,R,c,A,B,Q,G,obs] = nb_varStateSpace(par,nDep,nLags,constant,nExo,restr,restrVal)
% Syntax:
%
% [d,H,R,c,A,B,Q,G,obs] = nb_arimaStateSpace(par,nExo)
%
% Description:
%
% Returns a state-space representation of an VARX(nLags) model.
%
% Observation equation:
% y = d + Hx + v
% 
% State equation:
% x = c + Ax_1 + Gz + Bu
% 
% Input:
% 
% - par      : The parameter vector of the VARX model.
%
%              Order:
%              - constant
%              - exogenous
%              - lagged endogenous
%              - residual std
%
% - nDep     : The number of depedent variables of the model.
%
% - nLags    : the number of lags of the VAR.
%
% - constant : Include constant or not. true or false. 
% 
% - nExo     : Number of exogenous variables included in the model.
%
% - restr    : A nDep x nDep*nLags logical matrix. true fro the
%              non-restricted parameters.
%
% - restrVal : Values of the restricted parameters.
%
% Output:
% 
% - See equation above
%
% - obs : Index of observables in the state vector.
%
% Examples:
%
% See also:
% nb_kalmanlikelihood
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the equation x = c + A*x_1 + F z + B*u for the dynamic system
    %---------------------------------------------------------------
    c = zeros(nDep*nLags,1);            % No constant in the state equation
    if constant 
        c(1:nDep) = par(1:nDep);      % Constant in the state equation
        par       = par(nDep+1:end);   
    end
    nDepPar         = sum(~restr(:));
    predPar         = nan(nDep,nDep*nLags);
    predPar(~restr) = par(nExo+1:nExo+nDepPar);
    predPar(restr)  = restrVal(restr);
    parExo          = reshape(par(1:nExo),nDep,nExo/nDep);
    par             = par(nExo+nDepPar+1:end);
    
    % Construct matrices
    numRows = (nLags - 1)*nDep;
    A       = [predPar;eye(numRows),zeros(numRows,nDep)]; % Transition matrix
    G       = [parExo;zeros(numRows,nExo/nDep)];    
    B       = [eye(nDep);zeros(numRows,nDep)];      % One residual for each equation
    Q       = nb_expandCov(par,nDep);
    
    % Get the observation equation y = d + Hx + v
    H   = [eye(nDep),zeros(nDep,numRows+nExo)];  % Observation matrix
    R   = zeros(nDep);                           % No measurement error
    d   = zeros(nDep,1);                         % No constant in the observation equation
    obs = [true(1,nDep),false(1,numRows)];       % Observables index
   
end
