function xlcell = nb_excelCellOffset(base,x,y)
% Syntax:
%
% xlcell = nb_excelCellOffset(base,x,y)
%
% Description:
%
% Get the excel cell index the number of increments up/down and to the
% left/right of the cell given by start.
% 
% Input:
% 
% - base  : A string with the base cell. E.g. 'A1'
%
% - x     : A number of increments up (negative), or down (positive).
%
% - y     : A number of increments to the left (negative), or to the right 
%           (positive).
% 
% Output:
% 
% - xlcell : A string on the format 'A1'.
%
% See also:
% nb_excelRange, nb_letter2num, nb_num2letter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        y = 0;
        if nargin < 2
            x = 0;
        end
    end

    if ~nb_isScalarInteger(x) || x < 0
        error([mfilename ':: The row increment (x) must be a weakly positive scalar integer.'])
    end
    if ~nb_isScalarInteger(y) || y < 0
        error([mfilename ':: The column increment (y) must be a weakly positive scalar integer.'])
    end

    startNum = str2double(regexp(base,'\d+','match'));
    startStr = regexp(base,'\D','match');
    if isempty(startStr)
        error([mfilename ':: The base input is not a excel cell reference, i.e. on the form ''A1''.'])
    end
    startBase = nb_letter2num(startStr{1});
    newNum    = startNum + x;
    newBase   = startBase + y;
    if newNum < 1
        error([mfilename ':: The return cell is not a valid position. I.e. get a negative position.'])
    end
    if newBase < 1
        error([mfilename ':: The return cell is not a valid position. I.e. get a negative position.'])
    end
    newStr = nb_num2letter(newBase);
    xlcell = [newStr, int2str(newNum)];
    
end
