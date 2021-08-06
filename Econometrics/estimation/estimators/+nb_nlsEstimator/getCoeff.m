function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_nlsEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    coeff    = options.parameters;
    numCoeff = length(coeff);
    
end
