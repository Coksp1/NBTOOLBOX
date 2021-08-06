function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_lassoEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if options(1).constant
        coeff = [{'Constant'},options(1).exogenous{:}];
    else
        coeff = [{},options(1).exogenous{:}];
    end
    numCoeff = length(coeff);
    
end
