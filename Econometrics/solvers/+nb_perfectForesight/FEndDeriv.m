function Y = FEndDeriv(GEndDeriv,vars,parVal,exoVal,endVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FEndDeriv(GEnd,vars,parVal,exoVal,endVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GEndDeriv(vars,parVal,exoVal,endVal,varsSS);
    
end
