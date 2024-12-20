function dout = igrowth(DX,X,periods)
% Syntax:
%
% dout = igrowth(DX,X,periods)
%
% Description:
%
% Construct indicies based on inital values and time-series which 
% represent the series growth. Inverse of log approx. growth, i.e. 
% the inverse method of the growth method of the double class
% 
% Input:
%
% - din     : A double matrix with dimensions [r,c,p].
%
% - t       : A double matrix with dimensions [r,c,p].
% 
% - periods : The number of periods the din has been growthed over.
%
% Output:
% 
% - dout    : A double matrix with dimensions [r,c,p].
%
% See also: 
% growth, iegrowth
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 1;
    end

    [r,c,p] = size(DX);
    if nargin > 1
        if isscalar(X)
            d0 = ones(periods,c)*X;
        else
            d0 = X;
        end
    else
        d0 = ones(periods,c)*100;
    end
    [rr,cc,pp] = size(d0); 
    if rr == r
        d0 = d0(1:periods,:,:);
    elseif rr ~= periods
        error([mfilename,':: Initial values should have ' int2str(periods) ' row(s)'])
    end 
    if ~isequal(cc,c)
        error([mfilename,':: Initial values and data should have same number of columns'])
    elseif pp ~= 1 && pp ~= p
        error([mfilename,':: size of third dimension of Initial value should be 1 or ',int2str(p)])
    end
    if pp ~= p
        d0 = repmat(d0,[1,1,p]);
    end
    
    dout = nan(r,c,p);
    for ii = 1:periods
        d0t       = d0(ii,:,:);
        douttemp = exp(cumsum(DX(periods + ii:periods:end,:,:),1));
        r        = size(douttemp,1);
        dout(periods + ii:periods:end,:,:) = douttemp.*repmat(d0t,[r,1,1]);
    end
    dout(1:periods,:,:) = d0;
    
end
