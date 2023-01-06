function x = nb_almonLag(theta,K)
% Syntax:
%
% x = nb_almonLag(theta,K)
%
% Description:
%
% Implementation of the Almon lag polynominal.
% 
% Input:
% 
% - theta : A 1 x Q x P double with the hyperparameters of the almon lag
%           polynominal; exp(theta(1).*k + ... + theta(Q).*k.^Q)/
%           sum_k_K(exp(theta(1).*k + ... + theta(Q).*k.^Q))
% 
% - K     : Number of lags of the polynominal.
%
% Output:
% 
% - x     : A 1 x K double with the value of the Almon lag polynominal for
%           k = 1:K.
%
% See also:
% nb_midasFunc
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    Q      = size(theta,2);
    qq     = 1:Q;
    kk     = [1:K]'; %#ok<NBRAK>
    nom    = exp(sum(bsxfun(@times,theta,bsxfun(@power,kk,qq)),2));
    denom  = sum(nom,1);
    x      = bsxfun(@rdivide,nom,denom);
    x      = permute(x,[2,1,3]);
    
end
