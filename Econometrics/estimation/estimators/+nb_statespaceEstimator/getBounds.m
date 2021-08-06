function [lb,ub] = getBounds(options)
% Syntax:
%
% [lb,ub] = nb_statespaceEstimator.getBounds(options)
%
% Description:
%
% Get lower and upper bound on priors.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get upper and lower bound from truncated distributions 
    priorInp = options.prior(:,4);
    nEst     = size(priorInp,1);
    lb       = -inf(nEst,1);
    ub       = inf(nEst,1);
    indT     = cellfun(@(x)eq(size(x,2),4),priorInp);
    locT     = find(indT);
    for ii = 1:length(locT)
        if ~isempty(priorInp{locT(ii)}{3})
            lb(locT(ii)) = priorInp{locT(ii)}{3}; % Lower bound
        end
        if ~isempty(priorInp{locT(ii)}{4})
            ub(locT(ii)) = priorInp{locT(ii)}{4}; % Upper bound
        end
    end
    
    % Get upper an lower bound from domain of distribution
    locNot = find(~indT);
    for ii = 1:length(locNot)
        kk         = locNot(ii);
        domainFunc = str2func(strrep(func2str(options.prior{kk,3}),'_pdf','_domain'));
        bounds     = domainFunc(options.prior{kk,4}{:});
        lb(kk)     = bounds(1);
        ub(kk)     = bounds(2);
    end
    
end
