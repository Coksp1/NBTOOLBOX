function xlag = nb_mlag(x,nlag,type)
% Syntax:
%
% xlag = nb_mlag(x,nlag)
%
% Description:
% 
% Type = 'lagFast':
%
% Creates a matrix of size(x,1) x size(x,2)*nlag. I.e. 
% [x1(t-1), x1(t-2), ... x1(t-nlag), x2(t-1), ... x2(t-nlag)]  
%
% Type = 'varFast':
%
% Creates a matrix of size(x,1) x size(x,2)*nlag. I.e. 
% [x1(t-1), ... xp(t-1), ... , x1(t-nlag), ... xp(t-nlag)]
%
% Input:
% 
% - x    : A double
%
% - nlag : The number of lags. Default is 1. Could be a 1 x nvar 
%          double.
% 
% - type : Either 'lagFast' (default) or 'varFast'
%
% Output: 
% 
% - xlag : A double
% 
% Examples:
%
% xlag = nb_mlag(rand(20,2),4)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'lagFast';
        if nargin < 2
            nlag = 1;
        end
    end
    
    if all(nlag == 0) || isempty(nlag)
        xlag = nan(size(x,1),0,size(x,3));
        return
    end

    nSize = size(nlag,2);
    
    if nSize > 1
        
        [nobs, nvar, npage] = size(x);
        sOut = sum(nlag);
        mlag = max(nlag);
        xlag = nan(nobs,sOut,npage);
        switch lower(type)

            case 'varfast'

                % Find the lags
                kk = 1;
                for ii = 1:mlag
                    for jj = 1:nvar  
                        if ii <= nlag(jj) 
                            xlag(:,kk,:) = lag(x(:,jj,:),ii);
                            kk = kk + 1;
                        end
                    end
                end

            otherwise

                % Find the lags
                kk = 1;
                for ii = 1:nvar
                    for jj = 1:mlag   
                        if jj <= nlag(ii)
                            xlag(:,kk,:) = lag(x(:,ii,:),jj);
                            kk = kk + 1;
                        end
                    end
                end

        end
        
    else
        
        if nlag < 0
            error([mfilename ':: Input nlag must be greater or equal to 0.'])
        end
    
        % Initialize
        [nobs, nvar, npage] = size(x);
        xlag                = nan(nobs,nvar*nlag,npage);
        switch lower(type)
            case 'varfast'
                % Find the lags
                [~, nvar,~] = size(x);
                for t = 1:nlag
                    xlag(:,nvar*(t-1) + 1:nvar*t,:) = lag(x,t);
                end
            otherwise
                % Find the lags
                for t = 1:nlag
                    xlag(:,t:nlag:end,:) = cat(1,nan(t,nvar,npage),x(1:end-t,:,:));
                end
        end
        
    end
    
end
