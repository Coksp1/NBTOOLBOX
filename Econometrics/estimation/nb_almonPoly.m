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
                grid     = (1:1:K(qq)).^j;
                ind      = nb_getMidasIndex(qq,K,E);
                Q(k,ind) = grid;
                k        = k + 1; 
            end
        end
    end
    
end
