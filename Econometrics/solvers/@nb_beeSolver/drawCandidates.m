function draws = drawCandidates(lb,ub,nPar,nBees)
% Syntax:
%
% draws = nb_beeSolver.drawCandidates(lb,ub,nPar,nBees)
%
% Description:
%
% Draw candidates from a N dimensional box.
% 
% Input:
% 
% - lb    : A double vector with size nPar x 1.
%
% - ub    : A double vector with size nPar x 1.
%
% - nPar  : The number of parameters.
%
% - nBees : The number of bees.
% 
% Output:
% 
% - draws : A double with size nPar x nBees with the randomly selected
%           parameters inside the box.
%
% See also:
% nb_beeSolver.initialize, nb_beeSolver.scout
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    lb    = lb(:,ones(1,nBees));
    ub    = ub(:,ones(1,nBees));
    draws = lb + (ub-lb).*rand(nPar,nBees);
    
end
