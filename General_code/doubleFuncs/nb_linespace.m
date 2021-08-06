function l = nb_linespace(x,y,n)
% Syntax:
%
% l = nb_linespace(x,y,n)
%
% Description:
%
% Generates n points between x and y. x and y must be vectors with same
% size.
% 
% Input:
% 
% - x : A m x 1 double or a 1 x m double. Must match y.
%
% - y : A m x 1 double or a 1 x m double. Must match x.
%
% - n : Number of generated points. Default is 100.
% 
% Output:
% 
% - l : A m x n double or a n x m double dependent on the input.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 2
        n = 100;
    end
    
    transy = 1;
    if size(y,2) > 1
        y      = y';
        transy = 0;
    end
    transx = 1;
    if size(x,2) > 1
        x      = x';
        transx = 0;
    end
    
    if transy ~= transx
        error([mfilename ':: x and y must have the same sizes.'])
    end
    
    [my1,my2] = size(y);
    [mx1,mx2] = size(x);
    if my2 > 1
        error([mfilename ':: The y input must be a vector, but is a matrix.'])
    end
    if mx2 > 1
        error([mfilename ':: The x input must be a vector, but is a matrix.'])
    end
    
    if my1 ~= mx1
        error([mfilename ':: x and y must have the same sizes.'])
    end
        
    if n < 2 
        l = x;
    else  
        n1 = floor(n)-1;
        c  = (y - x).*(n1-1); % opposite signs may cause overflow
        if isinf(c)
            l = x(:,ones(1,n)) + bsxfun(@times,y./x,0:n1) - bsxfun(@times,x./n1,0:n1); 
        else
            l = x(:,ones(1,n)) + bsxfun(@times,(y - x)/n1,0:n1);
        end
        l(:,1)   = x;
        l(:,end) = y;
    end
    
    if transy
       l = l'; 
    end

end
