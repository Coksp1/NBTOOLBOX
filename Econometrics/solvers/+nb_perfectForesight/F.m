function Y = F(G,vars,parVal,exoVal,initVal,varsSS)
% Syntax:
%
% Y = nb_perfectForesight.F(G,vars,parVal,exoVal,...
%                   initVal,varsSS)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

    Y = G(vars,parVal,exoVal,initVal,varsSS);
    
end
