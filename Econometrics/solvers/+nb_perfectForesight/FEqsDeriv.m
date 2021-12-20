function Y = FEqsDeriv(GEqsDeriv,vars,parVal,exoVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FEqsDeriv(GEqsDeriv,vars,parVal,exoVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GEqsDeriv(vars,parVal,exoVal,varsSS);
    
end
