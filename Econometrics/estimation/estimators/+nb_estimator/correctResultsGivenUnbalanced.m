function [res,options] = correctResultsGivenUnbalanced(options,res)
% Syntax:
%
% [res,options] = nb_estimator.correctResultsGivenUnbalanced(options,res)
%
% Description:
%
% Expand beta and exogeneous to be equal when exogneous variables 
% are leaded and not. 
%
% See also:
% nb_olsEstimator.estimate, nb_quantileEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    iter   = size(res.beta,3);
    nQuant = size(res.beta,4);
    numAll = size(res.beta,2);
    if options.exogenousLead
        nExo = length(options.uniqueExogenous); % Unique number of exogenous variables
        if options.current
            addedExo          = nb_cellstrlag(options.exogenous(1:nExo),1);
            options.exogenous = [addedExo, options.exogenous];
        else
            addedExo          = options.uniqueExogenous;
            options.exogenous = [addedExo, options.exogenous];
        end
        numDet      = options.constant + options.time_trend;
        res.beta    = [res.beta(1:numDet,:,:,:); zeros(nExo,numAll,iter,nQuant); res.beta(numDet + 1:end,:,:,:)];
        res.stdBeta = [res.stdBeta(1:numDet,:,:,:); zeros(nExo,numAll,iter,nQuant); res.stdBeta(numDet + 1:end,:,:,:)]; 
        if ~options.recursive_estim 
            res.tStatBeta = [res.tStatBeta(1:numDet,:,:,:); nan(nExo,numAll,iter,nQuant); res.tStatBeta(numDet + 1:end,:,:,:)]; 
            res.pValBeta  = [res.pValBeta(1:numDet,:,:,:); nan(nExo,numAll,iter,nQuant); res.pValBeta(numDet + 1:end,:,:,:)];
        end
    else
        nExo              = length(options.uniqueExogenous); % Unique number of exogenous variables
        addedExo          = nb_cellstrlead(options.uniqueExogenous,1);
        options.exogenous = [options.exogenous, addedExo];
        res.beta          = [res.beta; zeros(nExo,numAll,iter,nQuant)];
        res.stdBeta       = [res.stdBeta; zeros(nExo,numAll,iter,nQuant)];
        if ~options.recursive_estim 
            res.tStatBeta = [res.tStatBeta; nan(nExo,numAll,iter,nQuant)];
            res.pValBeta  = [res.pValBeta; nan(nExo,numAll,iter,nQuant)];
        end
    end

end
