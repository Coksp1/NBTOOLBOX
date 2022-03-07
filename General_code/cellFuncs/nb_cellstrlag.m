function clag = nb_cellstrlag(c,nlag,type)
% Syntax:
%
% clag = nb_cellstrlag(c,nlag,type)
%
% Description:
% 
% Type = 'lagFast':
%
% Creates a array of size 1 x size(c,2)*nlag. I.e. 
% {'var1_lag1', 'var1_lag2', ... 'var1_lagN', ...
%       'var2_lag1', ... 'var2_lagN'} 
%
% Type = 'varFast':
%
% Creates a matrix of size 1 x size(c,2)*nlag. I.e. 
% ['var1_lag1', ... 'varp_lag1', ... , 'var1_lagN', ... 
%       'varp_lagN']
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
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'lagFast';
        if nargin < 2
            nlag = 1;
        end
    end
    
    if nlag == 0
        clag = {};
        return
    end

    [~, nvar] = size(c);
    nSize = size(nlag,2);
    if nSize == 1
        nlag = repmat(nlag,1,nvar);
    end
    
    sOut = sum(nlag);
    mlag = max(nlag);
    clag = cell(1,sOut);
    switch lower(type)

        case 'varfast'

            % Find the lags
            kk = 1;
            for ii = 1:mlag

                for jj = 1:nvar

                    if ii <= nlag(jj)

                        % Check if the variable already has a _lag
                        % postfix (then we append)
                        str   = c{jj};
                        ind   = regexp(str,'_lag[0-9]*$');
                        extra = 0;
                        if ~isempty(ind)
                            
                            extra = str2double(str(ind+4:end));
                            if isnan(extra)
                                extra = 0;
                            end
                            str = str(1:ind-1);
                            
                        end
                        
                        % Add lag postfix
                        clag{kk} = [str ,'_lag' int2str(ii + extra)];
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

                        % Check if the variable already has a _lag
                        % postfix (then we append)
                        str   = c{ii};
                        ind   = regexp(str,'_lag[0-9]*$');
                        extra = 0;
                        if ~isempty(ind)
                            
                            extra = str2double(str(ind+4:end));
                            if isnan(extra)
                                extra = 0;
                            end
                            str = str(1:ind-1);
                            
                        end
                        
                        clag{kk} = [str ,'_lag' int2str(jj + extra)];
                        kk = kk + 1;

                    end

                end

            end

    end
        
end
