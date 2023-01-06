function [coeff,numCoeff] = getCoeff(options,eqId)
% Syntax:
%
% [coeff,numCoeff] = nb_exprEstimator.getCoeff(options,eqId)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        nEq      = size(options.depFuncs,2);
        coeff    = cell(1,nEq);
        numCoeff = nan(1,nEq);
        for ii = 1:nEq 
            [coeff{ii},numCoeff(ii)] = nb_exprEstimator.getCoeff(options,ii);
        end
        return
    end
        
    if options(1).constant && options(1).time_trend
        coeff = [{'Constant','Time Trend'},options(1).exogenous{eqId}{:}];
    elseif options(1).constant
        coeff = [{'Constant'},options(1).exogenous{eqId}{:}];
    elseif options(1).time_trend
        coeff = [{'Time Trend'},options(1).exogenous{eqId}{:}];
    else
        coeff = [{},options(1).exogenous{eqId}{:}];
    end
    numCoeff = length(coeff);
    
end
