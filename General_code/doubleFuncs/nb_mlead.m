function xlead = nb_mlead(x,nlead,type)
% Syntax:
%
% xout = nb_mlead(xin,nlead)
%
% Description:
% 
% Type = 'lagFast':
%
% Creates a matrix of size(x,1) x size(x,2)*nlead. I.e. 
% [x1(t+1), x1(t+2), ... x1(t+nlead), x2(t+1), ... x2(t+nlead)]  
%
% Type = 'varFast':
%
% Creates a matrix of size(x,1) x size(x,2)*nlead. I.e. 
% [x1(t+1), ... xp(t+1), ... , x1(t+nlead), ... xp(t+nlead)]
%
% Input:
% 
% - xin   : A double
%
% - nlead : The number of lags. Default is 1. Could be a 1 x nvar 
%          double.
% 
% - type  : Either 'lagFast' (default) or 'varFast'
%
% Output: 
% 
% - xout : A double
% 
% Examples:
%
% xout = nb_mlead(rand(20,2),4)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'lagFast';
        if nargin < 2
            nlead = 1;
        end
    end
    if nlead == 0
        xlead = nan(size(x,1),0,size(x,3));
        return
    end

    nSize = size(nlead,2);
    
    if nSize > 1
        
        [nobs, nvar, npage] = size(x);
        sOut  = sum(nlead);
        mlead = max(nlead);
        xlead = nan(nobs,sOut,npage);
        switch lower(type)

            case 'varfast'

                % Find the lags
                kk = 1;
                for ii = 1:mlead
                
                    for jj = 1:nvar
                        
                        if ii <= nlead(jj)
                            
                            xlead(:,kk,:) = lead(x(:,jj),ii);
                            kk = kk + 1;
                            
                        end
                        
                    end
                    
                end

            otherwise

                % Find the lags
                kk = 1;
                for ii = 1:nvar
                
                    for jj = 1:mlead
                        
                        if jj <= nlead(ii)
                            
                            xlead(:,kk,:) = lead(x(:,ii),jj);
                            kk = kk + 1;
                            
                        end
                        
                    end
                    
                end

        end
        
    else
    
        % Initialize
        [nobs, nvar, npage] = size(x);
        xlead               = nan(nobs,nvar*nlead,npage);
        switch lower(type)

            case 'varfast'

                [~, nvar,~] = size(x);

                % Find the lags
                for t = 1:nlead
                    xlead(:,nvar*(t-1) + 1:nvar*t,:) = lead(x,t);
                end

            otherwise

                % Initialize
                [nobs, nvar, npage] = size(x);
                xlead                = nan(nobs,nvar*nlead,npage);

                % Find the lags
                for t = 1:nlead
                    xlead(:,t:nlead:end,:) = cat(1,x(1 + t:end,:,:),nan(t,nvar,npage));
                end

        end
        
    end
    
end
