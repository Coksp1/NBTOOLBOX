function xlag = nb_slag(xin,lags)
% Syntax:
%
% xlag = nb_slag(xin,lags)
%
% Description:
% 
% Creates a matrix of nObs x total number of lags. I.e. 
% [x1(t-1), x1(t-2), ... x1(t-max([lags{1}]), x2(t-1), ... ,
%  x2(t-max([lags{1}])]  
%
% Input:
% 
% - xin  : A nObs x nVar double.
%
% - lags : A 1 x nVar cell array. Each element must be a vector of 
%          integers with the lags to be made for the corresponding column 
%          of xin.
% 
% Output: 
% 
% - xlag : A nObs x total number of lags double.
% 
% Examples:
%
% xin  = rand(20,2);
% xlag = nb_slag(xin,{1,[1,2]})
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [nObs,nVars,nPages] = size(xin);
    nSize               = size([lags{:}],2);
    xlag                = nan(nObs,nSize,nPages);
    kk                  = 1;
    for ii = 1:nVars
        for lagii = lags{ii}
            xlag(:,kk,:) = nb_lag(xin(:,ii,:),lagii);
            kk           = kk + 1;
        end
    end
    
end
