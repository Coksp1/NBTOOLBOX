function [Y,err] = proSolver(obj,inputs,Y,iter)
% Syntax:
%
% [Y,err] = nb_perfectForesight.proSolver(obj,inputs,Y,iter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    block    = obj.parser.block;
    prologue = block.proEqs;
    if ~any(prologue)
        err = '';
        return
    end
    inputs.nVars = obj.dependent.number;
    if any(obj.parser.isAuxiliary)
        eqs = obj.parser.equationsParsed;
    else
        eqs = obj.parser.equations;
    end

    proY     = block.proEndo(:,ones(inputs.periodsU(iter),1));
    proY     = proY(:);
    proVars  = obj.parser.endogenous(block.proEndo);
    eqsPro   = eqs(prologue);
    YP       = Y(proY);
    exoVal   = inputs.exoVal(inputs.startExo(iter):end,:,iter);
    [YP,err] = nb_perfectForesight.forwardSolution(obj,YP,inputs,eqsPro,proVars,exoVal,iter);
    if isempty(err)
        Y(proY)  = YP;
    end
    
end
