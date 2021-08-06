function out = nb_multilined2line(in,sep)
% Syntax:
%
% out = nb_multilined2line(in)
%
% Description:
%
% Transform each cell of the input in which is multilined to 
% a one line string. 
%
% Input:
% 
% - in  : Either a cellstr (matrix) or a char.
%
% - sep : The seporator used. Default is ' \\ '.
% 
% Output:
% 
% . out : Either a cellstr (matrix) or a char. Depending on the 
%         input.
%
% Examples:
%
% in = char('fghhdfgj','dhfgdhf','dfsdfdf')
% 
% in =
% 
% fghhdfgj
% dhfgdhf 
% dfsdfdf 
% 
% To:
%
% out =
% 
% fghhdfgj \\ dhfgdhf \\ dfsdfdf
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        sep = ' \\ ';
    end

    if ischar(in)
        
        if size(in,1) > 1
            out = transform(in,sep);
        else
            out = in;
        end
        return
        
    elseif iscellstr(in)
        
        tr = 0;
        if size(in,2) == 1
            in = in';
            tr = 1;
        end
        
        % We must locate the elements with multiple lines
        ind = cellfun('size',in,1);
        for ii = 1:size(ind,1)

            indRow = find(ind);
            for jj = 1:size(indRow,2)

                in{ii,indRow(jj)} = transform(in{ii,indRow(jj)},sep);

            end

        end

        if tr 
           in = in'; 
        end
        out = in;
        
    else
        error([mfilename ':: Input must either be a char or a cellstr.'])
    end

end

function string = transform(multiChar,sep)
% Better to use strjoin, but it is not supported for older releases
% then (R2013a)

     string = '';
     for ii = 1:size(multiChar,1) - 1
         string = [string,strtrim(multiChar(ii,:)),sep]; %#ok
     end
     string = [string,multiChar(end,:)];

end
