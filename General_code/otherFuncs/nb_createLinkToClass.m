function link = nb_createLinkToClass(obj,className)
% Syntax:
%
% link = nb_createLinkToClass(obj,className)
%
% Description:
%
% Get hyperlink to class doc as a char.
% 
% Input:
% 
% - obj       : Any object.
%
% - className : A one line char.
% 
% Output:
% 
% - link      : A one line char.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        className  = class(obj);
    end
    siz  = size(obj);
    link = [int2str(siz(1)) ,'x', int2str(siz(2))];
    for ii = 3:size(siz,2)
        link = [link,'x', int2str(siz(3))]; %#ok<AGROW>
    end
    link = [link,' <a href="matlab: help ' className '">' className '</a>'];

end
