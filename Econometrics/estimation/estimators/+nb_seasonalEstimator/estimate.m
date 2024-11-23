function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_seasonalEstimator.estimate(options)
%
% Description:
%
% Estimate seasonally adjusted series.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_seasonalEstimator.template.
%              See also nb_seasonalEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_seasonalEstimator.print, nb_seasonalEstimator.help, 
% nb_seasonalEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'exogenous',{});
    options = nb_defaultField(options,'removeZeroRegressors',0);

    % Get the estimation options
    tempData = options.data;
    tempDep  = cellstr(options.dependent);
    if isempty(tempDep)
        error([mfilename ':: The dependent must be given!.'])
    end
    if isempty(tempData)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Get the estimation data
    [test,indZ] = ismember(tempDep,options.dataVariables);
    if any(~test)
        error(['Cannot locate the dependent variable(s); ',...
            toString(tempDep(~test))])
    end
    Z = tempData(:,indZ);
    if isempty(options.exogenous)
        X = nan(size(Z,1),0);
    else
        tempExo      = cellstr(options.exogenous);
        [testX,indX] = ismember(tempExo,options.dataVariables);
        if any(~testX)
            error(['Cannot locate the exogenous variable(s); ',...
                toString(tempExo(~testX))])
        end 
        X = tempData(:,indX);
    end
    
    % Shorten sample
    [options,Z,X] = nb_estimator.testSample(options,Z,X);
    
    % Get seasonally adjusted series by x12-census
    [results,options] = nb_seasonalEstimator.estimateSeasonal(options,Z,X);

    % Assign generic results
    results.includedObservations = size(Z,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_seasonalEstimator';
    options.estimType = 'classic';
    
end
