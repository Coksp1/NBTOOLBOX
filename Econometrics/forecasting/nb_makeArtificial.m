function YDRAW = nb_makeArtificial(model,options,results,method,replic,iter)
% Syntax:
%
% YDRAW = nb_makeArtificial(model,options,results,method,replic)
%
% Description:
%
% Make artificial data using bootstrap methods.
% 
% See also:
% nb_irfEngine, nb_uncondForecast
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    replic = ceil(replic);
    if isempty(method)
        method = 'bootstrap';
    end

    A        = model.A(:,:,iter);
    B        = model.B(:,:,iter);
    resid    = results.residual(:,:,iter); 
    indN     = ~isnan(resid(:,1));
    resid    = resid(indN,:); % Remove nan given that we could be dealing with recursive estimation
    exo      = model.exo;
    start    = options.estim_start_ind;
    nobs     = size(resid,1);
    finish   = start + nobs - 1;
    numEndo  = length(model.endo);
    endo     = model.endo;
    if strcmpi(model.class,'nb_var') || strcmpi(model.class,'nb_pitvar')
        if ~isempty(A)
            start = start - 1;
            nobs  = nobs + 1;
        end
    elseif strcmpi(model.class,'nb_sa')
        finish = finish + options.nStep; 
        ind    = ceil(nobs*rand(options.nStep,1));
        nobs   = nobs + options.nStep;
        resid  = [resid; resid(ind,:)]; % Put random residuals to the end here...
    end
    [~,indY] = ismember(endo,options.dataVariables);
    
    % Use the residuals to bootstrap: generate a random number bounded 
    % between 0 and # of residuals, then use the ceil function to select 
    % that row of the residuals (this is equivalent to sampling with 
    % replacement)
    dep = options.dependent;
    if isfield(options,'block_exogenous')
        dep = [dep,options.block_exogenous];
    end
    nEq = length(dep);
    
    % Then we bootstrap the residuals
    E = nb_bootstrap(resid,replic,method);
    
    % Get the deterministic exogenous variables
    X        = nan(nobs,0);
    constant = options.constant;
    if constant 
        X = [X,ones(nobs,1)];
    end

    if isfield(options,'time_trend')
        time_trend = options.time_trend;
        if time_trend
            t = 1:nobs;
            X = [X,t']; 
        end
    end

    % Get other exogenous variables (which are not randomized!!!)
    [ind,indX] = ismember(exo,options.dataVariables);
    indX       = indX(ind);
    XS         = options.data(start:finish,indX);    
    X          = [X,XS]'; 
        
    % Generate the artificial data
    %-------------------------------
    Y              = options.data(start:finish,indY)';
    YDRAW          = zeros(numEndo,replic,nobs);
    YDRAW(:,:,1)   = repmat(Y(:,1),[1,replic]);
    if strcmpi(options.class,'nb_ecm')
        C = model.C;
    else
        C = [eye(nEq);zeros(numEndo-nEq,nEq)];
    end
    if isempty(B)
    
        for t = 1:nobs-1
            AY             = A*Y(:,t);
            AY             = AY(:,ones(1,replic));
            YDRAW(:,:,t+1) = AY + C*E(:,:,t);
        end
        
    elseif isempty(A)
        
        for t = 1:nobs
            BX           = B*X(:,t);
            BX           = BX(:,ones(1,replic));
            YDRAW(:,:,t) = BX + C*E(:,:,t);
        end
        
    else
        
        for t = 1:nobs-1
            AY             = A*Y(:,t);
            AY             = AY(:,ones(1,replic));
            BX             = B*X(:,t+1);
            BX             = BX(:,ones(1,replic));
            YDRAW(:,:,t+1) = AY + BX + C*E(:,:,t);
        end
        
    end
    YDRAW = permute(YDRAW,[3,1,2]); 
    
end
