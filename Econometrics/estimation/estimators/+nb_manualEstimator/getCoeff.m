function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_manualEstimator.getCoeff(options)
%
% Description:
%
% Get names of the coefficients of the manually programmed model.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Construct the coeff names
    if ~isfield(options,'coeff')
        error(['Cannot get names of the coefficients of the model, as they ',...
            'are not provided by the function provided to the estimFunc option.'])
    end
    coeff    = options.coeff;
    numCoeff = length(coeff);

end
