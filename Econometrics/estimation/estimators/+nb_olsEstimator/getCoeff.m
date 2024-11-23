function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_olsEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if options(1).constant && options(1).time_trend
        coeff = [{'Constant','Time Trend'},options(1).exogenous{:}];
    elseif options(1).constant
        coeff = [{'Constant'},options(1).exogenous{:}];
    elseif options(1).time_trend
        coeff = [{'Time Trend'},options(1).exogenous{:}];
    else
        coeff = [{},options(1).exogenous{:}];
    end
    numCoeff = length(coeff);
    
end
