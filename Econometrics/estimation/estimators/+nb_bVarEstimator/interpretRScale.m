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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(options.prior,'R_scale') && nb_isempty(options.measurementEqRestriction)
        return
    end

    if isfield(options.prior,'R_scale')
        R_scale = options.prior.R_scale;
    else
        R_scale = [];
    end
    
    depNames = options.dependent;
    if isfield(options,'block_exogenous')
       depNames = [depNames,options.block_exogenous];
    end
    
    if isempty(R_scale) 
        if strcmpi(options.class,'nb_var') && nb_isempty(options.measurementEqRestriction)
            return
        else
            R_scale = 10;
        end
    end 
        
    if nb_isScalarNumber(R_scale)  
        if ~nb_isempty(options.measurementEqRestriction)
            if isfield(options,'mixing')
                [~,loc] = ismember(options.mixing(options.indObservedOnly),depNames); 
                num     = size(loc,2);
                R_scale = [depNames(loc)',num2cell(R_scale(ones(num,1),:))];
            else
                R_scale = cell(0,2);
            end
        else 
            if strcmpi(options.class,'nb_mfvar')
                if any(options.indObservedOnly)
                    options.prior.R_scale = R_scale;
                else
                    % Due to default old behavior a scalar is converted to 
                    % no measurement error. Not great solution, but couldn't
                    % do anything else...
                    options.prior.R_scale = [];
                end
            end
            return
        end
    end
    allNames = depNames;
    if ~nb_isempty(options.measurementEqRestriction)
        R_scaleRest = [{options.measurementEqRestriction.restricted}',...
                       {options.measurementEqRestriction.R_scale}'];
        R_scale     = [R_scale;R_scaleRest]; 
        allNames    = [allNames,R_scaleRest(:,1)'];
    end 
    if size(R_scale,2) ~= 2 || ~iscell(R_scale)
        error([mfilename ':: The R_scale field of the prior option must be a N x 2 cell matrix or a scalar number.'])
    end
        
    N           = size(R_scale,1);
    pCoeffInt   = nan(N,2);
    pCoeffN     = R_scale(:,1)';
    [test,indC] = ismember(pCoeffN,allNames);
    if any(~test)
        error(['The following names cannot be applied a specific R_scale parameter, ',...
            'as they are not a dependent nor block exogenous variables of the model; ',...
            toString(pCoeffN(~test)) '.'])
    end
    pCoeffInt(:,1)        = indC';
    pCoeffInt(:,2)        = [R_scale{:,2}]';
    options.prior.R_scale = pCoeffInt;

end
