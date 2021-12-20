function Y = FEqs(GEqs,vars,parVal,exoVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FEqs(GEqs,vars,parVal,exoVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GEqs(vars,parVal,exoVal,varsSS);
    
end
