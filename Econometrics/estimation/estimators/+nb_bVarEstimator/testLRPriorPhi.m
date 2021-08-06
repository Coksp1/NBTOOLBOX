function phi = testLRPriorPhi(phi,n)
% Syntax:
%
% phi = nb_bVarEstimator.testLRPriorPhi(phi,n)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if size(phi,2) > 1 
        if size(phi,1)
            phi = phi(:);
        else
            error([mfilename ':: The prior shrinkage (phi) cannot be a matrix.'])
        end
    end 

    if size(phi,1) ~= n
        error([mfilename ':: The prior shrinkage vector must have ' int2str(n) ' elements.'])
    end

end
