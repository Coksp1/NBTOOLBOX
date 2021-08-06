function [x0,P0,d,H,R,T,c,A,B,Q,G] = getStateSpace(A,G,B,nObs)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G] = nb_forecast.getStateSpace(A,B,CE,init,
%   exoInit,nObs) 
%
% Description:
%
% Go from the state space representation in the model struct to the 
% state space matrices needed by the nb_kalmansmoother_missing function.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Observation equation:
    % y(t) = d + H*x(t) + T*z(t) + R*v(t), v ~ N(0,R)
    nExo             = size(G,2);
    nEndo            = size(A,2);
    d                = zeros(nObs,1);
    T                = zeros(nObs,nExo);
    H                = zeros(nObs,nEndo);
    H(1:nObs,1:nObs) = eye(nObs);
    R                = zeros(nObs);
    
    % State equation:
    % x(t) = c + A*x(t-1) + G*z(t) + B*u(t), u ~ N(0,Q)
    c = 0;
    Q = eye(nObs);

    % Initialization of the filter
    x0  = zeros(nEndo,1);
    BQB = B*Q*B';
    P0  = nb_lyapunovEquation(A,BQB);

end
