function nCoeff = getNumberOfCoeff(options)
% Syntax:
%
% nCoeff = nb_dfmemlEstimator.getNumberOfCoeff(options)
%
% Description:
%
% Get the number of estimated coefficients of the dynamic factor model.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen
    
    % Transition equation including residual variances
    nObs = length(options.observables);
    if options.factorRestrictions
        nTransCoeff = options.nFactors*(options.nLags + 1);
    else
        nTransCoeff = options.nFactors^2*options.nLags + options.nFactors;
    end
    if options.nLagsIdiosyncratic
        nTransCoeff = nTransCoeff + 2*nObs;
    end
    nCoeff = nTransCoeff;

    if ~isempty(options.blocks)
        
        % Measurement equation
        if options.mixedFrequency
            nLow = options.nLow;
        else
            nLow = 0;
        end
        nHigh  = nObs - nLow;
        nCoeff = nCoeff + sum(sum(options.blocks(1:nHigh,:))) + sum(sum(options.blocks(nHigh+1:end,:)));
          
    else
        if options.mixedFrequency
            error('For the moment you need to use the block option when using mixed frequency data.')
        end
        
        % Measurement equation
        nCoeff = nCoeff + options.nFactors*nObs;
        
    end
    
    % Measurement errors
    if ~options.nLagsIdiosyncratic
        nCoeff = nCoeff + nObs;
    end
    
    % Mean and scaling
    nExo   = length(options.exogenous) + options.time_trend + options.constant;
    nCoeff = nCoeff + nExo*nObs;
    if strcmpi(options.transformation,'standardize')
        nCoeff = nCoeff + nObs;
    end

end
