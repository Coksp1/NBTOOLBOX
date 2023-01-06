function options = checkForMissing(options,startInd,endInd)
% Syntax:
%
% options = nb_missingEstimator.checkForMissing(options,...
%               startInd,endInd)
%
% Description:
%
% Check for missing observations.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get data that is used by the model
    tempData = options.data(:,:,end); % Use last vintage for real-time data
    if isempty(startInd)
        startInd = 1;
    end
    if isempty(endInd)
        endInd = size(tempData,1);
    end
    tempData   = tempData(startInd:endInd,:);

    [endo,exo]  = nb_missingEstimator.getVariables(options);
    vars        = [endo,exo];
    [test,indY] = ismember(endo,options.dataVariables);
    if any(~test)
        error([mfilename ':: Could not locate the variable(s) ' toString(endo(~test)) ' declared as dependent or block exogenous.'])
    end
    Y           = tempData(:,indY);
    Ymissing    = ~isfinite(Y);
    [test,indX] = ismember(exo,options.dataVariables);
    if any(~test)
        error([mfilename ':: Could not locate the variable(s) ' toString(exo(~test)) ' declared as exogenous.'])
    end
    X        = tempData(:,indX);
    Xmissing = ~isfinite(X);
    
    % Leading and trailing nan are not a problem, so those we can discard
    data         = [Ymissing,Xmissing];
    isAllMissing = all(data,2);
    isAnyMissing = any(data,2);
    if isAnyMissing(1)
        start = find(~isAnyMissing,1);
        if isempty(start)
            test = false(1,size(data,2));
            for ii = 1:size(data,2)
                if all(data(:,ii))
                    test(ii) = true;
                end
            end
            error([mfilename ':: The following variables have no valid observations; ' toString(vars(test))])
        end
    else
        start = 1;
    end
    if isAllMissing(end)
        finish = find(~isAllMissing,1,'last');
    else
        finish = size(isAllMissing,1);
    end
    Ytest = Ymissing(start:finish,:);
    Xtest = Xmissing(start:finish,:);
    
    % Then we test that the method assumption is met
    switch lower(options.missingMethod)        
        case 'forecast'
            
            if any(Xtest(:))
               error([mfilename ':: The ''missingMethod'' cannot be set to ''forecast'' when there is missing data on exogenous variables']) 
            end
            
            for ii = 1:size(Ytest,2)
                isMissingT = Ytest(:,ii);
                test       = [1:size(isMissingT,1)]'; %#ok<NBRAK>
                if any(test(end-sum(isMissingT)+1:end) ~= find(isMissingT))
                    error([mfilename ':: The data of the variable ' vars{ii} 'can only have missing observations at the end of the '...
                                     'sample when ''missingMethod'' is set to ''forecast''.'])
                end
            end
            
        case 'ar'
            
            dataTest = [Ytest,Xtest];
            for ii = 1:size(dataTest,2)
                isMissingT = dataTest(:,ii);
                test       = [1:size(isMissingT,1)]'; %#ok<NBRAK>
                if any(test(end-sum(isMissingT)+1:end) ~= find(isMissingT))
                    error([mfilename ':: The data of the variable ' vars{ii} 'can only have missing observations at the end of the '...
                                     'sample when ''missingMethod'' is set to ''ar''.'])
                end
            end
            
        case 'copula'
            
            % No problem with anything
            
    end
    
    % Store to output for later use
    options.missingStartInd  = start + startInd - 1;
    options.missingEndInd    = finish + startInd - 1;
    options.missingData      = [false(startInd-1,size(data,2));data]; 
    options.missingVariables = vars;

end
