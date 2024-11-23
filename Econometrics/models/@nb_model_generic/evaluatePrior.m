function logPriorD = evaluatePrior(prior,par)
% Syntax:
%
% logPriorD = nb_model_generic.evaluatePrior(prior,par)
%
% Description:
%
% Evaluate the prior at a point in the parameter space. 
% 
% Input:
% 
% - prior : See options.prior.
%
% - par   : A nEst x 1 double with the value of the point of evaluation.
% 
% Output:
% 
% - logPriorD: The log prior density at the evaluated point.
%
% See also:
% nb_dsge.objective
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    f = prior(:,3); 
    p = num2cell(par);
    p = p(:);
    i = prior(:,4);
    try
        logPriorD = cellfun(@(f,p,i)log(f(p,i{:})),f,p,i);
    catch
        logPriorD = -1e10;
        return
    end
    logPriorD = sum(logPriorD);
    if ~isfinite(logPriorD)
        logPriorD = -1e10;
    end
    
end
