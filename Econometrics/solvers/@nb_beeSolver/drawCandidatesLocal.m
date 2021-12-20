function draws = drawCandidatesLocal(fVal,cVal,x,nBees)
% Syntax:
%
% draws = nb_beeSolver.drawCandidates(fVal,cVal,x,nBees)
%
% Description:
%
% Draw candidates from a stochastic searching rule 
%
% x(n) = x(n-1) + alpha*fVal/cVal, alpha ~ U(0,1)
% 
% Input:
% 
% - fVal  : F(x), as N x 1 double.
%
% - cVal  : meritFunction(F(x)), as a scalar double.
%
% - x     : As a N x 1 double.
%
% - nBees : The number of bees.
% 
% Output:
% 
% - draws : A double with size N x nBees with the randomly selected
%           values of x around the current value.
%
% See also:
% nb_beeSolver.initialize, nb_beeSolver.scout
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    N     = size(fVal,1);
    alpha = rand(N,N,nBees);
    draws = nan(N,nBees);
    for ii = 1:nBees
        draws(:,ii) = x + alpha(:,:,ii)*(fVal./cVal);
    end
    
end
