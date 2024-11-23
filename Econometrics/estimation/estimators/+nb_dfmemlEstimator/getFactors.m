function factors = getFactors(results,options)
% Syntax:
%
% factors = nb_fmEstimator.getFactors(results,options)
%
% Description:
%
% Get the estimated factors of the estimated model as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'smoothed')
        factors = nb_ts();
    else
        alpha       = results.smoothed.variables.data;
        F           = alpha(:,1:options.nFactors); 
        factorNames = nb_appendIndexes('Factors_',1:options.nFactors);
        factors     = nb_ts(F, 'Factors', results.smoothed.variables.startDate,factorNames); 
    end

end
