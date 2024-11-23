function [residualStripped,stripInd] = stripSteapAheadResiduals(options,residual,indCovid)
% Syntax:
%
% [residualStripped,stripInd] = nb_estimator.stripSteapAheadResiduals(...
%       options,residual,indCovid)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    stripInd = false(size(residual,1),1);
    stripInd(end-double(options.nStep)+2:end) = true;
    if ~isempty(indCovid)
        indCovidAll = nb_estimator.getSteapAheadIndCovidAll(options.nStep,indCovid);
        stripInd(~indCovidAll(1:end-1)) = true; 
    end
    residualStripped             = residual;
    residualStripped(stripInd,:) = [];

end
