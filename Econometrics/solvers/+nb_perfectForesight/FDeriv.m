function Y = FDeriv(GDeriv,vars,parVal,exoVal,initVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FDeriv(GDeriv,vars,parVal,exoVal,initVal,varsSS)
%                   
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GDeriv(vars,parVal,exoVal,initVal,varsSS);
    
end
