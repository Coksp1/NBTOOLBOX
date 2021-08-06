function JF = getStackedJacobianAutomatic(inputs,funcs,Y,iter)
% Syntax:
%
% [YT,err] = nb_perfectForesight.blockIteration(obj,funcs,inputs,iter,...
%                   outer,YT)
%
% Description:
%
% Evaluate the Jacobian at the current iteration using automatic 
% derivatives that handles sparsity. For more see the myAD class
% written by SeHyoun Ahn and Martin Fink.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nY = size(Y,1);

    % Get exogenous variables
    exoVal = inputs.exoVal(inputs.startExo(iter):end,:,iter);
    if inputs.blockDecompose
        exoVal = [exoVal,inputs.prologueSolution]; % Append prologue solution
        exoVal = [exoVal,inputs.epilogueSolution(ones(1,inputs.periodsU(iter)),:)]; % Append epilogue solution (zeros at this point)
    end

    nVars = inputs.nVars;
    per   = inputs.periodsU(iter);
    I     = cell(1,per);
    J     = cell(1,per);
    V     = cell(1,per);
    
    % First period
    myDeriv          = myAD(Y(1:nVars*2));
    derivator        = funcs.FFirst(myDeriv,exoVal(1,:));
    JFFirst          = getderivs(derivator);
    [I{1},J{1},V{1}] = find(JFFirst);
    
    % Middle periods
    FEqs = funcs.FEqs;
    for ii = 2:per-1
        myDeriv       = myAD(Y(nVars*(ii-2)+1:nVars*(ii+1)));
        derivator     = FEqs(myDeriv,exoVal(ii,:));
        JPer          = getderivs(derivator);
        [IP,JP,V{ii}] = find(JPer);
        I{ii}         = IP + nVars*(ii-1);
        J{ii}         = JP + nVars*(ii-2);
    end
    
    % Last period
    myDeriv        = myAD(Y(end-nVars*2+1:end));
    derivator      = funcs.FEnd(myDeriv,exoVal(end,:));
    JFEnd          = getderivs(derivator);
    [IE,JE,V{per}] = find(JFEnd);
    I{per}         = IE + nVars*(per-1);
    J{per}         = JE + nVars*(per-2);
    
    % Create the full sparse matrix
    JF = sparse(vertcat(I{:}),vertcat(J{:}),vertcat(V{:}),nY,nY);

end
