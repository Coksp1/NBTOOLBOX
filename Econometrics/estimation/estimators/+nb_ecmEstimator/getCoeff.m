function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_ecmEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Construct the coeff names
    if options.constant && options.time_trend
        coeff = [{'Constant','Time Trend'},options.exogenous{:}];
    elseif options.constant
        coeff = [{'Constant'},options.exogenous{:}];
    elseif options.time_trend
        coeff = [{'Time Trend'},options.exogenous{:}];
    else
        coeff = [{},options.exogenous{:}];
    end
    coeff    = [coeff,options.rhs];
    numCoeff = length(coeff);

end
