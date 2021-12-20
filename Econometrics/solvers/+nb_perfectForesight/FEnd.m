function Y = FEnd(GEnd,vars,parVal,exoVal,endVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FEnd(GEnd,vars,parVal,exoVal,endVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GEnd(vars,parVal,exoVal,endVal,varsSS);
    
end
