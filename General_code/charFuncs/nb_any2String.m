function string = nb_any2String(anyObject)
% Syntax:
%
% string = toString(anyObject)
%
% Description:
%
% Same as toString, but cellstr and one line char are converted to the way 
% they are displayed by MATLAB instead of using nb_cellstr2String.
% 
% Input:
% 
% - anyObject : A double, logical, nb_ts, nb_cs, nb_data or cell.
% 
% Output:
% 
% - string    : A string
%
% See also:
% num2str, int2str, nb_cellstr2String, toString
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscellstr(anyObject)
        string = ['{', nb_cell2String(anyObject), '}']; 
    elseif nb_isOneLineChar(anyObject)
        string = ['''' anyObject ''''];
    else
        string = toString(anyObject);
    end
    
end
