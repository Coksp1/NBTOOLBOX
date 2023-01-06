function options = varModifications(options)
% Syntax:
%
% options = nb_olsEstimator.varModifications(options)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Add first lag to right hand side variable. nLags change to
    % refer to number of lags of the already lagged right hand side
    % variables
    tempAll  = cellstr(options.dependent);
    if isfield(options,'block_exogenous')
        if ~isempty(options.block_exogenous)
            tempAll = [tempAll,options.block_exogenous];
        end
    end
    endoLag = nb_cellstrlag(tempAll,1,'varFast');
    if ~all(ismember(endoLag,options.dataVariables))
    
        options.exogenous           = [options.exogenous,endoLag];
        options.modelSelectionFixed = [options.modelSelectionFixed,false(1,length(tempAll))];
        options.nLags               = options.nLags - 1;

        % Add first lag to dataset
        [~,indY]              = ismember(tempAll,options.dataVariables);
        Y                     = options.data(:,indY);
        Ylag                  = nb_mlag(Y,1,'varFast');
        options.data          = [options.data, Ylag];
        options.dataVariables = [options.dataVariables, endoLag];
        
    end

end
