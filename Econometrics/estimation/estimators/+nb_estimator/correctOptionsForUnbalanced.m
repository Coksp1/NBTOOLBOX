function options = correctOptionsForUnbalanced(options)
% Syntax:
%
% options = nb_estimator.correctOptionsForUnbalanced(options)
%
% See also:
% nb_olsEstimator.estimate, nb_quantileEstimator.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscell(options.nLags)
        error([mfilename ':: The unbalanced option cannot be set to true at the same time as the nLags option is a cell.'])
    end

    options.uniqueDependent = unique(regexprep(options.dependent,'_lead\d',''));
    if length(options.uniqueDependent) > 1
        error([mfilename ':: You can only declare one dependent variable if you use set the unbalanced option to true.'])
    end
    nUniqueExo              = length(options.exogenous);
    options.uniqueExogenous = options.exogenous(1:nUniqueExo);

    % Check ragged edge in this case
    [testY,indY] = ismember(options.uniqueDependent,options.dataVariables);
    [testX,indX] = ismember(options.uniqueExogenous,options.dataVariables);
    if any(~testY)
        error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(options.uniqueDependent(~testY))])
    end
    if any(~testX)
        error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.uniqueExogenous(~testX))])
    end
    if isempty(options.estim_start_ind)
        resetStart = true;
    else
        resetStart = true;
    end
    y        = options.data(:,indY);
    X        = options.data(:,indX);
    options  = nb_estimator.testSample(options,y); 
    lastZ    = find(~all(isnan(X),2),1,'last');
    e        = 0;
    if lastZ >= options.estim_end_ind+1
        e = 1;
    end
    options.exogenousLead = e;
    options.current       = options.nLags - e ~= -1;
    if resetStart
        options.estim_start_ind = [];
    end
    
    % Correct for nStep
    options.estim_end_ind = options.estim_end_ind - max(options.nStep,options.exogenousLead);
    if ~isempty(options.recursive_estim_start_ind)
        options.recursive_estim_start_ind = options.recursive_estim_start_ind - max(options.nStep,options.exogenousLead);
    end
    if options.exogenousLead
        options.nLags = max(options.nLags - 1,0);
    end
            
end
