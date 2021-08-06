function Q = nb_legendrePoly(P,K,E)
% Syntax:
%
% Q = nb_legendrePoly(P,K,E)
%
% Description:
%
% Implementation of the Legendre lag polynominal.
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

    %baseGrid = -1:2/(K-1):1;
    baseGrid = (0:K-1)/K;
    Q        = zeros(P*E,K*E);
    k        = 1;
    for j = 0:P-1 
        if j == 0
          grid = baseGrid.^j;
        elseif j == 1
          grid = baseGrid;   
        elseif j == 2
          grid = (3/2)*baseGrid.^2-(1/2);
        elseif j == 3
          grid = (5/2)*baseGrid.^3-(3/2)*grid;
        end
        for qq = 1:E
            ind      = qq:E:K*E;
            Q(k,ind) = grid;
            k        = k + 1;
        end
    end
    
end
