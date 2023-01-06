function ind = nb_cellfind(c,pattern)
% Syntax:
%
% ind = nb_cellfind(c,pattern)
%
% Description:
%
% Check if the given pattern is found in the cells of the cellstr 
% array. Will return a logical array of same size. Return true for 
% all cells where the pattern is found.  
% 
% Input:
% 
% - c       : A cellstr array
%
% - pattern : The pattern to look for. As a string
% 
% Output: 
% 
% - ind     : Logical array
% 
% Examples:
%
% c   = {'dfsdf','dfdf.df','sdfs'};
% ind = nb_cellfind(c,'.')
% 
% Written by Kenneth S. Paulsen   

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ci  = strfind(c,pattern);
    ind = ~cellfun(@isempty,ci);

end
