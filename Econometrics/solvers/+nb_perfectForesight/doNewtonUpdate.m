function [DY,err] = doNewtonUpdate(FY,JF,solveIter)
% Syntax:
%
% [DY,err] = nb_perfectForesight.doNewtonUpdate(FY,JF,solveIter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    err = false;
    if 1/condest(JF) < eps
        if any(~isfinite(JF(:)))
            err = true;
            DY  = nan;
            return
        else
            error([mfilename ':: Jacobian cannot be inverted.'])
        end
    end
    DY = JF\FY;
    if any(~isfinite(DY(:)))
        error([mfilename ':: Failed to do the newton update at iteration ' int2str(solveIter)]);
    end
    
end
