function Y = FFirst(GFirst,vars,parVal,exoVal,initVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.FFirst(GFirst,vars,parVal,exoVal,...
%                   initVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = GFirst(vars,parVal,exoVal,initVal,varsSS);
    
end
