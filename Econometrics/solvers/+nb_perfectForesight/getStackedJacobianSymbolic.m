function JF = getStackedJacobianSymbolic(inputs,funcs,Y,iter)
% Syntax:
%
% JF = nb_perfectForesight.getStackedJacobianSymbolic(inputs,funcs,Y,iter)
%
% Description:
%
% Evaluate the Jacobian at the current iteration using symbolic 
% derivatives that handles sparsity. For more see the nb_mySD and nb_Param 
% classes written by Kenneth S. Paulsen.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nY = size(Y,1);

    % Get exogenous variables
    exoVal = inputs.exoVal(inputs.startExo(iter):end,:,iter);
    if inputs.blockDecompose
        exoVal = [exoVal,inputs.prologueSolution]; % Append prologue solution
        exoVal = [exoVal,inputs.epilogueSolution(ones(1,inputs.periodsU(iter)),:)]; % Append epilogue solution (zeros at this point)
    end

    nVars = inputs.nVars;
    per   = inputs.periodsU(iter);
    
    % First period
    VFirst = funcs.FFirstDeriv(Y(1:nVars*2),exoVal(1,:));
    IFirst = funcs.firstInd(:,1);
    JFirst = funcs.firstInd(:,2);
    
    % Middle periods
    FEqsDeriv = funcs.FEqsDeriv;
    IEqsOne   = funcs.eqsInd(:,1);
    JEqsOne   = funcs.eqsInd(:,2);
    nEqs      = size(IEqsOne,1);
    IEqs      = nan((per-2)*nEqs,1);
    JEqs      = nan((per-2)*nEqs,1);
    VEqs      = nan((per-2)*nEqs,1);
    for ii = 2:per-1
        ind       = 1 + (ii-2)*nEqs:(ii-1)*nEqs;
        VEqs(ind) = FEqsDeriv(Y(nVars*(ii-2)+1:nVars*(ii+1)),exoVal(ii,:));
        IEqs(ind) = IEqsOne + nVars*(ii-1);
        JEqs(ind) = JEqsOne + nVars*(ii-2);
    end
    
    % Last period
    VEnd = funcs.FEndDeriv(Y(end-nVars*2+1:end),exoVal(end,:));
    IEnd = funcs.endInd(:,1) + nVars*(per-1);
    JEnd = funcs.endInd(:,2) + nVars*(per-2);
    
    % Create the full sparse matrix
    JF = sparse([IFirst;IEqs;IEnd],[JFirst;JEqs;JEnd],[VFirst;VEqs;VEnd],nY,nY);

end
