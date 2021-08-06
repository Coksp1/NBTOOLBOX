function c = nb_makeWritable(c)
% Syntax:
%
% c = nb_makeWritable(c)
%
% Description:
%
% Make a cellstr or char ready to be written to a file.
% 
% Input:
% 
% - c : Either a n x 1 cellstr or a n x m char.
% 
% Output:
% 
% - c : A n x 1 cellstr.
%
% See also:
% nb_cellstr2file
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(c)
        c = cellstr(c);
    elseif iscellstr(c)
       c = c(:);
    end
    c = strrep(c,'\','\\');
    c = strrep(c,'%','%%');
    
end
