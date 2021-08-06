function options = addLags(options)
% Syntax:
%
% options = nb_midasEstimator.addLags(options)
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
    X     = options.data(:,indX);
    nLags = 0:options.nLags;
    
    XNotF                 = X(:,~fixed);
    Xlag                  = nb_mlag(XNotF,max(nLags),'varFast');
    options.data          = [options.data,Xlag];
    dataVarLag            = nb_cellstrlag(options.exogenous(~fixed),max(nLags),'varFast');
    options.dataVariables = [options.dataVariables, dataVarLag];

    % Add lag postfix (If the variable already have a lag postfix we
    % append the number indicating that it is lag once more)
    exoFixed = options.exogenous(~fixed);
    exoLag   = cell(length(exoFixed),length(nLags(nLags>0)));
    for ii = 1:length(exoFixed)
        exoLag(ii,:) = nb_appendIndexes(strcat(exoFixed{ii},'_lag'),nLags(nLags>0));
    end
    exoLag = exoLag(:)';
    if any(nLags == 0)
        exoLag = [options.exogenous(~fixed),exoLag];
    end
    options.exogenous = exoLag;
    

end
