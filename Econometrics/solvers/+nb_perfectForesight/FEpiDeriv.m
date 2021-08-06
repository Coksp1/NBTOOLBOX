function Y = FEpiDeriv(GDeriv,epivars,vars,pars,ssVars)
% Syntax:
%
% Y = nb_perfectForesight.FDeriv(GDeriv,epivars,vars,pars,ssVars)
%                   
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth S�terhagen Paulsen

    Y = GDeriv(epivars,vars,pars,ssVars);
    
end
