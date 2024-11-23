function indCovidAll = getSteapAheadIndCovidAll(nStep,indCovid)
% Syntax:
%
% indCovidAll = nb_estimator.getSteapAheadIndCovidAll(nStep,indCovid)
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    indCovidDep = nb_mlead(indCovid(:,1),nStep);
    indCovidExo = indCovid(:,2);
    indCovidAll = all([indCovidDep,indCovidExo],2);

end
