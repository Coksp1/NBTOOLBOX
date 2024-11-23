function [y,X,blockRest,options] = preprareDataForEstimation(options)
% Syntax:
%
% [y,X,blockRest,options] = nb_estimator.preprareDataForEstimation(options)
%
% Description:
%
% Prepare data for estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Are we dealing with a VAR?
    %-------------------------------------------------------
    if isfield(options,'class')
        if strcmpi(options.class,'nb_var')
            options = nb_olsEstimator.varModifications(options); 
        end
    end
    
    % Get the estimation options
    %------------------------------------------------------
    tempDep  = cellstr(options.dependent);
    if isempty(tempDep)
        error(['No dependent variables selected, please assign the ',...
            'dependent field of the options property.'])
    end
    options.exogenous = cellstr(options.exogenous);
    
    if isempty(options.data)
        error('Cannot estimate without data.')
    end

    if isempty(options.modelSelectionFixed)
        fixed = false(1,length(options.exogenous));
    else
        fixed = options.modelSelectionFixed;
        if ~islogical(fixed)
            fixed = logical(options.modelSelectionFixed);
        end
    end
    options.modelSelectionFixed = fixed;

    % Get the estimation data
    %------------------------------------------------------
    if isempty(options.estim_types) % Time-series

        % Add seasonal dummies
        if ~isempty(options.seasonalDummy)
            options = nb_olsEstimator.addSeasonalDummies(options); 
        end
        
        % Do we deal with unbalanced dataset?
        if options.unbalanced
            options = nb_estimator.correctOptionsForUnbalanced(options);
        else
            options.uniqueExogenous = options.exogenous;
        end
        if options.nStep > 0
            if ~isempty(options.covidAdj) && length(options.dependent) > 1
                error('If covidAdj is not empty, you can only have one dependent variable!')
            end
            options = nb_estimator.addDepLeads(options);
        end
        
        % Add lags or find best model
        if ~isempty(options.modelSelection)

            if options.unbalanced
                error(['The unbalanced option cannot be set to true ',...
                    'at the same time as using model selection.'])
            end
            if ~isempty(options.restrictions)
                error(['Parameter restrictions cannot be applied at the ',...
                    'same time as using model selection.'])
            end
            minLags = [];
            if isfield(options,'class')
                if strcmpi(options.class,'nb_var')
                    minLags = 0; 
                end
            end
            options = nb_olsEstimator.modelSelectionAlgorithm(options,minLags); 
            
        else
            if options.addLags
                if iscell(options.nLags)
                    if isfield(options,'class')
                        if strcmpi(options.class,'nb_var')
                            error(['The ''nLags'' cannot be a cell, if ',...
                                'the model is of class nb_var.'])
                        end
                    end
                    options = nb_estimator.addExoLags(options,'nLags');  
                elseif ~all(options.nLags == 0) 
                    options = nb_olsEstimator.addLags(options);
                end
            end
        end
        
        % Check if we need have a block_exogenous model
        %----------------------------------------------
        blockRest = {};
        if isfield(options,'block_exogenous')
            if ~isempty(options.block_exogenous)
                tempDep   = [tempDep,options.block_exogenous];
                blockRest = nb_estimator.getBlockExogenousRestrictions(options);
            end
        end
        
        % Get data
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testX,indX] = ismember(options.exogenous,options.dataVariables);
        if any(~testY)
            error(['Some of the dependent variable are not found to be in ',...
                'the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testX)
            error(['Some of the exogenous variable are not found to be in ',...
                'the dataset; ' toString(options.exogenous(~testX))])
        end
        y = options.data(:,indY);
        X = options.data(:,indX);
        if isempty(y)
            error('The selected sample cannot be empty.')
        end
        
    else

        % Get data as a double
        [testY,indY] = ismember(tempDep,options.dataVariables);
        [testT,indT] = ismember(options.estim_types,options.dataTypes);
        [testX,indX] = ismember(options.exogenous,options.dataVariables);
        if any(~testY)
            error(['Some of the dependent variables are not found to ',...
                'be in the dataset; ' toString(tempDep(~testY))])
        end
        if any(~testX)
            error(['Some of the exogenous variables are not found to ',...
                'be in the dataset; ' toString(options.exogenous(~testX))])
        end
        if any(~testT)
            error(['Some of the types are not found to be in the dataset; ',...
                toString(options.estim_types(~testT))])
        end
        y = options.data(indT,indY);
        X = options.data(indT,indX);
        if isempty(y)
            error('The number of selected types cannot be 0.')
        end

    end

    % Check for constant regressors, which we do not allow
    if ~options.removeZeroRegressors
        if any(all(diff(X,1) == 0,1))
            error(['One or more of the selected exogenous variables is/are constant. '...
                'Use the constant option instead.'])
        end
    end

end
