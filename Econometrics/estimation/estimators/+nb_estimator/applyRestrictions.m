function [yRest,XRest,restrict] = applyRestrictions(options,y,X)
% Syntax:
%
% [yRest,XRest,restrict] = nb_estimator.applyRestrictions(options,y,X)
%
% See also:
% nb_olsEstimator.estimate, nb_estimator.addRestrictions
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    allExo = options.exogenous;
    if options.time_trend
        allExo = [{'time_trend'},allExo];
    end
    if options.constant
        allExo = [{'constant'},allExo];
    end

    if ~iscell(options.restrictions)
        error([mfilename ':: The restrictions input must be a 2 x N cell array.'])
    end
    if ~nb_sizeEqual(options.restrictions,[2,nan,1])
        error([mfilename ':: The restrictions input must be a 2 x N cell array.'])
    end
    if ~iscellstr(options.restrictions(1,:))
        error([mfilename ':: The first row of the restrictions input must be a 1 x N cellstr array, ',...
                         'i.e. with the exogenous variables to restrict.'])
    end
    
    % Get the exogenous variables to restrict the parameters of
    exo = options.restrictions(1,:);
    if ~iscell(options.restrictions)
        error([mfilename ':: The restrictions input must be a 2 x N cell array.'])
    end
    [ind,loc] = ismember(exo,allExo);
    if any(~ind)
        error([mfilename ':: Cannot restrict the parameter on the exogenous variables; ' toString(exo(~ind)) ...
                         ', as they are not decalred as exogenous variables of the model.'])
    end
    
    % Get the parameter restrictions
    try
        beta = [options.restrictions{2,:}]';
    catch
        error([mfilename ':: The second row of the restrictions input must only contain scalar double in each cell element.'])
    end
    
    % Construct the restricted data for estimation
    yRest = bsxfun(@minus,y,X(:,ind)*beta);
    XRest = X(:,~ind);
    
    % Store restrictions for adding them back in
    restrict.ind  = ind;
    restrict.loc  = loc;
    restrict.exo  = exo;
    restrict.beta = beta;
    
    % Adjust contant and time_trend options if needed
    if any(strcmpi(exo,'contant'))
        restrict.constant = true;
        options.constant  = false;
    else
        restrict.constant = false;
    end
    if any(strcmpi(exo,'time_trend'))
        restrict.time_trend = true;
        options.time_trend  = false;
    else
        restrict.time_trend = false;
    end
    
end
