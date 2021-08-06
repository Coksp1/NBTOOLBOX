function H = testLRPriorH(H,n)
% Syntax:
%
% H = nb_bVarEstimator.testLRPriorH(H,n)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if size(H,2) ~= n
        error([mfilename ':: The matrix with the long run priors must have ' int2str(n) ' columns.'])
    end
    k = size(H,1);
    if k > n
        error([mfilename ':: The matrix with the long run priors cannot have more than ' int2str(n) ' rows, but is ' int2str(k) '.'])
    elseif k < n
        Hfull        = zeros(n,n);
        Hfull(1:k,:) = H;
        H            = Hfull;
    end

end
