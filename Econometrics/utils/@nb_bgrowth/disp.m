function disp(obj)
% Syntax:
%
% disp(obj)
%
% Description:
%
% Display object (In the command window)
% 
% Input:
%
% - obj : An object of class nb_bgrowth
%
% Output:
%
% The object displayed on the command line.
%
% Examples:
%
% obj (Note without semicolon)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    disp(nb_createLinkToClass(obj));
    disp(' ')
    eqs = {obj.equation};
    eqs = char(eqs);
    disp(eqs);

end
