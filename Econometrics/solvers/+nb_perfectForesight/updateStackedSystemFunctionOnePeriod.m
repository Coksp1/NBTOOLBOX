function funcs = updateStackedSystemFunctionOnePeriod(obj,funcs,inputs,init,iter)
% Syntax:
%
% funcs = nb_perfectForesight.updateStackedSystemFunctionOnePeriod(obj,...
%                   funcs,inputs,init,iter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the parameter values and the end conditions
    parVal = obj.parameters.value;
    varsSS = inputs.ss(:,iter);
    
     % Update with the inputs that does not change for each period.
    G       = funcs.G;
    funcs.F = @(vars,exoVal)nb_perfectForesight.F(G,vars,parVal,exoVal,init,varsSS);
    if funcs.symbolic
        GDeriv       = funcs.GDeriv;
        funcs.FDeriv = @(vars,exoVal)nb_perfectForesight.FDeriv(GDeriv,vars,parVal,exoVal,init,varsSS); 
    end
    
end
