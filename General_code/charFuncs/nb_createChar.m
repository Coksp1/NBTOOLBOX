function out = nb_createChar(r,c)
% Syntax:
%
% out = nb_createChar(r,c)
%
% Description:
%
% Create a empty r x c char array.
% 
% Input:
% 
% - r   : Number of rows.
%
% - c   : Number of columns.
% 
% Output:
% 
% - out : A r x c char array.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    out = ' ';
    out = out(ones(r,1),ones(1,c));

end
