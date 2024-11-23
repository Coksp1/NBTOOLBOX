function [lbo,ubo] = getBounds(prior,lb,ub)
% Syntax:
%
% [lbo,ubo] = nb_estimator.getBounds(prior,lb,ub)
%
% Description:
%
% This function can be used for finding the finite support for those 
% optimizers that needs that. E.g. nb_abc and bee_gate. 
% 
% Input:
% 
% - prior : A struct with the prior specification. 
%
% - lb    : The lower bound, as a nParam x 1 double.
%
% - ub    : The upper bound, as a nParam x 1 double.
% 
% Output:
% 
% - lbo   : The lower bound where all non-finite elements are 
%           substituted with their 1 percentile.
%
% - ubo   : The upper bound where all non-finite elements are 
%           substituted with their 99 percentile.
%
% See also:
% nb_abc, bee_gate, nb_statespaceEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nParam = size(lb,1);
    lbo    = lb;
    ubo    = ub;
    for ii = 1:nParam

        if  ~isfinite(lb(ii)) || ~isfinite(ub(ii))
           
            priorFunc  = func2str(prior{ii,3});
            priorFunc  = str2func(strrep(priorFunc,'pdf','icdf'));
            priorParam = prior{ii,4};
            if ~isfinite(lb(ii))
                lbo(ii) = priorFunc(0.01,priorParam{:});
            end
            if ~isfinite(ub(ii))
                ubo(ii) = priorFunc(0.99,priorParam{:});
            end
            
        end
        
    end
    
    % Inform user about truncation
    indC = lbo ~= lb | ubo ~= ub;
    if any(indC)
        priorC = prior(indC,1);
        warning('nb_estimator:needBounds',[mfilename ':: When nb_abc or bee_gate is chosen as the optimizer the bounds need to be finite. ',...
            'The following parameters have either set its lower bound to the 1th percentile or its upper bound to the 99th percentile. ',...
            '(The percentiles are taken from the prior); ' toString(priorC)])
    end
        
end
