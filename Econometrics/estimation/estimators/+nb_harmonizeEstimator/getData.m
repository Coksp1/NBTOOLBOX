function [y,options] = getData(options)
% Syntax:
%
% [y,options] = nb_harmonizeEstimator.getData(options)
%
% Description:
%
% Get the data to estimate the model on.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the variables of all of the different models to set up
    [options.dependent,options.variables] = nb_harmonizeEstimator.getVariables(options);

    % Get data
    [testY,indY] = ismember(options.variables,options.dataVariables);
    if any(~testY)
        error(['The following variables are not found to be in the dataset; ',...
            toString(options.variables(~testY))])
    end
    y = options.data(:,indY);
    if isempty(y)
        error([mfilename ':: The selected sample cannot be empty.'])
    end
    
    testC = ismember(options.dependent,options.condDBVariables);
    if any(~testC)
        error(['The following variables are not found to be in the conditional data; ',...
            toString(options.dependent(~testC))])
    end
    
    % Shorten sample
    [options,y] = nb_estimator.testSample(options,y,'handleNaN');

end
