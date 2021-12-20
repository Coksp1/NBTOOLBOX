function restrictions = expandRestrictionsForBoundedForecast(restrictions,nSteps)
% Syntax:
%
% restrictions = nb_forecast.expandRestrictionsForBoundedForecast(...
%                   restrictions,nSteps,model)
%
% See also:
% nb_forecast.pointForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nEndo                      = length(restrictions.endo);
    yRest                      = nan(nSteps,nEndo);
    yRest(:,restrictions.indY) = restrictions.Y;
    restrictions.Y             = yRest;
    restrictions.indY          = 1:nEndo;
    restrictions.condEndo      = restrictions.endo;
    
end
