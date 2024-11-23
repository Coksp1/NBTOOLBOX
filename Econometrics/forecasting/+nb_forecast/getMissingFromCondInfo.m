function [nowcast,missing] = getMissingFromCondInfo(options,inputs,restrictions,dep)
% Syntax:
%
% [nowcast,missing] = nb_forecast.getMissingFromCondInfo(...
%       options,inputs,restrictions)
%
% Description:
%
% Get missing info when conditional information is used. I.e. the
% conditional information introduce ragged-edge in forecast.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if size(restrictions.Y,3) > 1
        % If we produce recursive conditional forecast we are not yet able
        % to register nowcast!
        nowcast = 0;
        missing = [];
        return
    end

    % Get missing information from exogenous. Deterministic variables
    % we set to true, as this is not conditional information supplied by
    % the user, but mechanically created information!
    missingExo           = isnan(restrictions.X);
    deterministic        = nb_forecast.getDeterministicVariables(restrictions.exo);
    indDet               = nb_ismemberi(restrictions.exo,deterministic);
    missingExo(:,indDet) = true;
    
    % Merge with missing information on endogenous variables
    missingDep = isnan(restrictions.Y);
    missingAll = [missingDep,missingExo];
    vars       = [restrictions.condEndo,restrictions.exo];
    
    % Add variables only in the data. These may be used to construct level
    % variables etc. We can without loss set these to missing
    indDataVar = ~ismember(options.dataVariables,vars);
    vars       = [vars,options.dataVariables(indDataVar)];
    missingAll = [missingAll,true(size(missingAll,1),sum(indDataVar))];
    
    % Reported variables
    nVars            = length(vars);
    missObj(1,nVars) = nb_logicalInExpr();
    for ii = 1:nVars
        missObj(ii) = nb_logicalInExpr(missingAll(:,ii),'&');
    end
    
    % Check each expressions
    for ii = 1:size(inputs.reporting,1)
        
        expression = inputs.reporting{ii,2};
        try 
            missObjOne = nb_eval(expression,vars,missObj);
        catch Err
            warning('nb_forecast:createReportedVariables:couldNotEvaluate','%s',Err.message);
            continue
        end

        % To make it possible to use newly created variables in the 
        % expressions to come, we must append it in this way
        found = strcmp(inputs.reporting{ii,1},vars);
        if ~any(found)
            missObj = [missObj,missObjOne];  %#ok<AGROW>
            vars    = [vars,inputs.reporting{ii,1}]; %#ok<AGROW>
        else
            missObj(found) = missObjOne;
        end
    end
    
    % Get the missing info on the dependent and reported variables only
    [testDep,locDep] = ismember(dep,vars);
    missObj          = missObj(locDep(testDep));
    missing          = [missObj.data];
    if any(~testDep)
       % Unobserved variables etc.
       missingOld         = missing;
       missing            = true(size(missing,1),length(dep));
       missing(:,testDep) = missingOld;
    end
    
    % Collect
    indM    = ~all(missing,2);
    missing = missing(indM,:);
    nowcast = size(missing,1);
        
end
