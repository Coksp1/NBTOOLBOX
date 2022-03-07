function out = nb_joinPath(p,f,e)
% Syntax:
%
% out = nb_joinPath(p,f,e)
%
% Description:
% 
% - Appends a backslash, \, to the end of a cellstring with the path name 
%   and then concatinates all the file components into a single cellstring.
% 
% Input:
% 
% - p,f,e  : The different file parts. As cellstrings.
% 
% Output:
% 
% - out    : A single cellstring with all the filepart concatinated.
%
% Examples:
%
% p = 'Matlab\B\test'
%
% f = 'fcsttest'
%
% e = 'xlsx'
%
% nb_joinPath(p,f,e)
%
% ans = 'Matlab\B\test\fcsttest.xlsx'
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

    if ~isempty(p)
        if ~strcmpi(p(end),'\')
            p = [p,'\'];
        end
    end
    out = [p,f,e];
    
end
