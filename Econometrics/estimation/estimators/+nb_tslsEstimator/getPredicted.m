function predicted = getPredicted(results,options)
% Syntax:
%
% residual = nb_tslsEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    predicted = nb_olsEstimator.getPredicted(results.('mainEq'),options.('mainEq'));

end
