function converged = checkConvergence(res,oldLogLik,tol)
% Syntax:
%
% converged = nb_dfmemlEstimator.checkConvergence(res,oldLogLik,tol)
%
% Description:
%
% Check for convergance of the EML-algorithm based on minus the log 
% likelihood.
%
% See also:
% nb_dfmemlEstimator.normalEstimation
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    change = abs(res.likelihood - oldLogLik);
    if change < tol
        converged = true;  
    else
        converged = false; 
    end

end
