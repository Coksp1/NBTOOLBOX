function options = addLags(options)
% Syntax:
%
% options = nb_olsEstimator.addLags(options)
%
% Description:
%
% Add lags to right hand side of estimation equation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    fixed        = options.modelSelectionFixed;
    [testX,indX] = ismember(options.exogenous,options.dataVariables);
    if any(~testX)
        error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
    end
    X            = options.data(:,indX);
    XNotF        = X(:,~fixed);
    Xlag         = nb_mlag(XNotF,options.nLags,'varFast');
    options.data = [options.data,Xlag];

    % Add lag postfix (If the variable already have a lag postfix we
    % append the number indicating that it is lag once more)
    exoLag                = nb_cellstrlag(options.exogenous(~fixed),options.nLags,'varFast');
    options.exogenous     = [options.exogenous,exoLag];
    options.dataVariables = [options.dataVariables, exoLag];

end
