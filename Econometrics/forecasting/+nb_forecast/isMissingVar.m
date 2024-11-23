function missingVar = isMissingVar(options)
% Syntax:
%
% missingVar = nb_mlEstimator.isMissingVar(options)
%
% Description:
%
% Is the model a missing observation VAR or MF-VAR model estimated with
% using a kalman filter?
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    missingVar = false;
    if ~isfield(options,'missingMethod')
        return
    end
    missingVar = any(strcmpi(options.class,{'nb_mfvar','nb_var'})) && strcmpi(options.missingMethod,'kalman');

end
