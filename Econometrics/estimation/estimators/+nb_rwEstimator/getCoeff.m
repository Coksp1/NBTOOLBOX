function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_rwEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if options(1).constant
        coeff = [{'Constant','AR'},options(1).exogenous{:}];
    else
        coeff = [{'AR'},options(1).exogenous{:}];
    end
    numCoeff = length(coeff);
    
end
