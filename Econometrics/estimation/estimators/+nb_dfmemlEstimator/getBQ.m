function results = getBQ(results)
% Syntax:
%
% results = nb_dfmemlEstimator.getBQ(results)
%
% Description:
%
% Standardize residuals of the idoiocyncratic components to have a 
% covariance matrix as the identity matrix. 
%
% See also:
% nb_dfmemlEstimator.initialize, nb_dfmemlEstimator.emlIteration
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen 

    ind = all(abs(results.Q) < eps,1);
    if any(ind)
        % Some factors are equal to a variables, so handle this case
        TSRest        = transpose(chol(results.Q(~ind,~ind)));
        TS            = zeros(size(results.Q));
        TS(~ind,~ind) = TSRest;
    else
        TS = transpose(chol(results.Q));
    end
    results.BQ = results.B*TS;

end
