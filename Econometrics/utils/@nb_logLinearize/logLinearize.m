function obj = logLinearize(obj)
% Syntax:
%
% obj = logLinearize(obj)
%
% Description:
%
% Do the log linearization.
% 
% Input:
% 
% - obj : An object of class nb_logLinearize
% 
% Output:
% 
% - obj : An object of class nb_logLinearize. See the property logLinEq
%         for the log-linearized equations.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
           
    % Translate equations into function handle
    obj = eq2Func(obj);

    % Calculate first order derivatives
    obj = doDeriv(obj);

    % Summarize log linearization
    obj = doLogLinearization(obj);
    
    % Pair equations
    obj = pairEquations(obj);

end
