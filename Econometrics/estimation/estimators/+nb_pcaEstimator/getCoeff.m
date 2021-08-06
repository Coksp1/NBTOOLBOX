function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_pcaEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Construct the coeff names
    options  = options(end);
    coeff    = nb_appendIndexes('Factor', 1:options.nFactors);
    numCoeff = length(coeff);

end
