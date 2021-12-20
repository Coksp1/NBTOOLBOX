function options = interpretRScale(options)
% Syntax:
%
% options = nb_bVarEstimator.interpretRScale(options)
%
% Description:
%
% Get indicies of priors on the measurement error.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(options.prior,'R_scale')
        return
    end

    R_scale = options.prior.R_scale;
    if isempty(R_scale) 
        options.prior.R_scale = 10;
    elseif nb_isScalarNumber(R_scale)
        return
    end
    if size(R_scale,2) ~= 2 || ~iscell(R_scale)
        error([mfilename ':: The R_scale field of the prior option must be a N x 2 cell matrix or a scalar number.'])
    end
    
    depNames = options.dependent;
    if isfield(options,'block_exogenous')
       depNames = [depNames,options.block_exogenous];
    end
    
    N           = size(R_scale,1);
    pCoeffInt   = nan(N,2);
    pCoeffN     = R_scale(:,1)';
    [test,indC] = ismember(pCoeffN,depNames);
    if any(~test)
        error([mfilename ':: The following names cannot be applied a specific R_scale parameter, ',...
                         'as they are not a dependent or block exogenous variables of the model; ' toString(pCoeffN(~test)) '.'])
    end
    pCoeffInt(:,1)        = indC';
    pCoeffInt(:,2)        = [R_scale{:,2}]';
    options.prior.R_scale = pCoeffInt;

end
