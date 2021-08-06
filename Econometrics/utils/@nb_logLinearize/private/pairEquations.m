function obj = pairEquations(obj)
% Syntax:
%
% obj = pairEquations(obj)
%
% Description:
%
% Pair log-linearized equations that are splitted by equality sign.
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind = ~isnan(obj.eqInd);
    if any(ind)
       
        start       = find(ind,1);
        pairedEqs   = obj.equations(1:start-1);
        pairedLLEqs = obj.logLinEq(1:start-1);
        pairedSSEqs = obj.ssEq(1:start-1);
        for ii = start:size(obj.equations,1)
            loc              = obj.eqInd(ii);
            pairedEqs{loc}   = [obj.equations{ii} '=' pairedEqs{loc}];
            pairedLLEqs{loc} = [obj.logLinEq{ii} '=' pairedLLEqs{loc}];
            pairedSSEqs{loc} = [obj.ssEq{ii} '=' pairedSSEqs{loc}];
        end
        obj.equations = pairedEqs;
        obj.logLinEq  = pairedLLEqs;
        obj.ssEq      = pairedSSEqs;
        
    end

end
