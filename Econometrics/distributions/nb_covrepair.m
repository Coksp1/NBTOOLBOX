function C = nb_covrepair(A,type)
% Syntax:
%
% C = nb_covrepair(A,type)
%
% Description:
%
% Convert a non (semi-)definite matrix to (semi-)definite matrix.
% 
% Input:
% 
% - A    : A symmetric matrix.
%
% - type : true or false. Give true to find the closest semi-definite 
%          matrix. Default is false, i.e. to find the closest definite
%          matrix.
% 
% Output:
% 
% - C    : A symmetric matrix with same size as A.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = false;
    end
    
    [n,m] = size(A);
    if n ~= m
        error([mfilename ':: The A matrix must be square.'])
    end

    [UT,D]     = eig((A+A')/2);
    [~,maxind] = max(abs(UT),[],1);
    neg        = UT(maxind + (0:n:(m-1)*n)) < 0;
    UT(:,neg)  = -UT(:,neg);
    D          = diag(D);
    if type
        D(D<0)  = 0;
    else
        D(D<=0) = (eps)^(1/3);
    end
    C = UT*diag(D)*UT';

end
