function R_prior = setUpPriorMeasEqCovMat(y,indObservedOnly,mixing,prior)
% Syntax:
%
% R_prior = nb_bVarEstimator.setUpPriorMeasEqCovMat(y,...
%       indObservedOnly,mixing,prior)
%
% Description:
%
% Get indicies of priors on the measurement error.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    numDep  = size(y,2);
    R_prior = zeros(numDep,1);
    if any(indObservedOnly) && ~isempty(mixing)
        % Even if all observation of the series are nan, this is not a
        % problem as the nan elements of R will never be used!
        if isscalar(prior.R_scale)
            R_prior(mixing.loc) = var(y(:,mixing.loc),'omitnan')/prior.R_scale;
        else
            varDep                      = var(y(:,prior.R_scale(:,1)),'omitnan')';
            R_prior(prior.R_scale(:,1)) = varDep./prior.R_scale(:,2);
        end
    elseif isfield(prior,'R_scale')
        if isempty(prior.R_scale)
            return
        elseif isscalar(prior.R_scale)
            R_prior(:) = var(y,'omitnan')/prior.R_scale;
        else
            varDep                      = var(y(:,prior.R_scale(:,1)),'omitnan')';
            R_prior(prior.R_scale(:,1)) = varDep./prior.R_scale(:,2);
        end
    end
    
end
