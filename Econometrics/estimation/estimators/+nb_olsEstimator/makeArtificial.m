function [YDRAW,start,finish,indY,startEst] = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% [YDRAW,start,finish,indY,startEst] = nb_olsEstimator.makeArtificial(...
%                                       model,options,results,method,...
%                                       draws,iter)
%
% Description:
%
% Make artificial data from model by simulation.
%
% Caution: The options struct is assumed to already be index by iter!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if strcmpi(model.class,'nb_sa')
        ind = ismember(model.endo,options.dataVariables);
        if any(~ind)
            % When some steps are jumped we need to add artifical series
            % for does
            numExtra              = sum(~ind);
            options.data          = [options.data,zeros(size(options.data,1),numExtra)];
            options.dataVariables = [options.dataVariables,model.endo(~ind)];
        end
    end

    YDRAW = nb_makeArtificial(model,options,results,method,draws,iter);
      
    % Correct sample + append initial value
    nLags = [];
    if strcmpi(model.class,'nb_var')
        nLags = options.nLags + 1;
    elseif strcmpi(model.class,'nb_singleEq')
        if ~(isempty(model.A) || model.A == 0)
            nDep  = length(options.dependent);
            nLags = size(model.A,1)/nDep;
        end
    end
    
    if ~(isempty(nLags) || isempty(model.A))
        dep = options.dependent;
        if isfield(options,'block_exogenous')
            dep = [dep,options.block_exogenous];
        end
        YDRAW  = YDRAW(:,1:length(dep),:);
        YDRAW  = [YDRAW,nb_mlag(YDRAW,nLags,'varFast')];
    end
    
    % Other outputs
    %------------------------
    if options.recursive_estim 
        finish = options.recursive_estim_start_ind + iter - 1;
        if ~isempty(options.rollingWindow)
            start = finish - size(YDRAW,1) + 1;
        else
            start = options.estim_start_ind;
        end
    else
        finish = options.estim_end_ind;
        start  = options.estim_start_ind;
    end
    if ~isempty(options.rollingWindow)
        startEst = start;
    else
        startEst = options.estim_start_ind;
    end
    
    % Correct sample + append initial value
    if ~(isempty(nLags) || isempty(model.A))
        if strcmpi(model.class,'nb_var')
            start    = start - 1;
            startEst = startEst + nLags - 1;
        else
            startEst = startEst + nLags;
        end
        endo = [dep,nb_cellstrlag(dep,nLags,'varFast')];
    else
        endo = model.endo;
    end
    [~,indY] = ismember(endo,options.dataVariables);
    
end
