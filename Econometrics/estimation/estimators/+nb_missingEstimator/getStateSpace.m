function [x0,P0,d,H,R,T,c,A,B,Q,G] = getStateSpace(options,model)
% Syntax:
%
% [x0,P0,d,H,R,T,c,A,B,Q,G] = nb_missingEstimator.getStateSpace(...
%   options,model) 
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
    nObs             = length([options.dependent, options.block_exogenous]);
    d                = zeros(nObs,1);
    T                = zeros(nObs,length(model.exo));
    H                = zeros(nObs,length(model.endo));
    H(1:nObs,1:nObs) = eye(nObs);
    R                = zeros(nObs);
    
    % State equation:
    % x(t) = c + A*x(t-1) + G*z(t) + B*u(t), u ~ N(0,Q)
    c = 0;
    A = model.A;
    G = model.B;
    B = model.C;
    Q = model.vcv;

    % Initialization of the filter
    s   = size(A,1);
    x0  = zeros(s,1);
    BQB = B*Q*B';
    P0  = nb_lyapunovEquation(A,BQB);

end
