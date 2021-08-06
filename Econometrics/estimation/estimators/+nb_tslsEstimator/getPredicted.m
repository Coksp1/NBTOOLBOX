function predicted = getPredicted(results,options)
% Syntax:
%
% residual = nb_tslsEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    predicted = nb_olsEstimator.getPredicted(results.('mainEq'),options.('mainEq'));

end
