function [stateNames,resNames] = getStateNames(options)
% Syntax:
%
% [stateNames,resNames] = nb_dfmemlEstimator.getStateNames(options)
%
% Description:
%
% Selects the wanted model class and estimate the model.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    factorNames = nb_appendIndexes('Factor',1:options.nFactors)';
    if options.mixedFrequency
        nFacLags = max(options.nLags - 1,4);
    else
        nFacLags = options.nLags - 1;
    end
    factorNames = [factorNames,nb_cellstrlag(factorNames,nFacLags,'varFast')];
    if options.mixedFrequency
        nLow       = options.nLow;
        nHigh      = options.nHigh;
        N          = nHigh + nLow;
        idioNamesH = nb_appendIndexes('Idio',1:nHigh)';
        idioNamesL = nb_appendIndexes('Idio',nHigh+1:nHigh+nLow)';
        idioNamesL = [idioNamesL, nb_cellstrlag(idioNamesL,4,'varFast')];
        idioNames  = [idioNamesH,idioNamesL];
    else
        N = options.nHigh;
        if N == 0
            N = options.nLow;
        end
        idioNames = nb_appendIndexes('Idio',1:N)';
    end
    if options.nLagsIdiosyncratic
        stateNames = [factorNames,idioNames];
        resNames   = strcat('E_',[factorNames(1:options.nFactors),idioNames(1:N)]);
    else
        stateNames = factorNames;
        resNames   = factorNames(1:options.nFactors);
        if options.mixedFrequency
            stateNames = [stateNames,idioNamesL];
            resNames   = [resNames,idioNamesL(1:nLow)];
        end
        resNames = strcat('E_',resNames);
    end
 
end
