function c = nb_appendIndexes(str,indexes)
% Syntax:
%
% c = nb_appendIndexes(str,indexes)
%
% Description:
%
% Append indexes to a string, and return those strin in an cellstr array.
% 
% Input:
% 
% - str     : A one line char (string). 
%
% - indexes : The index to append. E.g. 1:10.
% 
% Output:
% 
% - c       : A cellstr.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(str)
        if ~nb_isOneLineChar(str)
            error([mfilename ':: The str input must be a one line char.'])
        end
    end
    indexesStr = strtrim(cellstr(int2str(indexes(:))));
    c          = strcat(str,indexesStr);
    
end
