function str = nb_cellstr2String(c,sep,sepLast)
% Syntax:
%
% str = nb_cellstr2String(c)
% str = nb_cellstr2String(c,sep,sepLast)
%
% Description:
%
% Convert a cellstr array to a string using the sep input to 
% seperate the elements of the cellstr.
% 
% Input:
% 
% - c       : A cellstr.
%
% - sep     : A string. Default is ','
% 
% - sepLast : A string. Default is ','
%
% Output:
% 
% - str : A string.
%
% Example:
%
% c   = {'dfdfddf','dfdffdf','dfdfdf'};
% str = nb_cellstr2String(c,', ')
% 
% Gives str = 'dfdfddf, dfdffdf, dfdfdf'
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        sepLast = ',';
        if nargin < 2
            sep = ',';
        end
    end

    if isempty(c)
        str = '';
        return
    end

    c   = strcat(c,'\#&');
    str = [c{:}];
    str = strrep(str,'\#&',sep);
    s   = size(sep,2);
    str = str(1:end-s);
    
    if nargin == 3 && length(c) > 1
        ind  = strfind(str,sep);
        indF = ind(end) - 1;
        indS = ind(end) + s;
        str  = [str(1:indF), sepLast, str(indS:end)];
    end
    
end
