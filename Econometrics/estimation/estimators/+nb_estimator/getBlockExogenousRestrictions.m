function restrictions = getBlockExogenousRestrictions(options)
% Syntax:
%
% restrictions = nb_estimator.getBlockExogenousRestrictions(options)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    options = nb_defaultField(options,'blockLags',[]);
    if ~isempty(options.blockLags)
        if ~nb_isScalarInteger(options.blockLags) && ~isempty(options.blockLags)
            error([mfilename ':: The ''blockLags'' option must be set to a scalar interger or empty'])
        end
        if options.blockLags >  options.nLags + 1
            error([mfilename ':: The ''blockLags'' input must be lower or equal to the ''nLags'' input.'])
        end
    end
    
    block_exogenous = options.block_exogenous;
    allVars         = [options.dependent,block_exogenous];
    if strcmpi(options.class,'nb_mfvar')
        nLags = options.nLags;
        if isfield(options,'indObservedOnly')
            allVars = allVars(~options.indObservedOnly);
        end
        exogenous = [options.exogenous, nb_cellstrlag(allVars,nLags,'varFast')];
    else
        nLags     = options.nLags + 1;
        exogenous = options.exogenous;
    end
    nEq             = length(allVars);
    block_ids       = options.block_id;
    restrictions    = cell(1,nEq);
    if options.time_trend
        exogenous = ['time_trend',exogenous];
    end
    if options.constant
        exogenous = ['constant',exogenous];
    end
    nExo = length(exogenous);
    for ii = 1:nEq
        
        indB = find(strcmpi(allVars{ii},block_exogenous),1);
        if ~isempty(indB)
            id                = block_ids(indB);
            id                = block_ids == id;
            blockRestrictions = true(1,nExo);
            indE              = ~ismember(allVars,block_exogenous(id));
            excludedVars      = allVars(indE);
            excludedVars      = nb_cellstrlag(excludedVars,nLags,'varFast');
            if ~isempty(options.blockLags)
                all          = nb_cellstrlag(block_exogenous,options.nLags + 1,'varFast');
                wanted       = nb_cellstrlag(block_exogenous,options.blockLags,'varFast');
                removed      = setdiff(all,wanted);
                excludedVars = [excludedVars,removed]; %#ok<AGROW>
            end
            indE                    = ismember(exogenous,excludedVars);
            blockRestrictions(indE) = false;
            restrictions{ii}        = blockRestrictions;
        else
            restrictions{ii} = true(1,nExo);
        end
        
    end
    
end
