function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_tslsEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    residual = nb_olsEstimator.getResidual(results.('mainEq'),options.('mainEq'));

end
