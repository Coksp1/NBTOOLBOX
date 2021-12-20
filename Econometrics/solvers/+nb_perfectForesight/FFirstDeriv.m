function Y = FFirstDeriv(GFirstDeriv,vars,parVal,exoVal,initVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FFirstDeriv(GFirstDeriv,vars,parVal,exoVal,...
%                   initVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GFirstDeriv(vars,parVal,exoVal,initVal,varsSS);
    
end
