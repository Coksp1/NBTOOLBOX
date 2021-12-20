function res = addRestrictions(options,res,restrict)
% Syntax:
%
% res = nb_estimator.addRestrictions(options,res,restrict)
%
% See also:
% nb_olsEstimator.estimate, nb_estimator.applyRestrictions
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nExo                  = length(options.exogenous);
    nDep                  = length(options.dependent);
    nRec                  = size(res.beta,3);
    beta                  = nan(nExo,nDep);
    beta(restrict.ind,:)  = restrict.beta(:,ones(1,nDep),ones(1,nRec));
    beta(~restrict.ind,:) = res.beta;
    res.beta              = beta;
    
    if isfield(res,'stdBeta')
        stdBeta                  = nan(nExo,nDep);
        stdBeta(~restrict.ind,:) = res.stdBeta;
        res.stdBeta              = stdBeta;
    end
    
    if isfield(res,'tStatBeta')
        tStatBeta                  = nan(nExo,nDep);
        tStatBeta(~restrict.ind,:) = res.tStatBeta;
        res.tStatBeta              = tStatBeta;
    end
    
    if isfield(res,'pValBeta')
        pValBeta                  = nan(nExo,nDep);
        pValBeta(~restrict.ind,:) = res.pValBeta;
        res.pValBeta              = pValBeta;
    end
    
    % Adjust contant and time_trend options back if needed
    if restrict.constant
        options.constant = true;
    end
    if restrict.time_trend
        options.time_trend = true;
    end
    
end
