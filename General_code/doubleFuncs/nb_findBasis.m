function [i,B] = nb_findBasis(A)
% Syntax:
%
% [i,B] = nb_findBasis(A)
%
% Description:
%
% Find one basis of the linear system represented by A, and return the
% location of those equations.
% 
% Input:
% 
% - A : A NxM double matrix, where N >= M
% 
% Output:
% 
% - i : The index of the basis of the linear system represented by A.
%
% - B : The basis of the linear system represented by A.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if size(A,1) < size(A,2)
        error([mfilename ':: The matrix A must have more rows than columns.'])
    end
    C     = A';
    [~,i] = rref(C);
    if nargout > 1
        B = C(:,i)';
    end
    
end
