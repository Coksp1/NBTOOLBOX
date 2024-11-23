function [DY,err] = getNewtonUpdate(funcs,JF,Y,inputs,solveIter,iter)
% Syntax:
%
% [DY,err] = nb_perfectForesight.getNewtonUpdate(funcs,JF,Y,inputs,...
%                   solveIter,iter)
%
% Description:
%
% Get the Newton update utilizing sparsity of the jacobian JF.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Evaluate the stacked system at the current values
    nVars  = inputs.nVars;
    nY     = size(Y,1);
    per    = inputs.periodsU(iter);
    exoVal = inputs.exoVal(inputs.startExo(iter):end,:,iter);
    FY     = nan(nY,1);
    
    % Append prologue solution
    if inputs.blockDecompose
        exoVal = [exoVal,inputs.prologueSolution];
        exoVal = [exoVal,inputs.epilogueSolution(ones(1,inputs.periodsU(iter)),:)]; % Append epilogue solution (zeros at this point)
    end
    
    % For the first period
    FY(1:nVars) = funcs.FFirst(Y(1:nVars*2),exoVal(1,:));
    
    % Middle periods
    for ii = 2:per-1
        FY(nVars*(ii-1)+1:nVars*(ii)) = funcs.FEqs(Y(nVars*(ii-2)+1:nVars*(ii+1)),exoVal(ii,:));
    end
    
    % Last period
    FY(end-nVars+1:end) = funcs.FEnd(Y(end-nVars*2+1:end),exoVal(end,:));
    
    % Check for convergance
    if norm(FY,1) < inputs.fix_point_TolFun
        DY  = 0;
        err = false;
        return
    end
    
    % Do newton update
    [DY,err] = nb_perfectForesight.doNewtonUpdate(FY,JF,solveIter);
    
end
