function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Sets how the nb_date object is displayed, and all subclasses of 
% the nb_date class
% 
% Input:
% 
% - obj   : An object of class nb_date or of a subclass of the 
%           nb_date class.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    link = nb_createLinkToClass(obj);
    disp([link, ' with <a href="matlab: methods(' class(obj) ')">methods</a>']);
    disp(' ')
    disp(toString(obj))

end
