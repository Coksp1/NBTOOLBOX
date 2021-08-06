function clag = nb_scellstrlag(c,lags)
% Syntax:
%
% clag = nb_scellstrlag(c,lags)
%
% Description:
% 
% Creates a arrat of nObs x total number of lags. I.e. 
% [x1(t-1), x1(t-2), ... x1(t-max([lags{1}]), x2(t-1), ... ,
%  x2(t-max([lags{1}])] 
%
%
% Input:
% 
% - c    : A cellstr
%
% - nlag : The number of lags. Default is 1. Could be a 1 x nvar 
%          double.
% 
% - type : Either 'lagFast' (default) or 'varFast'
%
% Output: 
% 
% - xout : A cellstr
%
% Examples:
% clag = nb_scellstrlag({'Var1','Var2'},{1,[1,2]})
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [~,nVars] = size(c);
    nSize     = size([lags{:}],2);
    clag      = cell(1,nSize);
    kk        = 1;
    for ii = 1:nVars
        for lagii = lags{ii}
            clag{1,kk} = [c{ii} ,'_lag' int2str(lagii)];
            kk         = kk + 1;
        end
    end
        
end
