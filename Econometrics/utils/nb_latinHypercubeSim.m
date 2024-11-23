function V = nb_latinHypercubeSim(nPoints,nVars)
% Syntax:
%
% V = nb_latinHypercubeSim(nPoints,nVars)
%
% Description:
%
% Simulating optimized draws from the Latin hypercube from the uniform 
% distribution to be used in monte-carlo integration or other such
% applications.
%
% Algorithm is taken from:
% Larson et. al. (2005) "Supplying Local Microphysics Parameterizations 
% with Information about Subgrid Variability: Latin Hypercube Sampling"
%
% See section 3b.
%
% Input:
% 
% - nPoints : Number of points of the desired Latin hypercube (LH).
% 
% - nVars   : Number of variables in the LH.
%
% Output:
% 
% - V    : A nPoints x nVars double.
%
% See also:
% nb_monteCarloSim
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    PIE = nan(nPoints,nVars);
    for ii = 1:nVars
        PIE(:,ii) = randperm(nPoints) - 1;
    end
    U = rand(nPoints,nVars);
    V = 1/nPoints*(PIE + U); 

end
