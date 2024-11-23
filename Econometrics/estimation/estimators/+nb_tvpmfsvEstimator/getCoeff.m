function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_tvpmfsvEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Construct coefficents on exogenous
    options = options(end);
    exo     = options.exogenous;
    if options.time_trend
       exo = ['time_trend',exo]; 
    end
    if options.constant
       exo = ['constant',exo]; 
    end
    nObs     = size(options.observables,2);
    coeffExo = cell(1,size(exo,2)*nObs);
    for ii = 1:length(exo)
        coeffExo(1+(ii-1)*nObs:ii*nObs) = strcat(options.observables,['_' exo{ii}]);
    end
    if isfield(options,'transformation')
        if strcmpi(options.transformation,'standardize')
            coeffExo = [coeffExo,strcat(options.observables,'_standardize')];
        end
    end
    
    % Construct the coeff names of measurement matrix
    if strcmpi(options.class,'nb_var')
        factorNames    = options.dependent(options.invReorderLoc);
        coeffL         = {};
        k              = 0;
        measErrorNames = {};
    elseif strcmpi(options.class,'nb_mfvar')
        factorNames = options.dependent(options.invReorderLoc);
        if any(options.indObservedOnly) && ~isempty(options.mixing)
            factorNames = factorNames(~options.indObservedOnly);
        end
        coeffL         = {};
        k              = 0;
        measErrorNames = {};
    else
        factorNames = options.factorNames;
        N           = size(options.observables,2);
        coeffL      = cell(1,N*options.nFactors);
        if ~isempty(options.blocks)
            blocks = options.blocks;
        else
            blocks = true(N,options.nFactors);
        end
        k = 1;
        for ii = 1:options.nFactors
            obsForThisBlock              = options.observables(blocks(:,ii));
            namesFromThisBlock           = strcat(obsForThisBlock,'_',factorNames{ii});
            nFromThisBlock               = size(namesFromThisBlock,2);
            coeffL(k:k+nFromThisBlock-1) = namesFromThisBlock;
            k                            = k + nFromThisBlock;
        end
        
        % Construct the coeff names of the measurement errors (it is diagonal!)
        measErrorNames = strcat(options.observables,'_measurement_error');
        
    end
    
    % Construct the coeff names of transition matrix
    coeffA1    = cell(options.nFactors*options.nLags,options.nFactors);
    factorLags = nb_cellstrlag(factorNames,options.nLags,'varFast');
    for ii = 1:options.nFactors
        coeffA1(:,ii) = strcat(factorNames{ii},'_',factorLags);
    end
    coeffA1 = coeffA1';
    coeffA1 = coeffA1(:)';
    
    % Construct the coeff names of the variance of state variables (It is 
    % not diagonal)
    coeffVar = cell(options.nFactors,options.nFactors);
    for ii = 1:options.nFactors
        coeffVar(:,ii) = strcat(factorNames{ii},'_',factorNames);
    end
    coeffVar = coeffVar(:)';
    coeffVar = strcat(coeffVar,'_variance');
    
    % Concatenate
    coeff    = [coeffExo,coeffL(1:k-1),measErrorNames,coeffA1,coeffVar];
    numCoeff = length(coeff);

end
