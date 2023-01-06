function [results,options] = estimate(options)
% Syntax:
%
% [results,options] = nb_shorteningEstimator.estimate(options)
%
% Description:
%
% Shortening data according to settings.
% 
% Input:
% 
% - options  : A struct on the format given by 
%              nb_shorteningEstimator.template. See also 
%              nb_shorteningEstimator.help.
% 
% Output:
% 
% - result : A struct with the estimation results.
%
% - options : The return model options, can change depending on inputs.
%
% See also:
% nb_shorteningEstimator.print, nb_shorteningEstimator.help, 
% nb_shorteningEstimator.template
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    tStart = tic;

    if isempty(options)
        error([mfilename ':: The options input cannot be empty!'])
    end
    options = nb_defaultField(options,'func',[]);
    options = nb_defaultField(options,'handleMissing',false);

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
    if options.handleMissing
        isNaN = all(~isfinite(Z),2);
        if isempty(options.estim_end_ind)
            endI = find(~isNaN,1,'last');
            if isempty(endI)
                error([mfilename ':: None of the variables has any observations.'])
            end
            options.estim_end_ind = endI;
        end
        if isempty(options.estim_start_ind)
            startI = find(~isNaN,1);
            if isempty(startI)
                error([mfilename ':: None of the variables has any observations.'])
            end
            options.estim_start_ind = startI;
        end
        Z = Z(options.estim_start_ind:options.estim_end_ind,:);
    else
        [options,Z] = nb_estimator.testSample(options,'handleNaN',Z);
    end
    if isempty(options.func)
        [results,options] = nb_shorteningEstimator.doShortening(options,Z);
    else 
        [results,options] = nb_shorteningEstimator.doFunc(options,Z);
    end
    
    % Assign generic results
    results.includedObservations = size(Z,1);
    results.elapsedTime          = toc(tStart);
    
    % Assign results
    options.estimator = 'nb_shorteningEstimator';
    options.estimType = 'classic';
    
end
