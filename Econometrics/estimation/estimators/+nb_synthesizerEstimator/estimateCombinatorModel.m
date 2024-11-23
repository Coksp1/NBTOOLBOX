function [results,options] = estimateCombinatorModel(indicator,options)
% Syntax:
%
% [results,options] = estimateCombinatorModel(indicator,options)
%
% Description:
%
% Estimates the combinatorModel to get the final synthetic series and saves
% results.
% 
% Input:
%
% - indicator : The indicator for the varOfInterest.
%
% - options   : The options as a struct.
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen  
        
    model           = options.combinatorModel;
    model.data      = [model.data,indicator];
    model.dependent = [model.dependent;nb_rowVector(indicator.variables)'];

    % Estimate model 
    model           = nb_mfvar(model);
    model           = estimate(model);
    smoothed        = getCalculated(model);
    syntheticSeries = smoothed.window('','',options.varOfInterest);

    % Save results
    results                 = struct();
    results.startDate       = syntheticSeries.startDate;
    results.variables       = options.varOfInterest; 
    results.data            = double(syntheticSeries);
    results.combinatorModel = model;
    
end
