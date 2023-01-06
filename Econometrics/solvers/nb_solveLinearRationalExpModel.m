function [D,L,err] = nb_solveLinearRationalExpModel(A,B,nState)
% Syntax: 
%
% [D,L,err] = nb_solveLinearRationalExpModel(A,B,nState)
%
% Description: 
%
% Solves for the recursive representation of the stable solution to a 
% system of linear difference equations.
%
% Klein, Paul, 2000. "Using the generalized Schur form to solve a 
% multivariate linear rational expectations model," Journal of Economic 
% Dynamics and Control, Elsevier, vol. 24(10), pages 1405-1423, September.
%
% Solves A E[x(t+1)] = B x(t). x(t) is ordered so that the state variables
% comes first.
%
% Inputs: 
%
% - A, B   : Two square matrices A and B in the equation above.
%
% - nState : Number of state variables.
%
% Outputs: 
%
% - D, L   : The decision rule D and the law of motion L. Lets decompose 
%            x(t) into x(t) = [s(t);c(t)], where s(t) are the state 
%            variables. Then the solution can be found to be:
%
%            c(t)   = D*s(t) and
%            s(t+1) = L*s(t).
%
% - err    : Non-empty if the if either the Blanchard-Kahn rank condition
%            or order condition is not satisfied.
%
% See also:
% qz, ordqz
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    err            = '';
    [AA, BB, Q, Z] = qz(A,B);
    [AAS,BBS,~,ZS] = ordqz(AA,BB,Q,Z,'udo');  
    Z21            = ZS(nState+1:end,1:nState);
    Z11            = ZS(1:nState,1:nState);
    
    if rank(Z11) < nState
        err = 'Invertibility condition violated. Blanchard-Kahn rank condition not satisfied.';
        if nargout < 3
            error(err)
        end
        D = []; L = [];
        return
    end

    if abs(BBS(nState,nState))>abs(AAS(nState,nState)) || abs(BBS(nState+1,nState+1))<abs(AAS(nState+1,nState+1))
       err = 'Wrong number of stable eigenvalues. Blanchard-Kahn order condition not satisfied.';
       if nargout < 3
           error(err)
       end
       D = []; L = [];
       return
    end
    
    S11    = AAS(1:nState,1:nState);
    T11    = BBS(1:nState,1:nState);
    Z11inv = Z11\eye(nState);
    D      = real(Z21*Z11inv);
    L      = real(Z11*(S11\T11)*Z11inv);
    
end
