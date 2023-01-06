function Q = nb_betaPoly(theta,K,E)
% Syntax:
%
% Q = nb_betaPoly(theta,K,E)
%
% Description:
%
% Implementation of the Beta lag polynominal.
% 
% Input:
% 
% - theta : A scalar double with the last hyperparameter of the Beta lag
%           polynominal. See page 5 of Ghysels et al. (2006). In equation
%           (3) we have used K+1 instead of K. The first hyperparameter
%           is assumed to be 1!
%
% - P     : Number of lags of the polynomial. If empty it will default to 
%           K. Either as a scalar integer or a vector of integers with 
%           length E. 
% 
% - K     : Number of lags of the regressor. Either as a scalar integer or  
%           a vector of integers with length E. 
%
% - E     : Number of variables.
%
% Output:
% 
% - Q     : A E x K*E (or E x sum(K(i))) double with the mapping 
%           matrix.
%
% See also:
% nb_betaProfiling
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isscalar(K)
        Q    = zeros(E,K*E);
        k    = 1;  
        grid = nb_betaLag([1,theta],K);
        for qq = 1:E
            ind      = qq:E:K*E;
            Q(k,ind) = grid;
            k        = k + 1; 
        end
    else
        if isscalar(K)
            error('If P is not a scalar, this must be the case for K as well!')
        end
        if length(K) ~= E
            error('When K is not a scalar it must have lengh == E.')
        end
        
        Q = zeros(E,sum(K));
        k = 1; 
        for qq = 1:E
            grid     = nb_betaLag([1,theta],K(qq));
            ind      = nb_getMidasIndex(qq,K,E);
            Q(k,ind) = grid;
            k        = k + 1; 
        end
    end
    
end
