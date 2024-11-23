function options = correctOptionsForUnbalanced(options)
% Syntax:
%
% options = nb_estimator.correctOptionsForUnbalanced(options)
%
% See also:
% nb_olsEstimator.estimate, nb_quantileEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if iscell(options.nLags)
        error(['The unbalanced option cannot be set to true at the same ',...
            'time as the nLags option is a cell.'])
    end

    if length(options.dependent) > 1
        error(['You can only declare one dependent variable if you use ',...
            'set the unbalanced option to true.'])
    end
    options.uniqueExogenous = options.exogenous;

    % Check ragged edge in this case
    [testY,indY] = ismember(options.dependent,options.dataVariables);
    [testX,indX] = ismember(options.uniqueExogenous,options.dataVariables);
    if any(~testY)
        error(['Some of the dependent variable are not found to be in ',...
            'the dataset; ' toString(options.dependent(~testY))])
    end
    if any(~testX)
        error(['Some of the exogenous variable are not found to be in ',...
            'the dataset; ' toString(options.uniqueExogenous(~testX))])
    end
    y       = options.data(:,indY);
    X       = options.data(:,indX);
    options = nb_estimator.testSample(options,y); 
    lastZ   = nan(1,size(X,2));
    for ii = 1:size(X,2)
        lastZ(ii) = find(~isnan(X(:,ii)),1,'last');
    end
    options.exogenousLead   = min(lastZ - options.estim_end_ind,1);
    if any(options.exogenousLead < 0)
        error(['The variables ' toString(options.uniqueExogenous(options.exogenousLead < 0)),...
            ' has fewer observations than the dependent variable. This is not ',...
            'supported when the unbalanced options is set to true!'])
    end
    options.current         = options.nLags - options.exogenousLead ~= -1;
    options.estim_start_ind = [];

    % Correct for nLags
    if any(options.exogenousLead > 0)
        options.nLags = max(options.nLags - options.exogenousLead,0);
    end

    % Add leads of exogenous
    options = nb_olsEstimator.addLeads(options);
            
end
