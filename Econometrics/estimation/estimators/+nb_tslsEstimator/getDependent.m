function dependent = getDependent(results,options)
% Syntax:
%
% residual = nb_tslsEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    dependent = nb_olsEstimator.getDependent(results.('mainEq'),options.('mainEq'));

end
