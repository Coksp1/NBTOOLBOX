function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_tslsEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    residual = nb_olsEstimator.getResidual(results.('mainEq'),options.('mainEq'));

end
