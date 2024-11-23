function [alpha0,P0,Pinf0] = intiKF(results)
% Syntax:
%
% [alpha0,P0,Pinf0] = nb_dfmemlEstimator.intiKF(results)
%
% Description:
%
% Initialize Kalman filter.
%
% See also:
% nb_dfmemlEstimator.emlIteration, nb_dfmemlEstimator.normalEstimation
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    alpha0      = zeros(size(results.T,1),1);
    BB          = results.BQ*results.BQ';
    [P0,failed] = nb_lyapunovEquation(results.T,BB);
    Pinf0       = [];
    if failed
        [~,~,~,~,P0,Pinf0,failed] = nb_setUpForDiffuseFilter(results.Z,results.T,results.BQ);
        if failed
            error([mfilename ':: Initial value of the one step forecast error covariance matrix could not be calculated.'])
        end
    end

end
