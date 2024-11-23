function cellOut = figNumsAsCell(obj,len)
% Syntax:
%
% cellOut = figNumsAsCell(obj,len)
%
% Description:
%
% Get incrementing figure numbers as a len x 1 cell.
%
% Input:
%
% - obj     : An object of class nb_numbering.
%
% - len     : How many graphs/tables/figures you want to number
% 
% Output:
%
% - cellOut : A cell with the numbers.
%
% See also:
% char, charData, charNumOnly
%
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~nb_isScalarInteger(len,0)
        error([mfilename ':: The len input must be a strictly positive integer.'])
    end
    
    cellOut = cell(len,1);
    
    % Begin numbering before incrementing (looping)
    cellOut{1} = charNumOnly(obj);
    if len > 1
        for ii = 2:len
            plus(obj);
            cellOut{ii} = charNumOnly(obj);
        end
    end
    
end
