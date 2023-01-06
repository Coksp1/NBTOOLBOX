function C = nb_chol(A,type)
% Syntax:
%
% C = nb_chol(A,type)
%
% Description:
%
% Cholesky decomosition. If type is given as 'cov' it will to a eigenvalue
% decomposition such that C*C' = A. In the last case the matrix A must be
% positive semi-definite.
% 
% Input:
% 
% - A    : A symmetric positive (semi-)definite matrix
% 
% - type : Give 'cov' to use eignevalue decomposition if cholesky
%          decomposition fails. C is not necessary symmetric in this case!
%
%          Give 'covrepair' to reset all eigenvalue that are negative to
%          0.
%          
% Output:
% 
% - C    : A matrix such that C*C' = A
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = '';
    end

    [r,c] = size(A);
    if r ~= c
        error([mfilename ':: The A matrix must be square to do chol decomposition.'])
    end

    [C,err] = chol(A);
    switch lower(type)
        
        case {'cov','covrepair'}
            if err
                % Check for positive semi-definite matrix
                [T,D]    = eig(0.5*(A + A'));
                [~,d]    = max(abs(T),[],1);
                neg      = T(d + (0:r:(c-1)*r)) < 0;
                T(:,neg) = -T(:,neg);
                D        = diag(D);
                tol      = eps(max(D))*length(D);
                t        = abs(D) > tol;
                DT       = D(t);
                p        = sum(DT < 0); % number of negative eigenvalues
                if p == 0
                    C = diag(sqrt(DT))*T(:,t)';
                elseif strcmpi(type,'covrepair')
                    D(D<0) = eps(max(D));
                    AT     = T*diag(D)*T';
                    C      = nb_chol(AT,'cov');
                else
                    error([mfilename ':: Matrix must be positive semi-definite'])
                end
            end
        otherwise
            if err
                error([mfilename ':: Matrix must be positive definite'])
            end
    end

end
