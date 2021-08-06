function Q = nb_almonPoly(P,K,E)
% Syntax:
%
% Q = nb_almonPoly(P,K,E)
%
% Description:
%
% Implementation of the Almon lag polynominal.
% 
% Input:
% 
% - P : Number of lags of the polynomial. If empty it will default to K.
% 
% - K : Number of lags of the regressor.
%
% - E : Number of variables.
%
% Output:
% 
% - Q : A P x K*E double with the mapping matrix.
%
% See also:
% nb_midasFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(P)
        P = K;
    end

    Q = zeros(P*E,K*E);
    k = 1;
    for j = 0:P-1  
        grid = (1:1:K).^j;
        for qq = 1:E
            ind      = qq:E:K*E;
            Q(k,ind) = grid;
            k        = k + 1; 
        end
    end
    
end
