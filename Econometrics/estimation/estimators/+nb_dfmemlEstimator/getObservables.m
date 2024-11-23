function observables = getObservables(results,options)
% Syntax:
%
% observables = nb_dfmemlEstimator.getObservables(results,options)
%
% Description:
%
% Get the observables of the estimated model as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'Z')
        observables = nb_ts();
    else

        if isfield(options,'observablesOrig')
            % During estimation
            obs = options.observablesOrig;
        else
            obs = options.observables;
        end
        
        % Actual observations
        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
        [~,indX] = ismember(obs,options.dataVariables);
        X        = options.data(startInd:endInd,indX)';

        % Estimate of missing
        alpha = results.smoothed.variables.data';
        for tt = 1:size(X,2)
            for vv = 1:size(X,1)
                if isnan(X(vv,tt))
                    X(vv,tt) = results.Z(vv,:)*alpha(:,tt);
                    if ~isempty(results.S)
                        X(vv,tt) = bsxfun(@times,X(vv,tt),results.S(vv,:,end));
                    end
                    if size(results.W,2) > 0
                        X(vv,tt) = results.C(vv,:,end)*results.W(tt,:,end)' + X(vv,tt);
                    end
                end
            end
        end
        observables = nb_ts(X', 'Observables', results.smoothed.variables.startDate, obs,false); 

    end

end
