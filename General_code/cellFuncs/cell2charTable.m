function tableAsChar = cell2charTable(table)
% Syntax:
%
% tableAsChar = cell2charTable(table)
%
% Description:
%
% Convert a cell matrix to a printable char vector.
% 
% Input:
% 
% - table       : A cellstr matrix.
% 
% Output:
% 
% - tableAsChar : A char vector.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    body_format = '';
    dim         = nan(size(table,2) - 1,1);
    for ii = size(table,2):-1:2
        dim(ii - 1) = max(cellfun('size',table(:,ii),2)) + 2;
        body_format = ['%',int2str(dim(ii - 1)),'s ',body_format]; %#ok<AGROW>
    end

    tableAsChar = '';
    for ii = 1:size(table,1)
        tableRow    = table(ii,2:end);
        tableAsChar = char(tableAsChar,sprintf(body_format,tableRow{:}));
    end
    tableAsChar     = tableAsChar(2:end,:);
    firstColumnChar = char(table(:,1));
    tableAsChar     = [firstColumnChar,tableAsChar];
    
end
