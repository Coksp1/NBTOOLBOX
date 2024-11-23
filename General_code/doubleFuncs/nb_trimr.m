function z = nb_trimr(x,n1,n2)
% Syntax:
%
% z = nb_trimr(x,n1,n2)
%
% Description:
%
% Strip the rows before and included n1 and the rows after and 
% included n2 of a matrix x. 
%
% Note: Modeled after Gauss trimr function
%
% Input:
% 
% - x    : A double matrix.
%
% - n1   : See above. A scalar.
%
% - n2   : See above. A scalar.
% 
% Output: 
% 
% - z    : The stripped matrix as a double.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    n = size(x,1);
    if (n1 + n2) >= n
        error('Attempting to trim too much in nb_trimr');
    end;
    h1 = n1 + 1;   
    h2 = n - n2;
    z  = x(h1:h2,:);
    
end
