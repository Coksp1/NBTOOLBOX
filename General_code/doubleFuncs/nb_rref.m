function A = nb_rref(A)
% Syntax:
%
% A = nb_rref(X)
%
% Description:
%
% This method produces the row echelon form of a matrix A.
% 
% Input:
% 
% - A : A NxM double matrix.
% 
% Output:
% 
% - A : A NxM double matrix.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    rows  = size(A,1);
    cols  = size(A,2);
    count = 1;
    while count < cols
        countRows = count + 1;
        while countRows <= rows
            if A(count,count) == 0
                A(count,:)     = A(countRows,:);
                A(countRows,:) = A(countRows,:) - (A(countRows,count)./A(count,count)).*A(count,:);
                countRows      = countRows + 1;
            end
            A(countRows,:) = A(countRows,:) - (A(countRows,count)./A(count,count)).*A(count,:);
            countRows      = countRows+1;
        end
        count = count + 1;
    end
    
end
