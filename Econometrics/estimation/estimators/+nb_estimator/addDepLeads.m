function options = addDepLeads(options)
% Syntax:
%
% options = nb_estimator.addDepLeads(options)
%
% Description:
%
% Add leads to left hand side of estimation equation. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Add leads to data
    [testY,indY] = ismember(options.dependent,options.dataVariables);
    if any(~testY)
        error(['Some of the dependent variables are not found to be in ',...
            'the dataset; ' toString(options.dependent(~testY))])
    end
    Y            = options.data(:,indY);
    Ylead        = nb_mlead(Y,options.nStep,'varFast');
    options.data = [options.data,Ylead];

    % Add lead postfix
    yLead                 = nb_cellstrlead(options.dependent,options.nStep,'varFast');
    options.dataVariables = [options.dataVariables, yLead];

end
