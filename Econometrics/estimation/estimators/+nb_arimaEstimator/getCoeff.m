function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_arimaEstimator.getCoeff(options)
%
% Description:
%
% Get names of arima coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Construct the coeff names
    numAR = options.AR;
    if numAR > 0
        ARcoeff = [1:numAR]'; %#ok<NBRAK>
        ARcoeff = strtrim(cellstr(num2str(ARcoeff)));
        ARcoeff = strcat('AR',ARcoeff);
    else
        ARcoeff = {};
    end
    numMA = options.MA; 
    if numMA > 0
        MAcoeff = [1:numMA]'; %#ok<NBRAK>
        MAcoeff = strtrim(cellstr(num2str(MAcoeff)));
        MAcoeff = strcat('MA',MAcoeff);
    else
        MAcoeff = {};
    end
    coeff = [ARcoeff;MAcoeff];
    if options.constant
        coeff = ['Constant';coeff];
    end
    if options.SAR > 0
        coeff = [coeff;['SAR' int2str(options.SAR)]];
    end
    if options.SMA > 0
        coeff = [coeff;['SMA' int2str(options.SMA)]];
    end
    if isfield(options,'transition') && ~isempty(options.transition)
        exoT   = options.exogenous(options.transition);
        exoObs = options.exogenous(~options.transition);
        coeff  = [coeff;exoT(:);exoObs(:)];
    else
        coeff = [coeff;options.exogenous(:)];
    end
    numCoeff = length(coeff);

end
