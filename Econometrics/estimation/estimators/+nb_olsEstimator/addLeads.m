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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [testX,indX] = ismember(options.uniqueExogenous,options.dataVariables);
    if any(~testX)
        error(['Some of the exogenous variable are not found to be in ',...
            'the dataset; ' toString(options.uniqueExogenous(~testX))])
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
    if any(options.exogenousLead > 0)
        options.exogenous = [options.uniqueExogenous(options.current == 1),...
            exoLead(options.exogenousLead > 0)];
    end
    options.exogenous = [exoLags,options.exogenous];

    extra       = options.current == 1 & options.exogenousLead > 0;
    exoLagsData = nb_cellstrlag(options.uniqueExogenous,options.nLags + extra,'varFast');
    if ~isempty(exoLagsData)
        % Add expanded lags to data
        Xlag                  = nb_mlag(X,options.nLags + extra,'varFast');
        options.data          = [options.data,Xlag];
        options.dataVariables = [options.dataVariables, exoLagsData];
    end

    options.addLags = false;
    
end
