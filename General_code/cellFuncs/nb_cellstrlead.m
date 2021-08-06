function clead = nb_cellstrlead(c,nlead,type,reverse)
% Syntax:
%
% clag = nb_cellstrlead(c,nlead,type,reverse)
%
% Description:
% 
% Type = 'leadFast':
%
% Creates a matrix of size(x,1) x size(x,2)*nlead. I.e. 
% {'var1_lead1', 'var1_lead2', ... 'var1_leadN', ...
%       'var2_lead1', ... 'var2_leadN'} 
%
% Type = 'varFast':
%
% Creates a matrix of size 1 x size(c,2)*nlag. I.e. 
% ['var1_lead1', ... 'varp_lead1', ... , 'var1_leadN', ... 
%       'varp_leadN']
%
% Input:
% 
% - c     : A cellstr
%
% - nlead : The number of lead. Default is 1. Could be a 1 x nvar 
%           double.
% 
% - type  : Either 'leadFast' (default) or 'varFast'
%
% Output: 
% 
% - xout : A cellstr
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        reverse = false;
        if nargin < 3
            type = 'leadFast';
            if nargin < 2
                nlead = 1;
            end
        end
    end

    [~, nvar] = size(c);
    nSize     = size(nlead,2);
    if nSize == 1
        nlead = repmat(nlead,1,nvar);
    end
    
    sOut  = sum(nlead);
    mlead = max(nlead);
    clead = cell(1,sOut);
    switch lower(type)

        case 'varfast'

            if reverse
                
                % Find the leads
                kk = 1;
                for ii = mlead:-1:1

                    for jj = 1:nvar

                        if ii <= nlead(jj)

                            % Check if the variable already has a _lead
                            % postfix (then we append)
                            str   = c{jj};
                            ind   = regexp(str,'_lead[0-9]*$');
                            extra = 0;
                            if ~isempty(ind)

                                extra = str2double(str(ind+4:end));
                                if isnan(extra)
                                    extra = 0;
                                end
                                str = str(1:ind-1);

                            end

                            % Add lead postfix
                            clead{kk} = [str ,'_lead' int2str(ii + extra)];
                            kk        = kk + 1;

                        end

                    end

                end
                
            else
            
                % Find the leads
                kk = 1;
                for ii = 1:mlead

                    for jj = 1:nvar

                        if ii <= nlead(jj)

                            % Check if the variable already has a _lead
                            % postfix (then we append)
                            str   = c{jj};
                            ind   = regexp(str,'_lead[0-9]*$');
                            extra = 0;
                            if ~isempty(ind)

                                extra = str2double(str(ind+4:end));
                                if isnan(extra)
                                    extra = 0;
                                end
                                str = str(1:ind-1);

                            end

                            % Add lead postfix
                            clead{kk} = [str ,'_lead' int2str(ii + extra)];
                            kk        = kk + 1;

                        end

                    end

                end
                
            end

        otherwise

            % Find the leads
            kk = 1;
            for ii = 1:nvar

                for jj = 1:mlead

                    if jj <= nlead(ii)

                        % Check if the variable already has a _lead
                        % postfix (then we append)
                        str   = c{ii};
                        ind   = regexp(str,'_lead[0-9]*$');
                        extra = 0;
                        if ~isempty(ind)
                            
                            extra = str2double(str(ind+4:end));
                            if isnan(extra)
                                extra = 0;
                            end
                            str = str(1:ind-1);
                            
                        end
                        
                        clead{kk} = [str ,'_lead' int2str(jj + extra)];
                        kk = kk + 1;

                    end

                end

            end

    end
        
end
