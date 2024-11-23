function irfDataD = irfIdentDraws(model,options,results,inputs)
% Syntax:
%
% irfDataD = nb_irfEngine.irfIdentDraws(model,options,results,inputs)
%
% Description:
%
% Produce IRFs with error bands using uncertainty in identification.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isfield(inputs,'parallelL')
        if inputs.parallelL
            error([mfilename ':: Cannot run IRF in parallel (lower level) when ''method'' is set to ''identDraws''.'])
        end
    end
    
    periods        = inputs.periods;
    shocks         = inputs.shocks;
    vars           = inputs.variables;
    variablesLevel = inputs.variablesLevel;

    % Check that we are dealing with a VAR identified with sign restriction
    % and that draws of C has been done
    C      = model.C;
    replic = size(C,4);
    if replic == 1
        error([mfilename ':: You need to make draws of the matrix of the map from structural shocks '...
            'to dependent variables. See the method set_identification of the nb_var class (or subclasses '...
            'of this class).'])
    elseif replic < length(inputs.perc)
        error([mfilename ':: The number of draws of the matrix of the map from structural shocks '...
            'to dependent variables must at least be larger then the percentiles to calculate.'])
    end
    
    % Create waiting bar window
    if isfield(inputs,'index')
        h = nb_waitbar([],['Uses draws from identified matrices (IRF). Model ' int2str(inputs.index) ' of ' int2str(inputs.nObj)],replic,true);
    else
        h = nb_waitbar([],'Uses draws from identified matrices (IRF)',replic,true);
    end
    h.text = 'Starting...'; 
        
    modelDraw = model;
    nVars     = length(vars) + length(variablesLevel);
    nShocks   = length(shocks);
    irfDataD  = nan(periods+1,nVars,nShocks,replic);
    note      = nb_when2Notify(replic);
    for kk = 1:replic

        % Get the draw of the matrix of the map from structural shocks
        % to dependent variables
        modelDraw.C = C(:,:,end,kk);
        
        % Calculate impulse responses given the draw
        irfDataD(:,:,:,kk) = nb_irfEngine.irfPoint(modelDraw,options,inputs,results);

        % Report current estimate in the waitbar's message field
        if h.canceling
            error([mfilename ':: User terminated'])
        end
        
        if rem(kk,note) == 0
            h.status = kk;
            h.text   = ['Finished with ' int2str(kk) ' replications...'];
        end
        
    end
    
    % Delete the waitbar.
    delete(h) 
    
end
