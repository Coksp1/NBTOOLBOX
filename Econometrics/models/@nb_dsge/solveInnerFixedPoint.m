function [H,GAM,failed] = solveInnerFixedPoint(Alead,A0,Alag,H0,tol,rcondTol,maxIter)
% Syntax:
%
% [H,GAM,failed] = nb_dsge.solveInnerFixedPoint(Alead,A0,Alag,H0,tol,...
%                               rcondTol,maxIter)
%
% Description:
%
% No documentation.
% 
% See also:
% nb_dsge.optimalSimpleRules, nb_dsge.calculateLossDiscretion
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    crit   = inf;
    iter   = 0;
    failed = false;
    while crit > tol

        GAM = Alead*H0 + A0;
        if rcond(GAM) < rcondTol
            H = [];
            break;
        end
        H    = -GAM\Alag;           
        crit = max(abs(H(:) - H0(:))); % Maximum distance of any single element as criteria
        iter = iter + 1;
        H0   = H;
        if iter > maxIter
            failed = true;
            return
        end

    end
    
end
