function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_pcaEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Construct the coeff names
    options  = options(end);
    coeff    = nb_appendIndexes('Factor', 1:options.nFactors);
    numCoeff = length(coeff);

end
