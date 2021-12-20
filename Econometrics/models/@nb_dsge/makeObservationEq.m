function H = makeObservationEq(obsInd,nEndo)
% Syntax:
%
% H = nb_dsge.makeObservationEq(obsInd,nEndo)
%
% Description:
%
% Make observation equation of NB toolbox solved DSGE model.
% 
% Input:
% 
% - obsInd : A vector of integers with length nObs storing the location of
%            the observables in the vector of endogenous variables.
%
% - nEndo  : The number of endogenous variables.
% 
% Output:
% 
% - H      : A nObs x nEndo matrix.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nObs = length(obsInd);
    H    = zeros(nObs,nEndo);
    for ii = 1:nObs % This is faster than using sparse!
        H(ii,obsInd(ii)) = 1;
    end
    % H = full(sparse(1:nObs,obsInd,ones(nobs,1),nObs,nEndo)); % Just keep it sparse?

end
