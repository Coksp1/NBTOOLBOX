function [YDRAW,start,finish,indY,startEst] = makeArtificial(model,options,results,method,draws,iter)
% Syntax:
%
% [YDRAW,start,finish,indY,startEst] = nb_rwEstimator.makeArtificial(...
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    YDRAW = nb_makeArtificial(model,options,results,method,draws,iter);
      
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
    [~,indY] = ismember(model.endo,options.dataVariables);
    
end
