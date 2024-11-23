function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_hpEstimator.estimate(options)
%
% Description:
%
% Estimate HP-filtered series.
% 
% Input:
% 
% - options  : A struct on the format given by nb_hpEstimator.template.
%              See also nb_hpEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_hpEstimator.print, nb_hpEstimator.help, 
% nb_hpEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end

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
        error([mfilename ':: Cannot locate the dependent variable(s); ' toString(tempDep(~test))])
    end
    Z = tempData(:,indZ);
    
    % Shorten sample
    [options,Z] = nb_estimator.testSample(options,Z);
    
    % Get seasonally adjusted series by x12-census
    [results,options] = nb_hpEstimator.estimateHP(options,Z);

    % Assign generic results
    results.includedObservations = size(Z,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_hpEstimator';
    options.estimType = 'classic';
    
end
