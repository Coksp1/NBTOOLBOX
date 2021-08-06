function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_lassoEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if options(1).constant
        coeff = [{'Constant'},options(1).exogenous{:}];
    else
        coeff = [{},options(1).exogenous{:}];
    end
    numCoeff = length(coeff);
    
end
