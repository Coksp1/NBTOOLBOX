function [y,x,T] = stripObservations(prior,y,x)
% Syntax:
%
% [y,x,T] = nb_bVarEstimator.stripObservations(prior,y,x)
%
% Description:
%
% Strip observations from estimation data
% 
% See also:
% nb_bVarEstimator.minnesota, nb_bVarEstimator.glp,
% nb_bVarEstimator.jeffrey, nb_bVarEstimator.horseshoe,
% nb_bVarEstimator.laplace, nb_bVarEstimator.nwishart,
% nb_bVarEstimator.inwishart
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isempty(prior.indCovid)
        indKeep       = prior.indCovid;
        TInclDummyObs = size(y,1);
        T             = size(indKeep,1);
        if T < TInclDummyObs
            % If dummy observations are added, they are added last, and
            % then indKeep will not have same length as y. Here we take
            % care to keep all dummy observations!
            indKeep = [indKeep;true(TInclDummyObs - T,1)];
        end
        y = y(indKeep,:);
        x = x(indKeep,:);
    end
    T = size(y,1);

end
