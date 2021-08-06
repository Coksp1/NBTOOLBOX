function dependent = getDependent(results,options)
% Syntax:
%
% residual = nb_tslsEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    dependent = nb_olsEstimator.getDependent(results.('mainEq'),options.('mainEq'));

end
