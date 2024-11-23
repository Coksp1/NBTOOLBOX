function [stateNames,resNames] = getStateNames(options)
% Syntax:
%
% [stateNames,resNames] = nb_tvpmfsvEstimator.getStateNames(options)
%
% Description:
%
% Constructs variable names for printing results.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if strcmpi(options.class,'nb_var')
        factorNames = strcat('AUX_',options.observables);
    elseif strcmpi(options.class,'nb_mfvar')
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            factorNames = strcat('AUX_',options.observables(~options.indObservedOnly));
        else
            factorNames = strcat('AUX_',options.observables);
        end
    else
        factorNames = nb_appendIndexes('Factor',1:options.nFactors)';
    end
    if options.mixedFrequency
        nFacLags = max(options.nLags - 1,4);
    else
        nFacLags = options.nLags - 1;
    end
    stateNames = [factorNames,nb_cellstrlag(factorNames,nFacLags,'varFast')];
    if strcmpi(options.class,'nb_mfvar')
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            resNames = options.observables(~options.indObservedOnly);
        else
            resNames = options.observables;
        end
    else
        resNames = stateNames(1:options.nFactors);
    end
    resNames = strcat('E_',resNames);
 
end
