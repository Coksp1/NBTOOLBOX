function B = findAniticipatedMatrices(B1,nAntSteps,T1AT0iT1)
% Syntax:
% 
% B = nb_dsge.findAniticipatedMatrices(PHI,nsteps,T1AT0iT1)
% 
% Description:
%
% Forward expansion when dealing with expected shocks.
%
% This implements the formula find in appendiks A of Junior Maih (2010), 
% "Conditional forecasts in DSGE models".
%
% Let the linearized DSGE model be written as:
% 
% E_t[Theta_lead*y(t+1) + Theta_0*y(t) + Theta_lag*y(t-1) + PHI*eps(t)] = 0
%
% And the normal solution:
%
% y(t+1) = A*y(t) + B1*eps(t)
%
% Input:
%
% - B1        : Solution of the shock impact matrix, as a nEndo x nExo 
%               double. I.e. 
%
% - nAntSteps : Number of anticipated periods of the shocks.
%
% - T1AT0iT1  : inv(Theta_lead*A + Theta_0)*Theta_lead
% 
% Written by Kenneth Sæterhagen Paulsen
            
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [nEndo,nExo] = size(B1);
    B            = nan(nEndo,nExo,nAntSteps);
    B(:,:,1)     = B1;
    for j = 1:nAntSteps - 1
        B(:,:,j+1) = -T1AT0iT1*B(:,:,j);
    end
    B(abs(B) < 1e-9) = 0;

end
