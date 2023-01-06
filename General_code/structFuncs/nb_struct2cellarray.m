function c = nb_struct2cellarray(s,type)
% Syntax:
%
% c = nb_struct2cellarray(s,type)
%
% Description:
%
% Convert struct to cell.
% 
% Input:
% 
% - s : A struct.
%
% - type : > 'array' (default): 
%
%               Convert a struct to a cell array. I.e.
%               {'fieldName1',field1,'fieldName2',field2,....}
% 
%          > 'matrix': 
%
%               Convert a struct to a cell array. I.e.
%               {'fieldName1',field1;'fieldName2',field2;....}
%
% Output:
% 
% - c : A cell array
%
% See also:
% struct2cell
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'array';
    end
    
    if strcmpi(type,'matrix')
        fieldN = fieldnames(s);
        cTemp  = struct2cell(s(:));
        c      = [fieldN,cTemp];
    else
        fieldN     = fieldnames(s);
        cTemp      = struct2cell(s);
        c          = cell(1,length(fieldN)*2);
        c(1:2:end) = fieldN;
        c(2:2:end) = cTemp;
    end

end
