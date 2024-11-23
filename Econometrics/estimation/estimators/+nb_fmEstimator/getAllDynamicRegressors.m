function [allRegressors,restrictions] = getAllDynamicRegressors(options,type)
% Syntax:
%
% [allRegressors,restrictions] = nb_fmEstimator.getAllDynamicRegressors(options,type)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'all';
    end

    % Get all exogenous variables
    maxLags      = max(options.nLags);
    allExo       = nb_cellstrlag(options.dependent,maxLags,'varFast');
    allExoNotLag = [options.exogenous{:}];
    ind          = ismember(allExoNotLag,allExo);
    allExoNotLag = allExoNotLag(~ind);
    allExo       = [allExoNotLag,allExo];
    
    if ~strcmpi(type,'all')
        allRegressors = allExo;
        return
    end
    
    % Get all factors of the dynamic eq
    maxFLags   = max(maxLags,options.factorsLags); 
    allFactors = nb_cellstrlag(options.factors,maxFLags,'varFast');
    if options.contemporaneous
        allFactors = [options.factors,allFactors];
    end
    
    % Return all regressors
    allRegressors = [allExo,allFactors];

    % Get restrictions
    if nargout > 1
        
        numDep        = length(options.dependent);
        restrictions  = cell(1,numDep+options.nFactors);
        for ii = 1:numDep

            exo  = options.exogenous{ii};
            fac  = options.factorsRHS{ii};
            rest = ismember(allRegressors,[exo,fac]);
            if options.time_trend
                rest = [true,rest]; %#ok<AGROW>
            end
            if options.constant
                rest = [true,rest]; %#ok<AGROW>
            end
            restrictions{ii} = rest;

        end

        % Restrict the regressors of the fynamic factor model
        rest = ismember(allRegressors,options.factorsRHS{end});
        if options.time_trend
            rest = [true,rest];
        end
        if options.constant
            rest = [false,rest]; % No constant in the dynamic factor equation
        end
        for kk = 1:options.nFactors
            restrictions{ii+kk} = rest;
        end
        
    end
    
end
