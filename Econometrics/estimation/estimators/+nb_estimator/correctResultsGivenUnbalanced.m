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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    iter   = size(res.beta,3);
    nQuant = size(res.beta,4);
    numAll = size(res.beta,2);
    if any(options.exogenousLead > 0)

        nLags        = max(options.nLags) + double(all(options.exogenousLead > 0 & options.current == 1));
        newExogenous = [nb_cellstrlag(options.uniqueExogenous,nLags,'varFast'),...
                        options.uniqueExogenous];
        newExogenous = [newExogenous, nb_cellstrlead(options.uniqueExogenous,1,'varFast')];
        [~,loc]      = ismember(options.exogenous,newExogenous);
        numDet       = options.constant + options.time_trend;
        loc          = [1:numDet, loc + numDet];
        numNewCoeff  = numDet + size(newExogenous,2);

        numEq = size(res.beta,2);
        beta = zeros(numNewCoeff,numEq,iter,nQuant);
        if any(strcmpi(options.estim_method,{'lasso','ridge'}))
            stdBeta = nan(numNewCoeff,numEq,iter,nQuant);
        else
            stdBeta = zeros(numNewCoeff,numEq,iter,nQuant);
        end

        beta(loc,:,:,:)    = res.beta;
        stdBeta(loc,:,:,:) = res.stdBeta;
        res.beta           = beta;
        res.stdBeta        = stdBeta;

        if ~options.recursive_estim 
            if isfield(res,'tStatBeta')
                tStatBeta            = nan(numNewCoeff,numEq,iter,nQuant);
                tStatBeta(loc,:,:,:) = res.tStatBeta;
                res.tStatBeta        = tStatBeta;
            end
            if isfield(res,'pValBeta')
                pValBeta            = nan(numNewCoeff,numEq,iter,nQuant);
                pValBeta(loc,:,:,:) = res.pValBeta;
                res.pValBeta        = pValBeta;
            end
        end

        options.exogenous = newExogenous;

    else
        nExo              = length(options.uniqueExogenous); % Unique number of exogenous variables
        addedExo          = nb_cellstrlead(options.uniqueExogenous,1);
        options.exogenous = [options.exogenous, addedExo];
        res.beta          = [res.beta; zeros(nExo,numAll,iter,nQuant)];
        if any(strcmpi(options.estim_method,{'lasso','ridge'}))
            res.stdBeta = [res.stdBeta; nan(nExo,numAll,iter,nQuant)];
        else
            res.stdBeta = [res.stdBeta; zeros(nExo,numAll,iter,nQuant)];
        end
        if ~options.recursive_estim 
            if isfield(res,'tStatBeta')
                res.tStatBeta = [res.tStatBeta; nan(nExo,numAll,iter,nQuant)];
            end
            if isfield(res,'pValBeta')
                res.pValBeta  = [res.pValBeta; nan(nExo,numAll,iter,nQuant)];
            end
        end
    end

end
