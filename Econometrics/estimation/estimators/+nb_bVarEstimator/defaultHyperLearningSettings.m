function settings = defaultHyperLearningSettings()
% Syntax:
%
% settings = nb_bVarEstimator.defaultHyperLearningSettings()
%
% See also:
% nb_bVarEstimator.calculateRMSE
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    settings = struct('type','RMSE','startScorePerc',0.5,'variable','');

end
