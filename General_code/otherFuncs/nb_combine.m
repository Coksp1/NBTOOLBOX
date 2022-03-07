function vc = nb_combine(v,n,n2)
% Syntax:
%
% vc = nb_combine(v,n)
% vc = nb_combine(v,n,n2)
%
% Description:
%
% Pick n elements from the vector v in all possible ways.
% 
% Inspired by a function of Matt Fig.
% Reference:  http://mathworld.wolfram.com/BallPicking.html
%
% Input:
% 
% - v  : A vector.
%
% - n  : The number of picked elements.
%
% - n2 : If 3 inputs is given this function will produce a 
%        nb_countCombine(length(v),n,n2) cell array of all combinations
%        where n to n2 elements are picked from v. 
% 
% Output:
% 
% - vc : A n!/k!(n-k)! x n matrix, or see input n2.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isrow(v)
       error([mfilename ':: The v input must be vector.']);
    end

    if nargin == 3
        
        num = nb_countCombine(length(v),n,n2);
        vc  = cell(1,num);
        kk  = 1;
        for ii = n:n2
            vt = nb_combine(v,ii);
            for jj = 1:size(vt,1)
                vc{kk} = vt(jj,:);
                kk     = kk + 1;
            end
        end
        
    else

        v = v(:);
        r = size(v,1);

        if r < n
            error([mfilename ':: It is not possible to pick ' int2str(n) ' elements out of a vector of size ' int2str(n)])
        end

        if n == r

           vc = v';

        elseif n == 1

           vc = v;

        elseif n == 2  

            id1       = cumsum((r-1):-1:2)+1;
            cn        = zeros((r-1)*r / 2,2);
            cn(:,2)   = 1;
            cn(1,:)   = [1 2];
            cn(id1,1) = 1;
            cn(id1,2) = -((r-3):-1:0);
            cn        = cumsum(cn);
            vc        = [v,v];
            vc        = vc(cn);  

        elseif r == n + 1

           tmp          = v';
           c            = tmp(ones(r,1),:);
           c(1:r+1:r*r) = [];
           vc           = reshape(c,r,r-1);

        elseif r < 15

            wv      = 1:n;  
            lim     = n;   
            inc     = 1;    
            bc      = nchoosek(r,n);
            cn      = zeros(round(bc),n);
            cn(1,:) = wv;  
            for ii = 2:(bc - 1) 

                if logical((inc+lim)-r) 
                    stp = inc;  
                    flg = 0;  
                else
                    stp = 1;
                    flg = 1;
                end
                for jj = 1:stp
                    wv(n  + jj - inc) = lim + jj; 
                end
                cn(ii,:) = wv;  
                inc      = inc*flg + 1;  
                lim      = wv(n - inc + 1 );

            end
            cn(ii+1,:) = (r-n+1):r;
            vc         = v(:,ones(1,n));
            vc         = vc(cn); 

        else 
           error([mfilename ':: Vector cannot be longer than 15...'])
        end
        
    end

end
