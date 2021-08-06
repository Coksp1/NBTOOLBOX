function options = modelSelectionAlgorithm(options)
% Syntax:
%
% options = nb_midasEstimator.modelSelectionAlgorithm(options)
%
% Description:
%
% Function to automatically select model.
% 
% See also:
% nb_midasEstimator.etimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tempData = options.data;
      
    % Get start index for later
    startInd = options.estim_start_ind;
    if isempty(startInd)
        startInd = 1;
    end
    
    % Get end index for later
    endInd = options.estim_end_ind;
    if isempty(endInd)
        endInd = size(tempData,1);
    end
    
    fixed = options.modelSelectionFixed;

    % Get estimation sample
    tempDep = cellstr(options.dependent);
    if isfield(options,'block_exogenous')
        if ~isempty(options.block_exogenous)
            % The algorithm for model selection does not add these
            % restriction yet!!!!!
            tempDep = [tempDep,options.block_exogenous];
        end
    end
    [testY,indY] = ismember(tempDep,options.dataVariables);
    [testX,indX] = ismember(options.exogenous,options.dataVariables);
    if any(~testY)
        error([mfilename ':: Some of the dependent variable are not found to be in the dataset; ' toString(tempDep(~testY))])
    end
    if any(~testX)
        error([mfilename ':: Some of the exogenous variable are not found to be in the dataset; ' toString(options.exogenous(~testX))])
    end
    y         = tempData(startInd:endInd,indY);
    X         = tempData(startInd:endInd,indX);
    [~,~,y,X] = nb_checkSample(y,X);
    
    % Find the best model
    %----------------------------------------------------------
    switch lower(options.modelSelection)

        case 'laglength'

            % Check the degrees of freedom
            sizeX    = size(X,2);
            numCoeff = sizeX + options.constant + options.time_trend + sum(~fixed)*options.maxLagLength;
            dof      = size(X,1) - options.maxLagLength - options.requiredDegreeOfFreedom - numCoeff;
            if dof < 0
                needed = options.maxLagLength + options.requiredDegreeOfFreedom + numCoeff;
                error([mfilename ':: The sample is too short for lag length selection estimation with the selected maximum lag length. '...
                                 'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                                 'Which require a sample of at least ' int2str(needed) ' observations.'])
            end
            nLags = nb_lagLengthSelection(options.constant,options.time_trend,...
                              options.maxLagLength,options.criterion,'ols',y,X,fixed,1 + options.maxLagLength); 

            if ~isempty(minLags)   
                nLags = max(minLags,nLags);
            end
                          
            % The returend nLags is allways a 
            % scalar              
            if nLags == -1  
                % All the non fixed exogenous variables are
                % removed
                options.exogenous = options.exogenous(fixed);
            else
                % Add lag postfix (If the variable 
                % already have a lag postfix we
                % append the number indicating that
                % it is lag once more)
                exoLag            = nb_cellstrlag(options.exogenous(~fixed),nLags,'varFast');
                options.exogenous = [options.exogenous,exoLag];
                
                % Add the lags to the estimation data for later
                X                     = tempData(:,indX);
                XNotF                 = X(:,~fixed);
                Xlag                  = nb_mlag(XNotF,nLags,'varFast');
                options.data          = [options.data,Xlag];
                options.dataVariables = [options.dataVariables,exoLag];
                
            end

            options.nLags = nLags;

        case 'autometrics'

            % Check the degrees of freedom
            sizeX    = sum(~fixed);
            numCoeff = sizeX*options.maxLagLength + options.constant + options.time_trend;
            dof      = size(X,1) - options.maxLagLength - options.requiredDegreeOfFreedom - numCoeff;
            if dof < 0
                needed = options.maxLagLength + options.requiredDegreeOfFreedom + numCoeff;
                error([mfilename ':: The sample is too short for autometrics estimation with the selected maximum lag length. '...
                                 'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                                 'Which require a sample of at least ' int2str(needed) ' observations.'])
            end

            if size(y,2) > 1
                error('The model selection method autometrics is not possible with more dependent variables.')
            end

            results  = nb_automaticModelSelection(y,X,'alpha',   options.modelSelectionAlpha,...
                                                      'constant',options.constant,...
                                                      'lags',    0:options.maxLagLength,...
                                                      'start',   1 + options.maxLagLength,...
                                                      'fixed',   fixed);

            % Add lag postfix (If the variable 
            % already have a lag postfix we
            % append the number indicating that
            % it is lag once more)
            options.nLags      = results{1}.nlags;
            exoNames           = options.exogenous;
            newNames           = nb_appendLagPostfix(exoNames,results{1}.nlags);
            options.exogenous  = newNames;
            options.constant   = results{1}.constant;
            options.time_trend = 0;
            
            % Add the lags to the estimation data for later
            X                     = tempData(:,indX);
            mLags                 = max(cell2mat(options.nLags));
            Xlag                  = nb_mlag(X,mLags,'varFast');
            exoLag                = nb_cellstrlag(exoNames,mLags,'varFast');
            options.data          = [options.data,Xlag];
            options.dataVariables = [options.dataVariables,exoLag];

        otherwise

            error([mfilename ':: Unsupported model selection criterion ' options.modelSelection '.'])

    end

end
