function predicted = getPredicted(results,options)
% Syntax:
%
% predicted = nb_harmonizeEstimator.getPredicted(results,options)
%
% Description:
%
% Get the estimated model predicted values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    predicted = nb_harmonizeEstimator.getDependent(results,options);

end
