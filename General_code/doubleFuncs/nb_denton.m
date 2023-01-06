function x = nb_denton(y,z,k,type,d)
% Syntax:
%
% x = nb_denton(y,z,k,type,d)
%
% Description:
%
% The Denton method of transforming a series from low to high frequency.
% 
% See Denton (1971), Adjustment of Monthly or Quarterly Series to Annual  
% Totals: An Approach Based on Quadratic Minimization.
%
% Input:
% 
% - y    : A nobs x nvars x npage double with the main variable to 
%          transform.
%
% - z    : A nobs*k x nvars x npage double with observations to add 
%          judgment.
% 
% - k    : The number intra low frequency observations. If you have annual
%          data and want out quarterly data use 4.
%
% - type : Either 'sum', 'average', 'first' or 'last'. 'average' is 
%          default.
%
% - d    : 1 : first differences, 2 : second differences.
%
% Output:
% 
% - x    : Output series as a nobs*k x nvars x npage double.
%
% See also:
% nb_ts.convert, nb_ts.denton
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        d = 1;
        if nargin < 4
            type = 'average';
            if nargin < 3
                k = 4;
                if nargin < 2
                    z = [];
                end
            end
        end
    end
    
    [m,v,p] = size(y);
    if isempty(z)
        z = zeros(m*k,v,p);
    end

    n     = m*k;
    Bt    = constructBt(m,k,type);
    D     = constructD(n,d);
    A     = D'*D;
    B     = Bt';
    AinvB = A\B;
    C     = AinvB/(Bt*AinvB);
    if p > 1
        x = z;
        for pp = 1:p
            r         = y(:,:,pp) - Bt*z(:,:,pp);
            x(:,:,pp) = z(:,:,pp) + C*r;
        end
    else
        r = y - Bt*z;
        x = z + C*r;
    end
    
end


function D = constructD(n,d)

    D  = eye(n);
    D_ = [zeros(1,n);
          -eye(n-1),zeros(n-1,1)];
    D  = D + D_;
    if d == 2
        D = D*D;
    end
    
end

function Bt = constructBt(n,k,type)

    switch lower(type)
        case 'sum'  
           b     = ones(1,k);
        case 'average'
           b     = ones(1,k)./k;
        case 'last'
           b     = zeros(1,k);
           b(k)  = 1;
        case 'first'
           b     = zeros(1,k);
           b(1)  = 1;
        otherwise
           error ([mfilename ':: Unsupported type selected; ' type]);
    end
    Bt = kron(eye(n),b);
    
end
