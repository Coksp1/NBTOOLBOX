function [A,C,jacobian,err] = solveSimpleRule(parser,sol,srCoeff,srInd,param)
% Syntax:
%
% jacobian           = solveSimpleRule(parser,sol,srCoeff,srInd,param)
% [A,C,jacobian,err] = nb_dsge.solveSimpleRule(parser,sol,srCoeff,...
%                               srInd,param)
%
% Description:
%
% Solve the model given current values of the coefficient of the simple
% rules.
% 
% See also:
% nb_dsge.optimalSimpleRules, nb_dsge.solveAndCalculateLoss
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get options and solution
    jacobian = full(sol.jacobian);

    % Assign current values of the simple rule coefficients
    param(srInd) = srCoeff;

    % Evaluate the derivatives of the simple rules
    [~,ind,ss] = nb_dsge.getOrderingNB(parser,sol.ss);    
    myDeriv    = myAD(ss);
    derivator  = parser.srFunction(myDeriv,param);
    jacobianSR = full(getderivs(derivator)); 

    % Substitute in for the updated derivatives of the simple rules
    jacobian(parser.indSimpleRules,:) = jacobianSR;
    if nargout == 1
        A = jacobian;
    else
        % Find the solution using the Klein's algorithm
        FF        = jacobian(:,ind == 1);
        F0        = jacobian(:,ind == 0);
        FB        = jacobian(:,ind == -1); 
        FU        = jacobian(:,ind == 2);
        [A,C,err] = nb_dsge.kleinSolver(parser,FF,F0,FB,FU);
    end
    
end
