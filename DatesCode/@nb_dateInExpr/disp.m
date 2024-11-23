function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Display object (On the commandline)
% 
% Input:
%
% obj : An object of class nb_dateInExpr
%
% Output:
%
% The object display on the command line. (When not ending the 
% command with an semicolon)
%
% Examples:
%
% obj
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    link = nb_createLinkToClass(obj);
    disp([link, ' with <a href="matlab: methods(' class(obj) ')">methods</a>']);
    disp(' ')
    disp(toString([obj.date]));

end
