function funcs = updateStackedSystemFunction(obj,funcs,inputs,iter)
% Syntax:
%
% funcs = nb_perfectForesight.updateStackedSystemFunction(obj,funcs,...
%                   inputs,iter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if iter == 1
        initVal = cell2mat(struct2cell(inputs.initVal));
    else
        initVal = inputs.initValU(inputs.initValLoc);
    end

    % Get the parameter values and the end conditions
    parVal = obj.parameters.value;
    endVal = cell2mat(struct2cell(inputs.endVal(iter)));
    varsSS = inputs.ss(:,iter);
    
    % Assign all inputs except the path of the endogenous that we seek
    % to find, and the exogenous variables.
    funcs.FFirst = @(vars,exoVal)nb_perfectForesight.FFirst(funcs.GFirst,vars,parVal,exoVal,initVal,varsSS);
    funcs.FEqs   = @(vars,exoVal)nb_perfectForesight.FEqs(funcs.GEqs,vars,parVal,exoVal,varsSS);
    funcs.FEnd   = @(vars,exoVal)nb_perfectForesight.FEnd(funcs.GEnd,vars,parVal,exoVal,endVal,varsSS);
    if funcs.symbolic 
        funcs.FFirstDeriv = @(vars,exoVal)nb_perfectForesight.FFirstDeriv(funcs.GFirstDeriv,vars,parVal,exoVal,initVal,varsSS);
        funcs.FEqsDeriv   = @(vars,exoVal)nb_perfectForesight.FEqsDeriv(funcs.GEqsDeriv,vars,parVal,exoVal,varsSS);
        funcs.FEndDeriv   = @(vars,exoVal)nb_perfectForesight.FEndDeriv(funcs.GEndDeriv,vars,parVal,exoVal,endVal,varsSS);
    end
    
end
