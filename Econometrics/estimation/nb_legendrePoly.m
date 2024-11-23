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
%       Either as a scalar integer or a vector of integers with length E. 
% 
% - K : Number of lags of the regressor. Either as a scalar integer or a 
%       vector of integers with length E. 
%
% - E : Number of variables.
%
% Output:
% 
% - Q : A P*E x K*E (or sum(P(i)) x sum(K(i))) double with the mapping 
%       matrix.
%
% See also:
% nb_midasFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(P)
        P = K;
    end

    if isscalar(P) && isscalar(K)
        baseGrid = -1:2/(K-1):1;
        %baseGrid = (0:K-1)/K;
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
                grid = (5/2)*baseGrid.^3-(3/2)*baseGrid;
            end
            for qq = 1:E
                ind      = qq:E:K*E;
                Q(k,ind) = grid;
                k        = k + 1;
            end
        end
        
    else
        if isscalar(K)
            error('If P is not a scalar, this must be the case for K as well!')
        end
        if isscalar(P)
            error('If K is not a scalar, this must be the case for P as well!')
        end
        if length(P) ~= E
            error('When P is not a scalar it must have lengh == E.')
        end
        if length(K) ~= E
            error('When K is not a scalar it must have lengh == E.')
        end
        
        Q    = zeros(sum(P),sum(K));
        k    = 1;
        maxP = max(P);
        for j = 0:maxP-1  
            for qq = 1:E
                if P(qq) < j + 1
                    continue
                end
                baseGrid = -1:2/(K(qq)-1):1;
                %baseGrid = (0:K(qq)-1)/K(qq);
                if j == 0
                    grid = baseGrid.^j;
                elseif j == 1
                    grid = baseGrid;
                elseif j == 2
                    grid = (3/2)*baseGrid.^2-(1/2);
                elseif j == 3
                    grid = (5/2)*baseGrid.^3-(3/2)*baseGrid;
                end
                ind      = nb_getMidasIndex(qq,K,E);
                Q(k,ind) = grid;
                k        = k + 1; 
            end
        end
    end
    
end
