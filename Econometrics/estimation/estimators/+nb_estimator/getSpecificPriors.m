function options = getSpecificPriors(options)
% Syntax:
%
% options = nb_estimator.getSpecificPriors(options)
%
% Description:
%
% Get indicies of priors on specific coefficients
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(options.prior,'coeff')
        return
    end

    pCoeff = options.prior.coeff;
    if isempty(pCoeff)
        return
    end
    if size(pCoeff,2) ~= 2 || ~iscell(pCoeff)
        error([mfilename ':: The priors coeff field must be a N x 2 cell matrix.'])
    end

    coeffNames  = nb_bVarEstimator.getCoeff(options,'priors');
    N           = size(pCoeff,1);
    pCoeffInt   = nan(N,2);
    pCoeffN     = pCoeff(:,1)';
    [test,indC] = ismember(pCoeffN,coeffNames);
    if any(~test)
        error([mfilename ':: The following coefficients cannot be applied a specific prior; ' toString(pCoeffN(~test)) '.'])
    end
    pCoeffInt(:,1)         = indC';
    pCoeffInt(:,2)         = [pCoeff{:,2}]';
    options.prior.coeffInt = pCoeffInt;
    
end
