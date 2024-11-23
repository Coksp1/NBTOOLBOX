function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_dfmemlEstimator.getCoeff(options)
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
    if strcmpi(options.transformation,'standardize')
        coeffExo = [coeffExo,strcat(options.observables,'_standardize')];
    end

    % Construct the coeff names of transition matrix
    factorNames = options.factorNames;
    if options.factorRestrictions
        coeffA1 = cell(1,options.nFactors*options.nLags);
        k       = 1;
        for ii = 1:options.nFactors
            coeffA1(k:k+options.nLags-1) = nb_appendIndexes([factorNames{ii} '_lag'],1:options.nLags);
            k                            = k + options.nLags;
        end
    else
        coeffA1    = cell(options.nFactors*options.nLags,options.nFactors);
        factorLags = nb_cellstrlag(factorNames,options.nLags,'varFast');
        for ii = 1:options.nFactors
            coeffA1(:,ii) = strcat('Factor',int2str(ii),'_',factorLags);
        end
        coeffA1 = coeffA1(:)';
    end
    N    = size(options.observables,2);
    idio = nb_appendIndexes('Idio',1:N)';
    if options.nLagsIdiosyncratic
        coeffA2 = strcat(idio,'_lag1');
    else
        coeffA2 = {};
    end

    % Construct the coeff names of measurement matrix
    coeffL = cell(1,N*options.nFactors);
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

    % Construct the coeff names of the variance of state variables
    states   = [factorNames,idio];
    varNames = strcat(states,'_variance');

    % Concatenate
    coeff    = [coeffExo,coeffL(1:k-1),coeffA1,coeffA2,varNames];
    numCoeff = length(coeff);

end
