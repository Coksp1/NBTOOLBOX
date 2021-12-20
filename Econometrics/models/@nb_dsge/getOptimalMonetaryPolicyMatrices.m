function [Hlead,H0,Hlag,D] = getOptimalMonetaryPolicyMatrices(Alead,A0,Alag,B,W,beta)
% Syntax:
%
% [Hlead,H0,Hlag,D] = ...
%       nb_dsge.getOptimalMonetaryPolicyMatrices(Alead,A0,Alag,B,W,beta)
%
% Description:
%
% Form the optimal monetary policy matrices when the Klein algorithm is
% used to solve the problem.
% 
% See also:
% nb_dsge.optimalMonetaryPolicySolver
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [nMult,nEndo] = size(A0); 
    nExo          = size(B,2);

    Z     = zeros(nMult,nMult);
    Z2    = zeros(nEndo,nEndo);
    Hlead = [Alead, Z; Z2, beta*Alag'];
    H0    = [A0, Z; 2*full(W), A0'];
    Hlag  = [Alag, Z; Z2, (1/beta)*Alead'];
    D     = [B;zeros(nEndo,nExo)];
    
end
