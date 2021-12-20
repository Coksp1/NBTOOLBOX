function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_fmEstimator.estimate(options)
%
% Description:
%
% Estimate a factor model with ols using principal components.
% 
% Input:
% 
% - options  : A struct on the format given by nb_fmEstimator.template.
%              See also nb_fmEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change when for example using
%             the 'modelSelection' otpions.
%
% See also:
% nb_fmEstimator.print, nb_fmEstimator.help, nb_fmEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'unbalanced',false);
    if strcmpi(options.modelType,'stepAhead')
        options.current    = true;
        options.factorLead = 0;
        if options.unbalanced
            if length(options.dependent) > 1
                error([mfilename ':: If the unbalanced option is set to true, ',...
                    'only one dependent variable can be selected.'])
            end
        end
    end

    % Get the estimation options
    %------------------------------------------------------
    tempData = options.data;
    tempDep  = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: You must add the left side variable of the equation to dependent field of the options property.'])
    end
    tempObs = cellstr(options.observables);
    if isempty(tempObs)
        error([mfilename ':: The observables must be given!.'])
    end
    tempExo  = cellstr(options.exogenous);

    if isempty(tempData)
        error([mfilename ':: Cannot estimate without data.'])
    end

    if isfield(options,'modelSelectionFixed')
        fixed = options.modelSelectionFixed;
        if ~islogical(fixed)
            fixed = logical(options.modelSelectionFixed);
        end
    else
        fixed = [];
    end

    if isempty(fixed)
        fixed = false(1,length(tempExo));
    end

    % Get the estimation data
    %------------------------------------------------------
    % Add seasonal dummies
    if ~isempty(options.seasonalDummy)

        startDate       = options.dataStartDate;
        [ind,frequency] = nb_isQorM(startDate);
        if ind

            % Create seasonals
            period    = str2double(startDate(6:end));
            T         = size(tempData,1) + period - 1;
            seasonals = nb_seasonalDummy(T,frequency,options.seasonalDummy);
            seasonals = seasonals(period:end,:);

            % Add to data
            tempData     = [tempData,seasonals];
            seasVars     = strcat('Seasonal_',cellstr(int2str([1:frequency-1]'))'); %#ok<NBRAK>
            options.data = tempData;

            % Add to exogenous variables 
            tempExo                     = [seasVars,tempExo];
            options.exogenous           = tempExo;
            fixed                       = [true(1,frequency-1),fixed];

        end

    end
    options.modelSelectionFixed = fixed;

    % Use last valid observations
    [test,indY] = ismember(tempDep,options.dataVariables);
    if any(~test)
        error([mfilename ':: Cannot locate the dependent variable(s); ' toString(tempDep(~test))])
    end
    [test,indX] = ismember(tempExo,options.dataVariables);
    if any(~test)
        error([mfilename ':: Cannot locate the exogenous variable(s); ' toString(tempExo(~test))])
    end
    [test,indZ] = ismember(tempObs,options.dataVariables);
    if any(~test)
        error([mfilename ':: Cannot locate the observed variable(s); ' toString(tempObs(~test))])
    end
    
    y = tempData(:,indY);
    X = tempData(:,indX);
    Z = tempData(:,indZ); 
    if isfield(options,'observablesFast')
        [~,indZF] = ismember(options.observablesFast,options.dataVariables);
        ZF        = tempData(:,indZF);
    else
        ZF = nan(size(Z,1),0);
    end
    
    % Shorten sample
    e = 0;
    if options.unbalanced
        options  = nb_estimator.testSample(options,y);   
        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
        y        = y(startInd:endInd,:);
        ZF       = ZF(startInd:endInd,:);
        if strcmpi(options.modelType,'stepAhead') 
            % In this case we may have one more observation on the 
            % observables, which means that we should lead the regressors
            % one period
            lastZ = find(~all(isnan(Z),2),1,'last');
            if lastZ >= endInd+1
                e = 1;
            end
            Z                  = Z(startInd:endInd+e,:);
            options.factorLead = e;
            options.current    = options.nLags - e ~= -1;
        else
            Z = Z(startInd:endInd,:);
        end
    else
        [options,y,~,Z,ZF] = nb_estimator.testSample(options,y,X,Z,ZF);
        startInd           = options.estim_start_ind;
        endInd             = options.estim_end_ind;
        e                  = 0;
    end
    
    % Get factors by PC
    %--------------------------------------------  
    res = nb_fmEstimator.estimateFactors(options,y,Z,ZF);

    % Add to data
    tempData                   = options.data;
    Fdata                      = nan(size(tempData,1),size(res.F,2));
    Fdata(startInd:endInd+e,:) = res.F;
    tempData                   = [tempData,Fdata];
    factorNr                   = strtrim(cellstr(num2str([1:size(res.F,2)]'))); %#ok<NBRAK>
    factorNames                = strcat('Factor',factorNr)';
    options.data               = tempData;
    options.dataVariables      = [options.dataVariables,factorNames];
    options.factors            = factorNames;
        
    % Find best model or add lags
    %----------------------------------------------
    if ~isempty(options.modelSelection)  
        % Find the lags to include in the forecasting/dynamic part of the 
        % model
        options = nb_fmEstimator.modelSelectionAlgorithm(options);
    else
        options = getLagVariables(options,startInd);
    end

    % Do the estimation
    %------------------------------------------------------
    if options.recursive_estim
        [res,options] = nb_fmEstimator.recursiveEstimation(options,res);
    else % Not recursive
        [res,options] = nb_fmEstimator.normalEstimation(options,res);
    end

    % Assign generic results
    res.includedObservations = size(y,1);
    res.elapsedTime          = toc(tStart);
    res.correct              = e;
    
    % Assign results
    results = res;
    options.estimator = 'nb_fmEstimator';
    options.estimType = 'classic';
    
end

%==========================================================================
% SUB
%==========================================================================
function options = getLagVariables(options,startInd)

    tempData = options.data;
    
    % Here we add the need lag variables to the data before estimation
    % later on
    if ~all(options.nLags == 0) 

        maxLags = max(options.nLags,[],2);
        if startInd < maxLags + 1
            options.estim_start_ind = maxLags + 1;
        end
       
        if strcmpi(options.modelType,'dynamic')
            
            if numel(options.nLags) == 1
                options.nLags = ones(1,length(options.dependent))*options.nLags;
            end

            if numel(options.nLags) > 1 && numel(options.nLags) ~= size(options.dependent,2)
                error([mfilename ':: When modelType is set to either ''dynamic'' the nLags option must be a scalar or a vector with size 1 x numDep.'])
            end

            % Get the lagged dependent variables
            [~,indY] = ismember(options.dependent,options.dataVariables);
            y        = tempData(:,indY);
            ylag     = nb_mlag(y,options.nLags,'varFast');
            tempData = [tempData,ylag];

            % Get the lagged factors 
            [~,indF] = ismember(options.factors,options.dataVariables);
            F        = tempData(:,indF);
            maxLags  = max(maxLags,options.factorsLags);
            Flag     = nb_mlag(F,maxLags,'varFast');
            tempData = [tempData,Flag];

            % Add lag postfix (If the variable already have a lag postfix 
            % we append the number indicating that it is lag once more)
            numDep = size(y,2);
            exo    = cell(1,numDep);
            fRHS   = cell(1,numDep+1);
            exoAll = options.exogenous;
            for ii = 1:numDep
                
               exo{ii} = [exoAll,nb_cellstrlag(options.dependent(ii),options.nLags(ii),'varFast')];
               facLag  = nb_cellstrlag(options.factors,options.nLags(ii),'varFast');
                if options.contemporaneous
                    fRHS{ii} = [options.factors,facLag];
                else
                    fRHS{ii} = facLag;
                end
               
            end
            fRHS{end}             = nb_cellstrlag(options.factors,options.factorsLags,'varFast');
            options.factorsRHS    = fRHS;
            options.exogenous     = exo;
            depLag                = nb_cellstrlag(options.dependent,options.nLags,'varFast');
            facLag                = nb_cellstrlag(options.factors,maxLags,'varFast');
            options.dataVariables = [options.dataVariables, depLag, facLag];
            options.data          = tempData;

        elseif strcmpi(options.modelType,'favar')

            if numel(options.nLags) > 1
                error([mfilename ':: When modelType is set to either ''favar'' the nLags option must be a scalar.'])
            end

            % Get the lagged dependent variables
            [~,indY] = ismember(options.dependent,options.dataVariables);
            y        = tempData(:,indY);
            ylag     = nb_mlag(y,options.nLags,'varFast');
            tempData = [tempData,ylag];

            % Get the lagged factors 
            [~,indF] = ismember(options.factors,options.dataVariables);
            F        = tempData(:,indF);
            Flag     = nb_mlag(F,options.nLags,'varFast');
            tempData = [tempData,Flag];

            % Add lag postfix (If the variable already have a lag postfix 
            % we append the number indicating that it is lag once more)
            depLag                = nb_cellstrlag(options.dependent,options.nLags,'varFast');
            facLag                = nb_cellstrlag(options.factors,options.nLags,'varFast');
            options.exogenous     = [options.exogenous,depLag];
            options.factorsRHS    = facLag;
            options.dataVariables = [options.dataVariables, depLag, facLag];
            options.data          = tempData;

        else % 'stepAhead'

            if options.unbalanced
                factorLeadData = 1;
            else
                factorLeadData = 0;
            end
            
            % Get the factors 
            [~,indF] = ismember(options.factors,options.dataVariables);
            F        = tempData(:,indF);
            Flag     = nb_mlag(F,options.nLags,'varFast');
            Flead    = nb_mlead(F,factorLeadData,'varFast');
            tempData = [tempData,Flag,Flead];

            % Add lag postfix (If the variable already have a lag postfix 
            % we append the number indicating that it is lag once more)
            facLag       = nb_cellstrlag(options.factors,options.nLags,'varFast');
            facLagModel  = facLag;
            facLead      = nb_cellstrlead(options.factors,factorLeadData,'varFast');
            facLeadModel = nb_cellstrlead(options.factors,options.factorLead,'varFast');
            if options.current == 0
                options.factorsRHS = facLeadModel;
            else
                if options.factorLead && options.nLags > 0
                   facLagModel = facLagModel(options.nFactors + 1:end); 
                end
                options.factorsRHS = [facLagModel,options.factors,facLeadModel];
            end
            options.dataVariables = [options.dataVariables, facLag,facLead];
            options.data          = tempData;

            % Are the regressors leaded one period?
            options.nLags = max(0,options.nLags - options.factorLead);
            
        end 

    else
        if strcmpi(options.modelType,'favar') || strcmpi(options.modelType,'dynamic')
            error([mfilename ':: When modelType is set to either ''favar'' or ''dynamic'' the nLags option must be larger than 0.'])
        elseif strcmpi(options.modelType,'stepAhead')
            if options.current == 0
                
                % Get the factors 
                [~,indF]              = ismember(options.factors,options.dataVariables);
                F                     = tempData(:,indF);
                Flead                 = nb_mlead(F,1,'varFast');
                tempData              = [tempData,Flead];
                facLead               = nb_cellstrlead(options.factors,1,'varFast');
                options.dataVariables = [options.dataVariables,facLead];
                options.data          = tempData;
                
                % Add lag postfix (If the variable already have a lag postfix 
                % we append the number indicating that it is lag once more)
                options.factorsRHS = nb_cellstrlead(options.factors,options.factorLead,'varFast');
                
            else
                options.factorsRHS = options.factors;
                if options.unbalanced
                    % Add lead factors in this case
                    [~,indF]              = ismember(options.factors,options.dataVariables);
                    F                     = tempData(:,indF);
                    facLead               = nb_cellstrlead(options.factors,1,'varFast');
                    options.dataVariables = [options.dataVariables,facLead];
                    options.data          = [options.data, nb_mlead(F,1,'varFast')];
                end
            end
        else
            options.factorsRHS = options.factors;
        end
    end

end
