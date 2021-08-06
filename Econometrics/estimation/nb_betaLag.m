function x = nb_betaLag(theta,K)
% Syntax:
%
% x = nb_betaLag(theta,K)
%
% Description:
%
% Implementation of the Beta lag polynominal.
% 
% Input:
% 
% - theta : A 1 x Q x P double with the hyperparameters of the Beta lag
%           polynominal. See page 5 of Ghysels et al. (2006). In equation
%           (3) we have used K+1 instead of K.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    Q = size(theta,2);
    if Q ~= 2
        error([mfilename ':: size(theta,2) must be equal to 2.'])
    end
    
    kk     = [1:K]'; %#ok<NBRAK>
    nom    = subFunc(kk/(K+1),theta(1,1,:),theta(1,2,:));
    denom  = sum(nom,1);
    x      = bsxfun(@rdivide,nom,denom);
    x      = permute(x,[2,1,3]);
    
end

function y = subFunc(x,a,b)
    y = bsxfun(@rdivide,bsxfun(@power,x,a - 1).*bsxfun(@power,1 - x,b - 1),beta(a,b));
end
