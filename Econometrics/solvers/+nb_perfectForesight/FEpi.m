function Y = FEpi(G,epivars,vars,pars,ssVars)
% Syntax:
%
% Y = nb_perfectForesight.FEpi(G,epivars,vars,pars,ssVars)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = G(epivars,vars,pars,ssVars);
    
end
