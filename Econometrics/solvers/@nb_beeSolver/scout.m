function obj = scout(obj,lowerBound,upperBound)
% Syntax:
%
% obj = scout(obj,lowerBound,upperBound)
%
% Description:
%
% Employ scouts to new dancing areas.
%
% Input:
% 
% - obj        : A vector of nb_beeSolver objects.
% 
% - lowerBound : See the property with the same name in the nb_abcSolve
%                class.
%
% - upperBound : See the property with the same name in the nb_abcSolve
%                 class. 
%
% Output:
% 
% - obj        : A vector of nb_beeSolver objects.
%
% See also:
% nb_beeSolver.relocate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nBees = size(obj,1);
    if nBees == 0
        return
    end
    numPar = size(lowerBound,1);
    tested = nb_beeSolver.drawCandidates(lowerBound,upperBound,numPar,nBees);
    
    % Assing back to the bees
    for ii = 1:nBees
        % We do this to make the scout accept the move later on
        obj(ii).currentValue = inf; 
        obj(ii).tested       = tested(:,ii);
        obj(ii).trials       = 0;
    end
    
end
