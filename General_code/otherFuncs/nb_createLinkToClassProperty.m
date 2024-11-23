function link = nb_createLinkToClassProperty(className,propertyName)
% Syntax:
%
% link = nb_createLinkToClassProperty(className,propertyName)
%
% Description:
%
% Get hyperlink to class property or method doc as a char.
% 
% Input:
% 
% - className    : A one line char with the name of the class.
% 
% - propertyName : A one line char with the name of the property or method.
%
% Output:
% 
% - link         : A one line char.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    link = ['<a href="matlab: help ' className '.' propertyName '">' propertyName '</a>'];

end
