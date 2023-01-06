function funcs = updateEpiFunctionOnePeriod(funcs,YNotEpi,parExoVal,varsSS)
% Syntax:
%
% funcs = nb_perfectForesight.updateEpiFunctionOnePeriod(funcs,...
%               Yepi,YNotEpi,parExoVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
     % Update with the inputs that does not change for each period.
    G       = funcs.G;
    funcs.F = @(epivars)nb_perfectForesight.FEpi(G,epivars,YNotEpi,parExoVal,varsSS);
    if funcs.symbolic
        GDeriv       = funcs.GDeriv;
        funcs.FDeriv = @(epivars)nb_perfectForesight.FEpiDeriv(GDeriv,epivars,YNotEpi,parExoVal,varsSS); 
    end
    
end
