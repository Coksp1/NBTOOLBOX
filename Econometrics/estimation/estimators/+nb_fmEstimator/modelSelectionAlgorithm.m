function options = modelSelectionAlgorithm(options)
% Syntax:
%
% options = nb_fmEstimator.modelSelectionAlgorithm(options)
%
% Description:
%
% Function to automatically select model.
% 
% See also:
% nb_olsEstimator.etimate, nb_bVarEstimator.etimate
%
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tempData   = options.data;

    % Get start index for later
    startInd = options.estim_start_ind;
    if isempty(startInd)
        startInd = 1;
    end
    
    % Get end index for later
    endInd = options.estim_end_ind;
    if isempty(endInd)
        endInd = size(tempData);
    end

    % Get estimation sample
    %------------------------
    tempDep     = cellstr(options.dependent);
    [~,indY]    = ismember(tempDep,options.dataVariables);
    y           = tempData(startInd:endInd,indY);
    [~,indX]    = ismember(options.exogenous,options.dataVariables);
    X           = tempData(startInd:endInd,indX);
    [~,indF]    = ismember(options.factors,options.dataVariables);
    F           = tempData(startInd:endInd,indF);
    [~,~,y,X,F] = nb_checkSample(y,X,F);
    
    % Find best forecasting equation
    %----------------------------------------------------------
    switch lower(options.modelSelection)

        case 'laglength'

            if strcmpi(options.modelType,'dynamic')
        
                % Here we have different equation with different right
                % hand side variables, and we also allow for different
                % lag structure (forecasting equation)
                numDep  = size(y,2);
                nLags   = zeros(1,numDep+1);
                factors = cell(1,numDep+1);
                exo     = cell(1,numDep);
                yLag    = [];
                depLag  = cell(1,numDep);
                Flag    = [];
                
                % Lag the factors one period
                FLag     = nb_mlag(F,1,'varFast');
                FLagName = nb_cellstrlag(options.factors,1,'varFast');
                
                % The model can include the contemporaneous factor or
                % not, so we need to check that
                if options.contemporaneous
                    factorsT = options.factors;
                    FT       = F;
                else
                    factorsT = FLagName;
                    FT       = FLag;
                end
                
                % Find the lag for each forecasting equation
                for ii = 1:numDep
                    
                    depLagT = {[options.dependent{ii} '_lag1']};
                    yLagT   = nb_lag(y(:,ii),1);
                    [nLags(ii),factors{ii},FlagT,yLagT,depLag{ii}] = lagLengthSelectionAlgorithm(options,y(:,ii),X,FT,startInd+1 + options.maxLagLength,factorsT,yLagT,depLagT);
                    
                    yLag    = [yLag,yLagT]; %#ok<AGROW>
                    Flag    = [Flag,FlagT]; %#ok<AGROW>
                    exo{ii} = [options.exogenous,depLag{ii}];
                    
                end
                
                % Then we have the dynamic factor VAR to select the lag
                % length of
                optionsT = options;
                optionsT.constant   = 0;
                optionsT.time_trend = 0;
                [nLags(ii+1),factors{ii+1},FlagT] = lagLengthSelectionAlgorithm(optionsT,F,nan(size(F,1),0),FLag,startInd + options.maxLagLength,FLagName);
                Flag = [Flag,FlagT];
                
                % Shrink the factors and the data to the unique series
                [uFactors,ind] = unique(nb_nestedCell2Cell(factors));
                Flag           = Flag(:,ind); % Remove duplicated series
                [uDepLag,ind]  = unique(nb_nestedCell2Cell(depLag));
                yLag           = yLag(:,ind); % Remove duplicated series
                
                % Assign options for later
                options.nLags         = nLags;
                options.exogenous     = exo;
                options.factorsRHS    = factors;
                options.dataVariables = [options.dataVariables,uFactors,uDepLag];
                newData               = nan(size(options.data,1),size(yLag,2) + size(Flag,2));
                ind                   = startInd:endInd;
                newData(ind,:)        = [Flag,yLag];
                options.data          = [options.data,newData];
                   
            elseif strcmpi(options.modelType,'favar')

                FLag     = nb_mlag(F,1,'varFast');
                FLagName = nb_cellstrlag(options.factors,1,'varFast');
                yLag     = nb_mlag(y,1,'varFast');
                yLName   = nb_cellstrlag(options.dependent,1,'varFast');
                [nLags,factors,Flag,yLag,depLag] = lagLengthSelectionAlgorithm(options,[y,F],X,FLag,startInd + options.maxLagLength,FLagName,yLag,yLName);

            else
                % Only test the lags to include for y_t, and not for all 
                % y_t+h
                [nLags,factors,Flag,yLag,depLag] = lagLengthSelectionAlgorithm(options,y,X,F,startInd + options.maxLagLength,options.factors);
            end
    
            % Assign the options struct for later
            if ~strcmpi(options.modelType,'dynamic')
                options.nLags         = nLags;
                options.exogenous     = [options.exogenous,depLag];
                options.factorsRHS    = factors;
                options.dataVariables = [options.dataVariables,factors,depLag];
                newData               = nan(size(options.data,1),size(yLag,2) + size(Flag,2));
                ind                   = startInd:endInd;
                newData(ind,:)        = [Flag,yLag];
                options.data          = [options.data,newData];
            end
            
        case 'autometrics'
            
            error([mfilename ':: Autometrics are not supported for any type of factor model'])

        otherwise

            error([mfilename ':: Unsupported model selection criterion ' options.modelSelection '.'])

    end

end

%==========================================================================
% SUB
%==========================================================================
function [nLags,factors,Flag,yLag,depLag] = lagLengthSelectionAlgorithm(options,y,X,F,startInd,factors,yLag,depLag)

    if nargin < 8
        depLag = {};
        if nargin < 7
            yLag = [];
        end
    end

    fixedAll = [true(1,size(X,2)), false(1,size(F,2)), false(1,size(yLag,2))];

    RHS    = [X,F,yLag];
    isNaN  = any(isnan(RHS),2);
    numNaN = sum(isNaN);
    RHS    = RHS(~isNaN,:);
    y      = y(~isNaN,:);
    
    % Check the degrees of freedom
    sizeX    = size(X,2);
    numCoeff = sizeX + options.constant + options.time_trend + (size(F,2) + size(yLag,2))*options.maxLagLength + options.maxLagLength;
    dof      = size(RHS,1) - options.maxLagLength - options.requiredDegreeOfFreedom - numCoeff - numNaN;
    if dof < 0
        needed = options.maxLagLength + options.requiredDegreeOfFreedom + numCoeff + numNaN;
        error([mfilename ':: The sample is too short for lag length selection estimation with the selected maximum lag length. '...
                         'At least ' int2str(options.requiredDegreeOfFreedom) ' degrees of freedom are required. '...
                         'Which require a sample of at least ' int2str(needed) ' observations.'])
    end

    nLags = nb_lagLengthSelection(options.constant,options.time_trend,...
                      options.maxLagLength,options.criterion,'ols',y,RHS,fixedAll,startInd); 

    % The returned nLags is allways a scalar      
    if any(nLags == [-1,0])  
        nLags = 1;
    end

    % Add lag postfix (If the variable already have a lag postfix we
    % append the number indicating that it is lag once more)
    factLag   = nb_cellstrlag(factors,nLags-1,'varFast');
    factors   = [factors,factLag];
    if ~isempty(depLag)
        depLag = [depLag,nb_cellstrlag(depLag,nLags-1,'varFast')];
    end

    % Add the lags to the estimation data for later
    Flag = nb_mlag(F,nLags-1,'varFast');
    Flag = [F,Flag];
    if ~isempty(yLag)
        yLag = [yLag,nb_mlag(yLag,nLags-1,'varFast')];
    end

end
