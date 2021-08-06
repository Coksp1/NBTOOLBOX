function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_whitenEstimator.estimate(options)
%
% Description:
%
% Estimate a factors that have variance one and covariances 0 using 
% whitening.
% 
% Input:
% 
% - options  : A struct on the format given by nb_whitenEstimator.template.
%              See also nb_whitenEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_whitenEstimator.print, nb_whitenEstimator.help, 
% nb_whitenEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end

    % Get the estimation options
    tempData = options.data;
    tempObs  = cellstr(options.observables);
    if isempty(tempObs)
        error([mfilename ':: The observables must be given!.'])
    end
    if isempty(tempData)
        error([mfilename ':: Cannot estimate without data.'])
    end

    % Get the estimation data
    [test,indZ] = ismember(tempObs,options.dataVariables);
    if any(~test)
        error([mfilename ':: Cannot locate the observed variable(s); ' toString(tempObs(~test))])
    end
    Z = tempData(:,indZ);
    
    % Shorten sample
    [options,Z] = nb_estimator.testSample(options,Z);
    
    % Get factors by whitening 
    [results,options] = nb_whitenEstimator.estimateFactors(options,Z);

    % Assign generic results
    results.includedObservations = size(Z,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_whitenEstimator';
    options.estimType = 'classic';
    
end
