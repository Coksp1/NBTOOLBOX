function options = addLeads(options)
% Syntax:
%
% options = nb_olsEstimator.addLeads(options)
%
% Description:
%
% Add leads to right hand side of estimation equation. Only in the case
% that the unbalanced options is set to true. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [testX,indX] = ismember(options.uniqueExogenous,options.dataVariables);
    if any(~testX)
        error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.uniqueExogenous(~testX))])
    end
    X            = options.data(:,indX);
    Xlead        = nb_mlead(X,1,'varFast');
    options.data = [options.data,Xlead];

    % Add lag postfix (If the variable already have a lag postfix we
    % append the number indicating that it is lag once more)
    exoLead                = nb_cellstrlead(options.uniqueExogenous,1,'varFast');
    options.dataVariables = [options.dataVariables, exoLead];

    % Add lead to exognous and reorder lags, current and leads.
    exoLags = nb_cellstrlag(options.uniqueExogenous,options.nLags,'varFast');
    if options.exogenousLead
        if options.current
            options.exogenous = [exoLags,options.uniqueExogenous,exoLead];
        else
            options.exogenous = exoLead;
        end
        
        % Add expanded lags to data
        Xlag                  = lag(X,options.nLags + 1);
        options.data          = [options.data,Xlag];
        exoLag                = strcat(options.uniqueExogenous,'_lag',int2str(options.nLags + 1));
        options.dataVariables = [options.dataVariables, exoLag];
        
    else
        options.exogenous = [exoLags,options.uniqueExogenous];
    end
    
end
