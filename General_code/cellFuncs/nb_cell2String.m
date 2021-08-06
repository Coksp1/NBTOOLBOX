function string = nb_cell2String(c)
% Syntax:
%
% string = nb_cell2String(c)
%
% Description:
%
% Convert a cell to a string. Each element will be called with the toString
% method.
% 
% Input:
% 
% - c      : A cell.
% 
% Output:
% 
% - string : A string.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    string = '';
    for ii = 1:length(c)

        if ischar(c{ii}) && size(c{ii},1)
            string = [string,',''',c{ii} '''']; %#ok<AGROW>
        elseif iscell(c{ii})
            string = [string '{' nb_cell2String(c{ii}) '}']; %#ok<AGROW>
        else
            try
                string = [string,',',toString(c{ii})];  %#ok<AGROW>
            catch %#ok<CTCH>
                error('Could not convert the cell to a string, as some of its elements couln''t be converted to a string.')
            end
        end
    end
    if strcmpi(string(1,1),',')
        string = string(1,2:end);
    end
    
end
