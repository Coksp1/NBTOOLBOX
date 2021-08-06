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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen
    
     % Update with the inputs that does not change for each period.
    G       = funcs.G;
    funcs.F = @(epivars)nb_perfectForesight.FEpi(G,epivars,YNotEpi,parExoVal,varsSS);
    if funcs.symbolic
        GDeriv       = funcs.GDeriv;
        funcs.FDeriv = @(epivars)nb_perfectForesight.FEpiDeriv(GDeriv,epivars,YNotEpi,parExoVal,varsSS); 
    end
    
end
