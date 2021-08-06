function checkJacobian(obj,inputs,JFM)
% Syntax:
%
% nb_perfectForesight.checkJacobian(obj,JFM)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    eqs = obj.parser.equationsParsed; 
    per = size(JFM,1)/length(eqs);
    
    nVars     = inputs.nVars;
    indF      = 1:nVars*2;
    JFF       = JFM(indF,indF);
    indFailed = any(~isfinite(full(JFF)),2);
    if any(indFailed)
        eqs2      = [eqs;eqs];
        eqsFailed = eqs2(indFailed);
    end
    

end
